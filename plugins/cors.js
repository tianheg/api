import fp from "fastify-plugin";
import cors from "@fastify/cors";

// not using RegExp or a function for origin
// avoid DoS attacks https://github.com/fastify/fastify-cors#warning-dos-attacks

export default fp(async (app, _) => {
  // Apply CORS globally to all routes
  await app.register(cors);
});
