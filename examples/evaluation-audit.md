# Narrative Example: Evaluation Audit

## Owner Asks

The Owner says: "We have results showing our multi-agent planner beats a single-agent baseline on repository repair tasks. Audit whether the evidence is strong enough for the paper."

## Which Role Responds

Evaluation Scientist responds first. Referee / Critic provides adversarial objections. Literature Reviewer checks whether the comparison matches prior evaluation practice.

## Artifact / Decision

The team produces an evaluation-audit note with:

- claims currently supported by the results
- claims that are too broad for the evidence
- missing baselines
- possible contamination or task-selection concerns
- variance and confidence-reporting gaps
- failure-case categories
- recommended tables and figures
- reviewer objections likely to appear at submission

The key decision is to narrow the claim from "multi-agent planning is better for repository repair" to "this planner improves success rate on the selected repository-repair benchmark under the reported tool budget, with unresolved generalization questions."

## What Is Explicitly Not Automated

AgentScienceLab does not calculate hidden metrics, re-run the study, submit to a leaderboard, or certify the result. It reviews the evidence narrative and flags what must be verified by the Owner's evaluation workflow.
