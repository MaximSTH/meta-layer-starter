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

(none yet — first entry will land when `/refresh-vendor` runs against
a vendor file in this template)
