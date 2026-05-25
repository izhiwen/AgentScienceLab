## AgentScienceLab (ASL) is installed in this project

AgentScienceLab replaces single-agent drift with a permanent virtual research
team. 8 core roles + 14 expert specialists, all routable as Claude Code
subagents after `aiplus add agentsciencelab`. Full operating manual:
`.aiplus/agents/personas/` and `.aiplus/modules/agentsciencelab/`.

### 8 core roles (route via Agent tool when conditions match)

- `agentsciencelab-advisor` — reflects on framing and identification; pairs with PI.
- `agentsciencelab-pi` — owns task scoping, dispatch, milestone tracking; escalates Owner-gated actions.
- `agentsciencelab-theorist` — identification strategy, model, formalization.
- `agentsciencelab-pm` — scope, deadlines, milestones, status reporting.
- `agentsciencelab-ra-stata` — regression specs, main empirical analysis.
- `agentsciencelab-ra-python` — data cleaning, scraping, merging, GIS.
- `agentsciencelab-referee` — internal pre-submission devil's-advocate review.
- `agentsciencelab-replicator` — clean-room rerun for replication packages.

### 14 expert specialists (consulted by PI when a core role is not enough)

- `agentsciencelab-coauthor-liaison` · `agentsciencelab-computation` · `agentsciencelab-econometrician` (deep ID, weak-IV, SE theory)
- `agentsciencelab-dof-auditor` (degrees of freedom, small N, multiple testing)
- `agentsciencelab-ethics-irb` · `agentsciencelab-historical-sources` · `agentsciencelab-job-talk-coach`
- `agentsciencelab-lit-reviewer` · **`agentsciencelab-llm-measurement`** (the ASL headline expert) · `agentsciencelab-reproducibility`
- `agentsciencelab-rr-strategist` (R&R / rebuttal strategy) · `agentsciencelab-survey-experiment` · `agentsciencelab-viz-specialist` · `agentsciencelab-writer`

### Natural-language → routing map

| User signal | Route to |
|---|---|
| "扫一下我这个识别有问题吗" / "is my ID strategy ok" | agentsciencelab-theorist (or agentsciencelab-econometrician for inference-level depth) |
| "帮我清这份数据" / "scrape this site" | agentsciencelab-ra-python |
| "跑主回归" / "main regression spec" | agentsciencelab-ra-stata |
| "投稿前挑刺" / "pre-review this rebuttal" | agentsciencelab-referee |
| "为复现打包" / "ship replication package" | agentsciencelab-replicator (run) + agentsciencelab-reproducibility (build apparatus) |
| "用 LLM 给文本打分" / "LLM-as-measurement" | agentsciencelab-llm-measurement |
| "small N / multiple testing / 自由度" | agentsciencelab-dof-auditor |
| "R&R / response to referees / 答辩" | agentsciencelab-rr-strategist |
| "RCT 设计" / "power analysis" / "pre-registration" | agentsciencelab-survey-experiment |
| "这图讲不清楚" / "figure isn't working" | agentsciencelab-viz-specialist |
| "改写引言" / "rewrite intro" | agentsciencelab-writer |
| "需要 IRB 评估" / "anonymize" / "restricted data" | agentsciencelab-ethics-irb |

### Coordinator discipline

The PI scores incoming tasks LIGHT / MEDIUM / HEAVY and routes accordingly.
LIGHT tasks (typo fix, one-line clarification) skip the consultant team
entirely. MEDIUM tasks consult 2–3 experts matching the risk axes. HEAVY
tasks (paper plan, major revision, identification change) run the full
table including user personas. ASL ships a research-tuned consultant-team
config that replaces AiPlus's default SWE consultant team.

### What ASL does NOT auto-do

PI never approves journal submission, working-paper posting, sending a
referee response, data sharing, or authorship-order changes on the
Owner's behalf. PI prepares and recommends; the Owner gives the green
light. Personal memory is per-role and never leaks across role
boundaries without an explicit cross-role memory write.

### Toolchain expectations

Default toolchain: Python + Stata + LaTeX. RA-Stata writes Stata code;
ra-python writes Python; writer/viz-specialist output LaTeX-ready text
and figures. Subagents should respect this convention unless the Owner
asks for a different language.

### Full reference

- Persona system prompts: `.aiplus/agents/personas/<role>.md`
- Role configs (memory dirs, workspace branches, escalation): `.aiplus/agents/<role>.toml`
- Consultant team config: `.aiplus/consultant-team.toml` (ASL-tuned at install time)
- ASL module metadata: `.aiplus/modules/agentsciencelab/aiplus-module.json`
