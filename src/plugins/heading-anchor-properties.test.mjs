import assert from 'node:assert/strict';
import test from 'node:test';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';
import rehypeSlug from 'rehype-slug';
import rehypeAutolinkHeadings from 'rehype-autolink-headings';
import { headingAnchorProperties } from './heading-anchor-properties.mjs';

test('names the section using text from formatted headings without hiding its link', () => {
  const properties = headingAnchorProperties({
    type: 'element', tagName: 'h2', properties: { id: 'a-b' }, children: [
      { type: 'text', value: 'A & ' },
      { type: 'element', tagName: 'code', properties: {}, children: [{ type: 'text', value: 'B' }] },
    ],
  });
  assert.equal(properties.ariaLabel, 'Link to section: A & B');
  assert.equal(properties.ariaHidden, undefined);
  assert.equal(properties.tabIndex, undefined);
  assert.deepEqual(properties.className, ['heading-anchor']);
});

test('normalizes raw HTML without speaking its tags or hidden script text', () => {
  const properties = headingAnchorProperties({ type: 'element', tagName: 'h2', children: [
    { type: 'text', value: 'Raw ' },
    { type: 'raw', value: '<span>markup &amp; text</span><script>hidden</script>' },
  ] });
  assert.equal(properties.ariaLabel, 'Link to section: Raw markup & text');
});

test('includes image alternatives in both Markdown and raw HTML headings', () => {
  const properties = headingAnchorProperties({ type: 'element', tagName: 'h2', children: [
    { type: 'text', value: 'Image ' },
    { type: 'element', tagName: 'img', properties: { alt: 'diagram' }, children: [] },
    { type: 'raw', value: '<img alt=" &amp; chart" src="chart.png">' },
  ] });
  assert.equal(properties.ariaLabel, 'Link to section: Image diagram & chart');
});

test('names headings through Astro’s actual Markdown pipeline, including split raw tags', async () => {
  // Resolve the Markdown engine from Astro's own declared dependency tree.
  const astroRequire = createRequire(import.meta.resolve('astro/package.json'));
  const { createMarkdownProcessor } = await import(pathToFileURL(astroRequire.resolve('@astrojs/markdown-remark')).href);
  const processor = await createMarkdownProcessor({
    syntaxHighlight: false,
    rehypePlugins: [rehypeSlug, [rehypeAutolinkHeadings, {
      behavior: 'append', properties: headingAnchorProperties, content: [],
    }]],
  });
  const result = await processor.render('## Raw <span>markup &amp; text</span><script>hidden</script>\n\n## Image ![diagram](diagram.png)');
  assert.match(result.code, /aria-label="Link to section: Raw markup (?:&#x26;|&amp;) text"/);
  assert.match(result.code, /aria-label="Link to section: Image diagram"/);
  assert.doesNotMatch(result.code, /aria-label="[^"]*hidden/);
  assert.doesNotMatch(result.code, /aria-hidden|tabindex="-1"/);
});
