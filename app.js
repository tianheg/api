import Fastify from "fastify";
import Autoload from "@fastify/autoload";
import pino from "pino";
import pretty from "pino-pretty";
import { dirname,join } from "node:path";
import { fileURLToPath } from "node:url";
import registerRoutes from "./routes/routes.js";
import registerBooksRoutes from "./routes/booksRoutes.js";

import * as dotenv from "dotenv";
dotenv.config();


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

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
await app.register(Autoload, {
  dir: join(__dirname, "plugins"),
  dirNameRoutePrefix: false,
  ignorePattern: /.*.no-load\.js/,
  indexPattern: /^no$/i,
});

// routes
await registerRoutes(app);

// books routes
await registerBooksRoutes(app);

// start server
if (process.env.NODE_ENV === "development") {
  const start = async () => {
    try {
      await app.listen({ port: 3000 });
    } catch (error) {
      app.log.error(error);
      process.exit(1);
    }
  };
  start();
}

export default app;
