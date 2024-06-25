import { createRoute, paginationSchema } from "./utils.js";

export default async function registerRoutes(app) {
  const client = await app.pg.connect();

  const booksData = await client.query("SELECT * FROM books");
  const feedsData = await client.query("SELECT * FROM feeds");
  const moviesData = await client.query("SELECT * FROM movies");
  const musicData = await client.query("SELECT * FROM music");
  const musicalsData = await client.query("SELECT * FROM musicals");
  const promptsData = await client.query("SELECT * FROM prompts");
  const seriesData = await client.query("SELECT * FROM series");
  const wordsData = await client.query("SELECT * FROM words");

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

  console.log(booksData.rows.map((r) => r.json_data));
  createRoute(
    app,
    "/books",
    booksData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );
  createRoute(
    app,
    "/feeds",
    feedsData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );
  createRoute(
    app,
    "/movies",
    moviesData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );
  createRoute(
    app,
    "/music",
    musicData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );
  createRoute(
    app,
    "/musicals",
    musicalsData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );
  createRoute(
    app,
    "/prompts",
    promptsData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );
  createRoute(
    app,
    "/series",
    seriesData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );
  createRoute(
    app,
    "/words",
    wordsData.rows.map((r) => r.json_data),
    { schema: paginationSchema },
  );

  client.release();
}
