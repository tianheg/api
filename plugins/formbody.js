import fp from "fastify-plugin";
import formbody from "@fastify/formbody";

export default fp(async (app, opts) => {
  await app.register(formbody);
});
