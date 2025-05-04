import { getPaginatedData, paginationSchema } from "../utils.js";

export default function sentences(app, opts, done) {
  // Define schemas for validation
  const sentenceSchema = {
    type: "object",
    required: ["content"],
    properties: {
      content: { type: "string" },
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
  async function getSentences(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const sentencesData = await client.query("SELECT * FROM sentences ORDER BY id DESC");
      return await getPaginatedData(sentencesData.rows, search, page, limit);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to retrieve sentences" });
    } finally {
      client.release();
    }
  }

  async function createSentence(request, reply) {
    const { content } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO sentences (content) VALUES ($1) RETURNING *",
        [content],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to create sentence" });
    } finally {
      client.release();
    }
  }

  async function updateSentence(request, reply) {
    const { id } = request.params;
    const { content } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE sentences SET content = $1 WHERE id = $2 RETURNING *",
        [content, id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Sentence not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to update sentence" });
    } finally {
      client.release();
    }
  }

  async function deleteSentence(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM sentences WHERE id = $1 RETURNING *",
        [id],
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Sentence not found" });
      }
      return reply.send({ message: "Sentence deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: "Failed to delete sentence" });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/sentences",
    {
      schema: {
        querystring: paginationSchema,
      },
    },
    getSentences,
  );

  app.post(
    "/sentences",
    {
      schema: {
        body: sentenceSchema,
      },
    },
    createSentence,
  );

  app.put(
    "/sentences/:id",
    {
      schema: {
        params: paramsSchema,
        body: sentenceSchema,
      },
    },
    updateSentence,
  );

  app.delete(
    "/sentences/:id",
    {
      schema: {
        params: paramsSchema,
      },
    },
    deleteSentence,
  );

  done();
}
