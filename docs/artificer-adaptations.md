# Artificer adaptations

How this project consumes the Artificer design system, and where it deliberately
adds or diverges. As of 2026-06-05 the blog **consumes the published package**
(`@cameronsjo/artificer@0.12.0`) rather than mirroring a hand-authored subset —
the package is the source of truth for tokens and whimsy; `package.json` is the
provenance.

## 2026-06-05 · Dropped the frozen fork, adopted the package CSS

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

## 2026-05-31 · Upgrade to 0.10.1 collapsed to a provenance stamp (superseded)

*Superseded by the 2026-06-05 package adoption above — the blog no longer mirrors
a hand-authored subset, so the upgrade-matrix no-ops below no longer apply.
Kept for history.*

**Pivot:** Ran `/artificer-upgrade`. The blog consumed Artificer as a
hand-authored subset of the palette (`src/styles/global.css` + `whimsy.css`),
not `artificer.css` / npm / CDN — so every production-regression boundary in the
0.7→0.10 matrix was a no-op here. The only actionable step was stamping
`--art-version` (since removed when the package became the source of truth).
