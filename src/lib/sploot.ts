// Sploot's sprites, as pixel grids: the one source of truth. `#` is a pixel,
// anything else is empty. Sploot.astro turns each grid into quadrant block
// glyphs (2×2 px per character) at build time; the favicon and the GitHub
// profile card draw from the same shapes.
//
// Quadrant pixels render tall (about 0.3 × 0.65 em), so a grid reads about
// twice as wide as it looks here. Long-and-low suits a corgi: keep the body
// ~3× longer than tall, the ears wide-based triangles, and the legs one row.

export type Pose = 'stand' | 'droopy' | 'sleep' | 'sniff' | 'mini';

export const POSES: Record<Pose, string[]> = {
  // Ears up, fox snout, eye, long loaf, fluffy rump, four stubby legs.
  stand: [
    '....................#...#.....',
    '...................###.###....',
    '...................#######....',
    '.####################.######..',
    '##############################',
    '##########################....',
    '.#######################......',
    '...##..##..........##..##.....',
  ],
  // Ears flopped forward, a little lower in the shoulders.
  droopy: [
    '..............................',
    '..............................',
    '....................##..##....',
    '...................#######....',
    '.####################.######..',
    '##############################',
    '#########################.....',
    '...##..##..........##..##.....',
  ],
  // The namesake: belly down, eyes shut, back legs stretched out behind.
  sleep: [
    '..............................',
    '..............................',
    '....................#...#.....',
    '...................###.###....',
    '...########################...',
    '..##########################..',
    '..#########################...',
    '############################..',
  ],
  // Nose down: the standing body with the head lowered two rows, tail up.
  sniff: [
    '..............................',
    '..............................',
    '.##.................#...#.....',
    '.#####################.###....',
    '##########################....',
    '#####################.######..',
    '.#############################',
    '...##..##...........##..##....',
  ],
  // Two text rows, for the table-of-contents walker.
  mini: [
    '...........#.#..',
    '..........#####.',
    '.###########.###',
    '..#..#.....#..#.',
  ],
};

// Winter scarf for `stand`: a band around the neck, the end flying back over
// the shoulders. Drawn as its own layer so it can take another color.
export const SCARF: string[] = [
  '..............................',
  '..............................',
  '............#######...........',
  '..................###.........',
  '..................###.........',
  '..................###.........',
  '..............................',
  '..............................',
];

const GLYPH = [' ', '▘', '▝', '▀', '▖', '▌', '▞', '▛', '▗', '▚', '▐', '▜', '▄', '▙', '▟', '█'];

// Pixel grid → rows of quadrant block glyphs. Trailing blanks are trimmed; an
// all-blank row becomes a single space, because HTML drops a newline right
// after <pre> and an empty first row would shift the whole sprite up.
export function toGlyphs(grid: string[]): string[] {
  const at = (x: number, y: number) => (grid[y]?.[x] === '#' ? 1 : 0);
  const width = Math.max(...grid.map((row) => row.length));
  const rows: string[] = [];
  for (let y = 0; y < grid.length; y += 2) {
    let line = '';
    for (let x = 0; x < width; x += 2) {
      line += GLYPH[at(x, y) | (at(x + 1, y) << 1) | (at(x, y + 1) << 2) | (at(x + 1, y + 1) << 3)];
    }
    rows.push(line.trimEnd() || ' ');
  }
  return rows;
}
