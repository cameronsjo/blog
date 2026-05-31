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

// Brand palette (mirrors src/styles/global.css) as named constants so the card
// and the stylesheet share one source of truth. Fonts are left as the library
// default — the site ships woff2, which CanvasKit's FreeType backend can't
// decompress, so passing them would risk the build. The palette carries the
// brand without them.
type RGB = [number, number, number];
const GOLD: RGB = [219, 187, 111]; // --accent #dbbb6f
const OFF_WHITE: RGB = [216, 214, 209]; // --fg #e8e6e1
const INDIGO: RGB = [32, 32, 62]; // --fg light-theme ink #20203e, used as the field
const INDIGO_DEEP: RGB = [20, 20, 40];

const TITLE_SIZE = 64;
const DESCRIPTION_SIZE = 30;
const RAIL_WIDTH = 12;
const PADDING = 60;

export const { getStaticPaths, GET } = await OGImageRoute({
  param: 'slug',
  pages,
  getImageOptions: (_path, page) => ({
    title: page.title,
    description: page.description,
    bgGradient: [INDIGO, INDIGO_DEEP],
    border: { color: GOLD, width: RAIL_WIDTH, side: 'inline-start' },
    padding: PADDING,
    font: {
      title: { color: GOLD, size: TITLE_SIZE, weight: 'Bold', lineHeight: 1.15 },
      description: { color: OFF_WHITE, size: DESCRIPTION_SIZE, weight: 'Normal', lineHeight: 1.4 },
    },
  }),
});
