/**
 * OpenAPI/Swagger Documentation Plugin
 *
 * Generates and serves API documentation using Swagger/OpenAPI standards.
 * Documentation is available at /doc endpoint (except in production).
 */

import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";
import fp from "fastify-plugin";

export default fp(async (app) => {
  // Register OpenAPI schema generator
  await app.register(swagger, {
    openapi: {
      info: {
        title: "tianheg's API",
        description: "Recording things in my life",
        version: "1.0.0",
      },
    },
  });

  // Register Swagger UI for interactive documentation
  await app.register(swaggerUI, {
    routePrefix: "/doc",
    exposeRoute: process.env.NODE_ENV !== "production",
    uiConfig: {
      docExpansion: "list",
      deepLinking: false,
    },
  });
});
