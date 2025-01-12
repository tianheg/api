import S from "fluent-json-schema";

export function getPaginatedData(data, searchTerm, page, limit) {
  if (!Array.isArray(data)) {
    throw new Error("Invalid data type for pagination:", typeof data);
  }

  const filteredData = searchTerm
    ? data.filter((item) => {
        const itemString = JSON.stringify(item);
        return itemString.includes(searchTerm);
      })
    : data;

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

export const paginationSchema = S.object()
  .prop("page", S.integer().default(1))
  .prop("limit", S.integer().default(10))
  .prop("search", S.string().default(""))
  .required(["page", "limit", "search"]);

export async function runQuery(query, params) {
  const client = await this.pg.connect();

  try {
    const { rows } = await client.query(query, params);
    return rows;
  } catch (error) {
    return error;
  } finally {
    client.release();
  }
}
