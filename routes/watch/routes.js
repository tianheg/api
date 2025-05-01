import { getPaginatedData, paginationSchema } from "../utils.js";

export default function watch(app, opts, done) {
  // Define schemas for validation
  const watchSchema = {
    type: "object",
    required: ["name"],
    properties: {
      name: { type: "string" },
      review: { type: "string" },
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
  async function getWatch(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const watchData = await client.query("SELECT * FROM watch");
      return getPaginatedData(watchData.rows, search, page, limit);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to retrieve watch" });
    } finally {
      client.release();
    }
  }

  async function createWatch(request, reply) {
    const { name, review } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO watch (name, review) VALUES ($1, $2) RETURNING *",
        [name, review],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to create watch" });
    } finally {
      client.release();
    }
  }

  async function updateWatch(request, reply) {
    const { id } = request.params;
    const { name, review } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE watch SET name = $1, review = $2 WHERE id = $3 RETURNING *",
        [name, review, id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Watch not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to update watch" });
    } finally {
      client.release();
    }
  }

  async function deleteWatch(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM watch WHERE id = $1 RETURNING *",
        [id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Watch not found" });
      }
      return reply.send({ message: "Watch deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to delete watch" });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/watch",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    getWatch,
  );

  app.post(
    "/watch",
    {
      schema: {
        body: watchSchema,
      },
    },
    createWatch,
  );

  app.put(
    "/watch/:id",
    {
      schema: {
        params: paramsSchema,
        body: watchSchema,
      },
    },
    updateWatch,
  );

  app.delete(
    "/watch/:id",
    {
      schema: {
        params: paramsSchema,
      },
    },
    deleteWatch,
  );

  done();
}
