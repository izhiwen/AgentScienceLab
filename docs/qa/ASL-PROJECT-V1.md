# ASL-PROJECT-V1 Acceptance Suite

Codified: 2026-05-28 (commit pending)
First independent QA pass: commit 166abc3, 40/42 PASS
Validator: AiPlus generic agent-team QA (read-only)
Scope: ASL software artifact only: binary, personas, TOML, manifest, consultant policy, docs, build, repo hygiene.

## Boundaries

- Read-only validation
- No file modification, no git mutations
- No cargo build or scripts/build-asl.sh
- No `aiplus install` / `aiplus add` / runtime state changes
- STOP-gated findings escalate to Owner via Advisor

## Output format

Per criterion: PASS / FAIL / SKIP with command + output. End with totals and FAIL owners.

## Suite ASL-S1: Binary & Dispatch

### S1.1 — bash syntax
Command: `bash -n asl`
Expected: exit 0.

### S1.2 — help shows 11 roles (revised 2026-05-28: scope grep to dispatch table region)
Command:
```
./asl --help 2>&1 | sed -n '/^Roles you can chat with directly:/,/^$/p' | grep -cE "^  asl [a-z-]+ +[^-]"
```
Expected: 11.
Revision note: broader grep also matched help-footer examples; role-block scope fixes over-count.

### S1.3 — version string
Command: `./asl --version`
Expected exact output: `ASL 0.1.0 (aiplus 0.7.6+)`.

### S1.4 — dry-run install
Command: `./asl install --dry-run 2>&1`
Expected: contains `ASL_DRY_RUN=PASS` and exit 0.

### S1.5 — binary executable
Command: `test -x asl && echo OK || echo NOT_EXEC`
Expected: `OK`.

## Suite ASL-S2: Persona Files

### S2.1 — 11 persona md exist
Command:
```
for r in pi advisor experiment-designer benchmark-engineer evaluation-scientist agent-systems-engineer reproducibility-engineer literature-reviewer referee paper-writer editor; do test -f "core/templates/personas/$r.md" || echo "MISSING $r"; done
```
Expected: no output.

### S2.2 — size sanity
Command:
```
wc -c core/templates/personas/{pi,advisor,experiment-designer,benchmark-engineer,evaluation-scientist,agent-systems-engineer,reproducibility-engineer,literature-reviewer,referee,paper-writer,editor}.md
```
Expected: substantial; `pi.md` 14-17K, `referee.md` 13-16K, `editor.md` 14-17K, others 12-18K.

### S2.3 — 6 bold-inline subsection labels in each persona
Command:
```
python3 -c 'from pathlib import Path; L=["AI Advantages","Default Ownership Pattern","First Working Rule","Refuse Pattern","Context discipline","Output Discipline"]; bad=[p.name for p in Path("core/templates/personas").glob("*.md") if any(p.read_text().count(f"**{x}.**")!=1 for x in L)]; print(bad) if bad else None; raise SystemExit(bool(bad))'
```
Expected: no output.

### S2.4 — ASL CLI questions footer
Command:
```
for r in pi advisor experiment-designer benchmark-engineer evaluation-scientist agent-systems-engineer reproducibility-engineer literature-reviewer referee paper-writer editor; do grep -q '^## ASL CLI questions$' "core/templates/personas/$r.md" || echo "MISSING $r"; done
```
Expected: no output.

### S2.5 — no AEL/econ residue in any persona
Command:
```
rg -n 'AEL|AiEconLab|aieconlab|theorist|replicator|ra-stata|ra-python|Stata|economics|econ|paper project|replication package|AER|QJE|R&R|prefecture-pair FE|IV first-stage|IV defense|parallel trends|\bWriter\b' core/templates/personas/*.md
```
Expected: no output.

### S2.6 — Hostile Verification Principle exclusive to referee
Command:
```
rg -n 'find what is wrong, not to confirm what is right' core/templates/personas/*.md
```
Expected: exactly one match, in `core/templates/personas/referee.md`.

## Suite ASL-S3: Role TOML Files

### S3.1 — 11 role TOMLs exist
Command:
```
for r in pi advisor experiment-designer benchmark-engineer evaluation-scientist agent-systems-engineer reproducibility-engineer literature-reviewer referee paper-writer editor; do test -f "core/templates/$r.toml" || echo "MISSING $r"; done
```
Expected: no output.

### S3.2 — role TOMLs parse
Command:
```
python3 -c 'import glob,toml; [toml.load(p) for p in glob.glob("core/templates/*.toml")]; print("TOML_PASS")'
```
Expected: `TOML_PASS`.

