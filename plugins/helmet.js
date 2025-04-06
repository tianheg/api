import helmet from "@fastify/helmet";
import fp from "fastify-plugin";

export default fp(async (app, _) => {
  await app.register(helmet);
});
