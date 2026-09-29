# Artificer adaptations

How this project bends the Artificer design system, and why. Each surviving
entry mirrors a feedback issue filed upstream — a divergence not worth filing
is not worth keeping.

## 2026-09-29 · Facelift: reading-progress top rule, Pip, block-glyph font (0.22.1)

**Reading progress.** The fixed gold → purple `.topline` moved into
`ReadingProgress.astro`. On posts (`PostLayout` passes `progress`, the
`<article>` carries `[data-progress-target]`) it is a 3px bar over a `--border`
track that fills as the article scrolls past. It reveals with `clip-path`, so
the gradient stays pinned to the viewport. Everywhere else it is the same full,
static 2px rule as before. The header stays **non-sticky**. #131 asked for
exactly that, and `.masthead` codified it. A sticky `.page-shell > header`
version was built and reverted, so the progress bar is its own fixed element
instead of riding the header.

**Header.** Same structure. It borrows `.masthead__nav`'s current-page
treatment (accent + 2px inset band) instead of an fg/secondary color swap,
which keeps "you are here" from riding on color alone. It also moves the toggle
to tokens, gives touch pointers 44px targets, and collapses the toggle to its
dot under 400px so the row fits a 320px viewport.

**Pip.** Artificer's critter, minted here: a burnished seed with a sprout,
two dot eyes and two feet (`Pip.astro`). It is the wordmark's gold full stop
that took root, since a pip is both a dot and a seed, so it is `--accent`. It
is an original 18×10 px sprite drawn in quadrant block glyphs. A first draft
used Clawd, Anthropic's Claude Code mascot, and was replaced before merge: the
mascot is Anthropic's trademark, and this is not an Anthropic site. The index
h1 sits beside Pip in a terminal-style panel (accent frame, title cut into the
top border).

**Space scene.** Every page ends, below the colophon, with a full-bleed band
(`SpaceScene.astro`): Pip under a stepped glass bell jar (`<Pip helmet />`, a
second text layer in `--fg-secondary`) adrift among seeded, build-time
dot-matrix planets (`·` `•` `●` in `--fg-disabled`) and gold `+` sparkles
(`--accent-bright`). It's static, per the no-looping-decoration rule, and
hovering it gives the same one-shot hop. It's `aria-hidden`: scenery past the
content, nothing to announce. The planets paint as `content: attr(data-art)`
rather than DOM text, because they're drawn below text contrast on purpose, and
as text axe flags every `●`.

| type | surface | what + why | upstream? |
|------|---------|------------|-----------|
| gap | font | **Block-glyph subset.** The bundled JetBrains Mono is a 229-glyph Latin subset with no U+2500–25FF (box drawing, block elements, geometric shapes), so Pip, the `●` planets, and any `├──` tree in a code block rendered in the OS fallback mono and misaligned. `src/assets/fonts/jetbrains-mono-blocks.woff2` (3.4 KB, JetBrains Mono 2.304 Regular, OFL) extends the `"JetBrains Mono"` family via `unicode-range`. It is declared once per bundled weight: a face with a different weight descriptor is never consulted. Regenerate command in `global.css`. Retire when the package's subset includes U+2500–25FF. | yes |
| extension | progress | **Reading-progress bar.** No system primitive exists. Blog-local, built only from existing tokens. | maybe |
| extension | Pip | **Block-glyph rendering recipe:** whole-pixel cells (20/15px), whole-pixel line pitch under the 1.32em glyph (26/19px), body letter/word spacing undone, and a `0.03em` same-color text stroke to close anti-alias seams. Recorded upstream in case the system ever documents ASCII/TUI art. | maybe |

**Filed upstream:** [`cameronsjo/artificer-design-system#523`](https://github.com/cameronsjo/artificer-design-system/issues/523).

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
