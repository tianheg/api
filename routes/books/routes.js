import { getPaginatedData, paginationSchema } from "../utils.js";

export default function books(app, opts, done) {
  app.get(
    "/books",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    async (request, reply) => {
      const { page, limit, search } = request.query;
      const client = await app.pg.connect();
      try {
        const booksData = await client.query("SELECT * FROM books");
        const paginatedData = await getPaginatedData(
          booksData.rows,
          search,
          page,
          limit,
        );
        return paginatedData;
      } catch (error) {
        reply.status(500).send(error);
      }
    },
  );

  done();
}
