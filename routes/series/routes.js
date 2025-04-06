import { getPaginatedData, paginationSchema } from "../utils.js";

export default function series(app, opts, done) {
  // Define schemas for validation
  const seriesSchema = {
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
  async function getSeriesList(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const seriesData = await client.query("SELECT * FROM series");
      return await getPaginatedData(seriesData.rows, search, page, limit);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to retrieve series" });
    } finally {
      client.release();
    }
  }

  async function createSeries(request, reply) {
    const { name, review } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO series (name, review) VALUES ($1, $2) RETURNING *",
        [name, review],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to create series" });
    } finally {
      client.release();
    }
  }

  async function updateSeries(request, reply) {
    const { id } = request.params;
    const { name, review } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE series SET name = $1, review = $2 WHERE id = $3 RETURNING *",
        [name, review, id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Series not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to update series" });
    } finally {
      client.release();
    }
  }

  async function deleteSeries(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM series WHERE id = $1 RETURNING *",
        [id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Series not found" });
      }
      return reply.send({ message: "Series deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to delete series" });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/series",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    getSeriesList,
  );

  app.post(
    "/series",
    {
      schema: {
        body: seriesSchema,
      },
    },
    createSeries,
  );

  app.put(
    "/series/:id",
    {
      schema: {
        params: paramsSchema,
        body: seriesSchema,
      },
    },
    updateSeries,
  );

  app.delete(
    "/series/:id",
    {
      schema: {
        params: paramsSchema,
      },
    },
    deleteSeries,
  );

  done();
}
