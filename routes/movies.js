import jsondata from '../data/movies.js';

export default function (f, opts, next) {
  f.get('/movies', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}
