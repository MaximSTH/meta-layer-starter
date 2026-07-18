# Antigravity CLI refresh — 2026-07-18

## Objective

Apply the supervisor-approved ten-delta Antigravity CLI refresh, including the
amended safety chain that must complete before Antigravity peer-review dispatch
is re-enabled.

## Required outcomes

- Upgrade the local `agy` binary from 1.0.14 to 1.1.4.
- Persist a restrictive project policy: strict tool permission, terminal
  sandbox enabled, non-workspace access disabled, and artifact review required.
- Run a headless write probe in a scratch repository. The probe passes only
  when the requested file write is explicitly refused and no target file is
  created.
- Record the probe result in the Antigravity vendor-knowledge file.
- Refuse Antigravity dispatch loudly unless the binary floor, restrictive
  policy, and recorded probe marker all pass preflight.
- Apply the remaining approved installer, agent, hooks, MCP, error-behavior,
  and volatility deltas. Leave SPA-blocked rate-limit and pricing claims
  unchanged and explicitly unverified.
- Append the refresh ledger after the approved changes and evidence land.

## Review anchors

- `markdowns/protocols/refresh-vendor.md` — supervised drift application.
- `markdowns/protocols/fcpss-gate.md` — research and security coverage.
- `markdowns/protocols/cross-vendor-review.md` — anchor-or-decline review.
- Supervisor amendment in this session — four-step re-enable chain and loud
  refusal until completion.

## Tier

Tier 1: the dispatcher safety boundary changes. Peer-vendor review and explicit
`ship it` are required before merge.
