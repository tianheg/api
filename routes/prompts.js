import jsondata from '../data/prompts.js';

export default function (f, opts, next) {
  f.get('/prompts', (request, reply) => {
    reply.send(jsondata);
  });

  next();
}

/**
 * TODO
 * https://prompts.chat/
 * 心理学 prompt https://twitter.com/daydayuuup/status/1746012683625746852
 *
 * Refer
 * https://baoyu.io/blog/prompt-engineering/how-to-write-high-quality-prompt
 * https://www.wangdu.site/software/ai/2077.html
 * https://m.okjike.com/originalPosts/65937c9212ed2fda6838d586?s=eyJ1IjoiNTZkMDFjNGE4ZTNmZGMxMTAwMWQ4NWEzIiwiZCI6NX0%3D&amp%3Butm_source=wechat_session
 */
