import { getPaginatedData, paginationSchema } from "../utils.js";

export default function watch(app, opts, done) {

  const watchSchema = {
    type: 'object',
    properties: {
      name: { type: 'string' },
      review: { type: 'string' },
    }
  };

  // Get client from app for database connection
  const client = app.pg;

  async function getWatchItems(request, reply) {
    const { search, page, limit, type } = request.query;

    try {
      let query = "SELECT * FROM watch";
      const params = [];

      // Add type filter if specified
      if (type && (type === 'movie' || type === 'series')) {
        query += " WHERE type = $1";
        params.push(type);
      }

      const watchData = await client.query(query, params);
      return getPaginatedData(watchData.rows, search, page, limit);
    } catch (err) {
      console.error("Error getting watch items:", err);
      return reply.status(500).send({ error: "Failed to retrieve items" });
    }
  }

  async function createWatchItem(request, reply) {
    const { name, review, type } = request.body;

    try {
      const result = await client.query(
        "INSERT INTO watch (name, review, type) VALUES ($1, $2, $3) RETURNING *",
        [name, review, type || 'movie']
      );
      return reply.send(result.rows[0]);
    } catch (err) {
      console.error("Error creating watch item:", err);
      return reply.status(500).send({ error: "Failed to create item" });
    }
  }

  async function updateWatchItem(request, reply) {
    const { id } = request.params;
    const { name, review, type } = request.body;

    try {
      const result = await client.query(
        "UPDATE watch SET name = $1, review = $2, type = $3 WHERE id = $4 RETURNING *",
        [name, review, type || 'movie', id]
      );
      if (result.rows.length === 0) {
        return reply.status(404).send({ message: "Item not found" });
      }
      return reply.send(result.rows[0]);
    } catch (err) {
      console.error("Error updating watch item:", err);
      return reply.status(500).send({ error: "Failed to update item" });
    }
  }

  async function deleteWatchItem(request, reply) {
    const { id } = request.params;

    try {
      const result = await client.query(
        "DELETE FROM watch WHERE id = $1 RETURNING *",
        [id]
      );
      if (result.rows.length === 0) {
        return reply.status(404).send({ message: "Item not found" });
      }
      return reply.send({ message: "Item deleted successfully" });
    } catch (err) {
      console.error("Error deleting watch item:", err);
      return reply.status(500).send({ error: "Failed to delete item" });
    }
  }

  // Routes
  app.route({
    method: "GET",
    url: "/watch",
    schema: {
      querystring: {
        type: { type: "string", enum: ["movie", "series"] },
        search: { type: "string" },
        page: { type: "integer", default: 1 },
        limit: { type: "integer", default: 10 }
      }
    },
    handler: getWatchItems,
  });

  app.route({
    method: "POST",
    url: "/watch",
    schema: {
      body: watchSchema,
    },
    handler: createWatchItem,
  });

  app.route({
    method: "PUT",
    url: "/watch/:id",
    schema: {
      body: watchSchema,
    },
    handler: updateWatchItem,
  });

  app.route({
    method: "DELETE",
    url: "/watch/:id",
    handler: deleteWatchItem,
  });

  // Legacy endpoints to ensure backward compatibility
  app.route({
    method: "GET",
    url: "/movies",
    handler: async (request, reply) => {
      request.query.type = 'movie';
      return getWatchItems(request, reply);
    }
  });

  app.route({
    method: "GET",
    url: "/series",
    handler: async (request, reply) => {
      request.query.type = 'series';
      return getWatchItems(request, reply);
    }
  });

  done();
}
