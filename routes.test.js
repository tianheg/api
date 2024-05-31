import Fastify from "fastify";
import tap from "tap";
import registerRoutes from "./routes.js";

tap.test("routes.js", async (t) => {
  const app = Fastify();
  await registerRoutes(app);

  t.test("GET /", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/",
    });

    const baseUrl = "https://api.tianheg.org";
    const routes = [
      `${baseUrl}/books`,
      `${baseUrl}/feeds`,
      `${baseUrl}/movies`,
      `${baseUrl}/music`,
      `${baseUrl}/prompts`,
      `${baseUrl}/series`,
      `${baseUrl}/words`,
    ];

    t.equal(response.statusCode, 200);
    t.match(JSON.parse(response.body), {
      repo: "https://github.com/tianheg/api/",
      doc: `${baseUrl}/doc`,
      tech: "https://fastify.dev/",
      deploy: "https://vercel.com/",
      routes: routes,
    });
  });

  t.test("GET /books", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/books",
    });

    t.equal(response.statusCode, 200);
    t.type(response.body, String);
  });

  t.test("GET /feeds", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/feeds",
    });

    t.equal(response.statusCode, 200);
    t.type(response.body, String);
  });

  t.test("GET /movies", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/movies",
    });

    t.equal(response.statusCode, 200);
    t.type(response.body, String);
  });

  t.test("GET /music", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/music",
    });

    t.equal(response.statusCode, 200);
    t.type(response.body, String);
  });

  t.test("GET /prompts", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/prompts",
    });

    t.equal(response.statusCode, 200);
    t.type(response.body, String);
  });

  t.test("GET /series", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/series",
    });

    t.equal(response.statusCode, 200);
    t.type(response.body, String);
  });

  t.test("GET /words", async (t) => {
    const response = await app.inject({
      method: "GET",
      url: "/words",
    });

    t.equal(response.statusCode, 200);
    t.type(response.body, String);
  });

  t.end();
});
