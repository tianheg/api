import S from 'fluent-json-schema';
import crypto from 'node:crypto';

export default async function (app) {
  // Request magic link endpoint
  app.post('/auth/magic-link', {
    schema: {
      body: S.object()
        .prop('email', S.string().format('email').required())
        .prop('csrfToken', S.string()),  // Add CSRF token to schema
      response: {
        200: S.object()
          .prop('success', S.boolean())
          .prop('message', S.string()),
        400: S.object()
          .prop('error', S.string())
          .prop('message', S.string()),
        403: S.object()  // Add 403 response for CSRF errors
          .prop('error', S.string())
          .prop('message', S.string())
      }
    },
    preHandler: app.csrfProtect  // Add CSRF protection
  }, async (request, reply) => {
    const { email } = request.body;

    try {
      // Generate a random token
      const token = crypto.randomBytes(32).toString('hex');
      const expires = Date.now() + 15 * 60 * 1000; // 15 minutes

      // Store the token in the database
      const client = await app.pg.connect();
      try {
        await client.query(
          'INSERT INTO magic_links (email, token, expires) VALUES ($1, $2, $3)',
          [email, token, expires]
        );
      } finally {
        client.release();
      }

      // Create the magic link
      const magicLink = `${request.headers.origin || 'http://localhost:5173'}/verify?token=${token}`;

      // Send an actual email with the link
      try {
        await app.email.sendMagicLink(email, magicLink);
        app.log.info(`Magic link email sent to ${email}`);
      } catch (emailError) {
        app.log.error(`Failed to send email: ${emailError.message}`);
        // Still log the link in case of email sending failure
        app.log.info(`Magic link for ${email}: ${magicLink}`);
      }

      return {
        success: true,
        message: 'Magic link sent to your email'
      };
    } catch (error) {
      app.log.error(error);
      return reply.code(500).send({
        error: 'Internal Server Error',
        message: 'Failed to send magic link'
      });
    }
  });

  // Verify magic link endpoint
  app.post('/auth/verify', {
    schema: {
      body: S.object()
        .prop('token', S.string().required())
        .prop('csrfToken', S.string()),  // Add CSRF token to schema
      response: {
        200: S.object()
          .prop('token', S.string())
          .prop('user', S.object().prop('email', S.string()))
          .prop('csrfToken', S.string()),  // Add CSRF token to response
        401: S.object()
          .prop('error', S.string())
          .prop('message', S.string()),
        403: S.object()  // Add 403 response for CSRF errors
          .prop('error', S.string())
          .prop('message', S.string())
      }
    },
    preHandler: app.csrfProtect  // Add CSRF protection
  }, async (request, reply) => {
    const { token } = request.body;

    try {
      // Retrieve the token from the database
      const client = await app.pg.connect();
      let email;
      let expires;
      try {
        const result = await client.query(
          'SELECT email, expires FROM magic_links WHERE token = $1',
          [token]
        );

        if (result.rows.length === 0) {
          return reply.code(401).send({
            error: 'Unauthorized',
            message: 'Invalid or expired token'
          });
        }

        ({ email, expires } = result.rows[0]);

        // Check if token has expired
        if (Date.now() > expires) {
          await client.query('DELETE FROM magic_links WHERE token = $1', [token]);
          return reply.code(401).send({
            error: 'Unauthorized',
            message: 'Token expired'
          });
        }

        // Token is valid, clean it up
        await client.query('DELETE FROM magic_links WHERE token = $1', [token]);
      } finally {
        client.release();
      }

      // Create a JWT token
      const jwtToken = app.jwt.sign(
        { email },
        { expiresIn: '7d' } // Token expires in 7 days
      );

      // Generate a new CSRF token for the authenticated session
      const csrfToken = await reply.generateCsrf();

      return {
        token: jwtToken,
        user: { email },
        csrfToken: csrfToken  // Return the new CSRF token with the JWT
      };
    } catch (error) {
      app.log.error(error);
      return reply.code(500).send({
        error: 'Internal Server Error',
        message: 'Failed to verify magic link'
      });
    }
  });

  // Protected route example (for testing)
  app.get('/auth/me', {
    preHandler: app.authenticate,
  }, async (request) => {
    // The user email is available in the decoded token
    return { user: request.user };
  });
}
