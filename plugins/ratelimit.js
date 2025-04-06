import rateLimit from "@fastify/rate-limit";
import fp from "fastify-plugin";

export default fp(async (app, _) => {
  await app.register(rateLimit, {
    max: 100,
    timeWindow: "1 minute",
  });
});
