import jsondata from '../data/words.js';

export default function (f, opts, next) {
  f.get('/words', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}
