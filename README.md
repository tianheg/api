# api

## TODO

- 把 data/movies.js 中的 series 条目放到 data/series.js 中
- 把 https://neodb.social/users/tianheg/ 中标记的内容放到 api 中
- add https://github.com/SkeLLLa/fastify-metrics
- read https://www.mock-server.com/

## DONE

- routes files merged into main server.js
- add page, limit, search ability
- added security measures
- refactor code structure([src](https://github.com/tianheg/api/tree/2b12cb2e3c382428a2af11761c52b9baa478a8c2))
- add test

## Problems

### Swagger UI cannot display endpoints(SOLVED)

> The bug likely occurs due to the asynchronous nature of the `import()` function used in the `app.register()` calls. When you use `import()` inside `app.register()`, it returns a promise that resolves to the module, and Fastify's `register` method might not be set up to handle promises directly in this manner. This can lead to a race condition where Fastify starts setting up routes before the Swagger plugins are fully registered and configured, resulting in the Swagger UI not being aware of any routes.

### Stream closed prematurely when using async/await(SOLVED)

https://fastify.dev/docs/latest/Reference/Routes/#async-await

server.js:

```diff
async function createRoute(path, data, opts) {
  app.get(path, { schema: opts.schema }, async (request, reply) => {
    const { page, limit, search } = request.query;
    const paginatedData = await getPaginatedData(data, search, page, limit);
-   reply.send(paginatedData);
+   return reply.send(paginatedData);
  });
}
```

### With [current code](https://github.com/tianheg/api/tree/51d185ab530c624d54e812d304a910c1f2e55376), home page title is `http://127.0.0.1:3000`, not `https://api.tianheg.org/`(SOLVED)

Explicitly set baseUrl to https://api.tianheg.org

## Refer

- https://github.com/fedeperin/potterapi
