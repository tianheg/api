import { getPaginatedData, paginationSchema } from "../utils.js";

/**
 * Music Routes
 *
 * Provides CRUD endpoints for managing music entries
 */
export default function musicRoutes(app, opts, done) {
  // ============================================================================
  // VALIDATION SCHEMAS
  // ============================================================================

  const musicSchema = {
    type: "object",
    required: ["name"],
    properties: {
      name: {
        type: "string",
        description: "Music name or title",
      },
      url: {
        type: "string",
        format: "uri",
        description: "Link to music resource",
      },
    },
  };

  const idParamSchema = {
    type: "object",
    required: ["id"],
    properties: {
      id: {
        type: "integer",
        description: "Music ID",
      },
    },
  };

  // ============================================================================
  // HANDLERS
  // ============================================================================

  /**
   * GET /music - Retrieve all music entries with pagination
   */
  async function listMusic(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "SELECT * FROM music ORDER BY id DESC",
      );
      return await getPaginatedData(result.rows, search, page, limit);
    } catch (error) {
      app.log.error("Failed to list music:", error);
      return reply.status(500).send({
        error: "Failed to retrieve music",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * POST /music - Create a new music entry
   */
  async function createMusic(request, reply) {
    const { name, url } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `INSERT INTO music (name, url)
         VALUES ($1, $2)
         RETURNING *`,
        [name, url],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error("Failed to create music:", error);
      return reply.status(500).send({
        error: "Failed to create music",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * PUT /music/:id - Update an existing music entry
   */
  async function updateMusic(request, reply) {
    const { id } = request.params;
    const { name, url } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `UPDATE music
         SET name = $1, url = $2
         WHERE id = $3
         RETURNING *`,
        [name, url, id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Music not found",
          id,
        });
      }

      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(`Failed to update music ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to update music",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * DELETE /music/:id - Delete a music entry
   */
  async function deleteMusic(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "DELETE FROM music WHERE id = $1 RETURNING *",
        [id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Music not found",
          id,
        });
      }

      return reply.send({
        message: "Music deleted successfully",
        deleted: result.rows[0],
      });
    } catch (error) {
      app.log.error(`Failed to delete music ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to delete music",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  // ============================================================================
  // ROUTE REGISTRATION
  // ============================================================================

  app.get("/music", { schema: { querystring: paginationSchema } }, listMusic);

  app.post("/music", { schema: { body: musicSchema } }, createMusic);

  app.put(
    "/music/:id",
    { schema: { params: idParamSchema, body: musicSchema } },
    updateMusic,
  );

  app.delete(
    "/music/:id",
    { schema: { params: idParamSchema } },
    deleteMusic,
  );

  done();
}

