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

function hasRuntimeContent(node) {
  return (node.type.startsWith('mdx') && node.type !== 'mdxJsxTextElement') ||
    (node.attributes ?? []).some(attribute => typeof attribute.value === 'object' && attribute.value !== null) ||
    (node.children ?? []).some(hasRuntimeContent);
}

function staticHeading(node) {
  const children = (node.children ?? []).map(staticHeading);
  // JSX is not a HAST node. Its static children can still name the section;
  // components and expressions are never executed to produce an anchor label.
  if (node.type === 'mdxJsxTextElement') {
    const tagName = ['script', 'style', 'img'].includes(node.name) ? node.name : 'span';
    const alt = node.attributes?.find(attribute => attribute.type === 'mdxJsxAttribute' && attribute.name === 'alt')?.value;
    return { type: 'element', tagName, properties: typeof alt === 'string' ? { alt } : {}, children };
  }
  return { ...node, ...(node.children ? { children } : {}) };
}

/** Accessible names stay out of heading text so TOC labels remain clean. */
export function headingAnchorProperties(heading) {
  // Astro calls this before rehypeRaw and can split inline tags across siblings.
  // Normalize the entire heading only for its name; never mutate the rendered tree.
  if (hasRuntimeContent(heading)) {
    return { className: ['heading-anchor'], ariaLabel: 'Link to this section' };
  }
  const normalized = fromHtml(toHtml(staticHeading(heading), { allowDangerousHtml: true }), { fragment: true });
  return {
    className: ['heading-anchor'],
    ariaLabel: `Link to section: ${headingText(normalized).trim()}`,
  };
}
