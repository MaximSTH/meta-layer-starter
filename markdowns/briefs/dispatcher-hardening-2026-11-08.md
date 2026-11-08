# Brief — `dispatcher-hardening-2026-11-08`

## What's the work

Fixes the cross-vendor review dispatcher (`scripts/cross-vendor-review.sh`)
gaps found by the 2026-11-08 vendor refresh (PR #21), and updates the
docs that describe it.

- Reviews pin their model by tier instead of inheriting the operator's.
- Claude reviews get read-only tools only.
- Antigravity reviews fail closed on any denied tool action, using agy's JSON output.

Every behavior change was probed by execution before it was written.

## Tier

Tier 1. This is the security boundary of the review dispatcher: what a peer reviewer may execute, and when a review is refused.

## Scope — what's in

- **`--tier workhorse|frontier|light`** (default `workhorse`), resolved per vendor to a pinned model:
  - claude: `sonnet` / `opus` / `haiku`
  - codex: `gpt-6.1-sol` / `gpt-6-astra` / `gpt-6-luna`
  - antigravity: `gemini-3.8-flash-high` / `-low`; frontier exits 2

  A `Reviewer:` audit line is printed to stderr. Supervisor ruling: Sol is the Codex workhorse, and the authoring model may change the tier, recording why in the checkpoint.
- **codex:** `-m "$REVIEW_MODEL"` and `-c 'notify=[]'`.
- **claude:** `--tools "Read,Grep,Glob"` plus the tier model.
- **antigravity:**
  - Flags: `--output-format json`, `--model`, and `AGY_CLI_DISABLE_AUTO_UPDATE=1`. `--mode plan` is removed.
  - JSON envelope check: refuse unless `status` is SUCCESS, `denied_actions` is empty, there is no `finished_reason`, and `response` is non-empty. Parsed with python3, falling back to jq; if neither is available, refuse.
  - The widened text grep now scans agy's stderr only.
- **Exit codes:** a peer-vendor exit of 2, 3 or 4 is remapped to 1.
- **Stale items fixed:** the agy comment and the codex `INSTALL_URL`.
- **Antigravity probe record:** `headless-write-probe-verified-on: 1.5.3`, which re-enables Antigravity dispatch.
- **Docs:**
  - `cross-vendor-review.md`: read-only claim and a new reviewer-model paragraph.
  - `claude-code.md`, `codex-cli.md`, `antigravity-cli.md`: §9 flag sets, with open warnings now resolved.
  - `model-capabilities.md`: Codex and Antigravity rows.
  - README "Recent" note.
  - `refresh-log.md`: two rows closed and one ledger line added.

## Scope — what's deliberately out

- A `--json-schema` review-observation schema for Antigravity. The review body stays free text; only outcome checking moved to JSON.
- Behavioral confirmation that `AGY_CLI_DISABLE_AUTO_UPDATE` works. It is set but untested; the version gate is the real guard.
- Codex/Antigravity subagent-model enforcement (separate open row).

## FCPSS coverage

- **F (Functional):** Reviews run on the tier's model. A `frontier` tier on antigravity exits 2 with a message. Antigravity review works again on 1.5.3. End-to-end runs on all three vendors returned formatted reviews.
- **C (Cross-cutting):**
  - The tier→model mapping in the script is a declared quote of `model-capabilities.md`.
  - The protocol, the vendor files and the README describe the new flags.
  - `setup.sh` rewrites only the `TO=` line, which is unchanged in shape.
- **P (Performance):** Codex reviews now run on `gpt-6.1-sol` instead of the operator's `gpt-6-astra`, about 5× fewer credits per token. No added round-trips.
- **S (Security):**
  - Claude reviewer: was 26 tools, including Bash through operator allow rules; now Glob, Grep and Read only (probed).
  - Codex: the operator's `notify` hook no longer runs.
  - Antigravity: write refusal re-probed on 1.5.3. Any denied action, error, timeout or unparseable output now fails closed.
- **S (Stability):**
  - Missing python3 and jq → refuse rather than accept.
  - Exit codes no longer collide (agy timeout no longer reads as a rate limit).
  - Text grep confined to stderr, which avoids false refusals on reviews that quote denial phrases.

## Anchors for the cross-vendor review

- `scripts/cross-vendor-review.sh`: the tier mapping block, the claude/codex/antigravity branches, the belt-and-braces grep, and the exit remap.
- Probe evidence in the code comments and in `refresh-log.md`, 2026-11-08 dispatcher line.
- `markdowns/protocols/cross-vendor-review.md`: "Who runs the command" and "Reviewer model".
- `markdowns/protocols/refresh-vendor.md`: "Executable claims must be verified by execution".

## Open questions

- None.
