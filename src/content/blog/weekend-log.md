---
title: "Nine workstreams, one weekend: a log"
description: A keyless auth hole, four guards that failed open, a database argued into existence — and a headline number that turned out to be its own lesson.
pubDate: 2026-08-02
tags: [homelab, security]
---

Friday night through Sunday night: 281 commits landed on default branches across 22 repositories, behind 98 merged pull requests. I didn't set out to do that. I set out to fix one thing on Friday, and the weekend kept handing me the next thing.

Those numbers took three attempts to get right, which turns out to be the most on-theme thing in this post. More on that at the end.

So this is a log rather than an essay. I want the sequence written down while I still remember why each decision looked reasonable at the time, because a fair amount of what follows is me finding out that something I'd already built wasn't doing anything.

## Friday: the slate

Friday was `forgectl`, my own CLI for driving forge work, and it was a slate day. Eighteen PRs, mostly unglamorous: three-state git status so a directory that isn't a repository stops reporting as clean, `~` expansion in config directory keys, a docs server that now rejects cross-site requests and ships a Content-Security-Policy, the pinned Go toolchain moved 1.25 → 1.26.

Two are worth naming. The first is a hole in the clean-room review path. `forgectl` can review a pull request in a quarantined checkout: strip the instruction files, strip the tool registrations, then let an agent read the diff without the diff being able to talk back. It stripped `CLAUDE.md` and friends. It did not strip `.mcp.json`, which is a code-execution carrier, because an MCP server registration *is* a command line. A PR that adds one gets it executed by the reviewer. Fixed alongside the Codex tool-registration equivalent, plus case-folding the pattern rule, because `Claude.md` on a case-insensitive filesystem is the same file and was not the same match.

The second is ADR-0008, which I marked Accepted on Saturday: every verb must be drivable without a TTY. That sounds like an ergonomics rule. It's a security rule. A command that only works interactively is a command nobody can test in CI, which means its guards get asserted by hand, which means they get asserted once.

In parallel, `cadence-hooks` — the guardrail layer sitting in front of my shell — took eleven PRs of pure parsing work. All of it the same shape. The guard reads a command, decides what it is, and permits or blocks; every bug is a way to make a command look like something it isn't.

- The guard walked `git push` flags one at a time, so `git -c x=y push` and `git push -uf origin main` both hid the remote from it.
- A boolean `--long` flag was swallowing the `--hostname` that followed it in `gh api`, so a command aimed at a different GitHub host read as aimed at the default one.
- `$'...'` opens on an *odd* run of backslashes. The quote scanner didn't model that, so a malformed-looking quote could hide a repository delete.
- `env`, `sudo`, `nice`, `xargs`, `find -exec` each bury the real command a layer deeper, and the peel wasn't applied at every position where a command can appear.
- Executable verbs weren't case-folded.

None of these were exploited. All of them were found by attacking the guard rather than reading it, which turns out to be the theme of the entire weekend.

`chronicle`, the tool that ingests my session transcripts, got its redaction moved from a post-pass to on-ingest. Scrubbing secrets *after* they land in the database means they landed in the database. It also got a genuinely stupid bug fixed: the backup script checked that a Keychain item exists. A Keychain item can exist and be empty. The check passed, the value was blank, and the encrypted offsite archive had nothing behind it.

## Saturday: coming home

Saturday I brought Hermes home.

Hermes is my personal agent, and it had been running on an Azure VM since spring, which cost money and put my session data somewhere I don't control. It now runs on Unraid in a container as uid 10000 from PID 1, `cap_drop: ALL` with nothing added back, `no-new-privileges`, one bind mount, and a default-deny egress allowlist. The isolation suite passed 41 of 41 that day, up from 39 on Friday. Azure compute is torn down.

Then on Sunday I read my own documentation and found it lying.

Both `CLAUDE.md` and `security.md` said untrusted code goes to Cloudflare Workers — V8 isolates, "never on the VM directly." I measured it instead of believing it. A code-execution block reports hostname `hermes`, uid 10000, and `code_execution_tool.py` shells out via `subprocess`. Hermes has no external-sandbox hook anywhere in its source: no `sandbox_url`, no `remote_sandbox`, nothing that would redirect execution to an HTTP endpoint. The Cloudflare worker was deployed and healthy, returning 405 on GET and 401 on an unauthenticated POST, and it had never been wired in. It was also unreachable from the container, since `workers.dev` isn't on the egress allowlist.

