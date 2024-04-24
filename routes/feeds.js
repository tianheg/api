import jsondata from '../data/feeds.js';

export default function (f, opts, next) {
  f.get('/feeds', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}
