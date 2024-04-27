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
      `${baseUrl}/prompts`,
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

/**
 * definition:
 * movies - 单集
 * series - 系列剧集，包括动漫
 * 例外，如果是一个系列，既有剧集又有剧场版电影，视为series
 */