# Wrapper-Substrate Layering Heuristic

Provenance:
- Authored: AEL Advisor (izhiwen/AiEconLab), 2026-05-27
- Received: ASL Advisor via Owner channel, 2026-05-27
- Cross-applicability: any AiPlus wrapper (AEL, ASL, future MailCue / PAL / etc.)
- Heuristic license: shared editable; refinements ping back to AEL via Owner

## Heuristic body

# Wrapper-Substrate Layering Heuristic

**Audience:** any AiPlus wrapper project (AEL, ASL, and future wrappers such as MailCue / PAL).
**Origin:** AEL Advisor, 2026-05-20 working note, refined through 2026-05-26 cross-side audits with AiPlus Advisor and ASL Advisor.
**Use:** when a bug, feature request, or improvement lands and it's not obvious whether the wrapper or the substrate should own the fix.

---

## 1. Layering principle

AiPlus = substrate. Stays brand-neutral, role-neutral, domain-neutral. Substrate ships primitives that every wrapper can use.

A wrapper (AEL, ASL, MailCue, PAL, …) = thin layer that gives substrate a specific identity, persona set, command surface translation, and documentation. The wrapper configures substrate via team configs + env vars + role-aliases. The wrapper never asks substrate to default to wrapper-flavor behavior — substrate stays generic, wrapper provides overrides.

Dependency is one-way: wrapper depends on substrate. Substrate has no compile-time or runtime dependency on any wrapper. Learnings, however, flow both ways: wrappers surface bugs and primitive gaps that improve substrate; substrate improvements propagate to all wrappers on bump.

If a wrapper finds itself modifying substrate source to make wrapper-specific behavior work, the boundary has been crossed. Walk back, identify the missing primitive, file it upstream as a substrate request, and patch wrapper-side only as bridge until substrate version lands.

---

## 2. The 3-question heuristic

When deciding "should this fix / feature live in wrapper or substrate", ask in order:

1. **Generalizability:** *If a different AiPlus wrapper (today or future) hit the same situation, would they want the same fix / feature?*
   - Yes → substrate. The concern is shared across wrappers.
   - No → wrapper. The concern is wrapper-specific.

2. **Layer of concern:** *Does the fix change branding / persona content / role identity / wrapper-specific docs / command translation, or does it change a substrate primitive (process spawn, file I/O, identity context, memory schema, cross-platform behavior)?*
   - Brand / persona / role / wrapper docs / command translation → wrapper.
   - Substrate primitive → substrate.

3. **User-visible specificity:** *Is this a wrapper-distinguishing feature your users feel as wrapper-flavor, or is it generic infrastructure any AiPlus product would need?*
   - Wrapper-distinguishing → wrapper.
   - Generic infrastructure → substrate.

**Resolution rules:**

- All three pointing same direction = clear; act on that side.
- Two-vs-one split = think harder; usually the "two" side wins but it's worth surfacing the disagreement explicitly in the team-memory note.
- Three-way split = stop and write the question down; you may be looking at two interleaved concerns that need separating before either can be answered.

---

## 3. Worked examples

These come from actual cross-side audits in 2026-05.

**Example A — AEL `bin/ael.ps1` Windows wrapper (≈665 lines).**

Question 1: Would MailCue / PAL on Windows want a thin shim around AiPlus? Yes — they would also hit the lack of a PowerShell runtime entry point. → substrate.
Question 2: The bulk of the 665 lines is process spawn, stdin handling, argv normalization, Windows state-path conventions. → substrate primitives.
Question 3: Is "translating `ael <role>` to `aiplus identity --role <role>`" user-felt as AEL? Yes — that command-surface translation stays wrapper. But "stdin not being silently dropped on Windows" is invisible infrastructure. → split.

Resolution: command-surface translation stays in AEL `bin/ael.ps1`. Stdin / argv / state-path / empty-log handling: file as substrate primitive requests, keep wrapper bridge until substrate version delivers, then delete wrapper bridge in next wrapper minor. AiPlus accepted the request, queued as v0.8.x "wrapper invocation contract" spec.

**Example B — AEL first-run silent-install bug (Lane F).**

Owner observed `ael` in fresh project: silent for several seconds, user assumes hung, Ctrl-C.
Question 1: Would MailCue hit the same silent-install pattern? Only if MailCue chose the same capture-output-during-install pattern. → not necessarily.
Question 2: AEL's wrapper uses `run_substrate_capture` (a wrapper-defined helper) to silence substrate's own progress output. The substrate output is correct; the wrapper is the one swallowing it. → wrapper.
Question 3: User experience of "first ael feels alive" is wrapper-distinguishing flavor. → wrapper.

