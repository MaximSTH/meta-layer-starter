# Brief — `ci-gitleaks-secret-scan`

## What's the work

Make the pre-push secret gate CI-authoritative. Today supervision.md
calls the full-history gitleaks scan "a hard gate, not advisory," but
nothing mechanical backs it — no hook exists and check.yml has no
secret step, so the gate holds only when agents follow protocol. This
adds a `secret-scan` job to check.yml running the exact command
supervision.md mandates, mirroring how mirror-sync is already gated
("same gates run twice — CI is authoritative").

## Tier

Tier 2. Touches the security-enforcement surface and edits a protocol
file (supervision.md); not Tier 1 (additive and trivially revertible —
no auth flow, no data migration); erred up from Tier 3 per
stake-matrix's uncertainty rule.

## Scope — what's in

- `.github/workflows/check.yml` — new `secret-scan` job: checkout with
  `fetch-depth: 0` (full history — the point of the gate), download
  pinned gitleaks v8.30.1 (matches the version verified locally this
  session), run the same subcommand and flags supervision.md:83
  specifies (`gitleaks git --no-banner .`, invoked as `./gitleaks`
  since the binary is extracted to the working directory).
- `markdowns/protocols/supervision.md` — one sentence added to the
  "Pre-push secret gate" section noting CI re-runs the same scan, so
  the gate holds even when a local run is skipped.

## Scope — what's deliberately out

- The official `gitleaks/gitleaks-action` — needs a license key for
  org accounts and hides the command; the raw binary keeps CI running
  the same subcommand and flags the protocol names.
- Branch protection / rulesets on main (verified absent: API returns
  404 / zero rulesets) — enabling them is a repo-settings decision for
  the supervisor, recommended in the checkpoint; until then, blocking
  is protocol discipline (merges held to CI green), which the amended
  supervision.md sentence now states accurately.
- A git pre-push hook — supervision.md deliberately specifies an
  agent-run scan with a logged result, not a hook; CI is the backstop
  layer, matching the existing mirror-sync design.
- Any change to gate semantics, .gitignore patterns, or other jobs.

## FCPSS coverage

- **F (Functional):** No runtime behavior. System-visible: PRs and
  pushes to main now fail CI if any commit in history contains a
  detectable secret.
- **C (Cross-cutting):** check.yml (shared CI gate) + supervision.md
  (protocol, quoted by AGENTS.md's principles). The added sentence
  restates no values; it points at check.yml.
- **P (Performance):** CI-only: one extra parallel job, ~10-20 s
  (binary download + 172 ms scan at current repo size, measured
  locally). No developer-facing latency.
- **S (Security):** The change IS the security improvement: secret
  gate goes from protocol-only to mechanically enforced. Pinned
  version (no `latest` tag), release asset URL verified (HTTP 200).
  False positives block merge until triaged — intended behavior.
- **S (Stability):** A gitleaks release-asset outage would fail the
  job (fail-closed, correct for a security gate). Version bump path:
  edit one pinned string.

## Anchors for the cross-vendor review

- `markdowns/protocols/supervision.md:74-100` — the gate this
  mechanizes; CI must run the same command it names.
- `.github/workflows/check.yml:1-7` — the "same gates run twice / CI
  is authoritative" design comment the new job must match.
- Local verification this session: `gitleaks version` → 8.30.1;
  `gitleaks git --no-banner .` → clean, 26 commits.

## Open questions

- None.
