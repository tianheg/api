import cors from "@fastify/cors";
import fp from "fastify-plugin";

export default fp(async (app, _) => {
  await app.register(cors, {
    origin: (origin, cb) => {
      const allowedOrigins = [
        "https://lifebook.tianheg.org",
        "http://localhost:5173",
      ];
      if (!origin || allowedOrigins.includes(origin)) {
        cb(null, true);
      } else {
        cb(new Error("CORS not allowed"), false);
      }
    },
    methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type"],
  });
});
