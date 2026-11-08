# Brief — `vendor-refresh-2026-11-08`

## What's the work

A `/refresh-vendor` walk of all three vendor knowledge files (Claude Code,
Codex CLI, Antigravity CLI), 75 days after the last walk. Each file is
brought back in line with the currently installed binaries, plus the
consistency sweep that model drift forces into `model-capabilities.md`
and the docs that quote vendor facts. **Docs only — no script or hook
behavior changes.**

## Tier

Tier 2. Reference docs that drive agent behavior and the dispatcher's
documented contract, but no executable change. The dispatcher defects
found during the walk are Tier 1 and are explicitly out of scope (see below).

## Scope — what's in

- `markdowns/agents/vendor-knowledge/claude-code.md`: binary 2.1.220 → 2.1.319.
- `markdowns/agents/vendor-knowledge/codex-cli.md`: binary 0.144.5 → 0.162.1 installed. npm latest is 0.167.0, so claims about 0.163+ are tagged low-confidence.
- `markdowns/agents/vendor-knowledge/antigravity-cli.md`: binary 1.1.20 → 1.5.3. It auto-updated from 1.4.12 during the walk.
- `markdowns/agents/model-capabilities.md`: model rows and pricing for all three vendors, the tier map, and the enforcement-status block.
- Consistency sweep:
  - `markdowns/meta-layer/cross-vendor-harness.md`
  - `.claude/hooks/README.md`
  - `.claude/agents/Explore.md` (maintainer HTML comment only; the pin is unchanged)
  - `markdowns/agents/README.md`
  - `markdowns/protocols/cross-vendor-review.md` (one sentence)
- `markdowns/agents/refresh-log.md`: 4 ledger lines, plus residual-table updates.

## Scope — what's deliberately out

Supervisor ruling R4 sends the following to a separate Tier 1 PR. They are recorded as OPEN in the ledger and the vendor files:

- **(d)** The Codex call in `cross-vendor-review.sh` passes no `-m`.
- **(e)** On the Claude call, user `permissions.allow` rules stay in force under `--safe-mode`.
- **(a)** The agy denial regex misses the 1.1.27+ notice.
- **(b)** `--mode plan` no longer acts as a headless gate.
- **(c)** Exit code 3 collides between agy and the dispatcher.
- The agy write-refusal probe needs a re-run on 1.5.3.

Also out of scope:

- The Antigravity probe keys `headless-write-probe` and `headless-write-probe-verified-on: 1.1.20` are **deliberately unchanged**. The version gate must keep refusing dispatch until the probe is re-run.
- The AGENTS.md → CLAUDE.md sync hook is **kept** (ruling R5), even though Claude Code ≥2.1.277 reads AGENTS.md natively. That native read is only a fallback when no CLAUDE.md exists.
- The root `README.md` is maintainer surface and is not edited here.

## FCPSS coverage

- **F (Functional):** Agents reading these files get current facts. Notable changes:
  - Claude's subagent `model:` pin is now documented as a default, not enforcement.
  - Codex now has `agents.default_subagent_model`.
  - `codex mcp-server` is removed.
  - Hook counts are 33 / 12 / 6.
  - The tier map is re-resolved: GPT-6.1 Sol is now Codex's workhorse; Sonnet 5.5 and Haiku 5.5 are Claude's workhorse and light tiers.
- **C (Cross-cutting):** Model facts live in `model-capabilities.md` as the SSOT, and the vendor files link to it rather than restating it. Hook counts are canonical in `cross-vendor-harness.md`. Cross-file claims to check for consistency:
  - claude-code.md §10 ↔ codex-cli.md §3.
  - antigravity-cli.md §8 ↔ cross-vendor-harness.md MCP section.
- **P (Performance):** N/A for runtime, since this is docs only. Cost-relevant: the tier map now resolves the review workhorse to `gpt-6.1-sol`, which the Tier 1 PR will pin.
- **S (Security):**
  - Documents the open dispatcher gaps without claiming any of them fixed.
  - Records the Codex hidden `--yolo` alias.
  - Records the agy 1.5.3 sandbox fix.
  - No secrets.
  - The probe keys the gate reads are byte-identical.
- **S (Stability):** `scripts/cross-vendor-review.sh` greps frontmatter keys out of `antigravity-cli.md`. Those keys are unchanged, and the gate was re-run by hand and still refuses on 1.5.3.

## Anchors for the cross-vendor review

- `markdowns/protocols/refresh-vendor.md`: channel reliability ordering. Executable claims need execution, not a page-fetch. Low-confidence tagging. The model-drift sweep rule.
- `markdowns/protocols/evidence-discipline.md` §4: absence of evidence is not evidence of absence.
- AGENTS.md "SSOT for shared values".
- `scripts/cross-vendor-review.sh:146` (claude), `:173` (codex), `:235-240` (agy version gate), `:278` (agy denial regex). The vendor files must describe these accurately as they exist today.

## Open questions

- Whether `agy acp` (an ACP server, not MCP) counts toward the "peer ships a server mode" revisit trigger. Recorded as open; not decided here.
