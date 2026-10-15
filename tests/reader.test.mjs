import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import vm from 'node:vm';
import ts from 'typescript';

// Execute the components' actual TypeScript, with only their DOM boundary
// replaced. Browser tests separately exercise Astro's bundled output.
const source = (path) => readFileSync(new URL(`../src/${path}`, import.meta.url), 'utf8');
const frontmatter = (text) => text.split(/^---$/m)[1];
const scripts = (text) => [...text.matchAll(/<script(?:\s[^>]*?)?>([\s\S]*?)<\/script>/g)].map((m) => m[1]);
function run(code, globals = {}) {
  const context = vm.createContext({ exports: {}, ...globals });
  vm.runInContext(ts.transpileModule(code, {
    compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 },
  }).outputText, context);
  return context;
}
function events() {
  const handlers = new Map();
  return {
    addEventListener(name, callback) {
      if (!handlers.has(name)) handlers.set(name, []);
      handlers.get(name).push(callback);
    },
    emit(name, event = {}) { for (const fn of handlers.get(name) ?? []) fn(event); },
  };
}
function element(initial = {}) {
  const attrs = new Map(Object.entries(initial));
  return {
    getAttribute: (name) => attrs.get(name) ?? null,
    setAttribute: (name, value) => attrs.set(name, value),
    removeAttribute: (name) => attrs.delete(name),
    style: { setProperty: (name, value) => attrs.set(name, value) },
    dataset: {},
  };
}

test('TOC preserves literal C# and heading text, and includes only h2/h3', () => {
  const headings = [
    { depth: 1, slug: 'title', text: 'Title' },
    { depth: 2, slug: 'c', text: 'C#' },
    { depth: 3, slug: 'hash', text: 'A literal #' },
    { depth: 4, slug: 'detail', text: 'Detail' },
  ];
  const result = run(`${frontmatter(source('components/TableOfContents.astro'))}\nglobalThis.result = toc;`, {
    Astro: { props: { headings } }, exports: {},
  }).result;
  assert.deepEqual(Array.from(result, (h) => h.text), ['C#', 'A literal #']);
});

test('season bootstrap covers all seasons and copies season/theme before a swap', () => {
  const [bootstrap, themeModule] = scripts(source('layouts/BaseLayout.astro'));
  for (const [month, season] of [[0, 'winter'], [1, 'winter'], [2, 'spring'], [4, 'spring'], [5, 'summer'], [7, 'summer'], [8, 'autumn'], [10, 'autumn'], [11, 'winter']]) {
    const doc = { ...events(), documentElement: element() };
    let binds = 0;
    const win = { ArtificerTheme: { bind() { binds++; } } };
    const globals = {
      document: doc, window: win,
      localStorage: { getItem: () => 'light' },
      Date: class extends Date { getMonth() { return month; } },
      require: (name) => { assert.equal(name, '@cameronsjo/artificer/theme.js'); },
    };
    run(bootstrap, globals);
    assert.equal(doc.documentElement.getAttribute('data-season'), season);
    run(themeModule, globals);
    const incoming = element();
    doc.emit('astro:before-swap', { newDocument: { documentElement: incoming } });
    assert.equal(incoming.getAttribute('data-season'), season);
    assert.equal(incoming.getAttribute('data-theme'), 'light');
    doc.emit('astro:page-load');
    assert.equal(binds, 1);
  }
});

test('progress clamps the article range, handles short articles and rebinds on navigation', () => {
  const fill = element();
  let rect = { top: 100, height: 2400, bottom: 2500 };
  let post = true;
  const doc = {
    ...events(),
    querySelector: (selector) => selector.includes('topline') ? (post ? fill : null) : {
      getBoundingClientRect: () => rect,
    },
  };
  const win = { ...events(), innerHeight: 800 };
  run(scripts(source('components/ReadingProgress.astro'))[0], {
    document: doc, window: win, requestAnimationFrame: (fn) => fn(),
  });
  const progress = () => Number(fill.getAttribute('--progress'));
  doc.emit('astro:page-load');
  assert.equal(progress(), 0);
  rect = { top: -800, height: 2400, bottom: 1600 };
  win.emit('scroll');
  assert.equal(progress(), 0.5);
  rect = { top: -2000, height: 2400, bottom: 400 };
  win.emit('scroll');
  assert.equal(progress(), 1);
  rect = { top: 500, height: 400, bottom: 900 };
  win.emit('resize');
  assert.equal(progress(), 0);
  rect = { top: 300, height: 400, bottom: 700 };
  win.emit('scroll');
  assert.equal(progress(), 1);
  post = false;
  doc.emit('astro:page-load');
  rect = { top: 0, height: 2400, bottom: 2400 };
  win.emit('scroll');
  assert.equal(progress(), 1, 'non-post navigation must release old refs');
  post = true;
  doc.emit('astro:page-load');
  assert.equal(progress(), 0);
});

test('TOC spy has exactly one current link, repositions on resize and rebinds after navigation', () => {
  let tops = [100, 1000, 2000];
  let offsets = [20, 50, 80];
  let links = tops.map((_, i) => ({
    ...element(), dataset: { tocLink: `h${i}` },
    parentElement: { get offsetTop() { return offsets[i]; } },
  }));
  const walker = element();
  let present = true;
  const toc = { querySelectorAll: () => links, querySelector: () => walker };
  const doc = {
    ...events(), querySelector: () => present ? toc : null,
    getElementById: (id) => ({ getBoundingClientRect: () => ({ top: tops[Number(id.slice(1))] }) }),
  };
  const win = { ...events(), innerHeight: 800 };
  run(scripts(source('components/TableOfContents.astro'))[0], {
    document: doc, window: win, requestAnimationFrame: (fn) => fn(),
  });
  const active = () => links.filter((link) => link.getAttribute('aria-current') === 'location');
  doc.emit('astro:page-load');
  assert.deepEqual(active(), [links[0]]);
  tops = [-1500, -500, 500];
  win.emit('scroll');
  assert.deepEqual(active(), [links[1]]);
  assert.equal(walker.getAttribute('--walker-y'), '50px');
  offsets[1] = 95;
  win.emit('resize');
  assert.equal(walker.getAttribute('--walker-y'), '95px');
  present = false;
  doc.emit('astro:page-load');
  win.emit('scroll');
  links = links.map((link) => ({ ...link, ...element(), dataset: link.dataset }));
  present = true;
  doc.emit('astro:page-load');
  assert.deepEqual(active(), [links[1]]);
});

test('pixel conversion maps all quadrants and preserves blank/odd grid rows', () => {
  const context = run(source('lib/sploot.ts'), { exports: {} });
  const { toGlyphs, POSES } = context.exports;
  const glyphs = [' ', '▘', '▝', '▀', '▖', '▌', '▞', '▛', '▗', '▚', '▐', '▜', '▄', '▙', '▟', '█'];
  for (let mask = 0; mask < 16; mask++) {
    const grid = [0, 1].map((y) => [0, 1].map((x) => mask & (1 << (y * 2 + x)) ? '#' : '.').join(''));
    assert.deepEqual(Array.from(toGlyphs(grid)), [glyphs[mask]]);
  }
  assert.deepEqual(Array.from(toGlyphs(['...', '..#', '#'])), [' ▖', '▘']);
  for (const pose of Object.values(POSES)) assert.equal(toGlyphs(pose).length, Math.ceil(pose.length / 2));
});
