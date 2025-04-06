import fp from "fastify-plugin";
import cors from "@fastify/cors";

export default fp(async (app, _) => {
  await app.register(cors);
});
