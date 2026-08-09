# Artificer adaptations

How this project bends the Artificer design system, and why. Each surviving
entry mirrors a feedback issue filed upstream — a divergence not worth filing
is not worth keeping.

## 2026-08-02 · Adopted the `.colophon__spine` three-zone footer (0.22.0)

**Version bump** — `@cameronsjo/artificer` 0.21.0 → 0.22.0, which mints
`.colophon__spine` on the existing `.colophon` primitive (part of a six-site
consistency pass putting every sibling site's footer on the same three-zone
shape: optional label zone, always-present spine, optional fine-print zone).

**Footer rewrite.** `Footer.astro` now wraps `<footer class="colophon">` /
`<div class="container">` / `<div class="colophon__spine">` around the
existing three pieces of content — copyright, the `data-whimsy-greeting`
sign-off, and the RSS/GitHub links (now a `<nav class="cluster">`, the
spine's third positional slot). Zones 1 and 3 are unused; this site has no
label sections or fine print. All the Tailwind utility classes and inline
styles the old footer carried (`flex flex-col gap-2 border-t py-6 text-sm
sm:flex-row sm:items-center sm:justify-between`, the inline `border-color`/
`color`, and the sign-off's `w-fit` + inline `font-size: smaller`) are
deleted — the primitive now owns spacing, type treatment, the 44×44 touch
floor on spine links, and the mobile stack.

## 2026-08-02 · Bumped to 0.21.0

**Version bump only** — `@cameronsjo/artificer` 0.18.0 → 0.21.0 (npm sat at
0.18.1 since June; 0.19.0/0.20.0 were never published, so this crossed three
unpublished minors). `npm install`, no consumption-shape changes: still Path B
(Vite `import` from `node_modules`), still skipping `artificer-editorial.css`
and `artificer-theme.js`. `--art-version` in the built CSS confirms `"0.21.0"`.
Build is clean; all three surviving divergences below remain current — none
were absorbed by this range.

First run of `npx @cameronsjo/artificer lint "src/**/*.css"` against this repo:
3 pre-existing Hard-rule-#1 violations in `global.css` (raw `16px`/`12px`
font-sizes at L28, L222, L228 that map to `--t-body-lg-size` /
`--t-label-sm-size`), predating this bump. Not fixed here — recorded for a
follow-up pass.

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

## 2026-06-05 · Dropped the frozen fork, adopted the package CSS *(superseded)*

*Superseded by the 2026-06-13 model migration above, which carried this
adoption further (0.12.0 → 0.18.0, moved the `artificer.css`/`whimsy.css`
imports into `BaseLayout.astro`, deleted the self-hosted fonts). Kept for
history.*

**Pivot:** The blog used to mirror a hand-authored subset of the v0.6 palette in
`src/styles/global.css` (stamped `--art-version: "0.10.1"`) plus a local
`src/styles/whimsy.css` (v0.7.2). It tracked nothing. The published v0.12.0
package now ships the canonical CSS with **identical hex values** and the same
`[data-theme="light"]` switching contract, so it's a clean drop-in.

- `global.css` now `@import`s `@cameronsjo/artificer/artificer.css` then
  `@cameronsjo/artificer/whimsy.css` (after Tailwind + the typography plugin).
- The hand-authored `:root` dark/light token blocks and the `--art-version`
  stamp are deleted — the package defines every token the blog references
  (`--bg`/`--fg`/`--accent`/`--accent-bright`/`--accent-fill`/`--steel`
  /`--brand-purple`/`--attention`/`--success`/`--on-accent`/`--bg-raised`
  /`--fg-secondary`/`--fg-disabled`/`--border`/`--s-*`/`--radius-*`/`--dur-fast`
  /`--ease`), all with matching hexes.
- The local `whimsy.css` is deleted; whimsy (now v0.10.0, an upgrade from the
  local v0.7.2) comes from the package. The `BaseLayout.astro` import was
  removed.

### Blog-layer additions kept on top

These are the blog's own — not design-system concerns:

| addition | where | why |
|----------|-------|-----|
| Self-hosted `@font-face` + `@theme` font vars | `global.css` | The blog ships only the 6 font files it uses (JetBrains Mono, iA Writer Quattro S) from `src/fonts/`, and exposes them as Tailwind `font-sans`/`font-mono`. The package *also* ships these fonts (and Quattro/Quattro V variants the blog doesn't use), but keeping the blog's own `@font-face` gives font-load independence. |
| `--letter-spacing-body` / `--word-spacing-body` | (now from package) | The package defines both, so the blog no longer carries local copies. |
| `--grain-opacity` | `global.css` editorial section | An editorial choice (paper-grain intensity), not a token. |
| "frontend-design pass" — paper grain, gold→purple topline, page-load reveal, asymmetric index, prose bindings, heading anchors | `global.css` | The bespoke editorial-broadsheet craft layered on the Artificer DNA. Not in the package. |

> **Build note:** importing the full `artificer.css` pulls the package's
> `@font-face` rules (11 woff2 files) into `dist/`, but unused `@font-face`
> declarations are never *fetched* by the browser, so runtime page weight is
> unaffected — only the build artifact grows.

## 2026-06-05 · Nav stays hand-rolled — the primitives are dashboard-shaped

The published navigation primitives are **app/dashboard chrome**, not editorial
top-nav:

- `.appbar` — sticky 56px global chrome with a `border-bottom`. Wrong for a
  reading site; it would pin chrome over the prose.
- `.sidenav` — a section rail for multi-view surfaces.
- `.crumb` — breadcrumb for hierarchical app nav.
- `.tabs` — in-surface view switch; upstream explicitly says **not** for
  cross-page navigation.

The blog's `Header.astro` is a minimal editorial top nav: wordmark + three links
+ theme toggle, **non-sticky**, `py-5`. It's already token-bound and already
honors the `aria-current="page"` contract the primitives use, so there's no
accessibility gap to close by adopting them.

**Decision:** keep `Header.astro` as-is. The lightweight cross-page nav helper
that would actually fit a reading site is **pending upstream** (spec-only in the
design system's intro, not yet published) — reconcile when it ships.

## 2026-06-05 · `.wordmark` primitive double-stopped the mark

Adopting the package surfaced a collision on the wordmark. The blog's
`SITE_WORDMARK` is `'blog.'` (period in the text, and the editorial design
shimmers that stop *inside* the whimsy gradient). The package's `.wordmark`
primitive (`artificer.css`) appends its own accent stop via
`.wordmark::after { content: "."; }`, assuming a period-less mark — so the blog
rendered `blog..`.

**Fix:** suppress the primitive's stop in the blog layer
(`.wordmark::after { content: none; }` in `global.css`, after the import so it
wins the equal-specificity cascade). The period stays in the text, inside the
gradient.

**Why not adopt the primitive's stop instead** (drop the text period, let
`::after` render it): `.whimsy` sets `-webkit-text-fill-color: transparent`,
which *inherits* to `::after`, but `background-image` does **not** inherit to the
pseudo — so the accent stop would render transparent/invisible. The primitive's
`::after` stop and `.whimsy` are mutually exclusive on the same element. Filed
upstream as a primitive-contract finding.

## 2026-06-05 · Pride footer — local June variant

The footer whimsy line is `happy pride` for June, lifted from the near-static
`.whimsy--glacial` to full flowing `.whimsy` (full-spectrum rainbow, distinct
from the wordmark's `.whimsy--brand` cycle) per the upstream spec's "full
Whimsy" intent. It's **manual** (it's June now) and marked in
`Footer.astro` with a pointer to the upstream spec
(`.claude/intros/2026-06-05-1205-pride-footer-and-nav-primitives.md`). No
canonical pride/seasonal primitive exists upstream yet — swap for it when
published.

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
