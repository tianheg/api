import fp from "fastify-plugin";
import cors from "@fastify/cors";

export default fp(async (app, _) => {
  // Apply CORS globally to all routes
  await app.register(cors, {
    origin: (origin, cb) => {
      // Allow requests with no origin (like mobile apps, curl, etc)
      if (!origin) {
        cb(null, true);
        return;
      }
      
      // Check if origin is allowed
      const allowedOrigins = [
        'https://lifebook.tianheg.org',
        'http://localhost:5173'  // For local development
      ];
      
      // Check if the origin matches any allowed origin
      const allowed = allowedOrigins.some(allowedOrigin => 
        origin.startsWith(allowedOrigin)
      );
      
      if (allowed) {
        cb(null, true);
      } else {
        app.log.warn(`CORS blocked request from origin: ${origin}`);
        cb(new Error(`CORS not allowed for origin: ${origin}`), false);
      }
    },
    methods: ['GET', 'PUT', 'POST', 'DELETE', 'OPTIONS'],
    credentials: true,
    allowedHeaders: ['Content-Type', 'Authorization', 'Origin', 'X-Requested-With'],
    exposedHeaders: ['Content-Disposition'],
    maxAge: 86400, // Cache preflight response for 24 hours
    preflightContinue: false
  });
  
  // Log when CORS is initialized
  app.log.info('CORS plugin registered');
});
