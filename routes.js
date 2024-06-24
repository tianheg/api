import booksData from "./data/books.js";
import feedsData from "./data/feeds.js";
import moviesData from "./data/movies.js";
import musicData from "./data/music.js";
import musicalsData from "./data/musicals.js";
import promptsData from "./data/prompts.js";
import seriesData from "./data/series.js";
import wordsData from "./data/words.js";
import { createRoute, paginationSchema } from "./utils.js";

export default async function registerRoutes(app) {
  app.get("/", (request, reply) => {
    const baseUrl = "https://api.tianheg.org";
    const routes = [
      `${baseUrl}/books`,
      `${baseUrl}/feeds`,
      `${baseUrl}/movies`,
      `${baseUrl}/music`,
      `${baseUrl}/musicals`,
      `${baseUrl}/prompts`,
      `${baseUrl}/series`,
      `${baseUrl}/words`,
    ];

    reply.send({
      repo: "https://github.com/tianheg/api/",
      doc: `${baseUrl}/doc`,
      tech: "https://fastify.dev/",
      deploy: "https://vercel.com/",
      routes: routes,
    });
  });

  app.get("/calc", (request, reply) => {
    const client = app.pg.connect();

    console.log(client);
    // const sumResult = client.query < { sum } > "SELECT 2 + 2 as sum";

    // client.release();

    // return {
    //   sum: sumResult.rows,
    // };
  });

  createRoute(app, "/books", booksData, { schema: paginationSchema });
  createRoute(app, "/feeds", feedsData, { schema: paginationSchema });
  createRoute(app, "/movies", moviesData, { schema: paginationSchema });
  createRoute(app, "/music", musicData, { schema: paginationSchema });
  createRoute(app, "/musicals", musicalsData, { schema: paginationSchema });
  createRoute(app, "/prompts", promptsData, { schema: paginationSchema });
  createRoute(app, "/series", seriesData, { schema: paginationSchema });
  createRoute(app, "/words", wordsData, { schema: paginationSchema });
}
