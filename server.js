import Fastify from "fastify";
import compress from "@fastify/compress";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import rateLimit from "@fastify/rate-limit";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import pino from "pino";
import pretty from "pino-pretty";

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

// plugins
await app.register(compress, { encodings: ["gzip"] });

// security
/// not using RegExp or a function for origin
/// avoid DoS attacks https://github.com/fastify/fastify-cors#warning-dos-attacks
await app.register(cors);
await app.register(helmet);
await app.register(rateLimit, {
  max: 100,
  timeWindow: "1 minute",
});
await app.register(swagger);
await app.register(swaggerUi, {
  routePrefix: "/doc",
  uiConfig: {
    docExpansion: "full",
    deepLinking: false,
  },
  uiHooks: {
    onRequest: (request, reply, next) => {
      next();
    },
    preHandler: (request, reply, next) => {
      next();
    },
  },
  staticCSP: true,
  transformStaticCSP: (header) => header,
  transformSpecification: (swaggerObject, request, reply) => {
    return swaggerObject;
  },
  transformSpecificationClone: true,
});


app.get("/", (request, reply) => {
  const protocol = process.env.NODE_ENV === "development" ? "http" : "https";
  const baseUrl = `${protocol}://${request.headers.host}`;
  const routes = [
    `${baseUrl}/words`,
    `${baseUrl}/books`,
    `${baseUrl}/movies`,
    `${baseUrl}/series`,
    `${baseUrl}/music`,
    `${baseUrl}/feeds`,
    `${baseUrl}/prompts`,
  ];

  reply.send({
    repo: "https://github.com/tianheg/api/",
    doc: `${baseUrl}/doc`,
    tech: "https://fastify.dev/",
    deploy: "https://vercel.com/",
    routes: routes,
  });
});

if (process.env.NODE_ENV === "development") {
  /**
   * A function that asynchronously starts the application listening on port 3000.
   *
   * @return {Promise} A promise that resolves when the application starts listening successfully.
   */
  const start = async () => {
    try {
      registerRoutes(app);
      await app.listen({ port: 3000 });
    } catch (err) {
      app.log.error(err);
      process.exit(1);
    }
  };
  start();
}

export default app;
