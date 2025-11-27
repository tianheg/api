/**
 * CORS (Cross-Origin Resource Sharing) Plugin
 *
 * Configures which origins are allowed to make requests to this API.
 * Only explicitly whitelisted origins are permitted to make cross-origin requests.
 */

import cors from "@fastify/cors";
import fp from "fastify-plugin";

const ALLOWED_ORIGINS = [
  "https://lifebook.tianheg.org",
  "http://localhost:5173", // Development frontend
];

export default fp(async (app) => {
  await app.register(cors, {
    origin: (origin, cb) => {
      // Allow requests without an origin header (same-origin requests)
      if (!origin || ALLOWED_ORIGINS.includes(origin)) {
        cb(null, true);
      } else {
        cb(new Error("CORS policy violation: Origin not allowed"), false);
      }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
  });
});
