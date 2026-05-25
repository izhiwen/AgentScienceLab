# AgentScienceLab — OpenCode Adapter

## Current state in v0.3.x

This adapter ships OpenCode-native ASL assets. After a project installs
OpenCode support and opts into AgentScienceLab, AiPlus writes:

- 22 ASL subagents to `.opencode/agents/agentsciencelab-*.md`
- 4 slash commands to `.opencode/commands/asl-*.md`
- project-local ASL module assets under `.aiplus/modules/agentsciencelab/`

The generic `agent` subcommand remains runtime-aware and still works:

```bash
aiplus install opencode       # installs .opencode/ prompts and configs
aiplus agent route pi <task>  # creates worktree, logs dispatch
aiplus agent talk pi          # spawns OpenCode with pi.md pre-loaded
```

The persona definitions (`core/templates/personas/*.md`) remain
runtime-agnostic Markdown. `subagents.toml` maps each ASL role to the
matching persona file and supplies routing descriptions for OpenCode's
agent surface.

## Included files

| File | Purpose |
| --- | --- |
| `subagents.toml` | Manifest of 22 OpenCode subagents: name, routing description, and source persona. |
| `commands/asl-route.md` | Explicit PI-style routing command. |
| `commands/asl-talk.md` | Role-switch command for opening a specific ASL persona. |
| `commands/asl-fire-consultant.md` | Research consultant-table command for non-trivial plans. |
| `commands/asl-status.md` | Team status snapshot command. |

## Install check

```bash
aiplus install opencode
aiplus add agentsciencelab
aiplus doctor
```

Expected result: `.opencode/agents/` contains 22 prefixed ASL agent
files, `.opencode/commands/` contains the four `/asl-*` commands, and
`aiplus doctor` reports `DOCTOR_STATUS=PASS`.

## Role switching from natural language

OpenCode's interactive TUI recognizes role switches like "you are PI"
or "switch to the Referee" without explicit slash-command invocation.
The `subagents.toml` description gives OpenCode's agent picker enough
signal to re-bind the active persona mid-session. Note: in
non-interactive `opencode run` mode, this is currently limited by
OpenCode itself — we're tracking the upstream fix.
