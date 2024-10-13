import fp from "fastify-plugin";
import sensible from "@fastify/sensible";

export default fp(async (app, opts) => {
  await app.register(sensible);
});
