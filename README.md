# blog

Cameron Sjo's blog. Built with [Astro](https://astro.build), deployed to GitHub Pages.

## Features

- **View Transitions** + hover prefetch — SPA-style navigation, no full reloads
- **Sticky header** with a **reading-progress bar** — on posts, the gold → purple
  top rule fills as you read the article
- **Clawd** — the index opens on a Claude Code welcome-box homage, and every
  page ends with Clawd in a space helmet, adrift among dot-matrix planets (a
  nod to claude.dev). All of it is text: the same block characters the
  terminal draws him with. Hover him.
- **Expressive Code** — fenced blocks get a framed, copyable, titled treatment
- **Tags** (`/tags`, `/tags/<tag>`), a paginated **archive** (`/archive`), and
  **TOC** + heading anchors + reading time on posts
- **Static search** via [Pagefind](https://pagefind.app) (`/search`) — indexed at
  build, self-hosted, no third-party calls
- **SEO**: JSON-LD, build-time OG cards, `robots.txt`, `llms.txt`, sitemap with
  per-post `lastmod`
- **Privacy-friendly analytics** — Cloudflare Web Analytics beacon (cookieless)

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
draft: false              # optional, hides from listing + RSS + sitemap
tags: [meta, craft]       # optional, linked tag pages
heroImage: ./hero.png     # optional, stored under src/ so it's optimized
---
```

The filename (minus extension) becomes the URL slug: `/blog/posts/<slug>`.
Store post images under `src/` (not `public/`) so `<Image>` optimizes them.

## Structure

| Path | Purpose |
|------|---------|
| `src/content/blog/` | Posts (Markdown / MDX) |
| `src/content.config.ts` | Collection schema (Zod, incl. `heroImage`) |
| `src/pages/` | Routes — index, about, posts, tags, archive, search, `rss.xml`, `robots.txt`, `llms.txt`, `og/` |
| `src/layouts/` | `BaseLayout`, `PostLayout` |
| `src/components/` | Head/SEO, header, reading progress, footer, post card, table of contents, `Clawd`, `SpaceScene` |
| `src/plugins/` | `remark-reading-time` (frontmatter `minutesRead`) |
| `src/styles/global.css` | Tailwind v4 + [Artificer](https://github.com/cameronsjo) design tokens |
| `src/assets/fonts/` | 3.4 KB JetBrains Mono subset: box drawing, block elements, geometric shapes (U+2500–25FF), missing from the package's font |

Styling follows the Artificer design system — dark-default with a paper light
mode (toggle in the header, persisted to `localStorage`), mono headlines over a
humanist-sans body, gold accent. Post titles are JetBrains Mono; body is iA
Writer Quattro S.

The `blog.` wordmark carries the Artificer `ultrathink` shimmer (brand-palette
gradient, flowing). It honors `prefers-reduced-motion` — the flow stops, the
burnished gradient stays.

## Deploy

Pushing to `main` triggers `.github/workflows/deploy.yml`
(`withastro/action` → GitHub Pages). The repo's **Settings → Pages → Source**
must be set to **GitHub Actions** once.

Custom domain later (e.g. `blog.sjo.lol`): set `site` in `astro.config.mjs` to
the domain, remove `base`, and add `public/CNAME`.

### Analytics

Cloudflare Web Analytics uses a cookieless beacon, hardcoded in
`BaseLayout.astro` (`CF_BEACON_TOKEN`). The token is public/write-only. Because
CF Web Analytics aggregates **by hostname**, one CF site/token for
`cameronsjo.github.io` covers this blog, the root site, and
`/agentic-harnesses` — the same token is reused across all three repos and the
stats are filterable by path.

## License

[MIT](./LICENSE)
