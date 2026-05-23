# Documentation-Level Aliases

AgentScienceLab v0.1 uses aliases as public documentation labels for research-team responsibilities. These aliases do not create runtime roles, change agent config, modify runtime adapters, or alter AiPlus routing, memory, dispatch, locks, worktrees, MCP, refresh, safety, or runtime launch behavior.

Aliases are documentation-level v0.1 labels unless and until runtime role config is explicitly added.

## Alias Table

| Canonical role | Documentation aliases |
| --- | --- |
| Research Lead / PI | Research Lead, PI, Principal Investigator, Study Lead, Research Owner |
| Advisor | Advisor, Strategic Advisor, Field Advisor, Research Strategy Reviewer |
| Experiment Designer | Experiment Designer, Study Designer, Experimental Design Reviewer, Hypothesis Planner |
| Benchmark Engineer | Benchmark Engineer, Benchmark Feasibility Reviewer, Evaluation Environment Reviewer, Harness Feasibility Reviewer |
| Evaluation Scientist | Evaluation Scientist, Metrics Reviewer, Evidence Reviewer, Statistical Evaluation Reviewer |
| Agent Systems Engineer | Agent Systems Engineer, Agent Architecture Reviewer, Tool-Use Reviewer, Memory/Planning Reviewer |
| Reproducibility Engineer | Reproducibility Engineer, Artifact Reviewer, Rerun Reviewer, Reproduction Checklist Reviewer |
| Literature Reviewer | Literature Reviewer, Related Work Reviewer, Prior-Art Reviewer, Positioning Reviewer |
| Referee / Critic | Referee, Critic, Skeptical Reviewer, Reviewer 2, Adversarial Reviewer |
| Paper Writer | Paper Writer, Manuscript Writer, Drafting Reviewer, Rebuttal Writer |

## Boundary

These aliases are meant to make public docs easier to read and discuss. They are not command names, CLI wrappers, dispatch targets, roster entries, permission grants, or substrate extensions.

If a future version adds runtime role config, that change must be explicit, reviewed against AiPlus substrate alignment, and kept separate from this documentation-level alias table.