The container was doing the containing the whole time, and doing it on purpose. Its compose file opens with the line "the agent is prompt-injectable by design. Every control below assumes the agent itself is hostile," and there is no `ports:` stanza anywhere, so inbound is closed by the absence of a publish rather than by a rule someone has to maintain. None of that was luck. My documentation just credited a control that did not exist while the one actually doing the work went unnamed. This one has a sibling that turned up eleven times over the weekend, across network controls, tamper-detection assertions, credential handling and ad-hoc diagnosis: a check whose failure mode and success mode produce the same observable. The credited-fiction version is rarer — I have it written down twice. Eleven of the broader shape was enough to make it a named skill by Sunday night.

Also Saturday, and much more pleasant: `homelan` collapsed 33 `ts-*` DNS records into one name everywhere. My domain now resolves identically on the LAN and on the tailnet, so a certificate warning on one of those names has become diagnostic. It means you're off the tailnet. I also found a 13-day key expiry fuse burning on the NAS that nobody had noticed. Tagging it `tag:infra` was half the fix and I initially wrote down that it was the whole one: tagging does not clear an expiry already set, and the node read the new tag and its old 2026-08-14 date at the same time. Disabling the expiry was a separate step.

And eight fixes to my Dreo Homebridge plugin, because my office fan had started lying about whether it was on. The plugin slept 500 ms after sending a power command and then assumed success. It now waits for the device's own report and surfaces rejected commands instead of swallowing them.

## Sunday morning: the gateway answered 200

Sunday was the big one, and it opened with a number I did not enjoy.

My MCP gateway, the thing that federates every tool my agents can call, answered HTTP 200 to unauthenticated requests. It had done so for its entire history. Fifty-seven tools exposed, including `arr_add_series` and `vault_create_note`.

The cause is two schema defaults, unchanged from v1.0.1 through v1.4.1:

| Field | Default | The schema's own words |
|---|---|---|
| `mode` | `optional` | "allows requests without an API key" |
| `location` | `authorization` + `Bearer ` | where the key is read from |

My config set `keys:` and inherited both. Measured live before I touched anything:

```text
no auth header          -> 200, 57 tools
wrong x-api-key         -> 200
bogus Authorization     -> 401
```

That third line is why this survived years and a prior security review. A bogus *Bearer* token correctly 401s, so every casual probe of "is this port protected?" came back reassuring. A config review cannot see a default that is wrong. The wrongness lives in the schema, not the file, and the file looks complete.

Closing it took seven phases and fifteen PRs. Along the way, four separate protective mechanisms turned out to pass while protecting nothing, and three of the four had been written that same day by the session hunting the first one.

### The validator passed the exact vulnerable config

I wrote it specifically to stop the auth fix from regressing. It checked schema conformance, name uniqueness, and unrendered secrets, and it returned `OK`, exit 0, on an `apiKey` block containing only `keys:` — byte-for-byte the shape that had been serving unauthenticated traffic.

`mode` is optional *in the schema*, so schema validation structurally cannot catch its absence. The validator's own docstring claimed three gates "each of which has produced a real outage or a real security hole." None of the three was the security property.

### Then it passed a route with no auth at all

After I fixed it to assert "every apiKey is strict," I attacked it again. A config with one correctly-hardened listener plus a second listener serving MCP tools with no `apiKey` block whatsoever passed cleanly, because every apiKey it *did* contain was strict.

"Is every credential strong?" and "does every door have a lock?" are different questions. Adding a listener is a one-line diff.

### The guard was one restructure from going blind

The check walked a single hard-coded path: `binds[].listeners[].routes[].policies.apiKey`. The v1.4.1 schema permits `apiKey` at seven attachment points, and `binds` is deprecated in favor of `gateways` + `routes`, a migration I needed anyway for the provider catalog. Had I not made the guard shape-agnostic first, it would have gone silently blind at exactly the moment the config most needed checking.

The test suite had the same disease, in the more dangerous direction. Its mutation helper walked `cfg["binds"]`, so against a gateways-shaped config it mutated nothing and emitted the config unchanged. Every "this vulnerable variant must be rejected" case would have passed for the wrong reason, and passing is what I'd have seen.

### The ipAllowList blocked everything and looked correct

The plan called for a Traefik `ipAllowList` as the compensating control after dropping Authelia from the inference route. I shipped it and tested from a LAN address: 403. Exactly what a working allowlist looks like.

The tailnet address, which was *in* the allowlist, also returned 403.

