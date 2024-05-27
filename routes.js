import { createRoute, paginationSchema } from "./utils.js";
import booksData from "./data/books.js";
import feedsData from "./data/feeds.js";
import moviesData from "./data/movies.js";
import musicData from "./data/music.js";
import promptsData from "./data/prompts.js";
import seriesData from "./data/series.js";
import wordsData from "./data/words.js";

export default async function registerRoutes(app) {
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

  createRoute(app, "/books", booksData, { schema: paginationSchema });
  createRoute(app, "/feeds", feedsData, { schema: paginationSchema });
  createRoute(app, "/movies", moviesData, { schema: paginationSchema });
  createRoute(app, "/music", musicData, { schema: paginationSchema });
  createRoute(app, "/prompts", promptsData, { schema: paginationSchema });
  createRoute(app, "/series", seriesData, { schema: paginationSchema });
  createRoute(app, "/words", wordsData, { schema: paginationSchema });
}
