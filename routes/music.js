import jsondata from '../data/music.js';

export default function (f, opts, next) {
  f.get('/music', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}
