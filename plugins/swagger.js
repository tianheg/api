import fp from "fastify-plugin";
import swagger from "@fastify/swagger";
import swaggerUI from "@fastify/swagger-ui";

export default fp(async (app, _) => {
  await app.register(swagger, {
    openapi: {
      info: {
        title: "tianheg's API",
        description: "Recording things in my life",
      },
      // components: {
      //   securitySchemes: {
      //     bearerAuth: {
      //       type: 'http',
      //       scheme: 'bearer',
      //       bearerFormat: 'JWT',
      //     },
      //   },
      // },
    },
  });
  await app.register(swaggerUI, {
    routePrefix: "/doc",
    exposeRoute: process.env.NODE_ENV !== "production",
    uiConfig: {
      docExpansion: "list",
      deepLinking: false,
    },
  });
});
