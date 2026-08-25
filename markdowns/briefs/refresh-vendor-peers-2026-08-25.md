# Brief — /refresh-vendor codex + antigravity (2026-08-25)

**Artifacts:** `codex-cli.md` (PR #10), `antigravity-cli.md` (PR #11).
**Tier:** 2. Stacked on PR #9 (claude-code walk).

## Version deltas
- codex: file recorded binary 0.139.0; installed **0.144.5**.
- antigravity: file recorded 1.1.4; installed **1.1.19** (changelog shows 1.1.20).

## Load-bearing claims to attack
1. Codex `agents.max_depth` / `max_threads` "key existence binary-confirmed"
   rests on a --strict-config type-error discriminator, NOT on reading values.
   Is that inference sound?
2. Codex `agents.default_subagent_model` declared NON-EXISTENT because the
   binary rejects it. Docs say it exists. Binary-wins is claimed. Sound?
3. Codex per-agent `model` marked low-confidence because the control passed.
   Is low-confidence the right call, or should it be dropped entirely?
4. Antigravity `model`/`inherit` support is inferred from a CHANGELOG BUGFIX
   line, not from a schema. Is that over-read?
5. The rebuilt cross-vendor head-to-head asserts delegation posture is the
   load-bearing axis. Does the evidence support that conclusion?
6. Antigravity §9 claims our dispatcher's fail-closed grep may stop matching.
   That is a prediction about our script. Is it overstated?

## Known verification limits
Antigravity numeric fan-out caps unresolved (absence-of-evidence, not absence).
No behavioral delegate-and-observe test was run on any vendor.
