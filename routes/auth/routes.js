import S from 'fluent-json-schema';
import crypto from 'node:crypto';

// In-memory storage for magic links (in production, use Redis or a database)
const pendingMagicLinks = new Map();

export default async function (app) {
  // Request magic link endpoint
  app.post('/auth/magic-link', {
    schema: {
      body: S.object().prop('email', S.string().format('email').required()),
      response: {
        200: S.object()
          .prop('success', S.boolean())
          .prop('message', S.string()),
        400: S.object()
          .prop('error', S.string())
          .prop('message', S.string())
      }
    }
  }, async (request, reply) => {
    const { email } = request.body;
    
    try {
      // Generate a random token
      const token = crypto.randomBytes(32).toString('hex');
      
      // Store the token with the email (expires in 15 minutes)
      pendingMagicLinks.set(token, {
        email,
        expires: Date.now() + 15 * 60 * 1000 // 15 minutes
      });
      
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
      
      // Clean up expired tokens periodically
      setTimeout(() => {
        if (pendingMagicLinks.has(token)) {
          pendingMagicLinks.delete(token);
        }
      }, 15 * 60 * 1000);
      
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
      body: S.object().prop('token', S.string().required()),
      response: {
        200: S.object()
          .prop('token', S.string())
          .prop('user', S.object().prop('email', S.string())),
        401: S.object()
          .prop('error', S.string())
          .prop('message', S.string())
      }
    }
  }, async (request, reply) => {
    const { token } = request.body;
    
    // Check if token exists and is valid
    if (!pendingMagicLinks.has(token)) {
      return reply.code(401).send({
        error: 'Unauthorized',
        message: 'Invalid or expired token'
      });
    }
    
    const { email, expires } = pendingMagicLinks.get(token);
    
    // Check if token has expired
    if (Date.now() > expires) {
      pendingMagicLinks.delete(token);
      return reply.code(401).send({
        error: 'Unauthorized',
        message: 'Token expired'
      });
    }
    
    // Token is valid, clean it up
    pendingMagicLinks.delete(token);
    
    // Create a JWT token
    const jwtToken = app.jwt.sign(
      { email },
      { expiresIn: '7d' } // Token expires in 7 days
    );
    
    return {
      token: jwtToken,
      user: { email }
    };
  });

  // Protected route example (for testing)
  app.get('/auth/me', {
    preHandler: app.authenticate,
  }, async (request) => {
    // The user email is available in the decoded token
    return { user: request.user };
  });
}
