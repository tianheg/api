import { getPaginatedData, paginationSchema } from "../utils.js";

export default function feeds(app, opts, done) {
  // Define schemas for validation
  const feedSchema = {
    type: 'object',
    required: ['title', 'url', 'description', 'rss'],
    properties: {
      title: { type: 'string' },
      url: { type: 'string', format: 'uri' },
      description: { type: 'string' },
      rss: { type: 'string', format: 'uri' }
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
  async function getFeeds(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const feedsData = await client.query("SELECT * FROM feeds");
      return await getPaginatedData(
        feedsData.rows,
        search,
        page,
        limit,
      );
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to retrieve feeds' });
    } finally {
      client.release();
    }
  }

  async function createFeed(request, reply) {
    const { title, url, description, rss } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO feeds (title, url, description, rss) VALUES ($1, $2, $3, $4) RETURNING *",
        [title, url, description, rss]
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to create feed' });
    } finally {
      client.release();
    }
  }

  async function updateFeed(request, reply) {
    const { id } = request.params;
    const { title, url, description, rss } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE feeds SET title = $1, url = $2, description = $3, rss = $4 WHERE id = $5 RETURNING *",
        [title, url, description, rss, id]
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Feed not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to update feed' });
    } finally {
      client.release();
    }
  }

  async function deleteFeed(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM feeds WHERE id = $1 RETURNING *",
        [id]
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Feed not found" });
      }
      return reply.send({ message: "Feed deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to delete feed' });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/feeds",
    {
      schema: {
        querystring: paginationSchema
      }
    },
    getFeeds
  );

  app.post(
    "/feeds",
    {
      schema: {
        body: feedSchema
      }
    },
    createFeed
  );

  app.put(
    "/feeds/:id",
    {
      schema: {
        params: paramsSchema,
        body: feedSchema
      }
    },
    updateFeed
  );

  app.delete(
    "/feeds/:id",
    {
      schema: {
        params: paramsSchema
      }
    },
    deleteFeed
  );

  done();
}