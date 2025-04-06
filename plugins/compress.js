import compress from "@fastify/compress";
import fp from "fastify-plugin";

export default fp(async (app, _) => {
  await app.register(compress, { encodings: ["gzip"] });
});
