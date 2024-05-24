# api

## TODO

- 把 data/movies.js 中的 series 条目放到 data/series.js 中
- 把 https://neodb.social/users/tianheg/ 中标记的内容放到 api 中
- add https://github.com/SkeLLLa/fastify-metrics
- add test
- read https://www.mock-server.com/

## DONE

- routes files merged into main server.js
- add page, limit, search ability
- added security measures

## Problems

### Swagger UI cannot display endpoints(SOLVED)

> The bug likely occurs due to the asynchronous nature of the `import()` function used in the `app.register()` calls. When you use `import()` inside `app.register()`, it returns a promise that resolves to the module, and Fastify's `register` method might not be set up to handle promises directly in this manner. This can lead to a race condition where Fastify starts setting up routes before the Swagger plugins are fully registered and configured, resulting in the Swagger UI not being aware of any routes.


## Refer

- https://github.com/fedeperin/potterapi
