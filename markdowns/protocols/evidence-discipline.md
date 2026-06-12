---
name: evidence-discipline
description: Four rules an agent walks before recommending a destructive action (remove file, drop code branch, break an interface). Falsification-first, asymmetric burden of proof, multi-channel verification, absence-of-evidence reporting. Universal pre-recommendation discipline.
status: reference
---

# Evidence discipline

A common agent failure mode: collect the cheapest available evidence,
treat silence as proof, recommend destructive action. The cheap
evidence is usually a docs page or a single grep. The destructive
recommendation is usually "remove this — I can't find anything that
uses it" or "this flag doesn't exist — drop the case." Both errors
share a structure: the agent confuses *absence of evidence for X*
with *evidence of absence of X*.

This protocol is the discipline that prevents the structure.

## The four rules

### 1. Falsification first

Before checking evidence, write down what evidence **would change the
recommendation**. State the falsifier explicitly:

> "If `agy --help` lists `--print`, I'm wrong about dropping the
> antigravity case."
> "If this function is called from anywhere I haven't searched, my
> recommendation to delete it is wrong."

Commit to the falsifier *before* looking. Post-hoc rationalization is
the failure mode this prevents — once an agent has formed a position,
it tends to find reasons the contrary evidence "doesn't count."

### 2. Asymmetric burden of proof

| Recommendation | Burden of proof | Default when uncertain |
|---|---|---|
| **Keep something that exists and might work** | Low — no positive evidence required | Status quo |
| **Remove, drop, or destructively edit** | High — requires positive evidence the thing is broken | Verify further; do not act |

"I couldn't find evidence it works" **supports the status quo**, not
removal. The burden of proof is on the destructive side, not on the
keep side. When in doubt, leave it.

### 3. Multi-channel verification for destructive recommendations

Two independent evidence channels minimum. Channels in order of
reliability for vendor-capability claims:

| Channel | Why it's authoritative |
|---|---|
| **Binary `<vendor> --help`** | The CLI itself parses the flag set. Whatever `--help` lists is what the binary actually accepts. |
| **Upstream GitHub repo README** | Maintained at commit-time by the same engineers shipping the binary. Tracks reality faster than docs sites. |
| **Vendor docs site** | Edited by docs teams, lags behind shipped behavior. Often incomplete. |
| **Community usage** (StackOverflow, blog posts, GitHub issues) | Captures real-world invocation patterns but may be stale or wrong. |

Docs alone is not enough. The cheap channel returning "not found" means
"check the next channel," not "doesn't exist." A destructive
recommendation requires confirmation from two channels — typically the
binary's own help and one other source.

### 4. Absence-of-evidence reporting

When you can't find something, your report says **"I couldn't find X
via [channels tried]"** — not "X doesn't exist."

| Wrong | Right |
|---|---|
| "The `--print` flag doesn't exist." | "I couldn't find `--print` in the docs page or the GitHub README. I haven't checked the binary's `--help`." |
| "This function isn't called anywhere." | "I grep'd `lib/` and `web/`; I haven't checked `scripts/` or generated code." |
| "The feature was never shipped." | "No commit message mentions the feature; I haven't checked closed PRs or the release notes." |

The different sentence changes the downstream recommendation. "Doesn't
exist" supports removal. "I couldn't find via [channels]" supports
checking more channels. The framing matters.

## When this protocol fires

The discipline applies to **every recommendation involving destruction,
removal, or breaking change** — file deletion, code-branch removal,
deprecation, interface break, dropping a configuration option,
removing a near-match candidate during build-feature's reuse scan.

It does NOT fire for additive changes (writing new code, adding a
feature, authoring a new protocol). For additive changes, the
build-feature near-match scan handles the "what already exists" half
of the question; this protocol handles the "should I remove what
exists" half.

## Specific cases

### Vendor-knowledge URL fragility

A specific case of rule 3. When a vendor knowledge file claims a CLI
flag exists and the docs page doesn't mention it, the binary's `--help`
is the source of truth. Update the knowledge file's citation to point
at `--help` output if the docs are incomplete; don't drop the claim
just because the docs site is silent. See
[`refresh-vendor.md`](refresh-vendor.md) for the refresh flow that
applies this discipline at the per-claim level.

### Near-match scan in build-feature

A specific case of rules 1 + 2. When deciding whether to extend an
existing helper vs author a new one, the falsifier is "if the existing
helper covers ≥70% of the behavior I need, I extend." The burden of
proof is asymmetric: "I couldn't find an existing helper" requires
two channels (grep the codebase + check related directories) before it
supports "author new."

### Refactor extraction decide phase

A specific case of rule 4. When deciding whether the duplication count
warrants extraction, the report distinguishes "I found 3 copies via
[search method]" from "there are 3 copies." If the search method
missed a fourth copy, the decision changes (3 = ticket, 4 = refactor
IS the change).

## Walking this protocol does not slow you down

The four rules are cheap. A typical pre-recommendation walk:

1. Write down the falsifier (10 seconds).
2. Note that the recommendation is destructive (5 seconds).
3. Pick the right channel for the verification (15 seconds).
4. If the recommendation is to keep, report as "I checked X." If the
   recommendation is to remove, also check Y. (1–5 minutes.)
5. Phrase the report as "I checked X" / "I couldn't find via X" —
   never "X doesn't exist" unless the binary itself confirmed.

The cost of this discipline is roughly two minutes per destructive
recommendation. The cost of skipping it is destroying working code
based on a stale docs page.

## Adapt for your project

- Identify the channels most authoritative for your domain. For
  CLI-vendor claims, `--help` beats docs. For library-API claims,
  the source code beats the changelog. For database-schema claims,
  the migration file beats the diagram.
- Add an example to the per-case section above when a recurring
  failure mode in your project surfaces. Each example earns its way
  in by being a real incident the discipline would have prevented.
