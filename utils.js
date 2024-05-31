/**
 * Function that paginates data based on the given page and limit.
 *
 * @param {Array} data - The array of data to be paginated.
 * @param {number} page - The current page number.
 * @param {number} limit - The limit of items per page.
 * @return {Object} An object containing paginated data, current page, limit, total data count, total pages.
 */
export function getPaginatedData(data, searchTerm, page, limit) {
  // Filter data if searchTerm is provided
  const filteredData = searchTerm
    ? data.filter((item) =>
      JSON.stringify(item).toLowerCase().includes(searchTerm.toLowerCase()),
    )
    : data;

  // Calculate pagination as before
  const startIndex = (page - 1) * limit;
  const endIndex = Math.min(startIndex + limit, filteredData.length);
  const paginatedData = filteredData.slice(startIndex, endIndex);
  const totalPages = Math.ceil(filteredData.length / limit);

  return {
    page,
    limit,
    total: filteredData.length,
    totalPages,
    data: paginatedData,
  };
}

export const paginationSchema = {
  description: 'GET data',
  tags: ['personal'],
  summary: '',
  // params: {
  //   type: 'object',
  //   properties: {
  //     id: {
  //       type: 'string',
  //       description: 'user id'
  //     }
  //   }
  // },
  querystring: {
    type: "object",
    properties: {
      page: { type: "integer", minimum: 1, default: 1 },
      limit: { type: "integer", minimum: 1, maximum: 10000, default: 1000 },
      search: { type: "string", default: "" },
    },
  },
  // response: {
  //   201: {
  //     description: 'Successful response',
  //     type: 'object',
  //     properties: {
  //       hello: { type: 'string' }
  //     }
  //   },
  //   default: {
  //     description: 'Default response',
  //     type: 'object',
  //     properties: {
  //       foo: { type: 'string' }
  //     }
  //   }
  // },
};

/**
 * A function that creates a route for the given path, utilizing pagination schema.
 *
 * @param {string} path - The path for the route.
 * @param {Array} data - The data to be paginated.
 * @param {Object} opts - The options object containing the schema.
 */
export async function createRoute(app, path, data, opts) {
  app.get(path, { schema: opts.schema }, async (request, reply) => {
    const { page, limit, search } = request.query;
    const paginatedData = await getPaginatedData(data, search, page, limit);
    return reply.send(paginatedData);
  });
}