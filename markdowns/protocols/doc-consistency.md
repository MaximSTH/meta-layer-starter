---
name: doc-consistency
description: Cross-document semantic consistency — SSOT-for-values, the value-authority ladder, the post-edit consistency sweep, declared quoters for derived artifacts, two-trigger escalation path.
status: reference
---

# Doc consistency

Facts shared between documents — and between documents and the built
system — drift out of agreement: a user-journey change that never
reaches the architecture doc, two different prices in two places, a
diagram restating a total its source table abandoned two revisions ago.

This protocol has two halves: **authoring rules** that prevent value
drift structurally (SSOT-for-values, the value-authority ladder), and a
**consistency sweep** that detects semantic drift the rules can't
prevent.

## Decision tree

| Situation | Section |
|---|---|
| Writing a doc that needs a value stated elsewhere | [SSOT-for-values](#rule-1-ssot-for-values) |
| A diagram / summary table / export must restate a value | [Declared quoters](#declared-quoters) |
| A planned value is being implemented in the system | [Value-authority ladder](#rule-2-value-authority-ladder) |
| A session made a substantive edit to a planning/spec doc | [The consistency sweep](#the-consistency-sweep) |
| The same docs keep contradicting, or sweeps got heavy | [Escalation path](#escalation-path) |

## Rule 1: SSOT-for-values

Every shared literal fact — a price, a date, a limit, a metric target —
has exactly one canonical home per lifecycle stage. Every other document
— **or sibling section of the same document** — links to that home
instead of restating the value. Restating inline is the exception, and
it is declared (see below), never silent. Same-doc restatement (prose
repeating a table two paragraphs up) drifts just as readily as
cross-doc restatement.

This is prevention, not detection: once a fact has one home, the second
copy never gets written, and there is nothing to drift.

### Declared quoters

Some artifacts definitionally cannot "link, never restate" — a diagram
label, a summary table, a slide export. These **declare what they
quote**:

- Markdown files: a `quotes:` list in frontmatter —
  `quotes: [tech-stack.md#cost-model]`
- Non-frontmatter artifacts (SVG, HTML): a comment near the quoted
  value — `<!-- quotes: tech-stack.md#cost-model -->`

The declaration converts the worst drift category — invisible
duplicates — into enumerable ones: the consistency sweep includes every
declared quoter of a changed value, **regardless of its lifecycle
status** — a declared quoter is swept even when it is `reference` or
sits outside the draft+active set. **Scope guard:** `quotes:` is only
for artifacts that *cannot* link. It is not a general dependency-graph
mechanism; semantic dependencies between prose docs are the sweep's
job, not a declaration's.

**In template/library repos, declare quoters aggressively.** Where
reference docs *are* the product (a starter, a library), the draft+active
sweep scope will not reach a `reference` doc that restates a value (a
count, a version, a limit) whose canonical home is an index — so any
such restatement needs a `quotes:` declaration to be swept. README
files, comparison tables, and "what's in here" summaries are the usual
offenders.

## Rule 2: Value-authority ladder

A value changes owners over its lifecycle. Drift concentrates at the
ownership boundaries, so make each handoff explicit:

1. **Pre-implementation: the doc is authoritative.** The value is a
   decision; it lives in one decision doc. This is the only stage where
   markdown is ever authoritative for a value.
2. **Implementation is a handoff event, not an assumption.** When the
   value lands in its runtime home, edit the decision doc to re-point
   that value at its home ("implemented — authoritative value now in
   `<runtime home>`"). The handoff is **per-value, not per-doc**:
   archive the doc only when its purpose was that decision. A
   multi-value doc keeps living with its remaining open decisions.
3. **Post-implementation: the system is authoritative.** No active doc
   states a runtime-owned value as bare fact — prose never syncs to a
   database row. A doc that still needs the number uses **dated
   snapshot notation**: "X *as of YYYY-MM, authoritative in `<runtime
   home>`*". Notation scopes to a **section** when per-value tagging
   would be unreadable — a computed table deriving many runtime-owned
   values takes one scoping line ("all unit prices in this section as
   of YYYY-MM, authoritative in `<runtime home>`") instead of a tag
   per cell — one line per runtime home if a section mixes them. A
   bare runtime-owned value in a draft or active doc,
   outside any snapshot scope, is a sweep finding.

"Runtime home" is deliberately abstract here (DB row, config file,
billing provider, env var). One-authority applies inside the system
too: one module owns each value; if it is mirrored (e.g. DB ↔ billing
provider), pick one sync direction and never hand-edit both sides.

## The consistency sweep

Runs after a session makes a substantive edit to a planning/spec doc —
a decision changed, a value updated, a section restructured. The
`/doc-consistency` skill walks it; typo fixes and status flips exit at
the discriminator.

1. **State the semantic delta.** One or two sentences: what claim
   changed, what premise it may invalidate.
2. **Enumerate the sweep set:**
   - every doc with `status: draft` or `status: active` — drafts are
     where decisions churn, and churn is where drift lives; exclude
     `reference`, `template`, `archived`;
   - **the edited document itself, in full** — sibling sections
     frequently describe the changed mechanism or restate the changed
     value, and the doc's own summary surfaces (frontmatter
     `description`, intro, verdict/summary tables) contradict their
     body after restructures; a cross-doc sweep does not naturally
     re-read any of these, and the cost is near zero — the editor
     already has the doc in context;
   - every declared quoter of any changed value.
3. **Check each for dependent claims** — restated values, descriptions
   of the changed mechanism, premises the change invalidates.
4. **Classify each finding:** *contradiction* (fix in the same
   change-set), *stale-but-harmless* (note it, e.g. accurate history),
   or *unaffected*.
5. **Report findings anchored** as `file:line` (or `file#section`),
   per [`rubric-shared-anchors.md`](rubric-shared-anchors.md).
   Contradictions land in the same change-set as the edit that caused
   them — never deferred to "later".

## Escalation path

Two triggers, thresholds tunable per project (see "Adapt"):

- **Contradiction recurrence.** The same doc pair contradicts
  repeatedly (default: 3 strikes) → **consolidate first** — the docs
  overlap too much, and the shared content should live in one of them.
  Only if consolidation genuinely doesn't apply, install a pre-commit
  gate: hash-pinned `depends-on:` frontmatter, where a commit touching
  an upstream doc fails until dependents' pins are reviewed and bumped.
- **Sweep weight.** The draft+active set has grown large enough that
  per-edit sweeps are slow or expensive → graduate to declared
  `depends-on:` edges so the sweep checks dependents only, instead of
  enumerating everything.

The gate ships as documentation only — deliberately. On churning
planning docs a commit-blocking gate trains reflexive pin-bumping
("rubber-stamping"), trading silent drift for noisy theater. Install it
only when a trigger fires and consolidation didn't resolve it.

## Boundaries and honest limits

- **Detection by convention, not enforcement.** Nothing blocks a commit
  if the sweep doesn't fire, and skill auto-triggering is less reliable
  on some vendor CLIs than others. The design bet: probability-of-check
  goes from ~0 to high at near-zero infrastructure cost, with the
  escalation path if that proves insufficient.
- **LLM judgment over prose.** The sweep catches most contradictions,
  not all. It reduces drift; it does not guarantee consistency. Do not
  stand down human spot-checks because "the sweep handles it".
- **Format sync ≠ semantic sync — projects need both.** Mechanical
  derivation (MD → HTML regeneration, AGENTS.md → CLAUDE.md mirrors)
  belongs to pre-commit hooks: blockable, zero judgment. The sweep
  covers what hooks can't: meaning drift. A derivation hook does not
  handle semantic drift, and the sweep is not a substitute for a
  derivation hook.
- **Style and voice rules are out of scope.** Banned punctuation,
  pronoun conventions, brand voice — those belong to mechanical
  pre-commit greps. Don't spend an LLM sweep on what `grep -E` does
  better.

## When this fires

- **Authoring time** — SSOT-for-values and quoter declarations apply
  whenever a doc states a shared fact.
- **Post-edit** — the sweep, via the `/doc-consistency` skill, after
  substantive edits to draft/active docs in `markdowns/`.
- **Implementation time** — the value-authority handoff edit, when a
  planned value lands in the system.
- **On a trigger** — the escalation path, when recurrence or sweep
  weight fires.

## Adapt for your project

- Map "runtime home" concretely for your stack (settings table, config
  module, billing provider — and the one sync direction between them)
  in your project's `AGENTS.md`.
- Tune the escalation thresholds: contradiction strikes (default 3) and
  the sweep-weight ceiling (when per-edit sweeps feel slow, that's the
  signal).
- Pick the anchor style for quoter declarations (`file.md#section`
  works for most repos).
- If your project derives rendered artifacts from markdown (HTML,
  slides), pair this protocol with a mechanical regeneration hook —
  see "Boundaries" above for why neither replaces the other.
