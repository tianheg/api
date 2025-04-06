import { getPaginatedData, paginationSchema } from "../utils.js";

export default function words(app, opts, done) {
  // Define schemas for validation
  const sentenceSchema = {
    type: 'object',
    required: ['content'],
    properties: {
      content: { type: 'string' },
      csrfToken: { type: 'string' } // Add CSRF token to schema
    }
  };

  const paramsSchema = {
    type: 'object',
    required: ['id'],
    properties: {
      id: { type: 'integer' }
    }
  };

  // Handler functions
  async function getWords(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const wordsData = await client.query("SELECT * FROM words");
      return await getPaginatedData(
        wordsData.rows,
        search,
        page,
        limit,
      );
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to retrieve words' });
    } finally {
      client.release();
    }
  }

  async function createWord(request, reply) {
    const { content } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO words (content) VALUES ($1) RETURNING *",
        [content]
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to create word' });
    } finally {
      client.release();
    }
  }

  async function updateWord(request, reply) {
    const { id } = request.params;
    const { content } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE words SET content = $1 WHERE id = $2 RETURNING *",
        [content, id]
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Word not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to update word' });
    } finally {
      client.release();
    }
  }

  async function deleteWord(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM words WHERE id = $1 RETURNING *",
        [id]
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Word not found" });
      }
      return reply.send({ message: "Word deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to delete word' });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/words",
    {
      schema: {
        querystring: paginationSchema
      }
    },
    getWords
  );

  app.post(
    "/words",
    {
      preHandler: app.csrfProtect,
      schema: {
        body: sentenceSchema
      }
    },
    createWord
  );

  app.put(
    "/words/:id",
    {
      preHandler: app.csrfProtect,
      schema: {
        params: paramsSchema,
        body: sentenceSchema
      }
    },
    updateWord
  );

  app.delete(
    "/words/:id",
    {
      preHandler: app.csrfProtect,
      schema: {
        params: paramsSchema
      }
    },
    deleteWord
  );

  done();
}