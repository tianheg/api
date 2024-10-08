import fp from "fastify-plugin";
import compress from "@fastify/compress";

export default fp(async (app, opts) => {
  await app.register(compress, { encodings: ["gzip"] });
});
