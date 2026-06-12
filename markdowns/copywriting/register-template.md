---
name: copywriting-register-template
description: Skeleton for a project's copywriting register. Copy to a per-audience register file (e.g. `user-facing.md`, `professional.md`). The agent reads it on every copy decision targeting that audience.
status: template
---

# Copywriting register — `<AUDIENCE NAME>`

Per-audience copy rules. One file per audience register the project
ships (consumer / professional / internal / legal / etc.). The agent
walks this on every copy decision for this audience per
`content-review.md`.

## Audience

One paragraph: who reads this copy, what they expect, what they don't.
The persona files in `markdowns/design/personas/` are the long form;
this is the operational summary.

## Voice rules

Three to five rules max. Each is a specific, falsifiable instruction
the agent can apply to a single sentence.

- **`<RULE 1>`** — one sentence + a one-sentence "what this prevents."
- **`<RULE 2>`** — same shape.
- **`<RULE 3>`** — same shape.

Example:
- **No marketing puffery.** No "world-class," "best-in-class,"
  "cutting-edge," "leverage," "synergy." If a senior product person
  would mock the phrase, it's puffery.

## Tone calibration

| Surface | Tone | Why |
|---|---|---|
| Action buttons | Imperative + concrete | Reduces hesitation |
| Error messages | Blameless + action-pointing | Reduces support tickets |
| Confirmation flows | Reassuring + brief | Maintains momentum |
| Marketing headline | `<TONE>` | `<WHY>` |

## Banned words / phrases

List specific banned items the agent will respect mechanically. The
pre-commit hook can enforce these if the cost-benefit justifies it.

- `<BANNED PHRASE>` — why
- `<BANNED PHRASE>` — why

## Three calibration samples

- **Before:** `<WEAK COPY>` → **After:** `<STRONG COPY>` — why.
- **Before:** `<WEAK COPY>` → **After:** `<STRONG COPY>` — why.
- **Before:** `<WEAK COPY>` → **After:** `<STRONG COPY>` — why.

## Walked by

- `markdowns/protocols/content-review.md` — every copy change to this
  audience walks this file's rules.
- `markdowns/design/brand-guide-template.md` (renamed to your project's
  `brand-guide.md`) — voice traits feed register-level rules.

## Adapt for your project

Ship one register per distinct audience. The split is usually
audience-shaped, not surface-shaped — "consumer" register applies to
marketing site AND in-product copy if both target the same audience.
Add a new register when an audience's tone diverges meaningfully from
existing ones.
