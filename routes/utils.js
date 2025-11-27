import S from "fluent-json-schema";

// ============================================================================
// PAGINATION UTILITIES
// ============================================================================

/**
 * Paginates an array of data with optional search filtering
 *
 * @param {Array} data - The data to paginate
 * @param {string} searchTerm - Optional search term to filter results
 * @param {number} page - Page number (1-indexed)
 * @param {number} limit - Maximum items per page
 *
 * @returns {Object} Paginated result object with metadata
 * @throws {Error} If data is not an array
 */
export function getPaginatedData(data, searchTerm, page, limit) {
  if (!Array.isArray(data)) {
    throw new Error("Invalid data type for pagination:", typeof data);
  }

  // Ensure page and limit are valid numbers
  const pageNum = Math.max(1, parseInt(page) || 1);
  const limitNum = Math.max(1, parseInt(limit) || 10000);

  // Filter data by search term if provided
  const filteredData = searchTerm
    ? data.filter((item) => {
        const itemString = JSON.stringify(item).toLowerCase();
        return itemString.includes(searchTerm.toLowerCase());
      })
    : data;

  // Calculate pagination bounds
  const startIndex = (pageNum - 1) * limitNum;
  const endIndex = Math.min(startIndex + limitNum, filteredData.length);

  // Extract the paginated slice
  const paginatedData = filteredData.slice(startIndex, endIndex);

  // Calculate total pages
  const totalPages = Math.ceil(filteredData.length / limitNum);

  return {
    page: pageNum,
    limit: limitNum,
    total: filteredData.length,
    totalPages,
    data: paginatedData,
  };
}

/**
 * JSON Schema for pagination query parameters
 * Used for validating query strings like ?page=1&limit=10&search=term
 */
export const paginationSchema = S.object()
  .prop("page", S.integer().default(1).description("Page number (1-indexed)"))
  .prop(
    "limit",
    S.integer().default(10000).description("Maximum items per page"),
  )
  .prop("search", S.string().default("").description("Search filter term"))
  .required(["page", "limit", "search"]);

// ============================================================================
// DATABASE QUERY UTILITIES
// ============================================================================

/**
 * Executes a database query using the Fastify PostgreSQL plugin
 * Note: This method assumes `this` is the Fastify app instance
 *
 * @param {string} query - SQL query string
 * @param {Array} params - Query parameters for parameterized queries
 *
 * @returns {Promise<Array>} Array of result rows
 * @throws {Error} If query execution fails
 */
export async function runQuery(query, params) {
  const client = await this.pg.connect();

  try {
    const result = await client.query(query, params);
    return result.rows;
  } catch (error) {
    this.log.error("Database query failed:", error);
    throw error;
  } finally {
    client.release();
  }
}

