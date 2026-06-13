# Artificer adaptations

How this project bends the Artificer design system, and why. Each surviving
entry mirrors a feedback issue filed upstream — a divergence not worth filing
is not worth keeping.

## 2026-06-13 · Retired the hand-subset, adopted standard consumption (0.18.0)

**Model migration.** The blog had consumed Artificer as a *hand-authored token
subset* — ~17 colours (dark + light) plus spacing/radius/easing inlined into
`global.css`'s `:root` (stamped `--art-version: "0.10.1"`), a hand-mirrored
`whimsy.css`, and 7 self-hosted woff2 in `src/fonts/`. That is by definition a
custom implementation, which the owner doctrine (ruled 2026-06-10) forbids. This
upgrade retires the *model*, not just the version: pin `@cameronsjo/artificer@0.18.0`,
consume its CSS + fonts directly via Vite, and shrink `global.css` to only the
blog-specific editorial layer stacked on top.

**Absorbed by 0.18.0 (entries deleted):**

- *Palette subset.* The 17 hand-mirrored colours (dark + `[data-theme="light"]`),
  `--radius-*`, `--s-*`, `--dur-fast`, `--ease`, `letter/word-spacing` vars, and
  the `--art-version` stamp are all now sourced from `artificer.css`'s `:root`.
  `global.css` defines none of them.
- *Theme key.* The 0.10.1 "stamp `--art-version`" no-op is moot — the package's
  `:root` carries `--art-version: "0.18.0"` and flips on the same
  `[data-theme="light"]` selector the blog's inline bootstrap already set.
- *Type-scale.* The px→rem boundary stayed a no-op (type is Tailwind utilities +
  Expressive Code); the package's `body { font-size: var(--t-body-md-size) }`
  (true 14px, #211 fixed) now applies, with headings still `clamp()`-anchored to
  the kept `html { font-size: 16px }`.
- *Self-hosted fonts.* `src/fonts/` (7 woff2) deleted; the package's bundled
  `@font-face` (`iA Writer Quattro S` + `JetBrains Mono`) provide the same
  families, Vite-hashed and emitted under the `/blog/` base.
- *Hand-mirrored whimsy.* `src/styles/whimsy.css` deleted; `artificer-whimsy.css`
  is a verified superset (same `.whimsy--brand` / `.whimsy--glacial`, plus
  `--gold` / `--vivid`).

### Surviving divergences (kept, filed upstream)

| type | surface | what + why | upstream? |
|------|---------|------------|-----------|
| mechanism | consumption | **Path B — Vite `import` from `node_modules`**, not the intro's mandated `vendor-artificer.mjs` script. The blog is a bundler-backed Astro/Vite app (the intro itself flagged it "different from the siblings"); the standard import is more idiomatic *and* strictly more upgrade-robust — a bump is `version + npm install`, and Vite re-resolves the bundled `@font-face` URLs (fonts moved `src/fonts/`→`src/assets/fonts/` between 0.12→0.18, which a vendor glob would have 404'd on) and the `/blog/` base automatically. | yes |
| divergence | editorial | **Do NOT adopt `artificer-editorial.css` (E1).** It is a *different implementation* of the same class names — `.entry` flex-stacked vs the blog's rail-grid, `.entry__excerpt` vs `.entry__desc`, sans headlines vs the blog's mono, `.reveal` with no `--i` stagger, a hand-rolled `.prose` that would fight Tailwind Typography. The blog's editorial CSS was the *source* promoted (and simplified) into the package, so the blog's richer version is itself the feedback. Kept blog-specific in `global.css`. | yes |
| gap | theme / FOUC | **Keep the blog's inline `<script is:inline>` theme bootstrap** (BaseLayout.astro), not `artificer-theme.js`. It is already keyed `'artificer.theme'`, defaults dark pre-paint (no FOUC), and **rebinds toggles on `astro:page-load`** for Astro View Transitions — which the shipped `theme.js` does not. Importing theme.js would double-bind; `theme-bootstrap.html` is a subset of the inline script. | yes |

**Filed upstream:** [`cameronsjo/artificer-design-system#236`](https://github.com/cameronsjo/artificer-design-system/issues/236)
(`feedback(blog): retire hand-subset, adopt @cameronsjo/artificer@0.18.0 standard
consumption`) — covers all three surviving divergences plus the font-path move.

**Consumption shape now:** `BaseLayout.astro` imports, in cascade order,
`@cameronsjo/artificer/artificer.css` → `.../whimsy.css` → `../styles/global.css`.
Artificer is unlayered and loads first; the blog's unlayered rules load last and
win on equal specificity (Tailwind preflight is layered → loses to both). The
wordmark carries `wordmark--stop-none` so the literal `'blog.'` text-stop isn't
doubled by the package's `.wordmark::after { content: "." }`.

**Upstream issues:** #75 is CLOSED (no action). #131 (OPEN) stays relevant — nav
primitives remain dashboard-shaped (the blog keeps its hand-rolled Header) and the
editorial divergence persists; folded into this session's feedback rather than
re-raised.

---

## 2026-05-31 · Upgrade to 0.10.1 collapsed to a provenance stamp *(superseded)*

*Superseded by the 2026-06-13 model migration above, which retired the
hand-subset this entry described. Kept for provenance.*

**Pivot:** Ran `/artificer-upgrade`. The blog consumed Artificer as a
hand-authored subset of the palette (`global.css` + `whimsy.css`), not
`artificer.css` / npm / CDN — so every production-regression boundary in the
0.7→0.10 matrix was a no-op here. The only actionable step was stamping
`--art-version: "0.10.1"`. Boundaries that were no-ops: keyword contrast (code
renders via Astro Expressive Code / Shiki, not `.tok-keyword`); px→rem type scale
(type is Tailwind + Expressive Code); `localStorage` theme key (already on
`'artificer.theme'`).
