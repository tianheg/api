import jwt from "@fastify/jwt";
import fp from "fastify-plugin";

export default fp(async (app, _) => {
  await app.register(jwt, {
    secret: app.secrets.JWT_SECRET,
    sign: {
      expiresIn: "7d", // Default token expiration
    },
    verify: {
      extractToken: (request) => {
        // Try to extract the token from the Authorization header
        const authHeader = request.headers.authorization;
        if (authHeader?.startsWith("Bearer ")) {
          return authHeader.substring(7);
        }
        return null;
      },
    },
  });
});
