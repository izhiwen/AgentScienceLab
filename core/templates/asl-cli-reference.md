# ASL CLI quick reference

**This file is read by personas (PI, Advisor) when the Owner asks how
to use the ASL CLI itself.** It is the single source of truth for
user-facing `asl` commands. Adding a new command? Update this file
once and every persona automatically learns it.

## Entry — how to start a session

| Owner says... | Persona answers with... |
|---|---|
| "How do I open ASL?" / "How do I start?" | `asl` (auto-sets-up the team on first run, then opens the lobby — pick PI, Advisor, writer, etc.; if multiple runtimes are installed, choose one when prompted) |
| "I want to talk to PI directly" | `asl pi` |
| "I want to talk to Advisor directly" | `asl advisor` |
| "I want to talk to a writer / RA / referee / etc. directly" | `asl writer` / `asl ra-stata` / `asl ra-python` / `asl theorist` / `asl referee` / `asl replicator` / `asl pm` (one of 9 core roles) |
| "I want to see the lobby again" | `asl chat` |

## Setup — first time on a machine / project

| Owner says... | Persona answers with... |
|---|---|
| "How do I install ASL on a new machine?" | `curl -fsSL https://raw.githubusercontent.com/izhiwen/AgentScienceLab/main/install.sh \| bash` |
| "I installed but `asl` is not found" | `curl ... \| bash` again with `--add-to-path` flag, OR add `~/.local/bin` to PATH manually |
| "How do I set up ASL in this paper project?" | `cd MyPaperProject && asl` |
| "How do I refresh a specific runtime adapter?" | `cd MyPaperProject && asl install codex` / `asl install claude-code` / `asl install opencode` |
| "How do I set up every supported runtime in this project manually?" | `cd MyPaperProject && asl install all` (installs codex, claude-code, and opencode in sequence; the final summary shows which runtimes succeeded) |

## Day-to-day — once you are running

| Owner says... | Persona answers with... |
|---|---|
| "What is installed in this project?" | `asl status` |
| "How do I refresh this project's managed ASL files?" | `asl refresh --dry-run` to preview, then `asl refresh` to apply |
| "Something feels broken / I see NEEDS_FIX" | `asl doctor --fix` |
| "Is there a newer version of ASL?" | `asl update --dry-run` (shows what would change) then `asl update` to apply |
| "I don't want ASL anymore" | `asl uninstall --yes` (removes wrapper) OR `asl uninstall --purge --yes` (also removes project team config) |

## Safety / bypass

| Owner says... | Persona answers with... |
|---|---|
| "How do I turn off automatic runtime bypass?" | ASL removed `ASL_BYPASS` in v0.3.0. Use your runtime's normal safe-mode / approval setting before launching `asl`. |

## How personas should use this reference

When the Owner asks any question matching the left column above:

1. **Read this file** from `.aiplus/modules/agentsciencelab/core/templates/asl-cli-reference.md` (relative to the project root, which is your current working directory).
2. **Quote the exact command** from the right column verbatim — do NOT paraphrase or guess. Don't construct commands that aren't in this list.
3. **Never auto-run** these commands. Always tell the Owner what to type — these are Owner-controlled actions.
4. If the Owner's question doesn't match any entry, say so honestly and suggest they run `asl --help` themselves to see the full surface.

## Anti-patterns (don't do these)

- ❌ Don't make up commands like `asl upgrade` or `asl remove` — only the commands in this file exist.
- ❌ Don't say `aiplus <something>` to the Owner — that is the substrate, not ASL. Users should never see it.
- ❌ Don't auto-execute these commands "to be helpful". The Owner is the only one who runs them.
- ❌ Don't memorize this list across sessions — re-read it each time, since new versions of ASL add commands here.

## Source

This file lives at `core/templates/asl-cli-reference.md` in the ASL
repo. The `scripts/build-asl.sh` rsync ships it to
`assets/agentsciencelab/core/templates/` in the aiplus binary embed, which
extracts to `.aiplus/modules/agentsciencelab/core/templates/` during `aiplus add agentsciencelab`.

Updates to the ASL CLI must update this file in the same PR.
