import { getPaginatedData, paginationSchema } from "../utils.js";

/**
 * Sentences Routes
 *
 * Provides CRUD endpoints for managing sentence entries
 */
export default function sentencesRoutes(app, opts, done) {
  // ============================================================================
  // VALIDATION SCHEMAS
  // ============================================================================

  const sentenceSchema = {
    type: "object",
    required: ["content"],
    properties: {
      content: {
        type: "string",
        description: "Sentence content or text",
      },
    },
  };

  const idParamSchema = {
    type: "object",
    required: ["id"],
    properties: {
      id: {
        type: "integer",
        description: "Sentence ID",
      },
    },
  };

  // ============================================================================
  // HANDLERS
  // ============================================================================

  /**
   * GET /sentences - Retrieve all sentences with pagination
   */
  async function listSentences(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "SELECT * FROM sentences ORDER BY id DESC",
      );
      return await getPaginatedData(result.rows, search, page, limit);
    } catch (error) {
      app.log.error("Failed to list sentences:", error);
      return reply.status(500).send({
        error: "Failed to retrieve sentences",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * POST /sentences - Create a new sentence entry
   */
  async function createSentence(request, reply) {
    const { content } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `INSERT INTO sentences (content)
         VALUES ($1)
         RETURNING *`,
        [content],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error("Failed to create sentence:", error);
      return reply.status(500).send({
        error: "Failed to create sentence",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * PUT /sentences/:id - Update an existing sentence entry
   */
  async function updateSentence(request, reply) {
    const { id } = request.params;
    const { content } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `UPDATE sentences
         SET content = $1
         WHERE id = $2
         RETURNING *`,
        [content, id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Sentence not found",
          id,
        });
      }

      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(`Failed to update sentence ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to update sentence",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * DELETE /sentences/:id - Delete a sentence entry
   */
  async function deleteSentence(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "DELETE FROM sentences WHERE id = $1 RETURNING *",
        [id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Sentence not found",
          id,
        });
      }

      return reply.send({
        message: "Sentence deleted successfully",
        deleted: result.rows[0],
      });
    } catch (error) {
      app.log.error(`Failed to delete sentence ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to delete sentence",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  // ============================================================================
  // ROUTE REGISTRATION
  // ============================================================================

  app.get(
    "/sentences",
    { schema: { querystring: paginationSchema } },
    listSentences,
  );

  app.post("/sentences", { schema: { body: sentenceSchema } }, createSentence);

  app.put(
    "/sentences/:id",
    { schema: { params: idParamSchema, body: sentenceSchema } },
    updateSentence,
  );

  app.delete(
    "/sentences/:id",
    { schema: { params: idParamSchema } },
    deleteSentence,
  );

  done();
}

