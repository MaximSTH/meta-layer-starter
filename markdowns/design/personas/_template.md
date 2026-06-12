---
name: persona-template
description: Skeleton for a project persona. Copy to `<persona-name>.md` and fill in. The agent reads this when stress-testing user-facing changes against this user type per persona-stress-test.md.
status: template
---

# `<PERSONA NAME>`

One-sentence pitch — who this person is, in five words or less.

## Anchored claims

Each claim cites a source: a forum post, a review, a research study,
a documented customer conversation. **Invented claims don't ship** —
they fail `persona-stress-test.md` market-grounding mode.

| Claim | Source | Confidence |
|---|---|---|
| `<CLAIM>` | `<URL or named source>` | High / Medium / Low |
| `<CLAIM>` | | |
| `<CLAIM>` | | |

## What they care about

- (Specific, named outcomes — not abstractions.)
- (3-5 bullets max.)

## What makes them abandon

- (What causes drop-off. Specific failure modes, not vague friction.)
- (3-5 bullets max.)

## What they say (verbatim quotes from real discourse)

> `<DIRECT QUOTE from a real source>` — `<source>`

> `<DIRECT QUOTE>` — `<source>`

> `<DIRECT QUOTE>` — `<source>`

If you can't find real quotes from real people in your target audience,
the persona isn't grounded yet — author it from desk research first
before the agent uses it.

## Walked by

- `markdowns/protocols/persona-stress-test.md` — every change targeting
  this persona walks the rubric against this file.
- `markdowns/protocols/content-review.md` — copy decisions check
  against the voice claims here.

## Adapt for your project

Author one file per persona. The cross-vendor review's "anchored
observations" rule applies — claims without sources don't survive.
Personas without real-world grounding are just the team's imagination
projected onto a user; that produces product decisions the actual
users won't recognize.
