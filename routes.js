import { createRoute, paginationSchema } from "./utils.js";

export default async function registerRoutes(app) {
  app.get("/", (request, reply) => {
    const baseUrl =
      process.env.NODE_ENV === "development"
        ? "http://localhost:3000"
        : "https://api.tianheg.org";
    const routes = [
      `${baseUrl}/books`,
      `${baseUrl}/feeds`,
      `${baseUrl}/movies`,
      `${baseUrl}/music`,
      `${baseUrl}/musicals`,
      `${baseUrl}/prompts`,
      `${baseUrl}/series`,
      `${baseUrl}/words`,
    ];

    reply.send({
      repo: "https://github.com/tianheg/api/",
      doc: `${baseUrl}/doc`,
      tech: "https://fastify.dev/",
      deploy: "https://vercel.com/",
      routes: routes,
    });
  });

  const entities = [
    "books",
    "feeds",
    "movies",
    "music",
    "musicals",
    "series",
    "words",
  ];

  for (const entity of entities) {
    createRoute(
      app,
      `/${entity}`,
      async (request, reply) => {
        const client = await app.pg.connect();
        try {
          const data = await client.query(`SELECT * FROM ${entity}`);
          return data.rows;
        } catch (error) {
          reply.status(500).send(error);
        } finally {
          client.release();
        }
      },
      { schema: paginationSchema },
    );
  }

  app.post("/books", async (request, reply) => {
    const { name, url } = request.body;
    if (!name || !url) {
      reply.status(400).send("Missing name or url");
      return;
    }
    const client = await app.pg.connect();
    try {
      const response = await client.query(
        "INSERT INTO books (name, url) VALUES ($1, $2) RETURNing *",
        [name, url],
      );
      reply.send(response.rows[0]);
    } catch (error) {
      reply.status(500).send(error);
    } finally {
      client.release();
    }
  });

  app.delete("/books/:id", async (request, reply) => {
    const { id } = request.params; // Extract the ID from the request parameters.

    // Assuming app.pg.connect() is your method to get a database client.
    const client = await app.pg.connect();
    try {
      // Execute a SQL query to delete the book by its ID.
      // Ensure your query is protected against SQL injection by using parameterized queries.
      const result = await client.query(
        "DELETE FROM books WHERE id = $1 RETURNING *", // Returns the deleted book details.
        [id],
      );

      // If no rows are returned, the book with the given ID does not exist.
      if (result.rows.length === 0) {
        reply.status(404).send({ message: "Book not found" });
        return;
      }

      // Send back the details of the deleted book.
      reply.send(result.rows[0]);
    } catch (error) {
      // Handle any errors that occur during the database operation.
      reply.status(500).send(error);
    } finally {
      // Release the client back to the pool.
      client.release();
    }
  });

  app.put("/books/:id", async (request, reply) => {
    const { id } = request.params; // Extract the ID from the route parameters.
    const { name, url } = request.body; // Extract the updated name and url from the request body.

    // Input validation (optional but recommended)
    if (!name || !url) {
      reply
        .status(400)
        .send({ message: "Missing name or url in request body." });
      return;
    }

    const client = await app.pg.connect(); // Assuming app.pg.connect() is your method to get a database client.
    try {
      // Execute a SQL query to update the book by its ID.
      // Ensure your query is protected against SQL injection by using parameterized queries.
      const result = await client.query(
        "UPDATE books SET name = $1, url = $2 WHERE id = $3 RETURNING *", // Returns the updated book details.
        [name, url, id],
      );

      // If no rows are returned, the book with the given ID does not exist.
      if (result.rows.length === 0) {
        reply.status(404).send({ message: "Book not found" });
        return;
      }

      // Send back the details of the updated book.
      reply.send(result.rows[0]);
    } catch (error) {
      // Handle any errors that occur during the database operation.
      reply
        .status(500)
        .send({ error: "An error occurred while updating the book." });
    } finally {
      // Release the client back to the pool.
      client.release();
    }
  });
}
