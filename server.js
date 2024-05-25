import Fastify from "fastify";
import compress from "@fastify/compress";
import cors from "@fastify/cors";
import helmet from "@fastify/helmet";
import rateLimit from "@fastify/rate-limit";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";

// logger
import pino from "pino";
import pretty from "pino-pretty";
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

// routes
import booksData from "./data/books.js";
import feedsData from "./data/feeds.js";
import moviesData from "./data/movies.js";
import musicData from "./data/music.js";
import promptsData from "./data/prompts.js";
import seriesData from "./data/series.js";
import wordsData from "./data/words.js";

/**
 * Function that paginates data based on the given page and limit.
 *
 * @param {Array} data - The array of data to be paginated.
 * @param {number} page - The current page number.
 * @param {number} limit - The limit of items per page.
 * @return {Object} An object containing paginated data, current page, limit, total data count, total pages.
 */
function getPaginatedData(data, searchTerm, page, limit) {
  // Filter data if searchTerm is provided
  const filteredData = searchTerm
    ? data.filter((item) =>
      JSON.stringify(item).toLowerCase().includes(searchTerm.toLowerCase()),
    )
    : data;

  // Calculate pagination as before
  const startIndex = (page - 1) * limit;
  const endIndex = Math.min(startIndex + limit, filteredData.length);
  const paginatedData = filteredData.slice(startIndex, endIndex);
  const totalPages = Math.ceil(filteredData.length / limit);

  return {
    page,
    limit,
    total: filteredData.length,
    totalPages,
    data: paginatedData,
  };
}

const paginationSchema = {
  querystring: {
    type: "object",
    properties: {
      page: { type: "integer", minimum: 1, default: 1 },
      limit: { type: "integer", minimum: 1, maximum: 10000, default: 1000 },
      search: { type: "string", default: "" },
    },
  },
};

/**
 * A function that creates a route for the given path, utilizing pagination schema.
 *
 * @param {string} path - The path for the route.
 * @param {Array} data - The data to be paginated.
 * @param {Object} opts - The options object containing the schema.
 */
async function createRoute(path, data, opts) {
  app.get(path, { schema: opts.schema }, async (request, reply) => {
    const { page, limit, search } = request.query;
    const paginatedData = await getPaginatedData(data, search, page, limit);
    reply.send(paginatedData);
  });
}

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

createRoute("/books", booksData, { schema: paginationSchema });
createRoute("/feeds", feedsData, { schema: paginationSchema });
createRoute("/movies", moviesData, { schema: paginationSchema });
createRoute("/music", musicData, { schema: paginationSchema });
createRoute("/prompts", promptsData, { schema: paginationSchema });
createRoute("/series", seriesData, { schema: paginationSchema });
createRoute("/words", wordsData, { schema: paginationSchema });

if (process.env.NODE_ENV === "development") {
  /**
   * A function that asynchronously starts the application listening on port 3000.
   *
   * @return {Promise} A promise that resolves when the application starts listening successfully.
   */
  const start = async () => {
    try {
      await app.listen({ port: 3000 });
    } catch (err) {
      app.log.error(err);
      process.exit(1);
    }
  };
  start();
}

export default app;
