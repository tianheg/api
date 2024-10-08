export default async function registerRoutes(app) {
  app.get("/", (request, reply) => {
    const baseUrl =
      process.env.NODE_ENV === "development"
        ? "http://localhost:3000"
        : "https://api.tianheg.org";
    const routes = [
      `${baseUrl}/books`,
      `${baseUrl}/feeds`,
      `${baseUrl}/movies`,
      `${baseUrl}/music`,
      `${baseUrl}/musicals`,
      `${baseUrl}/series`,
      `${baseUrl}/words`,
    ];

    return {
      repo: "https://github.com/tianheg/api/",
      doc: `${baseUrl}/doc`,
      tech: "https://fastify.dev/",
      deploy: "https://vercel.com/",
      routes: routes,
    };
  });
}
