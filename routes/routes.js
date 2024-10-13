import S from "fluent-json-schema";

export default function home(app, opts, done) {
  app.get(
    "/",
    {
      schema: {
        response: {
          200: S.object()
            .prop("repo", S.string())
            .prop("doc", S.string())
            .prop("tech", S.string())
            .prop("deploy", S.string())
            .prop("routes", S.array().items(S.string())),
        },
      },
    },
    (request, reply) => {
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
    },
  );

  done();
}
