import jsondata from '../data/books.js';

export default function (f, opts, next) {
  f.get('/books', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}
