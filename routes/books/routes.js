import { getPaginatedData, paginationSchema } from "../utils.js";

export default async function books(app) {
  // GET all books
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
    }}
  )

  // POST a new book
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

  // PUT/PATCH to update a book
  app.put(
    "/books/:id",
    {
      preValidation: app.authenticate,
    },
    async (request, reply) => {
      const client = await app.pg.connect();
      // Implement update book logic
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

  // DELETE a book
  app.delete(
    "/books/:id",
    {
      preValidation: app.authenticate,
    },
    async (request, reply) => {
      const client = await app.pg.connect();
      // Implement delete book logic
      const { id } = request.params;
      try {
        await client.query("DELETE FROM books WHERE id = $1 RETURNING *", [id]);
        if (result.rows.length === 0) {
          reply.status(404).send({ message: "Book not found" });
          return;
        }

        // Send back the details of the deleted book.
        return `Book with id ${id} deleted successfully: ${result.rows[0]}`; // result.rows[0];
      } catch (error) {
        reply.status(500).send(error);
      } finally {
        client.release();
      }
    },
  );
}
