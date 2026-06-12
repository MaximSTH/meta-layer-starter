---
name: failure-attribution
description: Four-category rubric for attributing a production failure. Agent error, protocol gap, supervisor miss, or vendor regression. Forces a single attribution before retry so the team doesn't keep fixing the wrong layer.
status: reference
---

# Failure attribution

When something ships broken — a wrong recommendation merged, a
customer-facing bug, an outage — the team needs to know which layer
to fix. Without an attribution rubric, the default is "try the same
fix differently," which masks the actual cause and burns time.

This protocol forces a single attribution before any retry. The cost
is 5–10 minutes of disciplined diagnosis; the saving is the days you
don't spend fixing the wrong layer.

## The four categories

Walk top to bottom. Pick the first match. If two match equally, pick
the higher (more upstream) category — fixing the upstream cause also
fixes the downstream symptom.

| # | Category | What it means | Where to fix |
|---|---|---|---|
| **1** | **Vendor regression** | The model / CLI / API behaved differently than its vendor knowledge file documents. A flag changed, a model deprecated a capability, a rate limit dropped. | Refresh the vendor knowledge file (`/refresh-vendor <vendor>`); add a new claim with citation; update any code that depended on the old behavior. |
| **2** | **Protocol gap** | The protocols don't cover the failure mode — there's no rule that would have caught this. Either no protocol applies, or the protocol that should fire doesn't have language addressing this case. | Author the missing protocol section, or add a new protocol if no existing one fits. Wire citations from build-feature / refactor-extraction / cross-vendor-review where it should fire. |
| **3** | **Supervisor miss** | A protocol exists that should have caught this, and the supervisor approved the change anyway — either rubber-stamped a chat checkpoint, missed a flag in a cross-vendor review report, or skipped a rubric walk that should have run. | Reflect on the checkpoint that approved the change. Author a one-line lesson into the supervision protocol or the team's lessons-learned log. |
| **4** | **Agent error** | All three categories above ruled out. The protocols covered the case, the supervisor caught what they could, the vendor behaved as documented — and the agent still produced wrong output within its constraints. | Investigate the prompt context the agent had. Add anchored examples to the relevant protocol (showing the right pattern next to the wrong pattern). Walk evidence-discipline on whether the agent's verification was incomplete. |

## The walk

1. **Reproduce the failure cleanly.** State what happened in one
   sentence. State what should have happened in one sentence.
2. **Check the vendor knowledge file first.** Did the failed
   capability claim match what the vendor's binary / API actually
   does? If not → category 1.
3. **Check the protocol surface.** Is there a protocol that should
   have caught this? Find the closest fit and read its rubric. If no
   protocol covers the case → category 2.
4. **Check the supervision trail.** Look at the chat checkpoint that
   approved the change. Did the approver have the right signal to
   reject? If the signal was there and the approver missed it →
   category 3.
5. **Everything else → category 4.** The agent produced wrong output
   within constraints that should have held. Investigate the agent's
   reasoning trace if available.

## What this protocol prevents

The most common failure pattern in agent-driven codebases: a failure
ships, the team retries the agent with a slightly different prompt,
ships the same broken pattern again. The attribution rubric forces
the team to ask "is the agent the problem, or is the layer above the
problem?" — and points the fix at the right layer.

Vendor regressions stay invisible if you only retry the agent.
Protocol gaps stay invisible if you only blame the agent. Supervisor
misses get masked by claiming "agent error" if no one walks this
rubric. The discipline is in the explicit attribution.

## Cross-cite

- [`evidence-discipline.md`](evidence-discipline.md) — applies at
  step 5 when investigating whether the agent's verification was
  incomplete (rule 4: absence-of-evidence reporting).
- [`refresh-vendor.md`](refresh-vendor.md) — the protocol the
  category-1 fix walks (vendor knowledge file refresh).
- [`build-feature.md`](build-feature.md), [`refactor-extraction.md`](refactor-extraction.md), [`cross-vendor-review.md`](cross-vendor-review.md) — protocols a new category-2 section should wire into when authored.
- [`supervision.md`](supervision.md) — the protocol the category-3
  fix updates (lessons-learned at the chat checkpoint level).

## Adapt for your project

Add per-team conventions for tracking attributions over time. A
simple `markdowns/lessons-learned.md` with one bullet per attributed
failure gives you a pattern surface — when category 2 (protocol gap)
recurs, you're missing a protocol; when category 4 (agent error)
recurs, you have an anchored-examples gap in your prompts.

Don't attribute publicly to humans by name in shared logs. The
discipline targets the layer that needs fixing, not blame.
