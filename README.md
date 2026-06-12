# meta-layer-starter

A template repository for spinning up an agentic codebase governed by the
**four-layer agent stack** pattern: **model · harness · meta layer ·
surfaces**.

> **Status: v0, first public draft.** The patterns inside survived
> months of internal use on a real production codebase, but external
> feedback hasn't shaped them yet. File issues; expect evolution.

For a worked example of what the gate actually looks like in action
(chat checkpoint, FCPSS coverage, cross-vendor review report), see
[`markdowns/meta-layer/example-pr-walkthrough.md`](markdowns/meta-layer/example-pr-walkthrough.md).

## What this template gives you

| Layer | What's in here | What you'll add |
|---|---|---|
| **Meta layer** | 17 **protocols** (pre-ship gates, cross-vendor review, supervision, build/refactor flows, evidence + iteration + failure-attribution discipline, markdown lifecycle, etc.) + vendor knowledge files for Claude Code / Codex CLI / Antigravity CLI | Brand guide, personas, copywriting register, product plans |
| **Harness** | 3 meta-skills (`/build-feature`, `/refactor-extract`, `/refresh-vendor`) + Claude Code hooks (secret-file deny + write-guard) + sync scripts (AGENTS.md → CLAUDE.md, `.agents/skills/` → `.claude/skills/`) + a pre-commit stub | Project-specific drift checks, lint config, file-size hooks |
| **Surfaces** | Empty (this is a template) | Your product code |
| **Model** | (vendor-owned, nothing to add) | n/a |

## Prerequisites

The template works in two modes:

| Mode | Requires | What you get |
|---|---|---|
| **Solo** (default) | Claude Code only | All 17 protocols + FCPSS + stake matrix + supervision + skills + hooks + Tier 3/4 auto-merge. Tier 1/2 PRs degrade to same-vendor self-review instead of cross-vendor. |
| **Cross-vendor** | Claude Code + at least one of: Codex CLI, Antigravity CLI | Everything above + cross-vendor review on Tier 1/2 PRs. The peer vendor reads the diff cold and surfaces anchored observations the worker missed. |

