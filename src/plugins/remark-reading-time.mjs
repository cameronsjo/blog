import getReadingTime from 'reading-time';
import { toString } from 'mdast-util-to-string';

// Remark plugin: compute reading time from the full text of the post and stash
// it on frontmatter as `minutesRead` (e.g. "2 min read"). Surfaced in the post
// route via the `remarkPluginFrontmatter` that render() returns.
export function remarkReadingTime() {
  return (tree, { data }) => {
    const text = toString(tree);
    const { text: minutesRead } = getReadingTime(text);
    data.astro.frontmatter.minutesRead = minutesRead;
  };
}
