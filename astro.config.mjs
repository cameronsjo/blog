// @ts-check
import { defineConfig } from 'astro/config';
// astro-expressive-code MUST precede mdx() — it registers the markdown code-block
// renderer that mdx() then inherits. Reversed, fenced blocks fall back to Shiki.
import expressiveCode from 'astro-expressive-code';
import mdx from '@astrojs/mdx';
import sitemap from '@astrojs/sitemap';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  // GitHub Pages project site. For a custom domain (e.g. blog.sjo.lol):
  // set `site` to the domain, drop `base`, and add public/CNAME.
  site: 'https://cameronsjo.github.io',
  base: '/blog',
  trailingSlash: 'ignore',
  // View Transitions auto-enable prefetch; this makes the strategy explicit.
  prefetch: {
    prefetchAll: true,
    defaultStrategy: 'hover',
  },
  integrations: [
    expressiveCode({
      // Vitesse reads as muted/editorial rather than neon-IDE — it suits the
      // broadsheet aesthetic. The frame chrome below is re-skinned to site vars.
      themes: ['vitesse-dark', 'vitesse-light'],
      // This site toggles `data-theme="dark|light"`; EC defaults to keying on
      // the theme *name*. Key on `theme.type` so EC's token themes switch in
      // lockstep with the existing toggle.
      themeCssSelector: (theme) => `[data-theme='${theme.type}']`,
      styleOverrides: {
        borderColor: 'var(--border)',
        borderRadius: 'var(--radius-md)',
        codeFontFamily: 'var(--font-mono)',
        codeFontSize: '0.85rem',
        // Static `var(--…)` values resolve in the browser, so the frame chrome
        // re-themes live on toggle while syntax tokens stay baked per EC theme.
        frames: {
          frameBoxShadowCssValue: 'none', // broadsheet = flat, no drop shadow
          editorBackground: 'var(--bg-raised)',
          terminalBackground: 'var(--bg-raised)',
          editorTabBarBackground: 'var(--bg-inactive)',
          editorActiveTabBackground: 'var(--bg-raised)',
          editorActiveTabIndicatorTopColor: 'var(--accent)',
          editorActiveTabForeground: 'var(--fg)',
          editorTabBarBorderBottomColor: 'var(--border)',
          terminalTitlebarBackground: 'var(--bg-inactive)',
          terminalTitlebarForeground: 'var(--fg-secondary)',
          terminalTitlebarBorderBottomColor: 'var(--border)',
          terminalTitlebarDotsForeground: 'var(--accent)',
        },
      },
    }),
    mdx(),
    sitemap(),
  ],
  vite: {
    plugins: [tailwindcss()],
  },
});
