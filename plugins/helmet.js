import fp from "fastify-plugin";
import helmet from "@fastify/helmet";

export default fp(async (app, _) => {
  await app.register(helmet);
});
