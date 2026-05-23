# AgentScienceLab

**A virtual research team for the science of AI agents, built as a configuration layer on AiPlus.**

AgentScienceLab is a public research-team configuration for people studying LLM agents and AI agent systems. It packages research-facing roles, documentation-level aliases, consultant policy, and narrative examples for using an AiPlus-powered virtual team to reason about agent experiments, evaluations, reproducibility, literature context, criticism, and writing.

AgentScienceLab is not a new agent framework, not a benchmark collection or leaderboard, not an autonomous scientist, and not a replacement for LangChain, AutoGen, CrewAI, AgentLab, or Agent Laboratory. It does not create a new substrate, runtime, router, memory system, lock manager, worktree model, MCP layer, safety model, secret broker, refresh mechanism, or dispatch engine.

## What It Helps With

- experiment design
- evaluation review
- reproducibility
- literature positioning
- referee-style critique
- paper writing support

## What It Does Not Do

- It does not provide an agent framework.
- It does not ship a benchmark suite.
- It does not operate a leaderboard.
- It does not run an autonomous scientist loop.
- It does not fork or replace AiPlus substrate behavior.
- It does not replace existing agent engineering tools.

## Relationship To AiPlus

AgentScienceLab must remain behaviorally aligned with AiPlus. Routing, memory, dispatch, locks, worktrees, lanes, MCP behavior, runtime launch, safety semantics, secret handling, and refresh behavior are AiPlus substrate concerns. AgentScienceLab may differ in brand, team and agent configuration, roles and personas, role aliases, and agent-research documentation and examples.

Any proposed divergence from AiPlus substrate behavior should be treated as a bug unless it is explicitly approved as a project-level design change.

## Current Docs

- [Positioning](docs/positioning.md)
- [Non-goals](docs/non-goals.md)
- [Roles](docs/roles.md)
- [Documentation-level aliases](docs/aliases.md)
- [v0.1 scope](docs/v0.1-scope.md)
- [Alignment with AiPlus](docs/alignment-with-aiplus.md)

## Narrative Examples

- [Experiment design review](examples/experiment-design-review.md)
- [Evaluation audit](examples/evaluation-audit.md)
- [Reproducibility check](examples/reproducibility-check.md)
