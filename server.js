import Fastify from "fastify";

// logger
import pino from "pino";
import pretty from "pino-pretty";
const stream = pretty({
	translateTime: "SYS:HH:MM:ss Z",
	messageFormat: "{msg} {req.method} {req.url}",
	include: "time,pid,level",
	hideObject: true,
	colorize: false,  // enable this will make Vercel log get:
	// [15:32:27 UTC] [32mINFO[39m (10): [36mincoming request GET /[39m
	//[15:32:27 UTC] [32mINFO[39m (10): [36mrequest completed  [39m
});
const logger = pino({ level: "info" }, stream);

const app = Fastify({ logger });

// plugins
app.register(import("@fastify/swagger"));
app.register(import("@fastify/compress"), { encodings: ["gzip"] });
app.register(import("@fastify/cors"), {
	origin: (origin, cb) => {
		const allowedOrigins = [/^http:\/\/localhost:\d+$/, /^https?:\/\/tianheg\.org$/];
		const isAllowed = allowedOrigins.some(regex => regex.test(origin));
		cb(null, isAllowed);
		return
	},
});
app.register(import("@fastify/helmet"));
app.register(import("@fastify/rate-limit"), {
	max: 100,
	timeWindow: "1 minute",
});
app.register(import("@fastify/swagger-ui"), {
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
			limit: { type: "integer", minimum: 1, maximum: 100, default: 10 },
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
 * @return {Promise} A promise containing the paginated data.
 */
function createRoute(path, data, opts) {
	app.get(path, { schema: opts.schema }, async (request, reply) => {
		const { page, limit, search } = request.query;
		return getPaginatedData(data, search, page, limit);
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
