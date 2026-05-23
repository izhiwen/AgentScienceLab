# Alignment With AiPlus

AgentScienceLab is a configuration layer on AiPlus, not a competing substrate.

## Mandatory Principle

AgentScienceLab must remain behaviorally identical to AiPlus for all substrate features. Any divergence in routing, memory, locks, refresh, status, dispatch, runtime launch, or safety semantics is a bug unless explicitly approved.

## What May Differ

AgentScienceLab may differ from the base AiPlus setup in:

- brand and public positioning
- team and agent configuration
- research-oriented roles and personas
- role aliases
- agent-research documentation
- narrative examples for experiment design, evaluation review, reproducibility, critique, and writing

## What Must Not Differ

AgentScienceLab must not change or copy substrate behavior for:

- routing semantics
- memory semantics
- dispatch semantics
- lock behavior
- worktree behavior
- lane behavior
- MCP behavior
- runtime launch behavior
- status and refresh behavior
- safety gates
- secret-broker behavior
- external-account handling

## Operating Rule

When a proposed AgentScienceLab change appears to require new substrate behavior, the default decision is to reject or reframe the change as documentation, role configuration, or AiPlus upstream work. AgentScienceLab should describe how a research team uses AiPlus; it should not reimplement AiPlus.