### S3.3 — TOML role IDs match filenames
Command:
```
python3 -c 'import toml,pathlib; bad=[p.stem for p in pathlib.Path("core/templates").glob("*.toml") if p.stem not in ("agent-science-team","consultant-team.agentsciencelab") and toml.load(p)["agent"]["role"]!=p.stem]; print(bad) if bad else print("ROLE_IDS_PASS"); raise SystemExit(bool(bad))'
```
Expected: `ROLE_IDS_PASS`.

### S3.4 — persona file references exist
Command:
```
python3 -c 'from pathlib import Path; import toml; m=[str(Path("core/templates")/toml.load(p)["persona"]["system_prompt_file"]) for p in Path("core/templates").glob("*.toml") if "persona" in toml.load(p) and not (Path("core/templates")/toml.load(p)["persona"]["system_prompt_file"]).exists()]; print("\\n".join(m) if m else "PERSONA_REFS_PASS"); raise SystemExit(bool(m))'
```
Expected: `PERSONA_REFS_PASS`.

### S3.5 — read-only role policy
Command:
```
python3 -c 'import toml,pathlib; bad=[p.stem for p in pathlib.Path("core/templates").glob("*.toml") if p.stem not in ("agent-science-team","consultant-team.agentsciencelab") and toml.load(p)["workspace"]["needs_worktree"]]; print(bad if bad else "WORKTREE_POLICY_PASS"); raise SystemExit(bool(bad))'
```
Expected: `WORKTREE_POLICY_PASS`.

### S3.6 — memory policy shape
Command:
```
python3 -c 'import toml,pathlib; bad=[p.stem for p in pathlib.Path("core/templates").glob("*.toml") if p.stem not in ("agent-science-team","consultant-team.agentsciencelab") and (toml.load(p)["memory"]["personal_dir"]!=f".aiplus/agent-memory/{p.stem}" or toml.load(p)["memory"]["write_team_memory"])]; print(bad if bad else "MEMORY_POLICY_PASS"); raise SystemExit(bool(bad))'
```
Expected: `MEMORY_POLICY_PASS`.

## Suite ASL-S4: Module Manifest

### S4.1 — manifest JSON parses
Command: `python3 -m json.tool aiplus-module.json >/dev/null && echo JSON_PASS`
Expected: `JSON_PASS`.

### S4.2 — manifest identity
Command:
```
python3 -c 'import json; d=json.load(open("aiplus-module.json")); assert (d["name"],d["abbreviation"],d["version"])==("agentsciencelab","ASL","0.1.0"); print("IDENTITY_PASS")'
```
Expected: `IDENTITY_PASS`.

### S4.3 — requiredFiles all exist
Command:
```
python3 -c 'import json,os; m=[p for p in json.load(open("aiplus-module.json"))["requiredFiles"] if not os.path.exists(p)]; print("\n".join(m)) if m else None; raise SystemExit(bool(m))'
```
Expected: no output and exit 0.

### S4.4 — requiredFiles include editor
Command:
```
python3 -c 'import json; r=json.load(open("aiplus-module.json"))["requiredFiles"]; assert "core/templates/editor.toml" in r and "core/templates/personas/editor.md" in r; print("EDITOR_REQUIRED_PASS")'
```
Expected: `EDITOR_REQUIRED_PASS`.

### S4.5 — doctorChecks paths exist
Command:
```
python3 -c 'import json,os; m=[c["path"] for c in json.load(open("aiplus-module.json"))["doctorChecks"] if not os.path.exists(c["path"])]; print("\n".join(m)) if m else None; raise SystemExit(bool(m))'
```
Expected: no output and exit 0.

## Suite ASL-S5: Consultant Team Policy

### S5.1 — consultant TOML parses
Command:
```
python3 -c 'import toml; toml.load(".aiplus/consultant-team.toml"); print("CONSULTANT_TOML_PASS")'
```
Expected: `CONSULTANT_TOML_PASS`.

### S5.2 — consultant members include 11 canonical roles
Command:
```
python3 -c 'import toml; ids={m["id"] for m in toml.load(".aiplus/consultant-team.toml")["members"]}; exp=set("pi advisor experiment-designer benchmark-engineer evaluation-scientist agent-systems-engineer reproducibility-engineer literature-reviewer referee paper-writer editor".split()); assert exp<=ids, sorted(exp-ids); print("MEMBERS_PASS")'
```
Expected: `MEMBERS_PASS`.

### S5.3 — editor trigger exists
Command: `grep -n 'paper_review_battery' .aiplus/consultant-team.toml`
Expected: one match.

### S5.4 — owner gates preserved
Command:
```
python3 -c 'import toml; assert all(v is True for v in toml.load(".aiplus/consultant-team.toml")["owner_gates"].values()); print("OWNER_GATES_PASS")'
```
Expected: `OWNER_GATES_PASS`.

## Suite ASL-S6: Documentation

