/**
 * System Pressure Monitoring Plugin
 *
 * Monitors system health (memory, event loop lag, heap usage) and returns
 * 503 Service Unavailable if the system is under excessive load to prevent cascading failures.
 */

import underPressure from "@fastify/under-pressure";
import fp from "fastify-plugin";

export default fp(async (app) => {
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
    },
  });
});
