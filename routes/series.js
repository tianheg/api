import jsondata from '../data/series.js';

export default function (f, opts, next) {
  f.get('/series', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}

