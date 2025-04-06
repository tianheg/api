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
        'https://api.tianheg.org',  // Add the API domain itself
        'http://localhost:5173'  // For local development
      ];
      
      // Use exact matching instead of startsWith for more precise control
      if (allowedOrigins.includes(origin)) {
        // This will set Access-Control-Allow-Origin to the actual origin
        cb(null, true);
      } else {
        app.log.warn(`CORS blocked request from origin: ${origin}`);
        cb(new Error(`CORS not allowed for origin: ${origin}`), false);
      }
    },
    methods: ['GET', 'PUT', 'POST', 'DELETE'],
  });
  
  // Log when CORS is initialized
  app.log.info('CORS plugin registered');
});
