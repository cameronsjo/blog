/// <reference path="../.astro/types.d.ts" />

// artificer-whimsy ships no .d.ts and is a side-effect-only module that assigns
// window.Whimsy (see BaseLayout's seasonal-greeting script). Declare both so
// `astro check` stays clean.
declare module '@cameronsjo/artificer/whimsy.js';

interface Window {
  Whimsy?: {
    greeting(root?: Document | Element): void;
    greetingFor(
      date?: Date,
      opts?: { default?: string; defaultClass?: string }
    ): { season: string; text: string; classes: string[] };
    hydrate(root?: Document | Element): void;
    observe(root?: Document | Element): () => void;
  };
}
