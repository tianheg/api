import fp from "fastify-plugin";
import pg from "@fastify/postgres";

// Set up the PostgreSQL client with your configuration
export default fp(async (app, _) => {
  await app.register(pg, {
    connectionString: app.secrets.POSTGRES_URL,
  });
})