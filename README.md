# api

[CHANGELOG](./CHANGELOG.md)

问题：部署在Railway上，默认端口为什么是8080？需要添加PORT环境变量才能换成3000，这是为什么？

TODO:

- not public expose this API
- Use Vue.js/Nuxt.js write web site

## Ideas

如果说博客还有些想向他人展示的欲望的话，那么这个API则纯粹是为了自己纵览自己的输入而做的东西。

做UI的目的是看起来更方便，编辑啊什么的。

example:

https://github.com/avanelli/fastify-realworld-example-app/blob/main/lib/routes/users/index.js

https://github.com/fastify/fluent-json-schema

## TODO

- 把 data/movies.js 中的 series 条目放到 data/series.js 中（这是个大工程啊）
- 把 https://neodb.social/users/tianheg/ 中标记的内容放到 api 中(只剩唱片没转移了)

## DONE

- routes files merged into main server.js
- add page, limit, search ability
- added security measures
- refactor code structure([src](https://github.com/tianheg/api/tree/2b12cb2e3c382428a2af11761c52b9baa478a8c2))
- add test
- try pressure test with [Artillery](https://www.artillery.io/docs)
- json data to PostgreSQL DB

## PostgreSQL Database(by [Railway](https://railway.app/))

> Abandon Supabase because of the auto-paused free project policy

~The data will only be updated after redeployment? Maybe this is the problem of Vercel.~

Refer:

1. [PostgreSQL](https://www.postgresql.org/)

## SQLite Database

Refer:

1. https://turso.tech/

## Problems

### jsonToDb too much data timeout(SOLVED)

Use GitHub action

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
- https://github.com/fadhlimulyana20/fastify-docker-simple
- https://github.com/fastify/demo