### S6.1 — core docs exist
Command: `test -f README.md && test -f docs/roles.md && test -f docs/aliases.md && test -f docs/v0.1-scope.md && echo DOCS_EXIST`
Expected: `DOCS_EXIST`.

### S6.2 — roles doc lists 11 canonical IDs
Command: `grep -c '^> Canonical ID:' docs/roles.md`
Expected: 11.

### S6.3 — aliases table lists editor
Command: `grep -n '| Editor | editor |' docs/aliases.md`
Expected: one match.

### S6.4 — non-goals remain explicit
Command: `rg -n 'not (a )?(framework|benchmark runner|leaderboard|autonomous scientist|substrate fork)' README.md docs/non-goals.md docs/v0.1-scope.md`
Expected: matches for all five non-goals across the docs set.

### S6.5 — AiPlus boundary doc exists
Command: `test -f docs/alignment-with-aiplus.md && rg -n 'AiPlus' docs/alignment-with-aiplus.md | head -3`
Expected: file exists and output mentions AiPlus.

### S6.6 — upstream-requests directory contents (revised 2026-05-28: expect 3 files)
Command: `ls docs/upstream-requests/`
Expected: 3 files exactly:
- v0.7.7-module-registration.md
- v0.7.7-role-id-rename.md
- v0.7.7-asl-side-verification.md
Revision note: original expected 2 files; commit 782d06b verification report is legitimate and should count.

### S6.7 — contributing guide exists
Command: `test -f docs/contributing.md && echo CONTRIBUTING_DOC_PASS`
Expected: `CONTRIBUTING_DOC_PASS`.

### S6.8 — heuristic doc exists
Command: `test -f docs/heuristics/wrapper-substrate-layering.md && echo HEURISTIC_DOC_PASS`
Expected: `HEURISTIC_DOC_PASS`.

## Suite ASL-S7: Build Pipeline Hygiene

### S7.1 — build script syntax
Command: `bash -n scripts/build-asl.sh`
Expected: exit 0.

### S7.2 — build script excludes local runtime state
Command:
```
for p in './.aiplus' './.claude' './.codex' './.opencode' './.agents' './.mcp.json' './AGENTS.md' './CLAUDE.md' './opencode.json' './.DS_Store' 'Thumbs.db'; do grep -F -- "--exclude='$p'" scripts/build-asl.sh || echo "MISSING $p"; done
```
Expected: no `MISSING` lines.

### S7.3 — no cargo build in QA
Command: `rg -n 'cargo build|scripts/build-asl.sh' docs/qa/ASL-PROJECT-V1.md`
Expected: mentions only in boundaries / non-execution guidance; QA must not run cargo build or `scripts/build-asl.sh`.

## Suite ASL-S8: Repo Hygiene

### S8.1 — git status clean before QA
Command: `git status --short --branch`
Expected: `## main...origin/main` and no modified/untracked files.

### S8.2 — no forbidden tracked runtime paths
Command:
```
git ls-files | rg '^(\.aiplus/(agents|agent-memory|memory|compact|identities|backups|modules|restore|skills)/|\.agents/|\.claude/|\.codex/|\.opencode/|\.mcp\.json$|AGENTS\.md$|CLAUDE\.md$|opencode\.json$)' || true
```
Expected: no output.

### S8.3 — no AiPlus/AEL source changes
Command: `git status --short -- /Users/steve/Projects/AiPlus /Users/steve/Projects/AiEconLab 2>&1 || true`
Expected: no ASL QA mutation of those repositories; if command is outside repo, report SKIP with note.

### S8.4 — submodule pointer present
Command: `git submodule status vendor/aiplus`
Expected: one line for `vendor/aiplus`.

### S8.5 — no secret-like strings in public tracked files
Command:
```
git grep -nE '(AKIA[0-9A-Z]{16}|BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY|OPENAI_API_KEY|ANTHROPIC_API_KEY|GITHUB_TOKEN|ghp_[A-Za-z0-9_]{20,})' -- ':!vendor/**'
```
Expected: no output.

## Acceptance history

| Commit | Date | PASS | FAIL | Notes |
|---|---|---|---|---|
| d3c4255 | 2026-05-28 | 36/42 | 6 | Initial pass; 4 content FAILs + 2 criterion-noise. |
| 166abc3 | 2026-05-28 | 40/42 | 2 | Closed S2.3/S2.4/S2.5/S2.6; 2 criterion-noise remain. |
| pending | after codify | expected 42/42 | expected 0 | S1.2 and S6.6 revised. |

## Future revisions

When acceptance criteria need updating (new role added, new file structure, etc.), revise this file. Each revision should note the date and reason in the criterion's revision note. Acceptance history table appends a new row per re-run.
