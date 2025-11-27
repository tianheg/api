/**
 * Security Headers Plugin
 *
 * Configures Helmet to set HTTP security headers that help protect
 * against common web vulnerabilities like XSS, clickjacking, etc.
 */

import helmet from "@fastify/helmet";
import fp from "fastify-plugin";

export default fp(async (app) => {
  await app.register(helmet);
});
