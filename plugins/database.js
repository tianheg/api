/**
 * Database Connection Plugin
 *
 * Initializes and registers the PostgreSQL database connection pool.
 * Makes the pool available as `app.pg` for use in route handlers and other plugins.
 */

import pg from "@fastify/postgres";
import fp from "fastify-plugin";

export default fp(async (app) => {
  await app.register(pg, {
    connectionString: app.secrets.POSTGRES_URL,
  });
});
