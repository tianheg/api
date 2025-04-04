import fp from "fastify-plugin";
import cors from "@fastify/cors";

// not using RegExp or a function for origin
// avoid DoS attacks https://github.com/fastify/fastify-cors#warning-dos-attacks

export default fp(async (app, _) => {
  await app.register(cors, {
    origin: "https://lifebook.tianheg.org",
    methods: ["GET", "PUT", "POST", "DELETE", "OPTIONS"],
    credentials: true
  });
});
