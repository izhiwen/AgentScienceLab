# Narrative Example: Reproducibility Check

## Owner Asks

The Owner says: "Before we release the paper draft, check whether another lab could reproduce the agent experiments from our artifacts."

## Which Role Responds

Reproducibility Engineer responds first. Benchmark Engineer reviews benchmark setup assumptions. Paper Writer turns the findings into appendix and artifact-checklist language.

## Artifact / Decision

The team produces a reproducibility-check report with:

- required environment details
- model and provider version records
- prompt and system-message inventory
- dataset and task-source provenance
- random seed policy
- tool budget and timeout settings
- evaluation command description at a narrative level
- expected output files and tables
- missing artifacts that block external reruns

The key decision is to block public claims of full reproducibility until prompt templates, model-version records, and failed-run accounting are documented.

## What Is Explicitly Not Automated

AgentScienceLab does not create a benchmark runner, execute experiments, upload private data, manage secrets, or publish artifacts. It identifies reproducibility requirements and leaves execution, release, and external-account actions under Owner control and AiPlus safety gates.
