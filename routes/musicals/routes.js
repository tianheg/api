import { getPaginatedData, paginationSchema } from "../utils.js";

/**
 * Musicals Routes
 *
 * Provides CRUD endpoints for managing musical entries with reviews
 */
export default function musicalsRoutes(app, opts, done) {
  // ============================================================================
  // VALIDATION SCHEMAS
  // ============================================================================

  const musicalSchema = {
    type: "object",
    required: ["name", "review"],
    properties: {
      name: {
        type: "string",
        description: "Musical name or title",
      },
      review: {
        type: "string",
        description: "Review or description of the musical",
      },
    },
  };

  const idParamSchema = {
    type: "object",
    required: ["id"],
    properties: {
      id: {
        type: "integer",
        description: "Musical ID",
      },
    },
  };

  // ============================================================================
  // HANDLERS
  // ============================================================================

  /**
   * GET /musicals - Retrieve all musicals with pagination
   */
  async function listMusicals(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "SELECT * FROM musicals ORDER BY id DESC",
      );
      return await getPaginatedData(result.rows, search, page, limit);
    } catch (error) {
      app.log.error("Failed to list musicals:", error);
      return reply.status(500).send({
        error: "Failed to retrieve musicals",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * POST /musicals - Create a new musical entry
   */
  async function createMusical(request, reply) {
    const { name, review } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `INSERT INTO musicals (name, review)
         VALUES ($1, $2)
         RETURNING *`,
        [name, review],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error("Failed to create musical:", error);
      return reply.status(500).send({
        error: "Failed to create musical",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * PUT /musicals/:id - Update an existing musical entry
   */
  async function updateMusical(request, reply) {
    const { id } = request.params;
    const { name, review } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `UPDATE musicals
         SET name = $1, review = $2
         WHERE id = $3
         RETURNING *`,
        [name, review, id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Musical not found",
          id,
        });
      }

      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(`Failed to update musical ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to update musical",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * DELETE /musicals/:id - Delete a musical entry
   */
  async function deleteMusical(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "DELETE FROM musicals WHERE id = $1 RETURNING *",
        [id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Musical not found",
          id,
        });
      }

      return reply.send({
        message: "Musical deleted successfully",
        deleted: result.rows[0],
      });
    } catch (error) {
      app.log.error(`Failed to delete musical ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to delete musical",
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
    "/musicals",
    { schema: { querystring: paginationSchema } },
    listMusicals,
  );

  app.post("/musicals", { schema: { body: musicalSchema } }, createMusical);

  app.put(
    "/musicals/:id",
    { schema: { params: idParamSchema, body: musicalSchema } },
    updateMusical,
  );

  app.delete(
    "/musicals/:id",
    { schema: { params: idParamSchema } },
    deleteMusical,
  );

  done();
}

