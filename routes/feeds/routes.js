import { getPaginatedData, paginationSchema } from "../utils.js";

/**
 * Feeds Routes
 *
 * Provides CRUD endpoints for managing RSS feeds
 */
export default function feedsRoutes(app, opts, done) {
  // ============================================================================
  // VALIDATION SCHEMAS
  // ============================================================================

  const feedSchema = {
    type: "object",
    required: ["title", "url", "rss"],
    properties: {
      title: {
        type: "string",
        description: "Feed title",
      },
      url: {
        type: "string",
        format: "uri",
        description: "Website URL",
      },
      description: {
        type: "string",
        description: "Feed description",
      },
      rss: {
        type: "string",
        format: "uri",
        description: "RSS feed URL",
      },
    },
  };

  const idParamSchema = {
    type: "object",
    required: ["id"],
    properties: {
      id: {
        type: "integer",
        description: "Feed ID",
      },
    },
  };

  // ============================================================================
  // HANDLERS
  // ============================================================================

  /**
   * GET /feeds - Retrieve all feeds with pagination
   */
  async function listFeeds(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "SELECT * FROM feeds ORDER BY id DESC",
      );
      return await getPaginatedData(result.rows, search, page, limit);
    } catch (error) {
      app.log.error("Failed to list feeds:", error);
      return reply.status(500).send({
        error: "Failed to retrieve feeds",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * POST /feeds - Create a new feed
   */
  async function createFeed(request, reply) {
    const { title, url, description, rss } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `INSERT INTO feeds (title, url, description, rss)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [title, url, description, rss],
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error("Failed to create feed:", error);
      return reply.status(500).send({
        error: "Failed to create feed",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * PUT /feeds/:id - Update an existing feed
   */
  async function updateFeed(request, reply) {
    const { id } = request.params;
    const { title, url, description, rss } = request.body;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        `UPDATE feeds
         SET title = $1, url = $2, description = $3, rss = $4
         WHERE id = $5
         RETURNING *`,
        [title, url, description, rss, id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Feed not found",
          id,
        });
      }

      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(`Failed to update feed ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to update feed",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * DELETE /feeds/:id - Delete a feed
   */
  async function deleteFeed(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();

    try {
      const result = await client.query(
        "DELETE FROM feeds WHERE id = $1 RETURNING *",
        [id],
      );

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: "Feed not found",
          id,
        });
      }

      return reply.send({
        message: "Feed deleted successfully",
        deleted: result.rows[0],
      });
    } catch (error) {
      app.log.error(`Failed to delete feed ${id}:`, error);
      return reply.status(500).send({
        error: "Failed to delete feed",
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  // ============================================================================
  // ROUTE REGISTRATION
  // ============================================================================

  app.get("/feeds", { schema: { querystring: paginationSchema } }, listFeeds);

  app.post("/feeds", { schema: { body: feedSchema } }, createFeed);

  app.put(
    "/feeds/:id",
    { schema: { params: idParamSchema, body: feedSchema } },
    updateFeed,
  );

  app.delete("/feeds/:id", { schema: { params: idParamSchema } }, deleteFeed);

  done();
}

