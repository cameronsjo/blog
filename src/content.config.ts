import { glob } from 'astro/loaders';
import { defineCollection } from 'astro:content';
import { z } from 'astro/zod';

// Astro 5/6 Content Layer API: the glob() loader reads local Markdown/MDX and
// the Zod schema makes frontmatter type-safe — a bad `pubDate` fails the build
// instead of silently shipping. Note: entries expose `id` (the slug), not `slug`.
const blog = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/blog' }),
  // Schema is a function so we can use the `image()` helper: heroImage resolves
  // to an optimized ImageMetadata when the post stores its image under src/.
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string(),
      pubDate: z.coerce.date(),
      updatedDate: z.coerce.date().optional(),
      draft: z.boolean().default(false),
      tags: z.array(z.string()).default([]),
      heroImage: image().optional(),
    }),
});

export const collections = { blog };