Resolution: pure AEL fix. Wrapper changes `run_substrate_capture` to `run_substrate_visible` for the install path. Substrate ask = zero for this specific bug.

Note: a *related* substrate primitive (`install-and-launch-lobby` recipe doc) was filed separately because if substrate documents the invocation order, future wrappers don't have to discover it empirically. That's question 1 saying yes for a different but adjacent concern.

**Example C — AEL research persona content (PI / RA-Stata / etc.).**

Question 1: Would MailCue want AEL's PI persona? No — MailCue has email roles, not research roles. → wrapper.
Question 2: Persona content is role identity, not substrate primitive. → wrapper.
Question 3: Persona content is exactly what distinguishes one wrapper from another. → wrapper.

All three point to wrapper. Clear case. AEL owns persona content. AiPlus G-AT-PERSONA-V1 sprint produces the *template / shape*, AEL fills in the wrapper-specific content.

**Example D — AiPlus `AIPLUS_BRAND` / `AIPLUS_TEAM` env var protocol.**

Question 1: Would any wrapper want to override the displayed brand string? Yes. → substrate.
Question 2: It's a substrate primitive (configuration API). → substrate.
Question 3: Configuration APIs are generic infrastructure. → substrate.

Clear substrate case. AiPlus shipped this as v0.6.16+. AEL consumes via `AIPLUS_BRAND=AEL`.

---

## 4. What this heuristic prevents

- **Wrapper bloat from absorbing substrate problems.** When a wrapper accumulates substrate workarounds, future substrate fixes can't reach the wrapper users until the wrapper deletes the bridge. Mass deletion is harder than originally-not-writing.
- **Substrate dilution from absorbing wrapper preferences.** Substrate that hardcodes one wrapper's flavor becomes harder to host other wrappers. The substrate ecosystem narrows.
- **Boundary-call fatigue.** Without an explicit heuristic, every cross-cutting decision becomes a fresh debate. With one, debates collapse to "which question are we disagreeing on?"

---

## 5. What this heuristic does NOT replace

- Owner judgment when the heuristic's answer is "substrate" but substrate ETA is too far out — owner can authorize a wrapper bridge with an explicit cleanup deadline. (Example: AEL's 3-week fallback for `ael status` branding leak.)
- Inter-Advisor coordination when both sides have shippable patches — surface the duplication, pick the cheaper one, document who deletes the other's version.
- Substrate authority on substrate questions — when wrapper Advisor and substrate Advisor disagree on whether something is substrate-layer, substrate Advisor's read is canonical.

---

## 6. How to apply this when filing upstream

When a wrapper Advisor decides "this is substrate" via the heuristic:

1. Write the proposed substrate primitive / fix as a tier-ranked request (Tier 1 = blocks wrapper simplification, Tier 2 = QoL, Tier 3 = nice-to-have).
2. Include evidence: specific wrapper code paths or behaviors that work around the missing primitive.
3. Note explicitly what the wrapper will delete or simplify once substrate ships the primitive.
4. Don't ask for emergency timing unless wrapper has a real release blocker. Substrate's natural cadence wins by default.
5. Be ready to receive push-back from substrate Advisor — substrate authority on substrate questions.

For an example of this in practice, see AEL's 2026-05-26 upstream ask to AiPlus (`upstream-ask-to-aiplus-advisor-2026-05-26.md`): 5 tier-ranked items, 4 commit-level evidence references, explicit deletion plan per item, AiPlus accepted all 5 with one tier downgrade.

---

## 7. Open questions / refinements wanted

If you (a wrapper Advisor) use this heuristic and find an edge case that doesn't resolve cleanly, please report back. Refinements expected as more wrappers exist. Current open question:

- When a feature is generic infrastructure (question 3 → substrate) but only one wrapper currently has a use case (question 1 → maybe wrapper for now), where does it go? Current AEL convention: file as substrate request labeled "speculative-shared" so substrate has visibility without commitment, wrapper builds locally if blocker. This convention is provisional.

---

*Authoritative version maintained by AEL Advisor at `.aiplus/agent-memory/advisor/wrapper-substrate-layering-heuristic-shareable.md`. Other wrappers welcome to fork and adapt; please report adaptations back so the heuristic improves.*

## ASL data points (2026-05-27)

Three ASL decisions retrospectively tested against the heuristic:

### Test A — ASL module registration upstream request
(v0.7.7-module-registration.md)

