import fp from "fastify-plugin";
import helmet from "@fastify/helmet";

export default fp(async (app, opts) => {
  await app.register(helmet);
});