Unraid runs Docker's userland proxy. `docker-proxy` owns `:80`/`:443` and re-originates every inbound connection, so Traefik sees the bridge gateway `172.22.0.1` as the client for all external traffic, and `sourceRange` can only match that. The middleware allows everything or blocks everything. No `ipStrategy` saves it either, because Traefik is the first proxy and there's no upstream `X-Forwarded-For` to read. My inference hostname was fully unreachable between two commits, and testing only the leg that was supposed to be blocked would have shipped a control that denies all traffic.

### Then I took it down myself, with a comment

One PR moved the admin port to loopback and re-homed the admin UI. The commit added a helpful YAML comment showing how to reach `/config_dump` afterward:

```yaml
#   PID=$(docker inspect -f '{{.State.Pid}}' agentgateway)
#   nsenter -t $PID -n curl -s http://localhost:15000/config_dump
```

From the v1.4.1 release notes: *"Environment expansion now happens before configuration parsing, allowing variables in fields…"* Expansion therefore operates on raw text and has no concept of a YAML comment. It tried to resolve `PID` from the environment, failed, and refused to start.

Three restarts, from a comment. Preflight passed and 33 tests passed throughout, because nothing in the validation path performs env expansion — only the running binary does. Five minutes of downtime, and a category of check I hadn't been running at all: every other gate asserts something about the config's content, and this one is a transformation applied before content exists.

What shipped by the end: v1.0.1 → v1.4.1 direct, which also remediates `GHSA-mvgg-jvj2-4frq` (CVSS 8.1). `mode: strict` with an explicit `location` on both listeners. Per-consumer keys. A real provider catalog with Azure AI Foundry, Anthropic, and OpenRouter behind `fast`/`cheap`/`smart` virtual models, each pairing two different providers. Request *and* token rate limits, the latter because a request limiter can't see a handful of very expensive long-context calls.

The verification number I'm keeping is that a 150-request burst returned 123×400 and 27×429. That proves the mechanism engaged, not merely that the config parsed.

One more thing from that session, filed under how did this go unnoticed. The repository's `.githooks/pre-push` had been inert. `core.hooksPath` pointed at a stale second clone whose hooks directory held only `.sample` files, so every git hook in the repo was silently doing nothing, including a healthcheck guard I'd written *after* a two-week degradation that guard existed to prevent.

## Sunday afternoon: one primitive, six sites

A palate cleanser. I cut Artificer, my design system, from 0.21.0 to 0.22.1, minting `.colophon__spine` (a three-zone footer primitive) and `.btn--link`, which styles a `<button>` like a footer link so the theme toggle stops needing a special case.

Then I rolled it across every site that consumes it: this blog, my personal site, and four others. Seven footers, since one site has two, rebuilt onto a single primitive in an afternoon.

The part that mattered more than the primitive is that three of those sites were carrying hand-forked copies of Artificer. They're on provenance-tracked vendoring now — a recorded command with a recorded source version, and a note in the tree marking the result generated rather than hand-editable. Exact version pins, not caret ranges. A design system that six consumers have each locally modified is six design systems.

## Sunday, both ends: arguing a database into existence

I've told this as a clean arc and it wasn't one. This piece bookends the day rather than closing it: the design and both review passes happened Sunday morning, between 10:05 and 11:05, *before* the gateway work started at 11:48. Only the deploy landed in the evening, and even that wasn't last — the Artificer rollout merged after it. A log that reads in tidy order is a log that has been tidied.

The work was Tier 3 of my estate plan: a Postgres instance for `chronicle`, tailnet-bound and TLS-only, with the requirement stated behaviorally. A plaintext connection must be refused.

Three decisions, each against a live alternative.

TLS *on top of* the tailnet bind rather than instead of it. A bind address answers who can open the socket, `pg_hba` answers who may authenticate, and neither answers what happens to the bytes once someone is already on the tailnet.

Tailscale-issued certificates rather than a private CA, so the laptops get `sslmode=verify-full` with no private root to distribute and later rotate on every machine. The cost is a 90-day lifetime, which is one re-runnable script.

Native Postgres TLS rather than terminating at Traefik. Postgres doesn't speak TLS-on-connect at all: the client opens plaintext, sends `SSLRequest`, and only then upgrades. No TCP router can terminate that.

`pg_hba.conf` is where the requirement becomes testable, and it has a trap in it. `host` matches encrypted *and* unencrypted connections, so `ssl=on` sitting next to a `host` line is true and useless. Every TCP path here is `hostssl`.

Then the reviews found things, and then the first real deploy found more.

A red-team pass caught that the data directory was going to live inside a path my GitOps engine rewrites on every deploy, with PGDATA and the TLS key both sitting inside a rename-aside / rename-in / `RemoveAll` swap. The same pass caught that the healthcheck could never have passed: the postgres image declares no `USER`, so `docker exec` runs as root, and `pg_hba`'s `peer` compares the OS user against the role. The container would never have reported healthy, which silently takes the backup with it via `depends_on: service_healthy`.

