/**
 * Prefix a path with the configured `base` (e.g. "/blog"), collapsing slashes.
 * Astro does not auto-prefix `<a href>` values, so every internal link routes
 * through here to stay correct under GitHub Pages project paths.
 */
export function withBase(path = ''): string {
  const base = import.meta.env.BASE_URL.replace(/\/$/, '');
  const clean = path.replace(/^\//, '');
  return clean ? `${base}/${clean}` : `${base}/`;
}
