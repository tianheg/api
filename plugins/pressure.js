import  fp from "fastify-plugin";
import underPressure from "@fastify/under-pressure";

export default fp(async (app, _) => {
  await app.register(underPressure, {
    maxRequests: 100,
    maxRequestsPerMinute: 100,
    maxRequestsPerHour: 100,
    maxRequestsPerDay: 100,
    onRateLimit: (request, reply, options) => {
      return reply.code(429).send({
        message: "Too many requests",
        retryAfter: options.retryAfter,
      });
    }
  });
})