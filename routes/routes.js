import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import S from "fluent-json-schema";

/**
 * Home/Root Route
 *
 * Provides API information and lists all available endpoints
 */
export default function homeRoutes(app, opts, done) {
  /**
   * GET / - API information and available routes
   *
   * Returns metadata about the API, documentation links, and list of available endpoints
   */
  app.get(
    "/",
    {
      schema: {
        response: {
          200: S.object()
            .prop("repo", S.string().description("Repository URL"))
            .prop("doc", S.string().description("API documentation URL"))
            .prop("tech", S.string().description("Technology/framework URL"))
            .prop("deploy", S.string().description("Deployment information"))
            .prop(
              "routes",
              S.array()
                .items(S.string())
                .description("Available API endpoints"),
            ),
        },
      },
    },
    (request, reply) => {
      const baseUrl =
        process.env.NODE_ENV === "development"
          ? "http://localhost:3000"
          : "https://api-tianheg.up.railway.app";

      // Discover all route directories
      const routesDir = path.dirname(fileURLToPath(import.meta.url));
      const routeDirectories = fs
        .readdirSync(routesDir)
        .filter((file) => {
          const fullPath = path.join(routesDir, file);
          return (
            fs.statSync(fullPath).isDirectory() &&
            file !== "." &&
            file !== ".." &&
            !file.startsWith(".")
          );
        })
        .map((file) => path.parse(file).name);

      // Build list of available routes
      const routes = routeDirectories.map((route) =>
        route === "index" ? baseUrl : `${baseUrl}/${route}`,
      );

      // Build response object
      const response = {
        repo: "https://github.com/tianheg/api/",
        tech: "https://fastify.dev/",
        routes: routes.sort(),
      };

      // Add documentation URL in development
      if (process.env.NODE_ENV === "development") {
        response.doc = `${baseUrl}/doc`;
        response.deploy = "Run locally: npm run dev";
      }

      return response;
    },
  );

  done();
}

