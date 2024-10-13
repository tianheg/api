import fp from "fastify-plugin";
import jwt from "@fastify/jwt";

export default fp(async (app, opts) => {
  await app.register(jwt, {
    secret: app.secrets.JWT_SECRET,
  });
});
