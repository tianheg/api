/**
 * Rate Limiting Plugin
 *
 * Limits the number of requests a client can make within a time window
 * to prevent abuse and DoS attacks.
 *
 * Current limits: 100 requests per minute per IP address
 */

import rateLimit from "@fastify/rate-limit";
import fp from "fastify-plugin";

export default fp(async (app) => {
  await app.register(rateLimit, {
    max: 100, // Maximum requests
    timeWindow: "1 minute", // Time window
  });
});
