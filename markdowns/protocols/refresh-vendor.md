---
name: refresh-vendor
description: Vendor knowledge refresh cadence. Each claim in a vendor knowledge file carries a volatility tag (VOLATILE / MEDIUM / STABLE); the tag drives the re-verification ceiling. Triggered by weekly calendar reminder, drift-on-encounter, or rate-limit/flag-mismatch failure.
status: reference
---

# Refresh vendor

CLI flags change. Rate limits change. Hook event names get renamed
between versions. The vendor knowledge files in
[`markdowns/agents/vendor-knowledge/`](../agents/vendor-knowledge/)
will rot without a refresh cadence. This protocol is the cadence.

## Volatility tags

Each claim in a vendor knowledge file carries one tag:

| Tag | Inter-walk ceiling | Examples |
|---|---|---|
| **VOLATILE** | 60 days | Rate limits, pricing, model defaults |
| **MEDIUM** | 90 days | Filenames the vendor reads, skill formats, hook event names |
| **STABLE** | 365 days | Auth model, MCP support, headless invocation |

The tag drives the refresh cadence. Walks happen weekly; the tag
decides which claims actually get re-verified each walk.

## When the walk fires

| Trigger | What |
|---|---|
| **Weekly calendar reminder** | Open Claude Code and type `/refresh-vendor <vendor>`. Walks every claim regardless of tag. |
| **Drift-on-encounter** | A vendor capability is referenced in-session AND the per-volatility ceiling has been exceeded since `last-verified` |
| **Rate-limit / flag-mismatch failure in `scripts/cross-vendor-review.sh`** | The dispatcher hit an error traceable to a stale flag table — mandatory refresh before re-running |
| **Direct invocation** | The supervisor types `/refresh-vendor <vendor>` |

## Channel reliability ordering

Vendor docs sites are unreliable as the sole verification channel.
Walk channels in this reliability order when verifying a claim:

| Channel | Why authoritative | When to use |
|---|---|---|
| **Binary `<vendor> --help`** | The CLI itself parses the flag set. Whatever `--help` lists is what the binary actually accepts. | Flag-set claims, subcommand existence, default values. |
| **Upstream GitHub repo README** | Maintained at commit-time by the engineers shipping the binary. Tracks reality faster than docs sites. | Install procedure, supported platforms, recent changes. |
| **Vendor docs site (HTML)** | Edited by docs teams; often lags shipped behavior. SPA-rendered pages may be invisible to `curl` / `WebFetch` — fall back to a headless browser. | Conceptual explanations, walkthroughs, policy. |
| **GitHub issues + community usage** | Surfaces real-world invocation patterns, edge cases, gotchas. Often the first place a deprecation is mentioned. | Verifying "is this still supported?" / "what breaks?" |

A claim that conflicts across channels is resolved by the higher-
reliability channel. If `--help` lists `--print` and the docs page
doesn't mention it, the binary wins.

This applies the general principle in
[`evidence-discipline.md`](evidence-discipline.md) §3 to the
vendor-knowledge case.

### Executable claims must be verified by execution, not by page-fetch

A claim that can be checked by **running a command** must be — fetching
a page that *mentions* it is not verification. This is the exact trap
that shipped a hallucinated install string (`npm install -g
@openai/codex-cli`; the real package is `@openai/codex`): the walk
confirmed the docs URL resolved 200 and treated that as proof, while
the package name itself was never run. A resolving docs URL proves the
docs site is up, not that the claim on the page is true.

| Claim type | Verify by running | NOT by |
|---|---|---|
| **Package name / install string** | `npm view <pkg> version` (or the registry's equivalent — `pip index`, `cargo search`, `brew info`) | Fetching the docs page that prints the install command |
| **Binary name** | `command -v <binary>` or `<binary> --version` after install | Reading the README's "run `<binary>`" line |
| **Version number** | `<binary> --version` / `npm view <pkg> version` | A version string quoted in a blog or changelog header |
| **Flag / subcommand exists** | `<binary> --help \| grep <flag>` | A docs reference table |

If the command can't be run in this environment (no network, binary
not installable), say so explicitly in the drift report and tag the
claim `low-confidence` — do **not** upgrade it to verified on the
strength of a page-fetch. "The docs URL resolves" is evidence the docs
site is reachable, nothing more.

## The walk

1. **Read the current file.** Note the `last-verified` date and the
   per-claim volatility tags.
2. **Fetch from authoritative sources** — walk channels in the
   reliability ordering above. Start with the binary's `--help` if a
   local install is feasible; fall back to GitHub README + docs site
   if not.
3. **Diff** each claim against the source. Note: added capabilities,
   removed capabilities, changed behavior (renamed flags,
   deprecations, breaking changes), volatility re-tagging.
4. **Produce a drift report (drift-detected only)** — one bullet per
   claim with the source channel cited. A claim verified against
   `--help` cites `agy --help` (not the docs URL).
5. **Walk FCPSS coverage (drift-detected only)** per [`fcpss-gate.md`](fcpss-gate.md).
   Work shape = research. Output = updated knowledge file + drift memo.
6. **Human gate.** Surface the drift report in chat. Supervisor
   approves / declines / amends each delta. NO writes to the
   knowledge file before approval.
7. **Apply — conditional on drift.** If drift was detected and
   approved: edit the vendor knowledge file; bump `last-verified`;
   re-run dependent scripts. If no drift was found: do NOT edit;
   append one line to a refresh log; the walk ends here (no PR).
8. **Ship per tier (drift-detected only).** Tier 2 typical —
   supervision pattern per [`supervision.md`](supervision.md).

## When the cheap channel returns "not found"

The walk most commonly fails at step 2 when the docs site is silent
on a claim — e.g., a flag the knowledge file documents doesn't appear
on the published reference page. Per
[`evidence-discipline.md`](evidence-discipline.md) §4, "I couldn't
find X via [channel]" is not the same as "X doesn't exist." Before
recommending the claim be removed:

- Try the next channel up the reliability ordering.
- If the binary is installable, run `<vendor> --help` directly.
- If the binary isn't installable in this environment, surface "could
  not verify against the binary; relying on docs site only" in the
  drift report — the supervisor decides whether to install and verify
  or to flag the claim as `low-confidence` until the next walk.

Never silently drop a claim because the cheapest channel was silent.

## Change-marker semantics

A walk that finds nothing still has a real cost (the time to verify
nothing changed) and a real signal (the confirmation that the file is
still accurate). The semantics:

- **Drift detected** → updated knowledge file + PR + chat-checkpoint.
- **No drift** → ledger entry only, no PR, no chat-checkpoint. The
  ledger documents that the walk happened and confirmed accuracy.

The ledger is the durable record of "we checked this and it's still
true."

## Adapt for your project

Pick which vendor CLIs you actually use. Drop the vendor knowledge
files you don't need. Set up the weekly calendar reminder in your tool
of choice (calendar app, Slack reminder, daily cron).
