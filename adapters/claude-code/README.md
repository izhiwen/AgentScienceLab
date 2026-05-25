# AgentScienceLab — Claude Code Adapter

## Current state in v0.2.x

This directory ships the Claude Code adapter content that the AiPlus
installer reads when running `aiplus add agentsciencelab` against a project
that already has `aiplus install claude-code` applied. After install,
**Claude Code agents auto-use ASL features without you reminding them
each session.**

What lands in the user's project:

- `.claude/agents/agentsciencelab-*.md` — 22 subagents (8 core roles + 14
  expert specialists) with YAML frontmatter tuned for Claude Code's
  auto-routing. Persona bodies are loaded from
  `core/templates/personas/*.md`.
- `.claude/commands/asl-*.md` — 4 slash commands (`/asl-route`,
  `/asl-talk`, `/asl-fire-consultant`, `/asl-status`) for explicit
  invocation when auto-routing isn't what you want.
- ASL managed block in `CLAUDE.md` (separate markers from AiPlus's
  block) — declares the research team, expert directory, natural-
  language routing map, and coordinator discipline.

The ASL block coexists with the AiPlus block. AiPlus's `SessionStart` /
`PreCompact` hooks (declared in `.claude/settings.local.json`) continue
to fire and inject project memory + prepare compact handoff. ASL adds
the research-team layer on top.

## File map (this directory)

| File | Purpose |
|---|---|
| `subagents.toml` | Manifest of 22 Claude Code subagents — name, description (drives auto-routing), and `persona_file` (system prompt source). |
| `claude-md-block.md` | Body of the `<!-- BEGIN AIECONLAB MANAGED BLOCK -->` … `<!-- END AIECONLAB MANAGED BLOCK -->` section that AiPlus inserts into the user's project `CLAUDE.md`. |
| `commands/asl-route.md` | Slash command — explicit PI-style task routing. |
| `commands/asl-talk.md` | Slash command — load a specific role's persona as active context. |
| `commands/asl-fire-consultant.md` | Slash command — fire the research-tuned consultant team before non-trivial plans. |
| `commands/asl-status.md` | Slash command — one-shot team status. |

## How it gets installed

1. User runs `aiplus install claude-code` in their project — writes the
   5 AiPlus subagents, `.claude/settings.local.json` hooks, and the
   AiPlus CLAUDE.md block.
2. User runs `aiplus add agentsciencelab` — AiPlus reads this directory's
   contents from its embedded asset table and:
   - For each entry in `subagents.toml`, reads the matching persona
     file, prepends YAML frontmatter (`name`, `description`), and
     writes `.claude/agents/agentsciencelab-<name>.md`.
   - Copies each `commands/*.md` to `.claude/commands/`.
   - Inserts the contents of `claude-md-block.md` between
     `<!-- BEGIN AIECONLAB MANAGED BLOCK -->` and
     `<!-- END AIECONLAB MANAGED BLOCK -->` in the project root
     `CLAUDE.md` (creates the file if missing; preserves user content
     outside the block).
3. Optionally: re-run `aiplus install claude-code` later to refresh
   AiPlus content; ASL content survives because markers differ.
4. `aiplus doctor` verifies all 22 subagents, slash commands, and the
   ASL managed block are present.

## Role switching from natural language

Claude Code recognizes role switches like "you are PI" or "take the
referee role" without explicit slash-command invocation. The
`subagents.toml` description and YAML frontmatter on each
`.claude/agents/agentsciencelab-*.md` give Claude Code's auto-router enough
signal to re-bind the active persona when you name a role mid-session.
Verified at 10/10 on the AiPlus G1 test matrix.

## Uninstall

`aiplus uninstall --yes` strips the ASL managed block from `CLAUDE.md`
and the AiPlus managed block. Subagent and slash-command files are
left in place (consistent with AiPlus's adapter-file retention) — they
become inert without the `aiplus` binary on PATH, and they can be
manually deleted if desired.

## Safety boundaries

- No global config edits (`~/.claude/` is never touched).
- No secrets written. Persona files, role configs, and consultant-team
  config never contain credentials or restricted data paths.
- Owner-gated actions (journal submission, posting, sending referee
  responses, data sharing, authorship-order changes) never auto-fire
  from subagents or slash commands. They surface as recommendations
  awaiting explicit Owner confirmation.
