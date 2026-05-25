# Contributing

AgentScienceLab v0.1 is a docs-only public baseline. Contribution scope is intentionally narrow.

## What We Welcome

- Issues about positioning, wording, and role boundary clarity.
- Issues about likely misreadings, especially benchmark, leaderboard, or autonomous-scientist confusion.
- Issues about AiPlus alignment edge cases.
- Feedback from agent researchers about whether the roles are useful for experiment design, evaluation review, reproducibility, literature positioning, critique, or writing support.

## What We Defer

- Implementation PRs for CLI commands, runtime behavior, benchmark runners, leaderboards, or autonomous scientist loops.
- Module installer work, which is deferred to the AiPlus upstream onboarding proposal.
- Substrate behavior changes, which must go through AiPlus rather than AgentScienceLab.
- Role ID renaming PRs; open an issue first because cross-repo coordination is required.

The role-ID coordination pattern is documented in [v0.7.7 role ID rename request](upstream-requests/v0.7.7-role-id-rename.md).

## Boundaries

Before proposing changes, read [Non-goals](non-goals.md) and [Alignment with AiPlus](alignment-with-aiplus.md).

Contributors should never include secrets, private datasets, unpublished research, or AiPlus source modifications in AgentScienceLab PRs.
