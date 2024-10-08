import fp from "fastify-plugin";
import rateLimit from "@fastify/rate-limit";

export default fp(async (app, opts) => {
  await app.register(rateLimit, {
    max: 100,
    timeWindow: "1 minute",
  });
});
