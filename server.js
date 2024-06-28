import compress from "@fastify/compress";
import cors from "@fastify/cors";
import formbody from "@fastify/formbody";
import helmet from "@fastify/helmet";
import jwt from "@fastify/jwt";
import postgres from "@fastify/postgres";
import rateLimit from "@fastify/rate-limit";
import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";
import Fastify from "fastify";
import pino from "pino";
import pretty from "pino-pretty";

import * as dotenv from "dotenv";
dotenv.config();

import registerRoutes from "./routes.js";

// logger
const stream = pretty({
  translateTime: "SYS:HH:MM:ss Z",
  messageFormat: "{msg} {req.method} {req.url}",
  include: "time,pid,level",
  hideObject: true,
  colorize: false, // enable this will make Vercel log get:
  // [15:32:27 UTC] [32mINFO[39m (10): [36mincoming request GET /[39m
  //[15:32:27 UTC] [32mINFO[39m (10): [36mrequest completed  [39m
});
const logger = pino({ level: "info" }, stream);

const app = Fastify({ logger });

/// plugins
await app.register(compress, { encodings: ["gzip"] });

// security
// not using RegExp or a function for origin
// avoid DoS attacks https://github.com/fastify/fastify-cors#warning-dos-attacks
await app.register(cors);
await app.register(formbody);
await app.register(helmet);
await app.register(jwt, {
  secret: process.env.JWT_SECRET,
})
app.decorate("authenticate", async (request, reply) => {
  try {
    await request.jwtVerify();
  } catch (err) {
    reply.send(err);
  }
});

await app.register(rateLimit, {
  max: 100,
  timeWindow: "1 minute",
});
await app.register(swagger, {
  openapi: {
    info: {
      title: "tianheg's API",
      description: "Recording things in my life",
      version: "1.0.0",
    },
    // components: {
    //   securitySchemes: {
    //     bearerAuth: {
    //       type: 'http',
    //       scheme: 'bearer',
    //       bearerFormat: 'JWT',
    //     },
    //   },
    // },
  },
});
await app.register(swaggerUI, {
  routePrefix: "/doc",
  uiConfig: {
    docExpansion: "list",
    deepLinking: false,
  },
});

// database
await app.register(postgres, {
  connectionString: process.env.POSTGRES_URL,
});

/// routes
await registerRoutes(app);

if (process.env.NODE_ENV === "development") {
  /**
   * A function that asynchronously starts the application listening on port 3000.
   *
   * @return {Promise} A promise that resolves when the application starts listening successfully.
   */
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