A security pass found the superuser reachable from every tailnet node with only a password. Every rule was `all all`. Superuser carries `COPY ... FROM PROGRAM`, which is command execution in the container, on top of read/write over my entire session corpus. My own compose header already argued that a compromised tailnet node is inside the WireGuard boundary by construction — that argument is *why* the listener has TLS. I had acted on half of it.

The same pass found that `pg_reload_conf()` returns true even when Postgres rejected the new `pg_hba` and kept the old rules. The reload is fail-safe, but my hook was printing success for a policy the server had discarded, which is the exact silent divergence the hook exists to prevent.

Then the deploy found two more, both fatal, neither visible beforehand.

The secret reference was `$secrets.chronicle.superuser_password` while the keys live under `apps.chronicle`. Go's `text/template` emits its literal null marker at exit 0, so the container rendered with a fixed, publicly-known superuser password. I had written a render gate for exactly this. It didn't fire, because a failing post-sync hook is logged `on_failure: false` and doesn't fail the reconcile.

Postgres 18 also refuses to start with the mount at `/var/lib/postgresql/data`. It stores data in a major-version subdirectory so `pg_upgrade --link` never crosses a mount boundary, and the entrypoint rejects the old layout even on an empty directory, because the complaint is about the mount point rather than its contents.

The last one was my favorite, because it was the gate catching me rather than me catching the gate. The design argued that a Tailscale certificate means no CA to distribute to the laptops. True of the certificate; false of `libpq`. `verify-full` does not fall back to the OS trust store — it looks for `~/.postgresql/root.crt` and fails closed when that file is absent, which it is on a clean Mac. The DSN in my runbook would have failed on both my machines.

It surfaced because I ran the verification gate against the live server instead of reading it back. Plaintext-refused passed. Encrypted-session passed. TLS-floor passed. The one client setting my Macs actually use did not. `sslrootcert=system` fixed it, and the final gate came back 4 passed, 0 failed.

Tier 3 isn't finished, though, and I want that on the record rather than discovered later. Redact-on-ingest is client-side, so it arrives with the Macs' cutover and not with this deploy. And the nightly `pg_dump` currently lands unencrypted on the array, which contradicts the whole reason ingest runs Macs→NAS in the first place — the Tier 2 archives are encrypted precisely so the estate key never lives on the NAS. That's a decision I've written into the runbook and haven't made.

## What the log says

Nine workstreams, and one sentence keeps surfacing in the commit bodies: the thing protecting this was not the thing I thought was protecting it.

A wrong default is invisible to config review, because the config looks complete. A doc can credit a sandbox that was never wired in while a container quietly does the job. A `pre-push` hook can point at an empty directory for months. And a control that blocks everything is indistinguishable, from the blocked side, from a control that works.

None of that is discoverable by reading. It fell out of attacking the mechanism, or of a deploy touching real state for the first time. Which is the uncomfortable part, because reading is cheap and both of the other two are not — I can't run a live negative test against every gate I own every week, and I don't have a good answer yet for which ones earn it.

This post had the disease too, and it took three tries to stop having it.

The first draft opened with 430 commits, 66 pull requests, eighteen repositories. Not one of those was right. I'd counted commits with `git log --all`, which in a squash-merge repo counts a branch commit and its squashed landing as two, inflating the total. I'd counted PRs by grepping commit subjects for `(#123)`, which misses every PR whose squashed subject drops the reference — and which also counted three *issues* as PRs, because an issue reference looks identical. And I'd built the repo list by hand, so it quietly omitted four repos, including the one where I'd committed 32 times.

The second attempt fixed the commit method and broke something else: it looked for `origin/main` in a repo whose only remote is named `gitea`, scored it zero, and I nearly published that. An empty result from a wrong ref reads exactly like a quiet week.

The third attempt deduplicated by remote URL rather than by directory, which is when I found that `homelab` had been counted twice — two separate clones of the same repository, ninety commits of pure double-count. That second clone is the same stale one whose hooks directory had silently disabled every git hook in the repo. It got me twice in one weekend, in two completely different ways.

Every one of those wrong numbers looked reasonable. That's the whole problem: none of them had been checked against the thing they claimed to count.

What I do have is a smaller rule that survived the weekend: whatever the check returns, make it prove the mechanism engaged. Not that the config parsed. Not that the file conformed. The 429s, the refused connection, the 401 with no header. Everything else this weekend was green.
