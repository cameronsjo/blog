---
title: Rebuilding, deliberately
description: The first version of this blog had two static site generators, six docs, and zero posts. Here's the teardown.
pubDate: 2026-05-29
tags: [meta, craft]
---

The first version of this blog was a marvel. It had two static site generators — Jekyll *and* Hugo, side by side, so I could "compare them." It had six markdown files explaining how to deploy, how to use Docker, and how successfully I had deployed. It had twenty-six generated HTML files committed straight into git, because I never wrote a `.gitignore`.

It had zero actual posts.

I'd built the workshop and never made anything in it. Classic. The infrastructure became the project, the writing stayed theoretical, and the whole thing went cold around August. Ten months later I opened it back up, looked at the dual-generator setup, and felt nothing but the urge to `rm -rf`.

So I did. New history, one generator, Astro this time. The content is type-checked now, which means a typo in a date fails the build instead of shipping quietly — exactly the kind of small, invisible correctness I like.

The build was the easy part. It always is. Now comes the tuning, and the part I kept skipping: writing the words.

This is me skipping it less.
