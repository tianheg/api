import app from "../app.js";

export default async (request, reply) => {
  await app.ready();
  app.server.emit("request", request, reply);
};
