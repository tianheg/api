/**
 * Form Body Parser Plugin
 *
 * Enables parsing of `application/x-www-form-urlencoded` encoded request bodies.
 */

import formbody from "@fastify/formbody";
import fp from "fastify-plugin";

export default fp(async (app) => {
  await app.register(formbody);
});
