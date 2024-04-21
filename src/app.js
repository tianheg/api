import jsondata from '../assets/data/words.js';

const getWords = async (_, reply) => {
  reply.send(jsondata);
};

const getIndex = async (_, reply) => {
  reply.send({
    intro:
      "tianheg's api homepage, include words, books, movies, series, music",
    repo: 'https://github.com/tianheg/api/, powered by Fastify(https://fastify.dev/), deployed on Vercel(https://vercel.com/)',
  });
};

async function routes(fastify, options) {
  fastify.get('/words', getWords);
  fastify.get('/', getIndex);
}

export default routes;
