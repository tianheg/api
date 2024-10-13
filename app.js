import Fastify from "fastify";
import AutoLoad from "@fastify/autoload";
import Env from "@fastify/env";

import pino from "pino";
import pretty from "pino-pretty";
import { join } from "desm";

// logger
const stream = pretty({
  translateTime: "SYS:HH:MM:ss Z",
  messageFormat: "{msg} {req.method} {req.url}",
  include: "time,pid,level",
  hideObject: true,
  colorize: false,
});
const loggerInstance = pino({ level: "info" }, stream);

const app = Fastify({ loggerInstance });

app.decorate("authenticate", async (request, reply) => {
  try {
    await request.jwtVerify();
  } catch (err) {
    reply.send(err);
  }
});

// env
const envSchema = {
  type: "object",
  required: ["POSTGRES_URL", "JWT_SECRET"],
  properties: {
    POSTGRES_URL: { type: "string" },
    JWT_SECRET: { type: "strving" },
    NODE_ENV: { type: "string", default: "development" },
  },
};
await app.register(Env, {
  confKey: "secrets",
  schema: envSchema,
  dotenv: true,
});

await app.register(AutoLoad, {
  dir: join(import.meta.url, "plugins"),
  dirNameRoutePrefix: false,
  ignorePattern: /.*.no-load\.js/,
  indexPattern: /^no$/i,
});

// register routes
await app.register(import("./routes/routes.js"));
await app.register(import("./routes/books/routes.js"));
await app.register(import("./routes/feeds/routes.js"));
await app.register(import("./routes/movies/routes.js"));
await app.register(import("./routes/music/routes.js"));
await app.register(import("./routes/musicals/routes.js"));
await app.register(import("./routes/series/routes.js"));
await app.register(import("./routes/words/routes.js"));

// start server
const start = async () => {
  try {
    await app.listen({ host: "::", port: 3000 });
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
};
start();
