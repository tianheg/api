import jsondata from '../data/prompts.js';

export default function (f, opts, next) {
  f.get('/prompts', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}

// TODO
// https://prompts.chat/
// 心理学 prompt https://twitter.com/daydayuuup/status/1746012683625746852
// Refer
// https://baoyu.io/blog/prompt-engineering/how-to-write-high-quality-prompt