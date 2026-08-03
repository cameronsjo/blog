---
title: "36 issues, 6 minutes: why I can't stop reaching for Claude Code Workflows"
description: A fan-out triage session crystallized when Workflows earn their cost — and why the test isn't token count, it's verification.
pubDate: 2026-05-31
tags: [claude-code, workflows, tooling, ai]
---

Thirty-six open issues, each filed by a consumer against whatever version they'd vendored. Each asking, implicitly: does this gap still exist?

I could read them myself. I've done that — scrolling `gh issue view` output, six browser tabs, a growing pile of "this shipped three months ago" moments. It takes 40 minutes and leaves your context window full of noise you'll never reference again.

Or I could use a Workflow.

There's a test I've started applying to every triage: is the bottleneck *reading* or *verification*? A self-contained bug report — "here's the repro, here's the error" — is a reading task. One pass through the orchestrator is cheaper and faster than 36 agents, full stop. But a triage question that requires independently re-deriving ground truth per item — "does this gap still exist in *today's* canonical?" — that's a verification task. Every answer needs its own lookup. That's the shape Workflows were built for.

I ran 36 agents in parallel, one per issue, each verifying the gap against current source. 36/36 classified in about 6.3 minutes. Somewhere in the middle of watching the progress tree fill in, I realized I'd crossed a threshold I can't come back from.


## What I ran

Each agent had three jobs. Read the issue: `gh issue view N --json title,body,comments`. Verify against canonical: grep `src/artificer.css`, read `_palette.json`, check the CLAUDE.md decisions log, check CHANGELOG. Classify with a structured-output schema.

The schema was the difference between 36 text blobs and 36 sortable, routable records. I wanted output I could aggregate without reading every report in full. So each agent returned fields I could work with:

- `alreadyAddressed: no|partial|yes` — the question the entire triage turns on
- `recommendation: promote|dupe|wontdo|needs-human|lane-1-ratify` — routing
- `lane: lane-1|lane-3|meta` — ownership
- `related[]` — issue numbers that cluster naturally; this field did the clustering for me
- `proposedFix` — the prose evidence that matters most when the verdict field is wrong

One thing I didn't know going in: `agentType` and `schema` compose. `agent({..., agentType: 'Explore', schema: CLASSIFY})` works — the Explore agent's read-only discipline holds, and structured output is layered on top. That combination is clean and it matters, because I needed read-only agents (nothing should be writing during triage) and structured output simultaneously.

The workflow shape itself was simple: `parallel(args.map(it => () => agent(prompt(it), {label, phase, schema: CLASSIFY, agentType: 'Explore'})))`. The issue list was passed as `args` — an array of `{n, t}` pairs. No pipeline needed; every issue is independent.


## What broke

Three things, and they're worth naming.

**Two configuration directives that don't compose at the letter level.** Plan-mode says "use only Explore agents, up to three." Ultracode says "use Workflows on every substantive task." A 36-agent Workflow violates the letter of "up to three." I resolved it by reading *intent* — both directives wanted the same thing (read-only understanding, parallel thoroughness) — and building a Workflow *of* Explore agents satisfied both. But the tension was real. Rules that each make sense independently can still fail to compose when they meet. Worth noting, not smoothing over.

**Structured output leaked schema syntax into string field values.** Six agents emitted literal `<parameter name="...">` and `</proposedFix>` XML-style tags inside their JSON string values. Content was intact and readable. The structured-output layer just wasn't clean. This feels like a Workflow `StructuredOutput` quirk worth a minimal repro and a report.

**Don't trust the verdict field.** This one matters most. Three issues got `alreadyAddressed: "yes"` from the classifier, but their `addressedNote` field said the opposite — "gap persists / no guard present." Categorical verdict: wrong. Prose evidence: correct. Same agent, same turn. I classified off the prose and treated the enum as the error. The pattern generalizes: use a schema for *shape* (so you can sort, count, cluster), not for *trust*. For any high-stakes field, read the evidence.


## What I actually learned

**Token economics invert intuition.** The workflow completion notification reported 2.8M `subagent_tokens`. Summing `.message.usage` across the 37 per-agent transcripts gave something different: 98.7M total, of which 95.4M was cache reads. Actual generation was 115K tokens — that's the 36 classification records I synthesized from. Fan-out doesn't buy throughput at enormous expense. It buys a clean orchestrator context by spending cheap cache-reads. The expensive slice (output + fresh input, roughly 3.3M) stayed small. The 98.7M number sounds alarming until you remember that 96.7% of it bills at a fraction of fresh input.

**The orchestrator is the irreducible center.** Parallelism scaled the per-issue labor flawlessly. It couldn't touch the cross-cutting judgment. Two agents classified their issues as "regression" — a doc section "added in v0.9.0, then deleted in #58." But the CLAUDE.md decision log says those sections were marked *"pending PR B"* — they never landed. Same work either way, but the CHANGELOG story differs, and the framing matters. The fan-out agents didn't have that context. I did. The agents scaled the legs; the orchestrator held the spine.

That distinction — legs vs. spine — has become load-bearing for how I think about these sessions. Fan-out handles per-item labor: reading, verifying, classifying. The orchestrator handles judgment that requires holding the whole board: deduplication, sequencing, the difference between "regression" and "never shipped." You can't route the spine to a subagent. It's not a scalability problem; it's a *shape* problem.

**A schema makes output aggregatable, not trustworthy.** I knew this intellectually before this session. Now I've seen the counter-example clearly enough that it's a standing rule: the free-text evidence field from the same agent that got the enum wrong was consistently correct. The categorical field was *less* reliable than the prose. Schema gives shape; shape enables aggregation; aggregation is genuinely useful. But "the agent returned a schema-validated JSON" doesn't mean the classifications are right. For anything high-stakes — the decisions that determine what you *don't* build — read the evidence field.


## How to steal this

The test: is the bottleneck reading or verification? Self-contained bug reports? One orchestrator pass. Open triage questions that require re-deriving ground truth per item against a source that's newer than the report? That's the shape. The bottleneck isn't reading 36 issue bodies — it's independently checking 36 gaps against a canonical that consumers might not have seen.

Two things I'd do differently next time. First: add a cheap second pass over just the `alreadyAddressed: yes` and `partial` records after the main classification. Those are the error-prone verdicts — the ones most likely to have the enum and the prose disagreeing. A second verifier reading only the evidence field catches the mismatch before synthesis, rather than during. Second: give each agent a short "recent decisions" digest — three to five bullet points of cross-cutting context the orchestrator holds that isn't in the source files yet. The two "regression vs never-landed" misframes happened because the agents re-discovered something I already knew. The orchestrator's context advantage is real; don't make the agents work around it.

The thing I keep coming back to: the session produced 32 triaged-and-labeled issues with concrete `proposedFix` prose for each, and a sequenced execution plan for the four highest-value ones, in under 10 minutes of elapsed time. The Workflow didn't do the work. It multiplied the precision of the work I actually did — holding context, making judgment calls, sequencing by prevention value — by removing every part that didn't require it.

That's the threshold. Once you feel it, you can't un-feel it.
