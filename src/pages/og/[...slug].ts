import { OGImageRoute } from 'astro-og-canvas';
import { getCollection } from 'astro:content';
import { SITE_TITLE, SITE_DESCRIPTION } from '../../consts';

// Build-time OG share cards. One per published post (keyed by slug/id), plus a
// `default` card the rest of the site (home, about, tags) points at. Drafts are
// excluded so unpublished work never gets a shareable image.
const posts = await getCollection('blog', ({ data }) => !data.draft);

const pages: Record<string, { title: string; description: string }> = Object.fromEntries(
  posts.map((post) => [
    post.id,
    { title: post.data.title, description: post.data.description },
  ]),
);
pages.default = { title: SITE_TITLE, description: SITE_DESCRIPTION };

// Brand palette (mirrors src/styles/global.css): indigo field, burnished-gold
// rail + title. Fonts are left as the library default — the site ships woff2,
// which CanvasKit's FreeType backend can't decompress, so passing them would
// risk the build. The palette carries the brand without them.
export const { getStaticPaths, GET } = await OGImageRoute({
  param: 'slug',
  pages,
  getImageOptions: (_path, page) => ({
    title: page.title,
    description: page.description,
    bgGradient: [
      [32, 32, 62], // --fg light-theme ink, used here as an indigo field
      [20, 20, 40],
    ],
    border: { color: [219, 187, 111], width: 12, side: 'inline-start' }, // gold rail
    padding: 60,
    font: {
      title: { color: [219, 187, 111], size: 64, weight: 'Bold', lineHeight: 1.15 }, // gold
      description: { color: [216, 214, 209], size: 30, weight: 'Normal', lineHeight: 1.4 },
    },
  }),
});
