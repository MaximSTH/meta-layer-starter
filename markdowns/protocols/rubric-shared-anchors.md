---
name: rubric-shared-anchors
description: The five categories of anchors that every review rubric (code, plan, content, persona, research) accepts. An observation without one of these auto-declines.
status: reference
---

# Rubric shared anchors

Every review rubric in this project — code review, plan review,
content review, persona stress-test, research methodology — accepts
the same five anchor categories. The anchor categories are what makes
the **anchor-or-decline** rule per
[`cross-vendor-review.md`](cross-vendor-review.md) operational.

## The five anchor categories

| # | Anchor category | What counts |
|---|---|---|
| **1** | **Failing or missing test** | A test that fails on the current diff, or a test that *should* exist to cover this change and doesn't. Cite `file:line` + the assertion the test would make. |
| **2** | **Lint or pre-commit rule** | A named rule that fires on this change. Cite the rule name + `file:line` of the violation. |
| **3** | **Named section in project rules / protocols** | A specific section in `AGENTS.md`, a protocol file, or a per-surface rules file. Cite the file + named section heading (e.g., `cross-vendor-review.md "The two-stage flow"`) — or, when the file has numbered headings, the section number (e.g., `claude-code.md §4` for the Hooks section in the vendor knowledge file). |
| **4** | **Named section in brand / design / copywriting / spec files** | A specific section in a brand guide, component system, copywriting register, or design spec. Cite the file + section. |
| **5** | **Specific line in the brief passed with the review call** | A specific line in the `--brief` file. Cite the brief file + the line content or line number. |

## What does NOT count as an anchor

- **Aesthetic preferences** ("I would have done this differently")
- **Stylistic nits without a rule citation** ("this feels too verbose")
- **Vague references** ("the code is over-engineered" without naming a
  specific extracted concept)
- **Stale citations** (a rule that existed in a previous version but
  has since been removed)
- **Speculative future requirements** ("when we eventually add Y, this
  won't scale")

Observations failing the anchor test go in a separate **no-anchor**
section of the review output. They surface once at the chat
checkpoint and auto-decline.

## Why this is a single shared protocol

The anchor categories are stable across review types. A test is a test
whether you're reviewing code or content. A named section is a named
section whether you're reviewing a plan or a persona. Defining the
anchor categories once and citing them from each review rubric keeps
the rubrics consistent and easier to maintain.

## When this protocol fires

It doesn't fire on its own. It's cited from each review-type rubric
(`cross-vendor-review.md`, `plan-review.md`, `content-review.md`,
`persona-stress-test.md`, `research-methodology.md`) as the
definition of valid anchors.

## Adapt for your project

If your project has additional anchor categories (e.g., a specific
KPI threshold, a regulatory requirement, a SLA), extend the list here
and cite the extended list from each review rubric.