Install pointers per CLI:
- **Claude Code**: [`code.claude.com`](https://code.claude.com)
- **Codex CLI**: `npm install -g @openai/codex` ([docs](https://developers.openai.com/codex/cli))
- **Antigravity CLI**: `curl -fsSL https://antigravity.google/cli/install.sh | bash`

Optional tooling some scripts use:
- **`python3`**: `scripts/setup.sh` uses Python to update the refresh-vendor skill's hardcoded vendor list when you prune vendors. Pre-installed on macOS and most Linux distros. Without it, setup.sh warns and skips that one step.

## Quick start

```bash
# 1. Click "Use this template" on GitHub, name your new repo.
git clone git@github.com:<you>/<your-project>.git
cd <your-project>

# 2. Choose your vendor set. Prompts you for which CLIs you use
#    (claude / codex / antigravity). Prunes vendor knowledge files,
#    Antigravity's .gemini/ config dir, and cross-vendor-review.sh
#    defaults for the vendors you don't. Re-runnable later if you add
#    or drop a vendor.
scripts/setup.sh
#    Or non-interactively: scripts/setup.sh --vendors "claude codex"

# 3. Install the pre-commit hook. If you have an existing
#    pre-commit hook (husky / lefthook / pre-commit-go), it
#    will be backed up to .git/hooks/pre-commit.backup.<timestamp>
#    before being replaced. Merge by hand if you had custom rules.
scripts/install-hooks.sh

# 4. Refresh vendor knowledge. The capability matrices in this template
#    are accurate as of extraction but vendors update flags / rate limits
#    frequently. Run /refresh-vendor for each vendor you selected.
#
#    Open Claude Code in the repo and type these as Claude Code slash
#    commands (not shell commands):
#    /refresh-vendor claude-code
#    /refresh-vendor codex-cli         # if you selected codex
#    /refresh-vendor antigravity-cli   # if you selected antigravity

# 5. Author your project's Doc Map entries.
#    Open AGENTS.md (canonical source; CLAUDE.md is auto-mirrored
#    from it by the pre-commit hook; never edit CLAUDE.md directly).
#    Fill in:
#    - <PROJECT-NAME>
#    - <ONE-LINE-DESCRIPTION>
#    - <STACK>
#    - Project Overview section
```

## Your first session: bootstrap the foundation

You now have a configured repo and an empty project. The fastest way to
put the substrate to work is a guided foundation session: have your
agent capture the project's positioning, tech stack, and architecture
as durable markdown the rest of the work builds on.

Open your agent in the repo and paste the prompt below, filling in the
`<...>` placeholders. The three-document flow (overview, tech-stack,
architecture) is the common case for a greenfield software product.
Adapt the doc set to your project type; a research tool, a data
pipeline, or a library will want different documents.

```
We're laying the foundation for <PROJECT-NAME>. This is a deep-dive
working session, not a build session. The deliverables are three
documents, each with proper markdown-lifecycle frontmatter:

1. markdowns/product/overview.md: positioning (light is fine for now)
2. markdowns/engineering/tech-stack.md: tools + services, one-line
   rationale per choice
3. markdowns/engineering/architecture.md: system design

Before anything else: read <CLOSEST-QUALITY-BAR-REFERENCE: an existing
codebase, repo, or site whose quality is the bar this project must hit;
omit if none exists yet>. Read its structure before proposing any
architecture.

CONTEXT
- What we're building: <ONE-PARAGRAPH DESCRIPTION>
- Who it's for: <TARGET USER / MARKET>
- Strategy + constraints: <e.g. bootstrap vs funded, build-to-revenue
  vs build-to-sell, timeline, team split>
- What we're replacing or competing with: <EXISTING OPTION / PROTOTYPE>

PROCESS
Work conversationally, one section at a time. Take positions: one
clear recommendation, not a menu. Push back when I'm vague or
contradict an earlier decision. Capture every decision in the docs as
we go. Anything only a stakeholder can decide (and that I can't answer
now) gets marked explicitly as `TBD: <who> input` rather than
guessed, so I leave this session with a clean list of what I still
need from whom.

DOC CONTENTS
- overview.md: target customer, the problem with existing options, what
  we build, distribution, business-model shape, north-star metric, team
  split.
- tech-stack.md: frontend, hosting, database + auth, payments, any AI
  providers, third-party services. Every choice gets a rationale.
  Treat security + data handling as a first-class section, not a
  footnote: what sensitive data we hold, row-level-security on every
  table, access scoping, where data lives.
- architecture.md: the core structural decisions, a data-model sketch,
  the parts that are genuinely hard (call them out and take a position),
  and what the MVP must include vs defer.

Start with overview.md. Ask me your first question.
```

The `TBD: <who> input` markers are your post-session agenda: grep the
three docs for them and that's the exact set of decisions to take to
the people who own them. The documents themselves become the project's
durable memory, so the next session reads them instead of re-deriving
context.

## Walking through the protocols

Each protocol is a thin framework abstract, roughly 50-100 lines that
describe the *shape* of a rule, gate, or rubric without binding it to
any one stack. Every file ends with an **"Adapt for your project"**
section marking where you author project-specific examples. Read each
protocol once, then customize the closing section before applying.

Recommended read order for a fresh contributor:

1. [`markdowns/meta-layer/onboarding.md`](markdowns/meta-layer/onboarding.md):
   first-day walkthrough; ~20 min scan-mode.
2. [`markdowns/meta-layer/example-pr-walkthrough.md`](markdowns/meta-layer/example-pr-walkthrough.md):
   synthetic worked example showing what the gate produces in
   chat (FCPSS coverage, cross-vendor review report, iteration rounds).
3. [`fcpss-gate.md`](markdowns/protocols/fcpss-gate.md): the universal
   pre-ship checklist.
4. [`stake-matrix.md`](markdowns/protocols/stake-matrix.md): how to
   sort changes into four tiers.
5. [`cross-vendor-review.md`](markdowns/protocols/cross-vendor-review.md):
   the peer-vendor review rubric.
6. [`supervision.md`](markdowns/protocols/supervision.md): tier-aware
   merge gating + chat checkpoint.
7. Skim the rest as needed.

## Origin

This template was extracted from a real Flutter + Supabase + Next.js
codebase that runs Claude Code + Codex CLI side-by-side.
The patterns survived months of debate and real PR cycles before being
distilled to the shape you see here. Worked examples in the protocols
reference that source project's specifics; adapt them to yours.

## Author

Built by [Maxim St-Hilaire](https://maximsthilaire.com).

## License

MIT. See [`LICENSE`](LICENSE).
