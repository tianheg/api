/**
 * Compression Plugin
 *
 * Automatically compresses response payloads using gzip encoding
 * to reduce network bandwidth and improve performance.
 */

import compress from "@fastify/compress";
import fp from "fastify-plugin";

export default fp(async (app) => {
  await app.register(compress, {
    encodings: ["gzip"],
  });
});
