import fp from "fastify-plugin";
import formbody from "@fastify/formbody";

export default fp(async (app, _) => {
  await app.register(formbody);
});
