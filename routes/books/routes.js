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

  app.post(
    "/books",
    {
      preValidation: app.authenticate,
      schema: {
        paginationSchema,
      },
    },
    async (request, reply) => {
      const { name, url } = request.body;
      const client = await app.pg.connect();
      if (!name || !url) {
        reply.status(400).send("Missing name or url");
        return;
      }
      try {
        const response = await client.query(
          "INSERT INTO books (name, url) VALUES ($1, $2) RETURNing *",
          [name, url],
        );
        return response.rows[0];
      } catch (error) {
        reply.status(500).send(error);
      } finally {
        client.release();
      }
    },
  );

  app.put(
    "/books/:id",
    {
      preValidation: app.authenticate,
    },
    async (request, reply) => {
      const client = await app.pg.connect();
      const { id } = request.params;
      const { name, url } = request.body;
      if (!name || !url) {
        reply.status(400).send("Missing name or url");
        return;
      }
      try {
        const response = await client.query(
          "UPDATE books SET name = $1, url = $2 WHERE id = $3 RETURNing *",
          [name, url, id],
        );
        return response.rows[0];
      } catch (error) {
        reply.status(500).send(error);
      } finally {
        client.release();
      }
    },
  );

  app.delete(
    "/books/:id",
    {
      preValidation: app.authenticate,
    },
    async (request, reply) => {
      const client = await app.pg.connect();
      const { id } = request.params;
      try {
        await client.query("DELETE FROM books WHERE id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
          reply.status(404).send({ message: "Book not found" });
          return;
        }

        return `Book with id ${id} deleted successfully: ${result.rows[0]}`; // result.rows[0];
      } catch (error) {
        reply.status(500).send(error);
      } finally {
        client.release();
      }
    },
  );

  done();
}
