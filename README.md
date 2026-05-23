# AgentScienceLab

**A virtual research team for the science of AI agents, built as a configuration layer on AiPlus.**

AgentScienceLab is a public research-team configuration for people studying LLM agents and AI agent systems. It packages research-facing roles, documentation-level aliases, consultant policy, and narrative examples for using an AiPlus-powered virtual team to reason about agent experiments, evaluations, reproducibility, literature context, criticism, and writing.

AgentScienceLab is not a new agent framework, not a benchmark collection or leaderboard, not an autonomous scientist, and not a replacement for LangChain, AutoGen, CrewAI, AgentLab, or Agent Laboratory. It does not create a new substrate, runtime, router, memory system, lock manager, worktree model, MCP layer, safety model, secret broker, refresh mechanism, or dispatch engine.

## Who This Is For

AgentScienceLab is for AI-agent researchers, PhD students, research engineers, and labs studying LLM agents, multi-agent systems, tool use, planning, memory, evaluation, or agent reliability.

It is most useful when you want structured help with:

- turning a research idea into hypotheses, baselines, metrics, and ablations
- pressure-testing whether an evaluation supports a claim
- checking reproducibility before sharing a paper or artifact
- positioning a contribution against related work
- preparing paper structure, limitation language, rebuttal notes, or referee-style critique

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

## Quick Start

Prerequisite: AiPlus should already be installed and configured in the environment where you plan to use AgentScienceLab.

Clone the public repository:

```bash
git clone https://github.com/izhiwen/AgentScienceLab.git
cd AgentScienceLab
```

AgentScienceLab v0.1 is a configuration and documentation layer. It is not a standalone executable package, and it does not currently provide a one-command installer. Use it as an AiPlus-aligned research-team configuration and public reference for roles, boundaries, workflows, and examples.

## How To Use It

Use AgentScienceLab by bringing the relevant research role into the conversation through your normal AiPlus workflow. The role names in this repository are documentation-level labels unless runtime role configuration is explicitly added later.

Common starting points:

- Ask Advisor to pressure-test whether a research idea has a clear contribution and field position.
- Ask Experiment Designer to turn an idea into hypotheses, variables, baselines, metrics, ablations, and decision criteria.
- Ask Benchmark Engineer to review benchmark feasibility without asking it to build a benchmark runner or leaderboard.
- Ask Evaluation Scientist and Referee / Critic to audit whether the evidence supports the claim.
- Ask Reproducibility Engineer to check prompts, seeds, environments, datasets, and artifact readiness before sharing a paper.
- Ask Literature Reviewer and Paper Writer to improve related-work framing, limitation language, and manuscript structure.

## Typical Workflow

1. Start with a research question or rough agent-system claim.
2. Use Experiment Designer to define hypotheses, controls, baselines, metrics, and ablations.
3. Use Benchmark Engineer to identify feasibility constraints, dataset assumptions, and measurement requirements.
4. Use Evaluation Scientist and Referee / Critic to audit whether the evidence can support the intended claim.
5. Use Reproducibility Engineer to check prompts, seeds, environments, versions, artifacts, and rerun documentation.
6. Use Literature Reviewer and Paper Writer to position the work and prepare paper or rebuttal material.

## Relationship To AiPlus

AgentScienceLab must remain behaviorally aligned with AiPlus. Routing, memory, dispatch, locks, worktrees, lanes, MCP behavior, runtime launch, safety semantics, secret handling, and refresh behavior are AiPlus substrate concerns. AgentScienceLab may differ in brand, team and agent configuration, roles and personas, role aliases, and agent-research documentation and examples.

Any proposed divergence from AiPlus substrate behavior should be treated as a bug unless it is explicitly approved as a project-level design change.

## Status

AgentScienceLab is currently at a v0.1 public docs and configuration baseline.

- Runtime role aliases are documentation-level unless explicitly added later.
- The repository has no release or tag yet.
- v0.1 does not include a CLI wrapper, benchmark runner, leaderboard, autonomous scientist loop, runtime roster replacement, or substrate behavior change.

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
