/**
 * Sensible Defaults Plugin
 *
 * Provides HTTP-related utilities and best practices including:
 * - Default status codes
 * - Common error response formats
 * - Helpful error messages
 */

import sensible from "@fastify/sensible";
import fp from "fastify-plugin";

export default fp(async (app) => {
  await app.register(sensible);
});
