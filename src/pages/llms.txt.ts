import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';
import { SITE_TITLE, SITE_DESCRIPTION, SITE_AUTHOR } from '../consts';
import { withBase } from '../utils';

// llms.txt — a plain-text map of the site for language models, per the
// llms.txt convention (H1 name, blockquote summary, then a linked index).
// Mirrors the draft filter used by rss.xml.js and the sitemap.
export const GET: APIRoute = async ({ site }) => {
  const posts = (await getCollection('blog', ({ data }) => !data.draft)).sort(
    (a, b) => b.data.pubDate.getTime() - a.data.pubDate.getTime(),
  );

  const lines = [
    `# ${SITE_TITLE}`,
    '',
    `> ${SITE_DESCRIPTION}`,
    '',
    `Author: ${SITE_AUTHOR}`,
    '',
    '## Posts',
    '',
    ...posts.map((post) => {
      const url = new URL(withBase(`posts/${post.id}/`), site).href;
      const date = post.data.pubDate.toISOString().slice(0, 10);
      return `- [${post.data.title}](${url}): ${post.data.description} (${date})`;
    }),
    '',
  ];

  return new Response(lines.join('\n'), {
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  });
};
