# API Documentation

## Changelog

### 2024-10-13
- Changed routes structure ([1db5c68](https://github.com/tianheg/api/commit/1db5c68))

### 2024-10-08
- Organized plugins and routes ([76a64c9](https://github.com/tianheg/api/commit/76a64c9))

### 2024-08-18
- Migrated from Supabase to Railway, added backup ([bbb80ee](https://github.com/tianheg/api/commit/bbb80ee))

### 2024-06-28
- Added authentication ([0e1c52e](https://github.com/tianheg/api/commit/0e1c52e))
- Added frontend/Next.js ([1f86af3](https://github.com/tianheg/api/commit/1f86af3))

### 2024-06-24
- Switched to PostgreSQL (Supabase) ([7deb59c](https://github.com/tianheg/api/commit/7deb59c))

### 2024-05-27
- Added tests ([542a835](https://github.com/tianheg/api/commit/542a835))

### 2024-04-28
- Added search functionality ([42abefa](https://github.com/tianheg/api/commit/42abefa))

### 2024-04-21
- Migrated to Fastify ([2264677](https://github.com/tianheg/api/commit/2264677))

### 2024-04-01
- Initial commit ([1bbdaa9](https://github.com/tianheg/api/commit/1bbdaa9))

---

## Deployment Issue

When deploying on Railway, the default port is 8080. To switch to port 3000, you need to set the `PORT` environment variable. This behavior is due to Railway's default configuration.

---

## Ideas

This API is designed for personal use to manage and view data inputs. The UI aims to make editing and viewing more convenient.

Example references:
- [Fastify Realworld Example App](https://github.com/avanelli/fastify-realworld-example-app/blob/main/lib/routes/users/index.js)
- [Fluent JSON Schema](https://github.com/fastify/fluent-json-schema)

---

## TODO

- Move `series` entries from `data/movies.js` to `data/series.js` (a large task).
- Transfer marked content from [NeoDB](https://neodb.social/users/tianheg/) to the API (only records remain).

---

## DONE

- Merged route files into `server.js`.
- Added pagination, limit, and search capabilities.
- Implemented security measures.
- Refactored code structure ([source](https://github.com/tianheg/api/tree/2b12cb2e3c382428a2af11761c52b9baa478a8c2)).
- Added tests.
- Conducted pressure tests with [Artillery](https://www.artillery.io/docs).
- Migrated JSON data to PostgreSQL DB.

---

## Database

### PostgreSQL (via Railway)

Supabase was abandoned due to its auto-paused free project policy. Data updates occur only after redeployment, possibly due to Vercel's behavior.

References:
- [PostgreSQL](https://www.postgresql.org/)

### SQLite

References:
- [Turso](https://turso.tech/)

---

## Problems & Solutions

### Timeout in `jsonToDb` (SOLVED)

Solution: Use GitHub Actions.

### Swagger UI Endpoint Display Issue (SOLVED)

Cause: Asynchronous `import()` in `app.register()` caused a race condition.

### Stream Closed Prematurely (SOLVED)

Reference: [Fastify Async/Await](https://fastify.dev/docs/latest/Reference/Routes/#async-await)

Code fix:
```diff
async function createRoute(path, data, opts) {
  app.get(path, { schema: opts.schema }, async (request, reply) => {
    const { page, limit, search } = request.query;
-   reply.send(paginatedData);
+   return reply.send(paginatedData);
  });
}
```

### Incorrect Home Page Title (SOLVED)

Solution: Explicitly set `baseUrl` to `https://api.tianheg.org`.

---

## Security Issues

1. (Solved)**Magic Links Storage**: Currently stored in memory, which may cause DoS attacks and data loss on restart. Use Redis or a database.
2. (Solved)**Rate Limiting**: Add rate-limiting middleware to authentication endpoints.
3. **CSRF Protection**: Add CSRF protection for state-changing POST requests.
4. **Backup File Access**: Ensure SQL backup files are not publicly accessible.
5. **Error Information**: Simplify error responses to avoid exposing internal details.
6. **CORS Policy**: Set a strict CORS policy to limit API call origins.
7. **Environment Variables**: Ensure sensitive variables like `JWT_SECRET` are strong and well-managed.

---

## Authentication API

The API uses passwordless authentication with magic links.

### Endpoints

- `POST /auth/magic-link`
  - Request: `{ "email": "user@example.com" }`
  - Response: `{ "success": true, "message": "Magic link sent to your email" }`

- `POST /auth/verify`
  - Request: `{ "token": "your-token-here" }`
  - Response: `{ "token": "jwt-token", "user": { "email": "user@example.com" } }`

- `GET /auth/me`
  - Headers: `Authorization: Bearer your-jwt-token`
  - Response: `{ "user": { "email": "user@example.com" } }`

---

## References

- [PotterAPI](https://github.com/fedeperin/potterapi)
- [Fastify Docker Simple](https://github.com/fadhlimulyana20/fastify-docker-simple)
- [Fastify Demo](https://github.com/fastify/demo)
