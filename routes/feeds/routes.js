import { getPaginatedData, paginationSchema } from "../utils.js";

export default async function feeds(app) {
  // GET all feeds
  app.get(
    "/feeds",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    async (request, reply) => {
      const { page, limit, search } = request.query;
      const client = await app.pg.connect();
      try {
        const feedsData = await client.query("SELECT * FROM feeds");
        const paginatedData = await getPaginatedData(
          feedsData.rows,
          search,
          page,
          limit,
        );
        return paginatedData;
      } catch (error) {
        reply.status(500).send(error);
    }}
  )
}