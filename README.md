# blog

Cameron Sjo's blog. Built with [Astro](https://astro.build), deployed to GitHub Pages.

## Develop

```bash
npm install      # once
npm run dev      # http://localhost:4321/blog/
npm run build    # static output to dist/
npm run preview  # serve the built site
npm run check    # type-check content + components
```

## Write

Posts live in `src/content/blog/` as Markdown or MDX. Frontmatter is
type-checked against the schema in `src/content.config.ts`:

```yaml
---
title: A title
description: One sentence for previews and RSS.
pubDate: 2026-05-29
updatedDate: 2026-06-01   # optional
draft: false              # optional, hides from listing + RSS
tags: [meta, craft]       # optional
---
```

The filename (minus extension) becomes the URL slug: `/blog/posts/<slug>`.

## Structure

| Path | Purpose |
|------|---------|
| `src/content/blog/` | Posts (Markdown / MDX) |
| `src/content.config.ts` | Collection schema (Zod) |
| `src/pages/` | Routes — index, about, posts, `rss.xml` |
| `src/layouts/` | `BaseLayout`, `PostLayout` |
| `src/components/` | Head/SEO, header, footer, post card |
| `src/styles/global.css` | Tailwind v4 + dark-first theme tokens |

## Deploy

Pushing to `main` triggers `.github/workflows/deploy.yml`
(`withastro/action` → GitHub Pages). The repo's **Settings → Pages → Source**
must be set to **GitHub Actions** once.

Custom domain later (e.g. `blog.sjo.lol`): set `site` in `astro.config.mjs` to
the domain, remove `base`, and add `public/CNAME`.

## License

[MIT](./LICENSE)
