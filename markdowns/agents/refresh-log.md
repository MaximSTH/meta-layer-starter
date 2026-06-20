---
name: vendor-refresh-log
description: Append-only ledger of /refresh-vendor walks. A walk that finds no drift records only here (no PR). A walk that finds drift records here AND ships a knowledge-file update PR.
status: active
---

# Vendor refresh log

Append-only. Newest entries at the bottom. Each line:

```
YYYY-MM-DD  <vendor>  <result>  <notes>
```

Result codes:

- `no-drift` — walked every claim, none changed. No knowledge-file edit.
- `drift-applied` — drift detected, supervisor approved, knowledge file updated, PR shipped.
- `drift-declined` — drift detected, supervisor rejected (e.g., vendor announcement looked premature). No knowledge-file edit; reason in notes.
- `partial` — could not walk every claim (e.g., docs site down, binary unavailable). Notes which claims were verified.

The log's purpose is **proof that the walk happened** even when no
file changed. A "no-drift" walk is real work — re-verifying claims
takes time — and the ledger preserves the timestamp so the next walk
knows when freshness was last confirmed.

## Entries

```
2026-06-20  codex-cli        drift-applied  Skills §2/§3/§10 + harness reframe. Codex now ships a first-party skills primitive (open Agent Skills standard, .agents/skills/ scan cwd→repo-root, name+description, $skill + description-match invocation). Prior "no first-party skills primitive" claim corrected. Source: developers.openai.com/codex/skills, agentskills.io.
2026-06-20  antigravity-cli  drift-applied  Skills §2 upgraded from TBD/low-confidence to CONFIRMED. Workspace skills load from <workspace-root>/.agents/skills/, global from ~/.gemini/antigravity/skills/; open Agent Skills standard, official Google Codelab. Cross-vendor .agents/skills/ compatibility confirmed. Source: antigravity.google/docs/skills, codelabs.developers.google.com/getting-started-with-antigravity-skills.
```
