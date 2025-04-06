import { getPaginatedData, paginationSchema } from "../utils.js";

export default function movies(app, opts, done) {
  // Define schemas for validation
  const movieSchema = {
    type: 'object',
    required: ['name'],
    properties: {
      name: { type: 'string' },
      review: { type: 'string' },
      date: { type: 'string', format: 'date' }
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
  async function getMovies(request, reply) {
    const { page, limit, search } = request.query;
    const client = await app.pg.connect();
    try {
      const moviesData = await client.query("SELECT * FROM movies");
      return getPaginatedData(
        moviesData.rows,
        search,
        page,
        limit,
      );
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to retrieve movies' });
    } finally {
      client.release();
    }
  }

  async function createMovie(request, reply) {
    const { name, review, date } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "INSERT INTO movies (name, review, date) VALUES ($1, $2, $3) RETURNING *",
        [name, review, date]
      );
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to create movie' });
    } finally {
      client.release();
    }
  }

  async function updateMovie(request, reply) {
    const { id } = request.params;
    const { name, review, date } = request.body;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "UPDATE movies SET name = $1, review = $2, date = $3 WHERE id = $4 RETURNING *",
        [name, review, date, id]
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Movie not found" });
      }
      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to update movie' });
    } finally {
      client.release();
    }
  }

  async function deleteMovie(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();
    try {
      const result = await client.query(
        "DELETE FROM movies WHERE id = $1 RETURNING *",
        [id]
      );
      if (result.rowCount === 0) {
        return reply.status(404).send({ message: "Movie not found" });
      }
      return reply.send({ message: "Movie deleted successfully" });
    } catch (error) {
      app.log.error(error);
      return reply.status(500).send({ error: 'Failed to delete movie' });
    } finally {
      client.release();
    }
  }

  // Route definitions
  app.get(
    "/movies",
    {
      schema: {
        querystring: paginationSchema
      }
    },
    getMovies
  );

  app.post(
    "/movies",
    {
      schema: {
        body: movieSchema
      }
    },
    createMovie
  );

  app.put(
    "/movies/:id",
    {
      schema: {
        params: paramsSchema,
        body: movieSchema
      }
    },
    updateMovie
  );

  app.delete(
    "/movies/:id",
    {
      schema: {
        params: paramsSchema
      }
    },
    deleteMovie
  );

  done();
}