Decision made: file upstream to AiPlus (asked AiPlus to register agentsciencelab in
module_manifest.rs).

Heuristic retest:
- Q1 (generalizability): Would MailCue / PAL hit the same module-registration need?
Yes → substrate
- Q2 (layer of concern): Module registry is substrate primitive (static MODULES
const array, runtime dispatch) → substrate
- Q3 (user-visible specificity): Module registration is generic infrastructure →
substrate
- Three-way agreement on substrate.

Heuristic confirmed: ASL's decision matches the heuristic. AiPlus accepted, in
implementation as of 2026-05-27.

### Test B — ASL persona content (10 research roles)

Decision made: keep all persona content in ASL repo (core/templates/personas/*.md).

Heuristic retest:
- Q1: Would MailCue want experiment-designer? No → wrapper
- Q2: Persona content = role identity, not substrate primitive → wrapper
- Q3: Persona content is wrapper-distinguishing → wrapper
- Three-way agreement on wrapper.

Heuristic confirmed: ASL's decision matches the heuristic.

### Test C — scripts/build-asl.sh missing runtime-state excludes (new finding)

Background: 2026-05-27, ASL discovered that scripts/build-asl.sh inherited from
AEL's tar exclude list does not exclude .aiplus/, .claude/, .codex/, .opencode/,
.agents/, .mcp.json, AGENTS.md, CLAUDE.md, opencode.json. A fresh build would have
packaged 612 files into vendor/aiplus/assets/agentsciencelab/ instead of the
expected ~134. ASL fixed scripts/build-asl.sh wrapper-side.

Heuristic retest:
- Q1: Would MailCue / PAL hit the same packaging-runtime-state problem? Yes — any
wrapper that maintains local .aiplus/ runtime state and uses tar-based sync to
vendor/aiplus/assets/ will hit it → substrate (potential)
- Q2: The fix (tar exclude list) is wrapper build-script logic; the underlying
primitive ("standardized wrapper build-asset-excludes" or "git ls-files-style
tracked-only sync") would be substrate
- Q3: "Don't package wrapper local runtime state into wrapper-bundled assets" is
generic infrastructure → substrate

Resolution: two-vs-one split favoring substrate. Per heuristic Section 2 resolution
rule, two wins; substrate-side primitive candidate.

**Substrate primitive candidate**: AiPlus could provide a canonical
wrapper-build-asset-excludes list (or a `aiplus wrapper-build-assets` helper) that
wrappers consume instead of each maintaining their own tar exclude list. ASL's
current fix is wrapper-side bridge; substrate version, if delivered, would let ASL
delete the excludes from build-asl.sh.

**Tier**: Tier 2 (QoL — current wrapper bridge works; substrate version simplifies
wrapper maintenance and reduces drift risk for future wrappers).

**Evidence**: ASL commit 782d06b added 11 tar excludes to scripts/build-asl.sh; AEL
build-ael.sh almost certainly needs the same set.

**Status**: not yet filed upstream. Owner decides whether/when to file. Companion to
but distinct from v0.7.7-module-registration.

## Refinement candidate for heuristic v1.1

Section 7 of the heuristic invited refinements. Test C above suggests one concrete
refinement candidate:

When Q1 says "yes other wrappers would hit this" but only one wrapper currently
encounters it actively, the heuristic recommends "file as substrate request labeled
speculative-shared" (current AEL convention, provisional). Test C is exactly that
case — ASL is the first to surface it, but AEL would benefit equally on its next
vendor sync.

ASL recommends: keep the "speculative-shared" convention but add a tag for
"discovered by Nth wrapper" so substrate can prioritize gaps with multiple
independent encounters. Build-asset-excludes is currently 1-wrapper (ASL discovered,
AEL didn't surface). If AEL confirms similar packaging issue, it becomes 2-wrapper
and Tier promotes naturally.

## Drift translation rule (cross-side memo)

Separate from the layering heuristic, AEL Advisor and ASL Advisor agreed
(2026-05-27) on this companion rule for persona-writing discipline:

- drift-as-writing-failure → write-time scaffold (in CEO persona-writing prompt, not
in persona md)
- drift-as-identity-boundary → permanent Forbidden Action in persona md

Example: "agent-systems-engineer drifts into generic SWE" is write-time; goes in
scaffold. "evaluation-scientist plays hostile reviewer" is identity-boundary;
becomes a permanent Forbidden Action in evaluation-scientist.md.

Both wrappers absorb this as shared convention. Refinements ping back via Owner.
