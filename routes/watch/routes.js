import { getPaginatedData, paginationSchema } from "../utils.js";

/**
 * Watch Routes
 *
 * Provides CRUD endpoints for managing watch/video entries with reviews
 */
export default function watchRoutes(app, opts, done) {
  // ============================================================================
  // VALIDATION SCHEMAS
  // ============================================================================

  const watchSchema = {
    type: "object",
    required: ["name"],
    properties: {
      name: {
        type: "string",
        description: "Video/show name or title",
      },
      review: {
        type: "string",
        description: "Review or description of the video/show",
      },
    },
  };

  const idParamSchema = {
    type: "object",
    required: ["id"],
    properties: {
      id: {
        type: "integer",
        description: "Watch/video ID",
      },
    },
  };

  // ============================================================================
  // HANDLERS
  // ============================================================================

  /**
   * GET /watch - Retrieve all watch/video entries with pagination
   */
  async function listWatch(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "SELECT * FROM watch ORDER BY id DESC",
      );
      return getPaginatedData(result.rows, search, page, limit);
    } catch (error) {
      app.log.error("Failed to list watch entries:", error);
      return reply.status(500).send({
        error: "Failed to retrieve watch entries",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * POST /watch - Create a new watch/video entry
   */
  async function createWatch(request, reply) {
    const { name, review } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `INSERT INTO watch (name, review)
         VALUES ($1, $2)
         RETURNING *`,
        [name, review],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error("Failed to create watch entry:", error);
      return reply.status(500).send({
        error: "Failed to create watch entry",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * PUT /watch/:id - Update an existing watch/video entry
   */
  async function updateWatch(request, reply) {
    const { id } = request.params;
    const { name, review } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `UPDATE watch
         SET name = $1, review = $2
         WHERE id = $3
         RETURNING *`,
        [name, review, id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Watch entry not found",
          id,
        });
      }

      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(`Failed to update watch entry ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to update watch entry",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * DELETE /watch/:id - Delete a watch/video entry
   */
  async function deleteWatch(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "DELETE FROM watch WHERE id = $1 RETURNING *",
        [id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Watch entry not found",
          id,
        });
      }

      return reply.send({
        message: "Watch entry deleted successfully",
        deleted: result.rows[0],
      });
    } catch (error) {
      app.log.error(`Failed to delete watch entry ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to delete watch entry",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  // ============================================================================
  // ROUTE REGISTRATION
  // ============================================================================

  app.get("/watch", { schema: { querystring: paginationSchema } }, listWatch);

  app.post("/watch", { schema: { body: watchSchema } }, createWatch);

  app.put(
    "/watch/:id",
    { schema: { params: idParamSchema, body: watchSchema } },
    updateWatch,
  );

  app.delete("/watch/:id", { schema: { params: idParamSchema } }, deleteWatch);

  done();
}

