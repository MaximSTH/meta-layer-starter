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
2026-07-18  antigravity-cli  drift-applied  Local binary 1.0.14→1.1.4. Installer bootstrap/native-setup flag split + custom-dir behavior corrected; custom/nested agents, hooks paths, built-in guide/dynamic skills, MCP timeout/path fixes, and headless error behavior added. Tier 1 safety correction: dispatcher floor raised to 1.1.4 with no override; requires global strict+sandbox policy, project hardening, --mode plan, recorded write-refusal probe, and inline targets so no read grant is needed. Probe first falsified scratch-local settings (sentinel created in Antigravity default scratch, then removed); after persisting global toolPermission=strict + enableTerminalSandbox=true, headless write_file was explicitly auto-denied and no sentinel existed. Live Tier 1 Antigravity review completed tool-free: no anchored defects; no-anchor suggestions auto-declined per protocol; external claims reconciled against refresh evidence. Headless strict mode loaded but did not honor wildcard or exact-path read_file grants, so both temporary grants were removed and the dispatcher fails closed on permission-denial output. SPA-blocked rate-limit/pricing claims stayed unverified and unchanged. Sources: agy --version/--help/install --help/agent --help v1.1.4, official install.sh, GitHub CHANGELOG + v1.1.4 release, bundled antigravity_guide, live agy --print peer review 2026-07-18.
```
