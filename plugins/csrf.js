import fp from "fastify-plugin";
import csrfProtection from "@fastify/csrf-protection";
import cookie from '@fastify/cookie';

export default fp(async (app, _) => {
  // Register cookie plugin before CSRF protection
  await app.register(cookie, {
    secret: app.secrets.COOKIE_SECRET || 'fallback-dev-only', // Use environment variable
    parseOptions: {},
  });

  await app.register(csrfProtection, {
    // Use sessionPlugin to store CSRF secret in session cookie
    sessionPlugin: '@fastify/cookie',
    
    // Configure the cookie settings for improved security
    cookieOpts: {
      signed: true,
      httpOnly: true,
      sameSite: 'lax', // Or 'strict' for even more security, but may impact UX
      path: '/'
    },

    // Hook to check all state-changing requests for CSRF tokens
    getToken: (request) => {
      // Try to get the token from headers first (for API calls)
      const headerToken = request.headers['x-csrf-token'];
      if (headerToken) return headerToken;
      
      // If not in header, try to get from request body (for form submissions)
      return request.body?.csrfToken;
    }
  });

  // Create a preHandler hook that can be used selectively for routes that need CSRF protection
  app.decorate('csrfProtect', async (request, reply) => {
    // Skip CSRF check for GET, HEAD, OPTIONS requests as they should be idempotent
    if (['GET', 'HEAD', 'OPTIONS'].includes(request.method)) {
      return;
    }
    
    // Verify CSRF token for all other methods (POST, PUT, DELETE, etc.)
    try {
      await request.csrfProtection();
    } catch (err) {
      reply.code(403);
      return reply.send({ 
        error: "Forbidden", 
        message: "Invalid or missing CSRF token" 
      });
    }
  });

  // Add a route to get a new CSRF token
  app.get('/csrf/token', async (request, reply) => {
    const token = await reply.generateCsrf();
    return { csrfToken: token };
  });
});