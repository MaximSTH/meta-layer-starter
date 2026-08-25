# Brief — /refresh-vendor claude-code (2026-08-25)

**Artifact:** `markdowns/agents/vendor-knowledge/claude-code.md` (+ touchpoints)
**Tier:** 2 (vendor-knowledge correction; drives `cross-vendor-review.sh` + agent model selection)
**Walk trigger:** direct `/refresh-vendor claude` invocation.

## Version delta
File last-verified at **v2.1.210**. Local binary **v2.1.220**; npm latest **v2.1.245**.
31 releases walked (2.1.211 → 2.1.245).

## Verification limit (carry into review)
Flag-set claims are binary-verified only through **v2.1.220**. Claims from
2.1.221–.245 are changelog+docs-sourced, NOT execution-verified.

## What this change does
1. **Corrects two false claims** — §3 subagent nesting (depth/cap/configurability
   all wrong) and §6 Agent SDK credit (announced 2026-06-15, then PAUSED; never
   took effect).
2. **Corrects §2** cross-vendor portable subset (2 fields → 6).
3. **Resolves §8** websocket conflict by live binary probe → re-tag MEDIUM → STABLE.
4. **Records C1** — `cross-vendor-review.sh:117` runs `claude -p` with no `--bare`,
   which now-explicit docs say executes the *target repo's* hooks + MCP servers
   with no trust dialog. Recorded in §9; script fix deliberately OUT of scope.
5. Additive deltas across §1/§2/§4/§7/§9/§10.

## Cross-cadence touchpoint (forced by protocol)
Model drift → `model-capabilities.md`: Opus 5 missing entirely; Sonnet 5
$3/$15 → $2/$10 standard; `/fast` scope 4.8/4.7 → 5/4.8.
**Split applied:** factual corrections land now; the vendor-neutral tier
restructure is deferred to the consolidated pass after the codex + antigravity
walks (supervisor decision, 2026-08-25).

## Pending markers (NOT resolved here)
`codex-cli.md` §3/§10 head-to-head is invalidated (both vendors now default-low
and raisable). Mirror prose retired; Codex-side claims left unverified and
`last-verified` NOT bumped — the codex walk is next in sequence.

## Review focus
- Is A2 (SDK-credit pause) safe on a single support-article channel?
- Is the §3 rewrite faithful to the docs' stated version history?
- Does C1 belong in §9 as recorded, or is it over/under-stated?
