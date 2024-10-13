import { getPaginatedData, paginationSchema } from "../utils.js";

export default async function movies(app) {
  app.get(
    "/movies",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    async (request, reply) => {
      const { page, limit, search } = request.query;
      const client = await app.pg.connect();
      try {
        const feedsData = await client.query("SELECT * FROM movies");
        const paginatedData = await getPaginatedData(
          feedsData.rows,
          search,
          page,
          limit,
        );
        return paginatedData;
      } catch (error) {
        return reply.status(500).send(error);
    }}
  )
}