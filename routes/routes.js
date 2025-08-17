import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
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
    () => {
      const baseUrl =
        process.env.NODE_ENV === "development"
          ? "http://localhost:3000"
          : "https://api-tianheg.up.railway.app/";

      const routesDir = path.dirname(fileURLToPath(import.meta.url));
      const routeFiles = fs
        .readdirSync(routesDir)
        .filter((file) => !file.endsWith(".js") && file !== "routes.js")
        .map((file) => path.parse(file).name);

      const routes = routeFiles.map((route) =>
        route === "index" ? baseUrl : `${baseUrl}/${route}`,
      );

      const response = {
        repo: "https://github.com/tianheg/api/",
        tech: "https://fastify.dev/",
        routes,
      };

      if (process.env.NODE_ENV === "development") {
        response.doc = `${baseUrl}/doc`;
      }

      return response;
    },
  );

  done();
}
