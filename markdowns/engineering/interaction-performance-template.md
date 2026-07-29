---
name: interaction-performance-template
description: Skeleton for a project's interaction-performance standard — the measurable bar behind FCPSS's "P". Copy to `interaction-performance.md`, derive your budgets, and wire your gates to it before shipping UI.
status: template
---

# Interaction-performance standard — `<PROJECT-NAME>`

The committed bar every UI slice is built and reviewed against.
FCPSS's "P" points here; your UX conventions' pre-ship walk carries
its items. Binding for `<WHICH SURFACES — e.g. "all UI under
src/app/">` from `<WHEN — first UI slice, or a named milestone>`
onward; pre-existing violations go in the §7 ledger, never
grandfathered silently.

**Why this template exists (a paid-for lesson, not speculation).** In
the project this pattern was extracted from, the same
interaction-performance failure shipped five times, by different build
agents, before it was caught: small edits that blocked on a full
screen re-fetch, making the UI feel sluggish — and every one of those
sessions "passed" FCPSS's P in good faith, because "P" was a checkbox
with no measurable bar. Each agent made a defensible-looking style
choice (await the server, then refresh everything) that review had no
rule to reject. Attribution per
[failure-attribution.md](../protocols/failure-attribution.md):
**protocol gap**, not agent error. The fix is this document: budgets
as numbers with stated checks, so a reviewer verifies a number
instead of relitigating taste each PR.

Terms: **optimistic update** = the screen shows the result of an edit
immediately, before the server confirms, and reconciles behind;
**refetch / revalidation** = re-running server queries to re-render a
screen's data after a change; **round trip** = one awaited
client-server or server-datastore request-response.

## 1. Interaction classes and feedback budgets

Every user-triggered interaction belongs to exactly one class.
Classify in order:

1. Does the server work honestly take longer than `<LONG-JOB
   THRESHOLD>` (generation, a multi-item batch)? → **Class C**. A
   batch of small operations is Class C as a whole; its per-unit
   completions render as they land (§4).
2. Is it a mutation of one entity's field(s) or one row — rename,
   toggle, reorder, add/remove one item, save one field? → **Class A**.
3. Otherwise it changes what data the screen shows — navigation,
   search, filter, date range → **Class B**.

Budgets are hard numbers with a stated check. Meeting them is a
review requirement, not a style preference; "feels fine" does not
override a budget. FCPSS's binary coverage applies: **the "P" bullet
counts as covered only when every applicable budget passes, or the
chat checkpoint carries an explicit supervisor-approved exception**
(a `[SUPERVISOR]` decision per
[supervision.md](../protocols/supervision.md)) — a written
justification alone does not ship.

| Class | Budget | How it is checked |
|---|---|---|
| **A. Small edit** | Screen reflects the intended end-state within `<N ms>` of the input event — in practice, before any network round trip (optimistic, §2). | Structural, not stopwatch: the code applies the state update before awaiting the server call; clicking shows the change land instantly. Pending affordances must not gate the visible change and disable at most the acted-on control. |
| **B. Navigation / read** | A **visible** pending treatment within `<N ms>` (spinner, skeleton, label swap — an ARIA state accompanies, never substitutes). Filters over data the client already holds recompute client-side, zero round trips. Content arrival: `<N s>` to interactive content at current data scale. | Pending affordance: structural + observed. Content arrival: measured on a deployed build with the number recorded (§5), never eyeballed in dev. |
| **C. Long-running job** | A held-place state (the job visibly occupying its place in the UI) within `<N ms>` of the trigger — rendered before the server responds. Progress reflects real events only; terminal state always renders (§4). | Structural + observed: held-place renders before the round trip; progress wiring read from the code (real state, no simulated timers). |

**Where your numbers come from** (fill this — it is what makes the
budgets revisable instead of relitigated): state the derivation for
each number. Common anchors: the conventional perceived-as-instant
threshold for small edits; audience tolerance (staff tool vs consumer)
for content arrival; your audited screens' current query counts for
the §3 ceilings. Budgets are protocol values — revised by a
supervisor decision with a doc edit, not per PR.

