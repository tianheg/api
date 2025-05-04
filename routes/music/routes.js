import { getPaginatedData, paginationSchema } from "../utils.js";

export default function music(app, opts, done) {
  // Define schemas for validation
  const musicSchema = {
    type: "object",
    required: ["name"],
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
  async function getMusicList(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const musicData = await client.query("SELECT * FROM music ORDER BY id DESC");
      return await getPaginatedData(musicData.rows, search, page, limit);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to retrieve music" });
    } finally {
      client.release();
    }
  }

  async function createMusic(request, reply) {
    const { name, url } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO music (name, url) VALUES ($1, $2) RETURNING *",
        [name, url],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to create music" });
    } finally {
      client.release();
    }
  }

  async function updateMusic(request, reply) {
    const { id } = request.params;
    const { name, url } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE music SET name = $1, url = $2 WHERE id = $3 RETURNING *",
        [name, url, id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Music not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to update music" });
    } finally {
      client.release();
    }
  }

  async function deleteMusic(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM music WHERE id = $1 RETURNING *",
        [id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Music not found" });
      }
      return reply.send({ message: "Music deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to delete music" });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/music",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    getMusicList,
  );

  app.post(
    "/music",
    {
      schema: {
        body: musicSchema,
      },
    },
    createMusic,
  );

  app.put(
    "/music/:id",
    {
      schema: {
        params: paramsSchema,
        body: musicSchema,
      },
    },
    updateMusic,
  );

  app.delete(
    "/music/:id",
    {
      schema: {
        params: paramsSchema,
      },
    },
    deleteMusic,
  );

  done();
}
