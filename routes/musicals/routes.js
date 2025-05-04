import { getPaginatedData, paginationSchema } from "../utils.js";

export default function musicals(app, opts, done) {
  // Define schemas for validation
  const musicalSchema = {
    type: "object",
    required: ["name", "review"],
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
  async function getMusicals(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const musicalsData = await client.query("SELECT * FROM musicals ORDER BY id DESC");
      return await getPaginatedData(musicalsData.rows, search, page, limit);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to retrieve musicals" });
    } finally {
      client.release();
    }
  }

  async function createMusical(request, reply) {
    const { name, review } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO musicals (name, review) VALUES ($1, $2) RETURNING *",
        [name, review],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to create musical" });
    } finally {
      client.release();
    }
  }

  async function updateMusical(request, reply) {
    const { id } = request.params;
    const { name, review } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE musicals SET name = $1, review = $2 WHERE id = $3 RETURNING *",
        [name, review, id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Musical not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to update musical" });
    } finally {
      client.release();
    }
  }

  async function deleteMusical(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM musicals WHERE id = $1 RETURNING *",
        [id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Musical not found" });
      }
      return reply.send({ message: "Musical deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to delete musical" });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/musicals",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    getMusicals,
  );

  app.post(
    "/musicals",
    {
      schema: {
        body: musicalSchema,
      },
    },
    createMusical,
  );

  app.put(
    "/musicals/:id",
    {
      schema: {
        params: paramsSchema,
        body: musicalSchema,
      },
    },
    updateMusical,
  );

  app.delete(
    "/musicals/:id",
    {
      schema: {
        params: paramsSchema,
      },
    },
    deleteMusical,
  );

  done();
}
