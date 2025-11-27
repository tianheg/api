/**
 * CRUD Controller Helper
 *
 * Provides a reusable pattern for implementing Create, Read, Update, Delete operations.
 * Reduces code duplication across route modules.
 *
 * Usage:
 *   const controller = createCrudController(app, 'table_name', 'column_definitions');
 *   app.get('/endpoint', {}, controller.list);
 *   app.post('/endpoint', {}, controller.create);
 *   app.put('/endpoint/:id', {}, controller.update);
 *   app.delete('/endpoint/:id', {}, controller.delete);
 */

/**
 * Creates a CRUD controller for a specific database table
 *
 * @param {FastifyInstance} app - The Fastify application instance
 * @param {string} tableName - Name of the database table
 * @param {Object} columns - Column definitions with their types and constraints
 *
 * @returns {Object} Object with list, create, update, delete handler methods
 */
export function createCrudController(app, tableName, columns) {
  /**
   * List all records with pagination and optional search
   *
   * Query parameters:
   * - page: Page number (default: 1)
   * - limit: Records per page (default: 10000)
   * - search: Optional search term to filter results
   */
  async function list(request, reply) {
    const page = parseInt(request.query.page) || 1;
    const limit = parseInt(request.query.limit) || 10000;
    const search = request.query.search || "";
    const client = await app.pg.connect();

    try {
      const query = `SELECT * FROM ${tableName} ORDER BY id DESC`;
      const result = await client.query(query);
      const rows = result.rows;

      // Filter by search term if provided
      const filtered = search
        ? rows.filter((item) =>
            JSON.stringify(item).toLowerCase().includes(search.toLowerCase()),
          )
        : rows;

      // Apply pagination
      const startIndex = (page - 1) * limit;
      const endIndex = Math.min(startIndex + limit, filtered.length);
      const paginatedData = filtered.slice(startIndex, endIndex);

      return {
        page,
        limit,
        total: filtered.length,
        totalPages: Math.ceil(filtered.length / limit),
        data: paginatedData,
      };
    } catch (error) {
      app.log.error(`Failed to fetch ${tableName}:`, error);
      return reply.status(500).send({
        error: `Failed to retrieve ${tableName}`,
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * Create a new record
   * Body should contain all required columns defined in the controller
   */
  async function create(request, reply) {
    const client = await app.pg.connect();

    try {
      const values = Object.values(request.body);
      const columnNames = Object.keys(request.body);
      const placeholders = columnNames
        .map((_, i) => `$${i + 1}`)
        .join(", ");

      const query = `
        INSERT INTO ${tableName} (${columnNames.join(", ")})
        VALUES (${placeholders})
        RETURNING *
      `;

      const result = await client.query(query, values);
      return reply.status(201).send(result.rows[0]);
    } catch (error) {
      app.log.error(`Failed to create ${tableName} record:`, error);
      return reply.status(500).send({
        error: `Failed to create ${tableName}`,
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * Update an existing record by ID
   * Body should contain columns to update
   */
  async function update(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();

    try {
      const updates = request.body;
      const columnNames = Object.keys(updates);
      const values = Object.values(updates);

      const setClause = columnNames
        .map((col, i) => `${col} = $${i + 1}`)
        .join(", ");

      const query = `
        UPDATE ${tableName}
        SET ${setClause}
        WHERE id = $${columnNames.length + 1}
        RETURNING *
      `;

      const result = await client.query(query, [...values, id]);

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: `${tableName} record not found`,
          id,
        });
      }

      return reply.send(result.rows[0]);
    } catch (error) {
      app.log.error(`Failed to update ${tableName} record:`, error);
      return reply.status(500).send({
        error: `Failed to update ${tableName}`,
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  /**
   * Delete a record by ID
   */
  async function remove(request, reply) {
    const { id } = request.params;
    const client = await app.pg.connect();

    try {
      const query = `DELETE FROM ${tableName} WHERE id = $1 RETURNING *`;
      const result = await client.query(query, [id]);

      if (result.rowCount === 0) {
        return reply.status(404).send({
          error: `${tableName} record not found`,
          id,
        });
      }

      return reply.send({
        message: `${tableName} record deleted successfully`,
        deleted: result.rows[0],
      });
    } catch (error) {
      app.log.error(`Failed to delete ${tableName} record:`, error);
      return reply.status(500).send({
        error: `Failed to delete ${tableName}`,
        message: error.message,
      });
    } finally {
      client.release();
    }
  }

  return {
    list,
    create,
    update,
    delete: remove, // 'delete' is reserved in JavaScript, but we can expose it as a property
  };
}
