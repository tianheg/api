import { getPaginatedData, paginationSchema } from "../utils.js";

export default function books(app, opts, done) {
  // Define schemas for validation
  const bookSchema = {
    type: "object",
    required: ["name", "url"],
    properties: {
      name: { type: "string" },
      url: { type: "string", format: "uri" },
    },
  };

  const paramsSchema = {
    type: "object",
    required: ["id"],
    properties: {
      id: { type: "integer" },
    },
  };

  // Handler functions
  async function getBooks(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const booksData = await client.query("SELECT * FROM books");
      return await getPaginatedData(booksData.rows, search, page, limit);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to retrieve books" });
    } finally {
      client.release();
    }
  }

  async function createBook(request, reply) {
    const { name, url } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO books (name, url) VALUES ($1, $2) RETURNING *",
        [name, url],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to create book" });
    } finally {
      client.release();
    }
  }

  async function updateBook(request, reply) {
    const { id } = request.params;
    const { name, url } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE books SET name = $1, url = $2 WHERE id = $3 RETURNING *",
        [name, url, id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Book not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to update book" });
    } finally {
      client.release();
    }
  }

  async function deleteBook(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM books WHERE id = $1 RETURNING *",
        [id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Book not found" });
      }
      return reply.send({ message: "Book deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to delete book" });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/books",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    getBooks,
  );

  app.post(
    "/books",
    {
      schema: {
        body: bookSchema,
      },
    },
    createBook,
  );

  app.put(
    "/books/:id",
    {
      schema: {
        params: paramsSchema,
        body: bookSchema,
      },
    },
    updateBook,
  );

  app.delete(
    "/books/:id",
    {
      schema: {
        params: paramsSchema,
      },
    },
    deleteBook,
  );

  done();
}
