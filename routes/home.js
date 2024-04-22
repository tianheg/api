export default function (f, opts, next) {
  f.get('/', (request, reply) => {
    reply.send({
      intro:
        "tianheg's api homepage, include words, books, movies, series, music",
      repo: 'https://github.com/tianheg/api/, powered by Fastify(https://fastify.dev/), deployed on Vercel(https://vercel.com/)',
    });
  });

  next();
}
