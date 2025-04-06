import fp from "fastify-plugin";
import cors from "@fastify/cors";

export default fp(async (app, _) => {
  // Apply CORS globally to all routes
  await app.register(cors, {
    origin: (origin, cb) => {
      const allowedOrigins = [
        'https://lifebook.tianheg.org',
        'http://localhost:5173',
      ];
      if (!origin || allowedOrigins.includes(origin)) {
        cb(null, true);
      } else {
        cb(new Error('CORS not allowed'), false);
      }
    },
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Include OPTIONS
    allowedHeaders: ['Content-Type'], // Explicitly allow headers
  });
  
  // Log when CORS is initialized
  app.log.info('CORS plugin registered');
});
