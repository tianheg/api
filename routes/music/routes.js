import { getPaginatedData, paginationSchema } from "../utils.js";

export default function music(app, opts, done) {
  app.get(
    "/music",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    async (request, reply) => {
      const { page, limit, search } = request.query;
      const client = await app.pg.connect();
      try {
        const feedsData = await client.query("SELECT * FROM music");
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

  done();
}