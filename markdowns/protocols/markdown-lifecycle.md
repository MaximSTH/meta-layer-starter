---
name: markdown-lifecycle
description: Every markdown file in the project tree carries YAML frontmatter (name, description, status). Files transition status across their lifecycle (draft → active → reference → archived) so cold readers can tell at a glance what's load-bearing and what's frozen.
status: reference
---

# Markdown lifecycle

Every `.md` file in the project's authored-content tree
(`markdowns/` and equivalents) carries YAML frontmatter. The
frontmatter makes the file's lifecycle visible to cold readers and
tooling.

## Required frontmatter

```yaml
---
name: <file-slug>
description: <one-line summary — used for indexing and search>
status: <draft | active | reference | archived>
---
```

| Field | What it does |
|---|---|
| **`name`** | The file slug (matches the filename without extension). Used by tooling that builds indexes. |
| **`description`** | A one-line summary. Used in Doc Map tables and search results. |
| **`status`** | The file's lifecycle phase. Drives tooling behavior. |

## Status values

| Status | What it means |
|---|---|
| **`draft`** | Work in progress. Not yet ready to be cited. Lint can be looser. |
| **`active`** | Currently load-bearing. Other docs cite it. Lint applies in full. |
| **`reference`** | Stable reference material (e.g. a protocol). Edits possible but rare. |
| **`template`** | A skeleton intended to be **copied** into a project file, not read as in-force content. Carries placeholders (`<RULE 1>`, `<HEX>`). The filename usually ends in `-template.md` or `_template.md`. Lint may relax (placeholders are expected, not violations). |
| **`archived`** | Frozen historical record. Do not edit. Linked from descendants for context only. |

## Lifecycle transitions

```
draft → active → reference
        active → archived (when superseded by a successor)
template stays template (the skeleton itself is never "in force" — only its copies are)
```

Once a file is `archived`, do not edit it. The frontmatter status is
the durable signal that the content is frozen.

## File naming

- **Lowercase, hyphen-separated** filenames: `cross-vendor-review.md`,
  not `Cross_Vendor_Review.md` or `crossVendorReview.md`.
- **No numeric prefixes** (`01-foo.md`, `phase-3-bar.md`) — descriptive
  names only. Numeric prefixes rot when ordering changes.

## Where this protocol fires

- **Frontmatter validation** — convention in the starter, enforced by
  per-project pre-commit gates (the starter ships
  `scripts/check-skill-frontmatter.sh` for the skill subset; broader
  markdown frontmatter validation is a project-specific addition when
  the drift count justifies a gate).
- **Doc Map generation** reads the `description` field to populate
  index tables.
- **Archive operations** verify the file is `status: archived` before
  moving it to an archive directory.

## Exception folders

Some directories hold content that doesn't fit this lifecycle —
ephemeral session briefs, third-party content, legal documents.

The starter ships with these exceptions baked in:

| Path | Why exempt |
|---|---|
| `markdowns/briefs/` | Briefs are ephemeral session artifacts — committed at Step 0, `git rm`'d post "ship it". YAML frontmatter on a file you're about to delete is overhead with no payoff. |
| `markdowns/agents/refresh-log.md` | Append-only ledger; frontmatter is on the file itself but log entries don't carry per-entry frontmatter. |

Add to the list when you find a folder that genuinely doesn't fit
(third-party content, generated docs, etc.). The list is conventional
today — when the count of exception-eligible folders justifies a gate,
author a pre-commit check that reads from a `.markdown-lifecycle-exempt`
file at the repo root.

## Adapt for your project

Pick which directories the lifecycle applies to. Set the pre-commit
hook to enforce frontmatter on those paths only. Author exception
lists for ephemeral / legal / third-party folders.
