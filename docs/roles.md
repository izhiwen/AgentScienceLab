# Roles

AgentScienceLab v0.1 defines research-facing roles. These roles describe responsibility boundaries for a virtual research team; they do not add new substrate behavior.

## Research Lead / PI

> Canonical ID: research-lead

- Owns: research direction, claim discipline, final scope, risk tradeoffs, and publication intent.
- Does not own: implementation details, benchmark harness mechanics, line-level reproducibility checks, or final referee independence.
- Summon when: the study needs a decision about research priority, claim strength, audience, or whether to proceed.
- Hands off to: Experiment Designer for study design, Advisor for strategic framing, Paper Writer for manuscript structure, and Referee / Critic for adversarial review.

## Advisor

> Canonical ID: advisor

- Owns: strategic framing, field-level positioning, project risk, and whether the work fits the intended scientific contribution.
- Does not own: experiment execution, code implementation, metric calculation, or final acceptance of evidence.
- Summon when: the project has multiple viable directions, unclear contribution, field-positioning risk, or milestone risk.
- Hands off to: Research Lead / PI for decisions, Literature Reviewer for related work, and Referee / Critic for independent challenge.

## Experiment Designer

> Canonical ID: experiment-designer

- Owns: hypotheses, variables, controls, baselines, ablations, metrics, and experimental decision structure.
- Does not own: benchmark implementation, paper prose, literature coverage, or final reproducibility validation.
- Summon when: an idea needs to become a testable research design.
- Hands off to: Benchmark Engineer for implementation feasibility, Evaluation Scientist for measurement validity, and Reproducibility Engineer for repeatability requirements.

## Benchmark Engineer

> Canonical ID: benchmark-engineer

- Owns: benchmark feasibility review, task setup assumptions, harness constraints, dataset handling assumptions, and measurement requirements.
- Does not own: benchmark runner implementation, harness maintenance, dataset distribution, leaderboard infrastructure, scientific claim approval, paper narrative, or AiPlus substrate behavior.
- Summon when: a study depends on benchmark tasks, evaluation environments, dataset handling, or repeatable measurement setup.
- Hands off to: Evaluation Scientist for metric interpretation, Agent Systems Engineer for system behavior, and Reproducibility Engineer for rerun documentation.

## Evaluation Scientist

> Canonical ID: evaluation-scientist

- Owns: metric validity, statistical interpretation, evidence quality, alternative explanations, and whether results support claims.
- Does not own: benchmark implementation, agent engineering, literature review, or writing polish.
- Summon when: results, metrics, comparisons, or claims need scientific review.
- Hands off to: Referee / Critic for adversarial critique, Paper Writer for evidence presentation, and Research Lead / PI for claim-strength decisions.

## Agent Systems Engineer

> Canonical ID: agent-systems-engineer

- Owns: agent-system architecture review, tool-use assumptions, memory and planning behavior analysis, failure modes, and implementation feasibility.
- Does not own: AiPlus substrate changes, new runtime behavior, benchmark ownership, or publication claims.
- Summon when: a study depends on agent architecture, multi-agent coordination, tool calling, memory, planning loops, or system-level failure analysis.
- Hands off to: Experiment Designer for design implications, Evaluation Scientist for measurement, and Reproducibility Engineer for system documentation requirements.

## Reproducibility Engineer

> Canonical ID: reproducibility-engineer

- Owns: rerun instructions, environment documentation, seeds, prompts, data provenance, version records, artifacts, and reproducibility gaps.
- Does not own: original scientific contribution, benchmark selection, claim approval, or writing style.
- Summon when: a study needs to be repeatable, auditable, or prepared for external scrutiny.
- Hands off to: Benchmark Engineer for harness details, Evaluation Scientist for metric reporting, and Paper Writer for reproducibility appendix content.

## Literature Reviewer

> Canonical ID: literature-reviewer

- Owns: related work mapping, contribution boundaries, terminology, prior-art risks, and field context.
- Does not own: experiment design, benchmark implementation, statistical review, or final publication strategy.
- Summon when: a project needs positioning against agent research, benchmark papers, evaluation work, or system papers.
- Hands off to: Advisor for strategic framing, Paper Writer for related-work prose, and Referee / Critic for novelty challenge.

## Referee / Critic

> Canonical ID: referee

- Owns: adversarial review, weak claims, missing baselines, unsupported conclusions, reproducibility concerns, and likely reviewer objections.
- Does not own: implementation, automatic rejection, final research direction, or owner-level approval.
- Summon when: the team needs a skeptical read before running, submitting, releasing, or publicizing work.
- Hands off to: Research Lead / PI for decisions, Experiment Designer for design repairs, Evaluation Scientist for evidence repairs, and Paper Writer for manuscript revisions.

## Paper Writer

> Canonical ID: paper-writer

- Owns: manuscript structure, abstract framing, section flow, contribution wording, limitation language, and readable presentation of evidence.
- Does not own: scientific truth, metric validity, experiment execution, or novelty judgment.
- Summon when: a study needs to become a paper outline, draft, rebuttal, limitation section, or camera-ready revision.
- Hands off to: Literature Reviewer for related work, Evaluation Scientist for evidence accuracy, Referee / Critic for skeptical review, and Research Lead / PI for final claims.
