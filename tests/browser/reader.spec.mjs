import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test.beforeEach(async ({ page }) => {
  await page.route('https://static.cloudflareinsights.com/**', (route) => route.abort());
  await page.clock.setFixedTime(new Date('2026-12-15T12:00:00Z'));
});

for (const theme of ['dark', 'light']) {
  for (const width of [320, 390, 1199, 1200, 1600]) {
    test(`${theme}, ${width}px: navigation, reading chrome and accessibility`, async ({ page }) => {
      const errors = [];
      page.on('pageerror', (error) => errors.push(error.message));
      await page.setViewportSize({ width, height: 900 });
      await page.addInitScript((mode) => {
        localStorage.setItem('artificer.theme', mode);
        window.swapAttributes = [];
        document.addEventListener('astro:after-swap', () => {
          window.swapAttributes.push([
            document.documentElement.dataset.theme,
            document.documentElement.dataset.season,
          ]);
        });
      }, theme);
      await page.goto('/blog/');
      await expect(page.locator('html')).toHaveAttribute('data-theme', theme);
      await expect(page.locator('.welcome .sploot__scarf')).toBeVisible();
      await expect(page.locator('.site-header')).toHaveCSS('position', 'static');
      await expect(page.locator('.topline')).toHaveCSS('height', '2px');
      await expectNoOverflow(page);
      await expectChangedSurfacesAccessible(page);

      // Follow a real link through Astro's client router, rather than reloading.
      const post = page.locator('.entries a.entry').first();
      const postHref = await post.getAttribute('href');
      expect(postHref).toContain('/posts/');
      await post.click();
      await expect(page).toHaveURL(new RegExp(postHref.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
      await expect(page.locator('[data-progress-target]')).toBeVisible();
      await expect(page.locator('html')).toHaveAttribute('data-season', 'winter');
      await expect(page.locator('html')).toHaveAttribute('data-theme', theme);
      expect(await page.evaluate(() => window.swapAttributes)).toContainEqual([theme, 'winter']);
      await expect(page.locator('.topline')).toHaveCSS('height', '3px');
      const links = page.locator('[data-toc-link]');
      expect(await links.count()).toBeGreaterThan(1);
      await expect(page.locator('[data-toc-link][aria-current="location"]')).toHaveCount(1);
      await expect(page.locator('[data-toc]')).toHaveCSS('border-left-width', '0px');
      await expect(page.locator('[data-toc] .eyebrow')).toBeVisible();
      if (width >= 1200) await expect(page.locator('[data-toc-walker]')).toBeVisible();
      else await expect(page.locator('[data-toc-walker]')).toBeHidden();

      for (const fraction of [0, 0.5, 1]) {
        await page.evaluate((value) => {
          const rect = document.querySelector('[data-progress-target]').getBoundingClientRect();
          window.scrollTo({ top: window.scrollY + rect.top + value * (rect.height - innerHeight), behavior: 'instant' });
        }, fraction);
        await expect.poll(() => page.locator('.topline__fill').evaluate((el) =>
          Number(el.style.getPropertyValue('--progress')))).toBeCloseTo(fraction, 1);
        await expect(page.locator('[data-toc-link][aria-current="location"]')).toHaveCount(1);
        await expect.poll(() => page.evaluate(() => {
          const links = [...document.querySelectorAll('[data-toc-link]')];
          const headings = links.map((link) => document.getElementById(link.dataset.tocLink));
          const articleEnd = document.querySelector('article').getBoundingClientRect().bottom;
          const visible = headings.filter((heading) => heading.getBoundingClientRect().top <= innerHeight / 4);
          const expected = articleEnd <= innerHeight + 1 ? headings.at(-1) : visible.at(-1) ?? headings[0];
          return document.querySelector('[data-toc-link][aria-current="location"]').dataset.tocLink === expected.id;
        })).toBe(true);
      }
      await expectNoOverflow(page);
      await expectChangedSurfacesAccessible(page);

      // Reflow while a later section is selected: the walker must realign.
      await page.setViewportSize({ width: 1280, height: 700 });
      await expect.poll(() => page.evaluate(() => {
        const current = document.querySelector('[data-toc-link][aria-current]');
        return document.querySelector('[data-toc-walker]').style.getPropertyValue('--walker-y') === `${current.parentElement.offsetTop}px`;
      })).toBe(true);

      const anchors = page.locator('.heading-anchor');
      expect(await anchors.count()).toBeGreaterThan(0);
      const anchor = anchors.first();
      // Exercise the actual tab order; programmatic focus could hide tabindex=-1.
      for (let presses = 0; presses < 100; presses++) {
        await page.keyboard.press('Tab');
        if (await anchor.evaluate((el) => el === document.activeElement)) break;
      }
      await expect(anchor).toBeFocused();
      await expect(anchor).toHaveAccessibleName(/Link to/);
      await expect(anchor).toHaveCSS('opacity', '1');

      await page.locator('.site-nav a', { hasText: 'About' }).click();
      await expect(page.locator('.topline')).not.toHaveAttribute('data-progress');
      await expect(page.locator('html')).toHaveAttribute('data-season', 'winter');
      expect(errors).toEqual([]);
    });
  }
}

test('canonical theme cycle, reduced motion, touch links, 404 and favicon', async ({ browser, request }) => {
  const context = await browser.newContext({ viewport: { width: 390, height: 844 }, hasTouch: true, reducedMotion: 'reduce', colorScheme: 'light' });
  const page = await context.newPage();
  await page.route('https://static.cloudflareinsights.com/**', (route) => route.abort());
  await page.goto('/blog/');
  const toggle = page.locator('[data-theme-toggle]');
  await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');
  for (const [stored, resolved] of [['light', 'light'], ['auto', 'light'], ['dark', 'dark']]) {
    await toggle.click();
    await expect.poll(() => page.evaluate(() => localStorage.getItem('artificer.theme'))).toBe(stored);
    await expect(page.locator('html')).toHaveAttribute('data-theme', resolved);
  }
  await page.locator('.welcome').hover();
  await expect(page.locator('.welcome .sploot')).toHaveCSS('animation-name', 'none');
  await page.locator('.entries a.entry').first().click();
  await expect(page.locator('.heading-anchor').first()).toHaveCSS('opacity', '1');
  const response = await page.goto('/blog/does-not-exist');
  expect(response.status()).toBe(404);
  await expect(page.getByRole('heading', { name: 'Page not found' })).toBeVisible();
  await expect(page.getByRole('link', { name: 'Search the blog' })).toHaveAttribute('href', '/blog/search/');
  const favicon = await request.get('/blog/favicon.svg');
  expect(favicon.status()).toBe(200);
  expect(await favicon.text()).toContain('viewBox="0 0 32 32"');
  await context.close();
});

async function expectNoOverflow(page) {
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
}

async function expectChangedSurfacesAccessible(page) {
  const results = await new AxeBuilder({ page })
    .include('.site-header').include('.sploot').include('.space')
    .include('.topline').include('.toc-rail').include('.heading-anchor').analyze();
  expect(results.violations).toEqual([]);
}
