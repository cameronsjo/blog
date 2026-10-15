import { preview } from 'astro';

// Use the public API so the test runner owns the server lifetime even when
// the CLI detects an agent and starts a background daemon automatically.
const server = await preview({ server: { host: '127.0.0.1', port: 4327 } });
for (const signal of ['SIGINT', 'SIGTERM']) {
  process.once(signal, async () => {
    await server.stop();
    process.exit(0);
  });
}
