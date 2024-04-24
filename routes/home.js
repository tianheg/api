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
      repo: 'https://github.com/tianheg/api/',
      tech: 'https://fastify.dev/',
      deploy: 'https://vercel.com/',
      routes: routes,
    });
  });

  next();
}
