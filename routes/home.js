export default function (f, opts, next) {
  f.get('/', (request, reply) => {
    const protocol = process.env.NODE_ENV === 'development' ? 'http' : 'https';
    const baseUrl = `${protocol}://${request.headers.host}`;
    const routes = [
      `${baseUrl}/words`,
      `${baseUrl}/books`,
      `${baseUrl}/movies`,
      `${baseUrl}/series`,
      `${baseUrl}/music`,
      `${baseUrl}/feeds`,
    ];

    reply.send({
      intro: "tianheg's api homepage",
      repo: 'https://github.com/tianheg/api/, powered by Fastify(https://fastify.dev/), deployed on Vercel(https://vercel.com/)',
      routes: routes,
    });
  });

  next();
}
