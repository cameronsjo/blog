# Artificer adaptations

How this project bends the Artificer design system, and why. Each entry mirrors a
feedback issue filed upstream.

## 2026-05-31 · Upgrade to 0.10.1 collapsed to a provenance stamp

**Pivot:** Ran `/artificer-upgrade`. The blog consumes Artificer as a
hand-authored subset of the palette (`src/styles/global.css` + `whimsy.css`),
not `artificer.css` / npm / CDN — so every production-regression boundary in the
0.7→0.10 matrix was a no-op here.

| type | surface | token / rule | what + why | upstream? | lane |
|------|---------|--------------|------------|-----------|------|
| confusion | document | upgrade matrix (skill) | The matrix assumes a *real* migration (swap `artificer.css`, run px→rem, fix `localStorage` key). A hand-authored, already-value-current subset hits none of them; the only actionable step was stamping `--art-version`. | yes | 3 |
| gap | document | `--art-version` (not yet adopted) | Added `--art-version:"0.10.1"` to `:root` so the blog can answer "what am I running?" | n/a (already an upstream token) | 3 |

**Boundaries that were no-ops:** keyword contrast (blog renders code via Astro
Expressive Code / Shiki, not `.tok-keyword`); px→rem type scale (zero `--t-*-size`
overrides; type is Tailwind + Expressive Code); `localStorage` theme key (already
on the dot key `'artificer.theme'`).

**Not upstreamed / deliberately skipped:** baseline dashboard tokens
(`--urgent`, fill/on-color variants, focus-ring tokens), `--brand-purple-bright`
(no `.tok-keyword` to use it) — dead CSS for a blog. The `.theme-toggle`
touch-target nit is the blog's own pre-existing a11y issue, independent of
Artificer.
