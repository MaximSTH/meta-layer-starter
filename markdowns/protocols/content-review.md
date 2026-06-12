---
name: content-review
description: Cross-vendor review rubric for user-facing rendered content (paywall copy, marketing copy, model-generated user text, error copy, onboarding strings, action labels). Fires per the tier of the implementation the content ships with.
status: reference
---

# Content review

User-facing content (copy that appears in a UI, an email, a model
response, an error message) is reviewed by a different vendor than
the one that wrote it. A different vendor catches the rationalized
phrasing the author lived with — the "review your own about-me page"
intuition, generalized.

## When the rubric fires

Content inherits the tier of the implementation it ships with:

| Content category | Typical tier |
|---|---|
| Action labels on mutating admin operations; error copy users can't dismiss; model-generated user text that ships to all users | **Tier 1** |
| Marketing-site copy, paywall flow copy, onboarding screens, new analytics-event labels users see | **Tier 2** |
| Internal tooltips, copy behind a paid wall already audited at Tier 1/2 | **Tier 3** (optional same-vendor) |
| Console-only debug strings, log-message strings, formatter-only diffs | **Tier 4** (skipped) |

## The rubric

| Dimension | Question |
|---|---|
| **Voice match** | Does the copy match the project's copywriting register (user-facing voice vs professional / clinical voice)? |
| **Concrete vs abstract** | Is the copy specific to what the user is doing, or is it stock marketing language? |
| **Action-meaning fidelity** | Does the label accurately describe what the button does? (Especially: does the label change the apparent meaning of a destructive action?) |
| **Length** | Is the copy short enough for its container at the smallest target width? |
| **Jargon density** | Does the copy lean on internal vocabulary that won't land with the audience? |
| **Brand-voice alignment** | Does the copy reflect the brand register your project's copywriting spec defines? |
| **Em-dash / forbidden constructs** | Does the copy follow your project's banned-construct rules (em-dashes, oxford commas, hyphenation conventions)? |

## Anchored vs no-anchor

Same rule as code review per [`cross-vendor-review.md`](cross-vendor-review.md).
A content observation cites a brand-spec line, a copywriting register
file, or a length constraint (e.g., a button's max width). Aesthetic
preferences without a citation go in no-anchor and auto-decline.

## Adapt for your project

Author your project's copywriting register specs — user-facing voice,
professional/clinical voice if you have one, brand-voice rules,
forbidden constructs. Each spec is what content-review anchors
against. Author the reviewer-prompt template.
