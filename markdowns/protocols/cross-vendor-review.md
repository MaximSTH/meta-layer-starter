---
name: cross-vendor-review
description: Peer-vendor code review with the anchor-or-decline rule. The worker self-checks first, then a different vendor reviews the diff cold. Observations cite a specific anchor (test, lint rule, named spec section) or get declined.
status: reference
---

# Cross-vendor review

The flow that catches what same-vendor review misses. A model
reviewing its own work is an echo chamber — it tends to bless what it
generated, especially on UX and copy decisions. A different vendor
reading the same diff cold catches the blind spots the first vendor
rationalized past.

## The two-stage flow

1. **Self-check first.** The worker re-walks its own diff against the
   rubric in a fresh context and produces anchored + no-anchor
   observations in the same shape the cross-vendor pass will. Catches
   implementation-context friction. The worker also walks
   [`evidence-discipline.md`](evidence-discipline.md) at this stage —
   every observation that recommends removal or destructive change
   passes the asymmetric-burden-of-proof rule before it's surfaced.
   **This is the stage that executes external-claim checks** (see
   below): the worker runs in a full session with command-execution
   rights, so `npm view` / `--version` / `--help | grep` run here.
2. **Cross-vendor second.** A different vendor runs the same rubric
   and returns its observations. Catches blind-spot friction the
   worker rationalized past. The cross-vendor reviewer runs
   **read-only** (no command execution — see the dispatcher's
   `--allowedTools` / `--sandbox` wiring), so it *flags* external
   claims for the worker to verify in the next round rather than
   running commands itself.

Both passes feed the chat checkpoint. The signal worth watching is the
**no-anchor delta** — an observation the cross-vendor pass surfaces in
no-anchor that self-check missed is a blind spot worth inspecting even
though it auto-declines.

## Anchored vs no-anchor — the key distinction

Every observation cites an anchor:

- A failing or missing test (`file:line` + the assertion it would make)
- A lint / pre-commit rule (rule name + `file:line` of the violation)
- A named section in the project rules / a protocol file / a brand or
  design spec
- A specific line in the brief passed with the review call

Observations without an anchor go in a separate "no-anchor" section.
The author surfaces them once in the chat checkpoint and declines
them — **failure to anchor IS the decline signal.**

This shifts the burden of justification to the reviewer. If they
can't cite a rule, a test, a spec line, or a brief line, the
observation doesn't escalate across rounds.

## Externally-falsifiable claims — anchor to the world, not the repo

The anchors above all point *inward* (a test, a lint rule, a protocol
section, a brief line). A reviewer that only reads the repo can confirm
the repo is internally consistent and still miss a claim that's wrong
about the outside world. This is a real miss this template shipped: a
vendor knowledge file, a README, and a script all said `npm install -g
@openai/codex-cli` — internally consistent across three files, and the
package does not exist (it's `@openai/codex`). Every inward-anchored
reviewer passed it.

So the rubric carries one **outward**-anchored dimension. Any diff line
that asserts a fact about the external world — a package name, an
install command, a URL, a version number, a CLI flag or subcommand, an
API endpoint — is an **externally-falsifiable claim**, and the anchor
for confirming OR refuting it is the output of a command run against
the world:

| Claim in the diff | Command that settles it |
|---|---|
| `npm install -g <pkg>` | `npm view <pkg> version` (404 → refute) |
| "`<binary> --version` is X" | running `<binary> --version` |
| "the `--foo` flag exists" | `<binary> --help \| grep -- --foo` |
| a URL the doc relies on | an HTTP fetch returning 2xx for the *claim*, not just the host |

**Who runs the command — and who only flags.** The cross-vendor
reviewer runs read-only (the dispatcher invokes `claude` with
`--allowedTools "Read,Grep,Glob"` and `codex` with `--sandbox
read-only` — no Bash, no network). It therefore **cannot** run these
commands, and must not be told to. Its job is to **spot** every
externally-falsifiable claim in the diff and list them for
verification. The **execution** happens at a layer that has
command-execution rights:

- the **worker self-check** (stage 1), which runs in a full session
  with Bash — the worker verifies every external claim in its own diff
  there and reports the command output as the anchor; and
- the **iteration round** — when the cross-vendor reviewer flags a
  claim, the worker runs the command in the next round and reports the
  result.

A refuted external claim is an **anchored** observation (the command
output is the anchor) and must be fixed before ship. A flagged claim
nobody could run (no network, binary absent) is surfaced as no-anchor
with the reason — never silently blessed. "The host resolves" is not
confirmation of the claim on the page.

## When the rubric fires

| Tier | Reviewer | Iteration exit condition |
|---|---|---|
| **Tier 1** | Different vendor mandatory | Ship when no anchored observations remain unfixed |
| **Tier 2** | Different vendor mandatory (lighter resolution bar than Tier 1) | Same |
| **Tier 3** | Same-vendor self-review with this rubric in fresh context | CI is the main gate; rubric catches obvious misses |
| **Tier 4** | Skipped | Pre-commit hooks suffice |

## The reviewer prompt template (paste into the cross-vendor call)

`scripts/cross-vendor-review.sh` extracts the prompt body between the
HTML markers below and injects it into the peer-vendor invocation. If
you author your own rubric file, delimit it the same way — the
extraction is marker-driven, not heading-driven, so the section can
move and rename without breaking the script.

<!-- RUBRIC START -->
```
Review the diff at <PR-URL> against <protocol-file> §<N>.
Read-only — do not write, do not execute, do not modify any file.

Return:
- Anchored observations: each cites an anchor (test:line, lint rule
  name + file:line, named protocol section, brief line). One per
  bullet. No anchor → goes in the no-anchor section below.
- Externally-falsifiable claims: you are running read-only and cannot
  execute commands. For every diff line asserting a fact about the
  outside world (package name, install command, URL, version, CLI
  flag/subcommand, API endpoint), FLAG it in a list titled "External
  claims to verify" with the exact command the worker should run to
  confirm or refute it (e.g. `npm view <pkg> version`, `<binary>
  --version`, `<binary> --help | grep -- --foo`, an HTTP fetch of the
  specific URL). Do NOT treat reading the file that asserts the claim,
  or a host merely resolving, as confirmation. The worker runs these
  commands in the next round; a refuted claim becomes anchored and
  must be fixed.
- No-anchor observations: aesthetic preferences, "I would have done
  this differently", style nits without a rule citation. The author
  declines these by default.
```
<!-- RUBRIC END -->

## Failure modes

| Failure | Recovery |
|---|---|
| Reviewer rate-limited | Re-run with a different peer vendor; log to your project's cross-vendor friction log |
| Reviewer flag table mismatch (CLI option no longer exists) | Refresh the vendor knowledge file via `/refresh-vendor` |
| Reviewer cites a non-existent anchor | Treat as no-anchor; surface so the supervisor can spot a hallucinating reviewer |
| Reviewer puts everything in no-anchor | The reviewer isn't using the rubric; re-run with `--rubric` explicit |
| All vendors unavailable | Block on the supervisor; do not silently downgrade tier |

## Adapt for your project

Wire `scripts/cross-vendor-review.sh` to your default peer vendor.
Author per-rubric reviewer-prompt templates for the review types you
ship (code / plan / content / persona / research). Each template is
the rubric body that gets injected into the peer-vendor invocation
verbatim.
