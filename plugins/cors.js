import cors from "@fastify/cors";
import fp from "fastify-plugin";

export default fp(async (app, _) => {
  await app.register(cors);
});