**Sanctioned exceptions** (blocking is correct, not a violation) —
enumerate yours. Typical set: entity-level deletes after a confirm
(post-delete navigation depends on server truth); create-then-navigate
(the target route doesn't exist until the server replies);
deliberate-pause confirms (spend gates — the budget clock starts at
the post-confirm trigger). Destructiveness is defined by irreversible
data loss, not the verb on the button.

## 2. Optimistic by default, reconcile behind — including the failure half

The rule for every Class A edit:

1. **Apply the edit to the screen first**, inside the same handler
   tick — then call the server.
2. **Reconcile behind, without freezing the screen.** The refresh is
   cleanup, not the reveal; unrelated controls stay interactive.
3. **On a rejected edit: revert and tell.** The optimistic state falls
   back to server truth, and the user sees an error at the point of
   action. Both halves are required: reverting without telling = the
   user's edit silently evaporates; telling without reverting = **the
   screen lies about what is saved**. Optimistic UI never silently
   diverges from persistence — whatever the screen shows after failure
   must be what the datastore holds.
4. **On an unknown outcome, re-read — don't guess.** A transport
   failure (network drop, timeout) means the write may or may not have
   committed. Catch it, tell the user, and run a targeted
   authoritative re-read of the affected entity so the screen
   converges on datastore truth. If the re-read also fails, say so
   plainly and re-read at the next opportunity (reconnect, focus,
   navigation) — never silently assert either outcome. Never refetch
   after a *clean* rejection (rule 3) — that case is known.
5. **Out-of-order responses must not win.** Rapid successive edits to
   the same entity either serialize or carry a monotonic-intent guard
   so a stale response cannot overwrite a newer edit.
6. **Controlled inputs resync on revert**, so a rejected edit visibly
   snaps back.

Name your house-pattern reference implementation here once one ships:
`<FILE — the component new Class A work copies instead of reinventing>`.

## 3. Refetch discipline

What makes a UI feel sluggish is rarely one slow query — it is edits
that quietly re-run a whole screen's worth of reads, and screens that
fetch more than they show. This section caps both.

**Targeted revalidation only.** A mutation refetches exactly the
routes/views that render the data it changed — no more (a one-field
write does not re-run a whole screen's loader as its blocking cost)
and no fewer (enumerate every view that renders the changed data; the
PR states the enumeration so review can check it).

**High-frequency loops refetch nothing per edit.** An interaction the
user repeats many times in a row updates targeted client state per
edit and reconciles at most once per pause — a per-edit refetch is a
violation even "in the background"; its queued re-runs are the
throughput cost the user feels. Coalesce: at most one reconciliation
refresh in flight per screen.

**Read cardinality.** A read on an interactive path fetches what the
screen needs: point lookups are single-row queries, never
fetch-all-then-filter. A read whose result set grows with usage
states its expected cardinality in the PR.

**Query ceilings.** Counting rule: one awaited datastore/auth request
= one round trip; a per-row or pagination loop counts every iteration;
conditional reads count when they fire in the common case. Count at
realistic data scale and state the number in the FCPSS "P" bullet.

| Surface | Ceiling (new code) |
|---|---|
| Class A mutation, critical path | `<N>` round trips server-side (guard reads + write; auth counts). A structural write needing more belongs in one atomic operation. Background reconciliation is excluded but bounded by the screen ceiling. |
| Screen load / Class B read | `<N>` distinct queries, `<N>` sequential round-trip stages. Independent reads run concurrently; a read awaits another only when its inputs depend on the result. |
| Pagination | A paged read that can exceed one page at realistic scale states its expected page count; unbounded sequential chains on an interactive path are a review flag. |

New screens meet the ceilings from day one. Existing screens that
exceed them are §7 ledger entries — the ceiling is not retroactive
shame, it is the bar for the next touch.

## 4. Long-job honesty

Class C jobs never fake progress and never go quiet:

- **Held-place state:** the job occupies its real place in the UI
  (the row, the slot, the node) with an honest label.
- **Real events only:** progress is driven by actual state transitions
  (stream events, or polling persisted job state). No simulated
  timers, no invented percent bars, no spinner pretending progress
  when nothing is known. A coarse-but-true label beats a fabricated
  progress bar.
- **The work survives the view:** per-step results persist as they
  complete, so navigation, reload, or a dropped connection loses the
  live view, never the work. A stream is a live window, not the
  system of record.
- **Terminal honesty:** success, failure, and partial results all
  render; a failed step shows its last good artifact clearly marked;
  "Stop" states exactly what stopping does and does not do.

## 5. The dev-vs-deployed evaluation split

Dev mode's overhead (compilation, unoptimized bundles) dominates
first-load wall-clock. Without this rule, perceived dev latency gets
misattributed to code — repeatedly.

**A dev-stage review CAN prove** (and must check): class conformance
(does a Class A edit paint before the round trip — structural +
observed); pending affordances (dev lag makes this check *stricter*);
failure honesty (force a clean rejection **and** a transport failure,
confirm §2's revert-and-tell / re-read for each); query counts,
counted from source per §3.

**A dev-stage review CANNOT prove:** raw latency, absolute load
times, "does this feel fast." Never diagnose slowness from a dev
stage without first separating dev overhead.

**Deployed measurement.** Wall-clock budgets are measured only on a
deployed build under stated conditions (`<BROWSER / NETWORK / DATA
SCALE>`). Record two numbers, pass or fail: the cold first visit
(hard reload, cache disabled — includes the client bundle the route
ships) and the warm second visit. The `<N s>` budget applies to the
warm number; a cold number far above it signals a bundle problem —
load the heavy import lazily and name any large added client
dependency in the "P" bullet. Define when measurement happens:
`<e.g. pre-merge on a preview deployment when a slice flags Class B
budget risk; once per phase on the production URL, numbers recorded
in the phase checkpoint>`.

## 6. Enforcement map (honest about its limits)

No enforcement theater: state exactly what a machine checks, what a
reviewer checks, and what nobody currently checks. Filling this table
optimistically defeats its purpose — the gap column is the point.

| Rule | Enforcement today | Mechanical path (when justified) |
|---|---|---|
| `<e.g. reads are index-backed>` | `<mechanical: named CI test — covering exactly what it enumerates, no more>` | `<what would extend it, and the trigger that justifies building it>` |
| Query ceilings (§3) | `<typically review-rubric: counted from source, stated in the "P" bullet>` | `<e.g. a query-counting test wrapper — worth it the first time a ceiling regression ships, not before>` |
| Class A optimistic + revert-and-tell (§2) | `<typically review-rubric: reviewer exercises the interaction and forces both failure modes per §5>` | Not mechanically checkable in general — it is a behavior property. |
| Feedback budgets (§1) | `<structural review for A/C; deployed measurement with recorded numbers for B>` | `<synthetic perf CI measures noise at small scale — revisit when there is traffic worth alerting on>` |
| This standard reaches every UI slice | Wiring: FCPSS "P" points here; the UX pre-ship walk carries a performance item; worker kickoff prompts cite this doc. | — |

## 7. Remediation ledger

The honest list of places the existing app already breaks the rules
above, so nothing is silently grandfathered. Each entry: where, what,
disposition. **Dispositions:** **fix-now** = scheduled as a small
dedicated remediation slice (normal tier/review rules);
**fix-when-touched** = binding on the next PR that **changes or
materially depends on the affected interaction** — not merely any PR
touching the containing file (per the scope-not-cleanliness operating
principle); the reviewer treats shipping such a change without the
fix as a finding.

| ID | Where | Violation | Disposition |
|---|---|---|---|
| `<ID>` | `<file:line>` | `<one sentence>` | `<fix-now / fix-when-touched>` |

Also record the good patterns fixes should copy — the ledger teaches
in both directions.

## Relationship to other docs

- [fcpss-gate.md](../protocols/fcpss-gate.md) — "P" delegates its bar
  to this doc; the gate stays the five-question checklist, and §1
  states when P counts as covered.
- `<YOUR UX-CONVENTIONS DOC>` — owns what feedback looks like and
  where it appears (semantics, placement, destructive-action rules);
  this doc owns how fast it must appear, what an interaction may
  cost, and how perceived speed is judged. **All budget and ceiling
  numbers live here only** — the UX doc restates none of them, so
  they cannot drift apart.
- `<YOUR MECHANICAL LAYER — e.g. CI plan-shape tests>` — what §6's
  mechanical column builds on.

## Adapt for your project

Fill every `<SLOT>`: derive your budgets and ceilings (record the
derivation in §1), enumerate your sanctioned exceptions, name your
house patterns as they ship, run a first audit to seed §7, and fill
§6 truthfully. Then wire it: point FCPSS's "P" here, add the
performance item to your UX pre-ship walk, and cite this doc in
worker kickoff prompts. When a second surface with a different
audience starts, re-derive the numbers for it by supervisor decision
— the classes and disciplines (§1–§5) are surface-agnostic; the
numbers are not.
