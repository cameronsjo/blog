import type { APIRoute } from 'astro';
import { withBase } from '../utils';

// Static robots.txt. Under `base: '/blog'` this renders at /blog/robots.txt;
// the host-root /robots.txt belongs to the cameronsjo.github.io user-site repo.
// It becomes the authoritative robots if/when the blog moves to a custom domain
// (plan PR 6). Either way it points crawlers at the absolute sitemap URL.
export const GET: APIRoute = ({ site }) => {
  const sitemapURL = new URL(withBase('sitemap-index.xml'), site);
  const body = `User-agent: *
Allow: /

Sitemap: ${sitemapURL.href}
`;
  return new Response(body, {
    headers: { 'Content-Type': 'text/plain; charset=utf-8' },
  });
};
