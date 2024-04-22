'use strict';

// Read the .env file.
import * as dotenv from 'dotenv';
dotenv.config();

// Require the framework
import http from 'node:http';
import Fastify from 'fastify';
import fastifyCaching from '@fastify/caching';

// Instantiate Fastify with some config
const app = Fastify({
  logger: true,
});

// plugins
app.register(import('@fastify/cors'));
app.register(
  import('@fastify/caching'),
  { privacy: fastifyCaching.privacy.PUBLIC },
  (err) => {
    if (err) throw err;
  }
);
// Register your application as a normal plugin.
app.register(import('./src/app.js'));

if (process.env.NODE_ENV === 'development') {
  const start = async () => {
    try {
      await app.listen({ port: 3000 });

      http.get('http://127.0.0.1:3000/', (res) => {
        console.log(res.headers['cache-control']);
      });
    } catch (err) {
      app.log.error(err);
      process.exit(1);
    }
  };
  start();
}

export default app;
