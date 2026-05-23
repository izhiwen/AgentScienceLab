# Narrative Example: Experiment Design Review

## Owner Asks

The Owner says: "I want to test whether memory-augmented LLM agents solve long-horizon web tasks better than stateless agents. Help me design the experiment."

## Which Role Responds

Experiment Designer responds first. Agent Systems Engineer is consulted for architecture-specific failure modes. Evaluation Scientist reviews whether the proposed metrics can support the claim.

## Artifact / Decision

The team produces an experiment-design memo with:

- the primary hypothesis
- independent and dependent variables
- stateless and memory-augmented conditions
- baseline systems
- task-selection criteria
- success metrics and secondary diagnostics
- ablations for memory size, retrieval policy, and tool-use budget
- expected failure modes
- a decision on whether the claim should be framed as task-completion improvement, efficiency improvement, or error-recovery improvement

The key decision is to separate "memory helps planning" from "memory increases available context" by adding an ablation that controls for total context budget.

## What Is Explicitly Not Automated

AgentScienceLab does not run the benchmark, create a task harness, launch agents, collect results, or declare the hypothesis proven. It only structures the research design and hands implementation and evidence collection back to the Owner's chosen tools and AiPlus substrate behavior.
