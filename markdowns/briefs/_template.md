<!-- This is a template, not a live brief. Copy and rename when authoring
     a new session brief (e.g., `markdowns/briefs/feature-auth-refactor.md`).
     Briefs ship committed at session start and are git rm'd post "ship it"
     per supervision.md §session-brief lifecycle.

     The README of this starter explains the lifecycle:
     - Commit at session Step 0
     - Pass via `scripts/cross-vendor-review.sh --brief <path>` on every
       cross-vendor pass
     - Remove in a follow-up commit before merge
     - Squash collapses everything; main never holds the brief long-term -->

# Brief — `<artifact-name>`

## What's the work

Two or three sentences describing the surface, the change shape, and the
intended user / system-visible behavior after ship. No protocol jargon.
Concrete enough that a peer vendor reviewing the diff knows what to
anchor against.

## Tier

(One of Tier 1 / Tier 2 / Tier 3 / Tier 4, per `stake-matrix.md`. State
the chosen tier and one sentence of justification. If the tier is
unclear, escalate up — Tier 2 over Tier 3 is cheap, Tier 3 over Tier 1
is dangerous.)

## Scope — what's in

- (Bullet list of concrete changes.)
- (Files, behaviors, surfaces.)

## Scope — what's deliberately out

- (Things a reviewer might reasonably expect but are explicitly deferred.)
- (One line per item, with the deferral reason.)

## FCPSS coverage

- **F (Functional):** What user-visible / system-visible behavior changes?
- **C (Cross-cutting):** What shared canonical files / SSOTs / other surfaces does this touch?
- **P (Performance):** Round-trip count, latency budget, cost envelope.
- **S (Security):** Auth boundary, RLS / input sanitization, secret surface.
- **S (Stability):** Error boundaries, retry, partial-failure recovery, observability.

(Each bullet must be answered. "N/A" must explain why.)

## Anchors for the cross-vendor review

- (File:line citations the reviewer should anchor observations against.)
- (Named protocol sections the change should comply with.)
- (Test files that should fail before the change and pass after.)

## Open questions

- (Anything the supervisor needs to decide before / during the session.)
- (Anything blocked on external info.)
