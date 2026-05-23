# Positioning

## Why AgentScienceLab

The name AgentScienceLab points to the intended use: a virtual research team for studying AI agents as scientific and engineering systems. "Agent" names the subject matter. "Science" emphasizes hypotheses, evidence, measurement, critique, and reproducibility. "Lab" describes a coordinated research setting rather than a standalone framework or autonomous discovery machine.

AgentScienceLab is deliberately a configuration layer on AiPlus. It gives researchers a public, research-oriented team shape without inventing new substrate behavior.

## Difference From AgentLab, Agent Laboratory, And Benchmark Frameworks

AgentScienceLab is not a benchmark suite, leaderboard, experiment runner, agent framework, or autonomous research pipeline. It does not define new task environments, scoring harnesses, runtime abstractions, or agent execution protocols.

AgentScienceLab is not affiliated with AgentLab or Agent Laboratory, and is not a replacement for them.

AgentLab, Agent Laboratory, benchmark frameworks, and agent engineering tools may provide environments, automation, evaluation harnesses, or agent-building primitives. AgentScienceLab instead provides research-team roles and documentation that help people design, review, critique, and write about agent-system research while relying on AiPlus for the underlying routing, memory, dispatch, safety, worktree, lane, and runtime semantics.

## One-Sentence Positioning

AgentScienceLab is an AiPlus-powered virtual research-team configuration for researchers studying LLM agents and AI agent systems.

## Target Users

- Researchers designing experiments on LLM agents, multi-agent systems, tool use, planning, memory, evaluation, or agent reliability.
- Graduate students and research engineers who need structured critique before running or publishing an agent-systems study.
- Paper authors who want explicit separation between experiment design, evaluation review, reproducibility checks, literature positioning, and referee-style criticism.
- Labs that already use AiPlus and want a research-oriented public team configuration without changing substrate behavior.

## Non-Target Users

- Teams looking for a new agent runtime, orchestration framework, benchmark harness, or production agent SDK.
- Users who want an autonomous scientist that independently discovers, runs, and publishes research end to end.
- Benchmark maintainers looking for leaderboard infrastructure.
- Product teams looking for a replacement for LangChain, AutoGen, CrewAI, AgentLab, Agent Laboratory, or other agent engineering tools.

## Best-Fit Use Cases

1. Pre-registration-style experiment design review: turn a rough agent-system research idea into hypotheses, variables, baselines, metrics, ablations, failure modes, and acceptance criteria.
2. Evaluation and evidence audit: review whether a proposed evaluation actually supports the paper's claims and whether alternative explanations remain unresolved.
3. Reproducibility check: inspect whether a study has enough documentation, environment detail, seeds, prompts, datasets, metrics, and reporting discipline for another researcher to reproduce or challenge it.
