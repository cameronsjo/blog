# Finish the Sploot facelift

Status: implementation and verification complete. External delivery is recorded
in the chief-of-staff report.

Cameron approved the chief-of-staff Phase 1 plan through `go.md`: finish
blog #13, preserving main's canonical theme, hairline TOC and accessible
heading anchors. Codex must leave the PR open and ready; merging and
deployment are excluded.

- [x] Fetch main and create the prescribed detached PR worktree.
- [x] Resolve the four conflicts without reverting dependency/security fixes.
- [x] Preserve literal trailing `#` in headings and carry `data-season` through
      Astro swaps alongside `data-theme`.
- [x] Correct the README's sticky-header claim.
- [x] Add unit regressions for TOC text, season lifecycle, progress, scroll-spy
      and glyph conversion; prove each detects a deliberate implementation break.
- [x] Finish the production-build browser matrix and scoped accessibility checks.
- [x] Review the net diff independently and fix supported findings.
- [x] Run affected final checks.
Delivery: after the implementation commit, Codex will push the feature ref,
update its PR body, mark it ready and watch CI for at most 15 minutes.
The chief-of-staff `report.md` records the final external delivery state.

Codex keeps main's three-mode Artificer toggle and ruled/eyebrow TOC while
retaining the existing PR's non-sticky header, current-page band, progress
bar, Sploot scenes, 404, favicon and sticky wide-screen TOC rail. No upstream
design-system adoption or new visual direction is included.

Verification commands: `npm ci`, `npm test`, `npm run check`,
`npm run build`, `npm run test:browser`, and `git diff --check`.
Browser coverage targets dark/light at 320/390/1199/1200/1600px, actual
client navigation, theme/season carry-over, progress, TOC reflow, keyboard
and touch permalinks, reduced motion, 404 and favicon. Axe is scoped to
the changed surfaces; it does not certify unchanged syntax highlighting.

Review: a fresh read-only Codex reviewer found that the browser command needed
to build on a clean checkout. The command now builds first, and README documents
Chromium setup and the font-fetch boundary. The Node engine floor now matches
Astro 7.2.9 (22.12). The reviewer rechecked these changes and the scoped inline-code
wrap correction with no remaining supported findings.

Results: npm ci, npm test (10 tests), npm run check (zero errors/warnings/hints),
and npm run test:browser (fresh 17-page build plus 11 Chromium tests) all exit 0.
Six staged implementation breaks each exited 1: literal-# stripping, missing
season carry-over, progress stuck at zero, missing current TOC link, a quadrant
bit error, and disabled inline-code wrapping. Each source was restored before
the final checks.

Next action: deliver the feature ref and ready PR; keep merge/deployment excluded.
