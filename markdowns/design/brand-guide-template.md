---
name: brand-guide-template
description: Skeleton for a project's brand guide. Copy to `brand-guide.md` and fill in. The agent reads this on every user-facing change to keep output consistent with brand voice + visual identity.
status: template
---

# Brand guide — `<PROJECT-NAME>`

Cross-surface brand SSOT. Read by the agent on any work touching
user-facing copy, visual design, or product surfaces. Keep it short —
brand decisions should fit in head, not in a 50-page document.

## Visual identity

- **Palette.** Primary `<HEX>`, secondary `<HEX>`, neutrals `<HEX>` /
  `<HEX>`. Why these colors (mood, audience, association).
- **Typography.** Display `<FONT>`, body `<FONT>`, fallbacks.
- **Spacing scale.** 4 / 8 / 16 / 24 / 32 / 48 / 64. Or your stack's
  default.
- **Layout grid.** Mobile-first / desktop-first / responsive base.
- **Logo.** Reference file. Clear-space rule. Acceptable variants.

## Voice + tone

| Trait | What it means | What it doesn't mean |
|---|---|---|
| `<TRAIT 1>` | One concrete sentence | One concrete sentence |
| `<TRAIT 2>` | | |
| `<TRAIT 3>` | | |

## Banned language

Specific words or phrasings that don't belong in user-facing output.
The pre-commit hook may enforce these depending on stack (em-dashes,
specific brand-conflicting terms, AI-sounding tics).

## Three reference samples

- **Headline that lands.** `<EXAMPLE>` — why it works.
- **Headline that doesn't.** `<EXAMPLE>` — why it doesn't.
- **Error copy.** `<EXAMPLE>` — short, blameless, action-pointing.

## Walked by

- `markdowns/protocols/content-review.md` — every user-facing copy
  change reviews against this file.
- `markdowns/protocols/persona-stress-test.md` — persona walkthroughs
  reference the voice rules here.

## Adapt for your project

This skeleton is intentionally minimal. Add sections as you find
brand decisions you keep re-litigating — accessibility palette,
icon style, photography rules, motion language. Don't add sections
preemptively; let the gaps surface as the project authors content.
