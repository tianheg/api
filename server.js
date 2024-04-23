'use strict';

//import http from 'node:http';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import Fastify from 'fastify';
import fastifyCaching from '@fastify/caching';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Instantiate Fastify with some config
import pino from 'pino';
import pretty from 'pino-pretty';

const stream = pretty({
  translateTime: 'SYS:HH:MM:ss Z',
  messageFormat: '{levelLabel} - {pid} - url:{req.url}',
  singleLine: true,
});
const logger = pino({ level: 'info' }, stream);

const app = Fastify({ logger });

// plugins
app.register(import('@fastify/autoload'), {
  dir: join(__dirname, 'routes'),
});
app.register(
  import('@fastify/caching'),
  { privacy: fastifyCaching.privacy.NOCACHE },
  (err) => {
    if (err) throw err;
  }
);
app.register(import('@fastify/cors'));
app.register(import('@fastify/helmet'));
app.register(import('@fastify/rate-limit'), {
  max: 100,
  timeWindow: '1 minute',
});
app.register(import('@fastify/swagger'));
app.register(import('@fastify/swagger-ui'), {
  routePrefix: '/doc',
  uiConfig: {
    docExpansion: 'full',
    deepLinking: false,
  },
  uiHooks: {
    onRequest: function (request, reply, next) {
      next();
    },
    preHandler: function (request, reply, next) {
      next();
    },
  },
  staticCSP: true,
  transformStaticCSP: (header) => header,
  transformSpecification: (swaggerObject, request, reply) => {
    return swaggerObject;
  },
  transformSpecificationClone: true,
});
// app.register(import('@fastify/under-pressure'), {
//   maxEventLoopDelay: 1000,
//   maxHeapUsedBytes: 100000000,
//   maxRssBytes: 100000000,
//   maxEventLoopUtilization: 0.98,
//   message: 'Under pressure!',
//   retryAfter: 50,
// });

if (process.env.NODE_ENV === 'development') {
  const start = async () => {
    try {
      await app.listen({ port: 3000 });

      // http.get('http://127.0.0.1:3000/', (res) => {
      //   console.log(res.headers['cache-control']);
      // });
    } catch (err) {
      app.log.error(err);
      process.exit(1);
    }
  };
  start();
}

export default app;
