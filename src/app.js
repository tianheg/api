import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));

const dataFilePath = `${__dirname}/words.json`;
const jsonData = JSON.parse(readFileSync(dataFilePath, 'utf-8'));

const getDataHandler = async (request, reply) => {
  reply.send(jsonData);
};

async function routes(fastify, options) {
  fastify.get('/', getDataHandler);
}

export default routes;
