import { fromHtml } from 'hast-util-from-html';
import { toHtml } from 'hast-util-to-html';

function headingText(node) {
  if (node.type === 'text') return node.value;
  if (node.type === 'element') {
    if (node.tagName === 'script' || node.tagName === 'style') return '';
    if (node.tagName === 'img') return String(node.properties?.alt ?? '');
  }
  return (node.children ?? []).map(headingText).join('');
}

/** Accessible names stay out of heading text so TOC labels remain clean. */
export function headingAnchorProperties(heading) {
  // Astro calls this before rehypeRaw and can split inline tags across siblings.
  // Normalize the entire heading only for its name; never mutate the rendered tree.
  const normalized = fromHtml(toHtml(heading, { allowDangerousHtml: true }), { fragment: true });
  return {
    className: ['heading-anchor'],
    ariaLabel: `Link to section: ${headingText(normalized).trim()}`,
  };
}
