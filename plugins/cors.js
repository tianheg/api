import fp from "fastify-plugin";
import cors from "@fastify/cors";

export default fp(async (app, _) => {
  // Apply CORS globally to all routes
  await app.register(cors, {
    origin: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'], // Include OPTIONS
    allowedHeaders: ['Content-Type'], // Explicitly allow headersa
  });
  
  // Log when CORS is initialized
  app.log.info('CORS plugin registered');
});
