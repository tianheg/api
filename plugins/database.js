import fp from "fastify-plugin";
import pg from "@fastify/postgres";

import { config } from "dotenv";

config();

export default fp(async (app, opts) => {
  await app.register(pg, {
    connectionString: process.env.POSTGRES_URL,
  });
})