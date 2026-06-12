---
name: research-methodology
description: Per-data-point research discipline. Each claim entering shipping data carries a source URL, a confidence rating, and an audit trail. Cross-vendor methodology audit at completion (not as a diff). Separate engine from code review.
status: reference
---

# Research methodology

Research output that feeds shipping data (model prompts, user-facing
claims, domain mappings, fact-bases) is a separate review engine from
code review. The reviewer audits the methodology, not a diff —
there's no code, just data and the process that produced it.

## Per-data-point discipline

Each data point that ends up in shipping data carries:

| Field | What |
|---|---|
| **Source** | Primary source URL (or named expert reference). Not "I think" or "common knowledge." |
| **Confidence** | High / Medium / Low — based on source reliability, freshness, corroboration |
| **Audit trail** | Where this data point lives now, what it feeds, when it was last verified, who flagged any earlier issues |

A data point that can't fill all three doesn't ship.

## When the rubric fires

Research methodology fires per the tier of what the research feeds:

| Research feeds into | Methodology tier |
|---|---|
| Model prompts that ship to all users | **Tier 1** — methodology + cross-vendor audit mandatory |
| User-facing claims (marketing site, blog) | **Tier 2** — methodology + cross-vendor audit mandatory (lighter bar) |
| Internal-only decisions / analyses | **Tier 3** — methodology trail required, audit optional |

## The audit

Audit happens **at completion**, not as a diff. The reviewer reads:

- The per-data-point trail (source, confidence, audit)
- The aggregate distribution (low-confidence claims clustered? all from one source?)
- The methodology itself (was the search strategy appropriate? did the
  researcher stop too early? did they triangulate against primary
  sources?)

## Rolling chat updates

Per uncertain data point, the researcher surfaces a rolling chat
update — "data point X, source URL, confidence Medium, here's why" —
and the supervisor intervenes only when confidence is low or sources
conflict. The chat is the audit trail in real time.

## Confidence-rating heuristic

- **High** — multiple primary sources agree; recent; named experts in
  the relevant field
- **Medium** — single primary source OR multiple secondary sources OR
  expert consensus without explicit citation
- **Low** — single secondary source OR contested claim OR claim that
  the researcher couldn't independently verify

A claim shipping at Low confidence requires explicit supervisor
approval at the chat-checkpoint.

## Adapt for your project

Decide what counts as a "data point" in your domain. Specify what
sources are acceptable (peer-reviewed papers, official documentation,
verified expert accounts). Set the threshold at which "this is too
many low-confidence claims" blocks shipping. Author the reviewer-prompt
template for the cross-vendor methodology audit.
