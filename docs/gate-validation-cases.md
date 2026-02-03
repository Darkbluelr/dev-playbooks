# Gate Validation Case Matrix (T9)

> Goal: turn common failure modes (“dropped work”, “forgotten tail”, “weak links”, and “drift”) into a **reproducible, machine-judgeable** checklist with a clear `next_action`; directly reusable for integration validation (T10).

## 0) Conventions: keep cases reproducible + machine-judgeable

1) **Use a dedicated `change-id` per case** (avoid cross-case contamination).  
2) **Try to trigger only 1 gate per case**: keep only the target gate in `proposal.md.required_gates` (other gate issues will usually show as *skipped* warnings and should not count as the failure you’re asserting).  
3) **Prefer machine assertions from `evidence/gates/*.json`** via `status/next_action`; if a script only emits stdout/stderr, redirect output to `evidence/gates/*.log` and assert with a fixed grep pattern.  
4) Recommended unified parameters (adjust for your project layout):
   - `--project-root .`
   - `--change-root dev-playbooks/changes`
   - `--truth-root dev-playbooks/specs`

## 1) Case matrix (G0–G6 × 4 failure classes)

> Each case provides a tuple: **Trigger → expected failure → expected `next_action` → evidence output**.  
> “Expected failure” includes machine assertions (`status=fail|warn` and `failure_reasons` keywords).

## G0 (metadata / baseline / state / void)

- **Leak: UC-G0-LEAK-BASELINE (baseline artifacts missing → Bootstrap fallback)**  
  - Trigger: run `skills/devbooks-delivery-workflow/scripts/change-metadata-check.sh` with `--truth-root` pointing to a directory that lacks the baseline `*_meta/*.md` artifacts (e.g. an empty dir).  
  - Expected failure: `evidence/gates/change-metadata-check.json.status=fail` and `failure_reasons[]` contains `truth baseline missing; next_action=Bootstrap`.  
  - Expected `next_action`: `Bootstrap` (read `evidence/gates/change-metadata-check.json.next_action`).  
  - Evidence output: `dev-playbooks/changes/<change-id>/evidence/gates/change-metadata-check.json`.

- **Forget: UC-G0-FORGET-DECISION (Decision not Approved, still try strict)**  
  - Trigger: keep `proposal.md## Decision Log` at `Decision Status: Pending` (or missing Approved), then run `skills/devbooks-delivery-workflow/scripts/change-check.sh --mode strict`.  
  - Expected failure: `evidence/gates/G0-strict.report.json.status=fail` and `failure_reasons[]` contains `proposal decision status must be Approved`.  
  - Expected `next_action`: `DevBooks` (read `evidence/gates/G0-strict.report.json.next_action`).  
  - Evidence output: `dev-playbooks/changes/<change-id>/evidence/gates/G0-strict.report.json`.

- **Weak link: UC-G0-WEAK-VOID (declare `next_action=Void` but Void artifacts missing)**  
  - Trigger: set `proposal.md` front matter to `next_action: Void` (do not create `void/`), then run `skills/devbooks-delivery-workflow/scripts/void-protocol-check.sh --mode strict`.  
  - Expected failure: `evidence/gates/void-protocol-check.json.status=fail` and `failure_reasons[]` contains `missing Void artifact:` or `VOID_ENABLED!=true`.  
  - Expected `next_action`: `Void` (read `evidence/gates/void-protocol-check.json.next_action`).  
  - Evidence output: `dev-playbooks/changes/<change-id>/evidence/gates/void-protocol-check.json`.

- **Drift: UC-G0-DRIFT-CHANGEID (directory name != `proposal.change_id`)**  
  - Trigger: change `proposal.md` front matter `change_id:` to a different value, then run `skills/devbooks-delivery-workflow/scripts/change-metadata-check.sh --mode strict`.  
  - Expected failure: `evidence/gates/change-metadata-check.json.status=fail` and `failure_reasons[]` contains `proposal change_id mismatch:`.  
  - Expected `next_action`: `DevBooks` (read `evidence/gates/change-metadata-check.json.next_action`).  
  - Evidence output: `dev-playbooks/changes/<change-id>/evidence/gates/change-metadata-check.json`.

## G1 (required_gates derivation and determinism)

- **Leak: UC-G1-LEAK-REQUIRED-GATES (`required_gates` missing/empty)**  
  - Trigger: delete `required_gates:` from `proposal.md` front matter (or set it to empty), then run `skills/devbooks-delivery-workflow/scripts/required-gates-check.sh`.  
  - Expected failure: `evidence/gates/required-gates-check.json.status=fail` and `failure_reasons[]` contains `proposal.required_gates is missing or empty`.  
  - Expected `next_action`: `DevBooks` (read `evidence/gates/required-gates-check.json.next_action`).  
  - Evidence output: `dev-playbooks/changes/<change-id>/evidence/gates/required-gates-check.json` (also generates `required-gates-derive.json`).

- **Forget: UC-G1-FORGET-RISK-UPGRADE (`risk_level` upgraded but G5 not added)**  
  - Trigger: set `proposal.md:risk_level` to `medium` (or `high`), but keep `required_gates` without `G5`, then run `required-gates-check.sh`.  
  - Expected failure: `required-gates-check.json.status=fail` and `failure_reasons[]` contains `missing derived gate: G5`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/required-gates-check.json` + `evidence/gates/required-gates-derive.json`.

- **Weak link: UC-G1-WEAK-MISS-G6 (missing the final adjudicator gate)**  
  - Trigger: remove `G6` from `required_gates` (keep others), then run `required-gates-check.sh`.  
  - Expected failure: `required-gates-check.json.status=fail` and `failure_reasons[]` contains `missing derived gate: G6`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/required-gates-check.json`.

- **Drift: UC-G1-DRIFT-CONTRACT-QUALITY (deliverable quality upgraded but G2 not added)**  
  - Trigger: set `completion.contract.yaml:intent.deliverable_quality` to `draft` (or higher), but keep `required_gates` without `G2`, then run `required-gates-check.sh`.  
  - Expected failure: `required-gates-check.json.status=fail` and `failure_reasons[]` contains `missing derived gate: G2`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/required-gates-check.json` (you can also see the derivation reason in `required-gates-derive.json`).

## G2 (Green Evidence closure / task closure / failure evidence block)

> Use `skills/devbooks-delivery-workflow/scripts/change-check.sh <change-id> --mode strict` and keep only `G2` in `proposal.md.required_gates` to isolate other gates.

- **Leak: UC-G2-LEAK-TASKS (tasks not completed)**  
  - Trigger: ensure `evidence/green-final/` is non-empty (any file without FAIL patterns), but leave unchecked items in `tasks.md`.  
  - Expected failure: `evidence/gates/G2-strict.report.json.status=fail` and `failure_reasons[]` contains `Task completion rate` (AC-002).  
  - Expected `next_action`: `DevBooks` (read `evidence/gates/G2-strict.report.json.next_action`).  
  - Evidence output: `evidence/gates/G2-strict.report.json` + `evidence/green-final/*`.

- **Forget: UC-G2-FORGET-GREEN (missing Green Evidence)**  
  - Trigger: mark all `tasks.md` checkboxes done (or remove all checkboxes), but keep `evidence/green-final/` empty.  
  - Expected failure: `G2-strict.report.json.status=fail` and `failure_reasons[]` contains `Missing Green evidence` (AC-001).  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/G2-strict.report.json`.

- **Weak link: UC-G2-WEAK-P0-SKIP (P0 skipped without approval evidence)**  
  - Trigger: add an unchecked `- [ ] [P0] <task>` in `tasks.md` and ensure there’s no nearby `<!-- SKIP-APPROVED:` comment.  
  - Expected failure: `G2-strict.report.json.status=fail` and `failure_reasons[]` contains `P0 task skip requires approval` (AC-005).  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/G2-strict.report.json` (trigger is in `tasks.md`).

- **Drift: UC-G2-DRIFT-GREEN-FAIL (Green Evidence contains FAIL patterns)**  
  - Trigger: ensure tasks are closed (all checked), then write a failure pattern line like `FAIL:` / `FAILED:` / `not ok` into any file under `evidence/green-final/`.  
  - Expected failure: `G2-strict.report.json.status=fail` and `failure_reasons[]` contains `Test failure: Green evidence contains failure pattern` (AC-007).  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/G2-strict.report.json` + the corresponding `evidence/green-final/*` file.

## G3 (Knife / anchors: machine-readable for high-risk or epic)

- **Leak: UC-G3-LEAK-ANCHORS (contract `checks[]` missing deterministic fields)**  
  - Trigger: keep `completion.contract.yaml.checks[]` missing `runner/timeout_seconds/requires_network/success_criteria/failure_next_action`, then run `skills/devbooks-delivery-workflow/scripts/verification-anchors-check.sh --mode strict`.  
  - Expected failure: `evidence/gates/verification-anchors-check.json.status=fail` and `failure_reasons[]` contains `missing anchor fields:`.  
  - Expected `next_action`: `DevBooks` (read `verification-anchors-check.json.next_action`).  
  - Evidence output: `evidence/gates/verification-anchors-check.json`.

- **Forget: UC-G3-FORGET-KNIFE (`risk=high` or epic but Knife inputs missing)**  
  - Trigger: set `proposal.md:risk_level` to `high`, leave `epic_id/slice_id` empty, then run `skills/devbooks-delivery-workflow/scripts/knife-plan-check.sh --mode strict --out evidence/gates/knife-plan-check-strict.json`.  
  - Expected failure: `knife-plan-check-strict.json.status=fail` and `failure_reasons[]` contains `missing epic_id` (or `Knife Plan ... missing`).  
  - Expected `next_action`: `Knife` (read `knife-plan-check-strict.json.next_action`).  
  - Evidence output: `evidence/gates/knife-plan-check-strict.json`.

- **Weak link: UC-G3-WEAK-FREEZE-REV (entered `in_progress+` but Knife revision not frozen)**  
  - Trigger: set `proposal.md` to `risk_level: high`, `epic_id: EPIC-AINATIVE-PROTOCOL-V1-1-COMPLETION`, `slice_id: SLICE-AINATIVE-PROTOCOL-V1-1-FULLY`, `state: in_progress`, but keep `truth_refs` missing `knife_plan_revision`, then run `knife-plan-check.sh`.  
  - Expected failure: `knife-plan-check-*.json.status=fail` and `failure_reasons[]` contains `truth_refs.knife_plan_revision is required once state=`.  
  - Expected `next_action`: `Knife`.  
  - Evidence output: `evidence/gates/knife-plan-check-*.json` (and the referenced `dev-playbooks/specs/_meta/epics/**/knife-plan.yaml`).

- **Drift: UC-G3-DRIFT-EPIC-AC (`proposal.ac_ids` mismatches `slice.ac_subset`)**  
  - Trigger: set `proposal.md` to `risk_level: high` and keep the same `epic_id/slice_id` as above, but change `ac_ids` to be inconsistent with the slice’s `ac_subset`; run `skills/devbooks-delivery-workflow/scripts/epic-alignment-check.sh --mode strict`.  
  - Expected failure: `evidence/gates/epic-alignment-check.json.status=fail` and `failure_reasons[]` contains `AC alignment mismatch:`.  
  - Expected `next_action`: `DevBooks` (read `epic-alignment-check.json.next_action`).  
  - Evidence output: `evidence/gates/epic-alignment-check.json`.

## G4 (extension pack integrity / structural gate / docs impact)

- **Leak: UC-G4-LEAK-PACK-MISSING (pack enabled but directory missing)**  
  - Trigger: run `skills/devbooks-delivery-workflow/scripts/extension-pack-integrity-check.sh --enabled-packs not-exist-pack`.  
  - Expected failure: `evidence/gates/extension-pack-integrity-check.json.status=fail` and `failure_reasons[]` contains `enabled pack missing under truth root`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/extension-pack-integrity-check.json`.

- **Forget: UC-G4-FORGET-DOCS-IMPACT (P0 docs work declared but checklist incomplete)**  
  - Trigger: add any `| P0 |` row in `design.md` (indicating P0 docs work exists) and add an unchecked item like `- [ ] New workflow ...`; run `change-check.sh --mode strict` (keep only `G4` in `required_gates`).  
  - Expected failure: `evidence/gates/G4-strict.report.json.status=fail` and `failure_reasons[]` contains `Documentation update checklist has incomplete items` (AC-008).  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/G4-strict.report.json`.

- **Weak link: UC-G4-WEAK-MAPPING-INVALID (pack mapping missing executable fields)**  
  - Trigger: under a temporary `--truth-root`, create a pack (e.g. `t9-bad-pack`) and write a mapping that misses `evidence_paths` or `check_id`, then run `extension-pack-integrity-check.sh --enabled-packs t9-bad-pack --truth-root <tmp>`.  
  - Expected failure: `extension-pack-integrity-check.json.status=fail` and `failure_reasons[]` contains `mapping entry missing required fields`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/extension-pack-integrity-check.json`.

- **Drift: UC-G4-DRIFT-PACK-ID (invalid `pack_id` in enabled list)**  
  - Trigger: run `extension-pack-integrity-check.sh --enabled-packs Bad_Pack` (uppercase / underscore).  
  - Expected failure: `extension-pack-integrity-check.json.status=fail` and `failure_reasons[]` contains `invalid pack_id (expected [a-z0-9-])`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/extension-pack-integrity-check.json`.

## G5 (risk evidence / protocol coverage: risk-driven blocking)

- **Leak: UC-G5-LEAK-RISK-EVIDENCE (`risk=medium|high` but risk evidence missing)**  
  - Trigger: set `proposal.md:risk_level=medium` (or high), do not provide `rollback-plan.md` and `evidence/risks/dependency-audit.log`, run `skills/devbooks-delivery-workflow/scripts/risk-evidence-check.sh --mode strict --out evidence/gates/risk-evidence-check-strict.json`.  
  - Expected failure: `risk-evidence-check-*.json.status=fail` and `failure_reasons[]` contains `missing rollback-plan.md` / `missing dependency audit log`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/risk-evidence-check-*.json`.

- **Forget: UC-G5-FORGET-P10-REPORT (P10 triggered but coverage report missing)**  
  - Trigger: set `proposal.md` to `risk_flags.protocol_v1_1: true` (or `risk_level: high`), provide basic risk evidence (rollback plan + dependency audit), but do not generate `evidence/gates/protocol-v1.1-coverage.report.json`; run `change-check.sh --mode strict` (keep only `G5` in `required_gates`).  
  - Expected failure: `evidence/gates/G5-strict.report.json.status=fail` and `failure_reasons[]` contains `missing protocol coverage report (P10)`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/G5-strict.report.json`.

- **Weak link: UC-G5-WEAK-EXT-PACK-EVIDENCE (pack enabled but its evidence missing)**  
  - Trigger: set `risk_level=medium|high` and enable a pack via env var `DEVBOOKS_EXTENSIONS_ENABLED_PACKS_CSV=security-audit`; provide rollback plan + dependency audit, but do not provide `evidence/risks/security-audit.log`; run `risk-evidence-check.sh`.  
  - Expected failure: `risk-evidence-check-*.json.status=fail` and `failure_reasons[]` contains `missing extension pack evidence (security-audit): .../evidence/risks/security-audit.log`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/risk-evidence-check-*.json`.

- **Drift: UC-G5-DRIFT-P10-SHA (coverage report SHA mismatches the mapping source)**  
  - Trigger: trigger P10 (as above), generate `evidence/gates/protocol-v1.1-coverage.report.json`, but set its `design_source_sha256` to a value different from `dev-playbooks/specs/protocol-core/protocol-v1.1-coverage-mapping.yaml:design_source_sha256`; run `change-check.sh --mode strict`.  
  - Expected failure: `G5-strict.report.json.status=fail` and `failure_reasons[]` contains `design_source_sha256 mismatch (P10)`.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/G5-strict.report.json` + `evidence/gates/protocol-v1.1-coverage.report.json`.

## G6 (archive adjudication: scope evidence bundle + weak links + freshness + reference integrity)

- **Leak: UC-G6-LEAK-SCOPE-EVIDENCE (scope evidence bundle triggered, required evidence missing)**  
  - Trigger: set `proposal.md` to `risk_level: medium` (or `request_kind: epic|governance`) to trigger the Scope Evidence Bundle, but do not generate `evidence/gates/reference-integrity.report.json` and `evidence/gates/check-completion-contract.log`; run `skills/devbooks-delivery-workflow/scripts/archive-decider.sh --mode strict`.  
  - Expected failure: `evidence/gates/G6-archive-decider.json.status=fail` and `scope_evidence_bundle_evaluation.status=fail`, with `missing_artifacts[]` containing those paths.  
  - Expected `next_action`: `DevBooks` (read `G6-archive-decider.json.next_action`).  
  - Evidence output: `evidence/gates/G6-archive-decider.json`.

- **Leak: UC-G6-LEAK-RUNBOOK-STRUCTURE (higher-scope triggered, RUNBOOK control-plane headings removed)**  
  - Trigger: trigger higher-scope (as above), then delete `## Cover View` or `## Context Capsule` headings from the change package `RUNBOOK.md`; run `skills/devbooks-delivery-workflow/scripts/archive-decider.sh --mode strict` (or `change-check.sh --mode strict`).  
  - Expected failure: `evidence/gates/G6-archive-decider.json.status=fail` and `runbook_structure_evaluation.status=fail`, with `missing_sections[]` containing the missing headings.  
  - Expected `next_action`: `DevBooks` (restore RUNBOOK structure and rebuild derived cache).  
  - Evidence output: `evidence/gates/G6-archive-decider.json`.

- **Forget: UC-G6-FORGET-STATE-CLOSE (not closed, still try `completed` adjudication)**  
  - Trigger: keep `proposal.md.state` != `completed` (or `Decision Status` != Approved / `verification.md` still Draft/Ready), run `skills/devbooks-delivery-workflow/scripts/check-state-consistency.sh --state completed --out evidence/gates/state-consistency-check.json`.  
  - Expected failure: `state-consistency-check.json.status=fail` and `blockers[]` includes a corresponding blocker (e.g. `missing_decision_status` / `verification_not_done` / `traceability_has_todo`).  
  - Expected `next_action`: `DevBooks` (read `state-consistency-check.json.next_action`).  
  - Evidence output: `evidence/gates/state-consistency-check.json`.

- **Weak link: UC-G6-WEAK-STALE-ARTIFACT (weak-link evidence stale / broken chain)**  
  - Trigger: declare a `weak_link` MUST obligation in `completion.contract.yaml` (applies_to → deliverables.path), create its `checks[].artifacts[]` (e.g. `evidence/gates/docs-consistency.report.json` with `{\"status\":\"pass\",\"issues_count\":0}`), then update the covered deliverable so its mtime becomes newer than the artifact, run `archive-decider.sh --mode strict`.  
  - Expected failure: `G6-archive-decider.json.status=fail`, and `weak_link_evaluation.unmet_weak_link_obligations[]` is non-empty or `freshness_evaluation.stale_artifacts[]` is non-empty.  
  - Expected `next_action`: `DevBooks`.  
  - Evidence output: `evidence/gates/G6-archive-decider.json` (plus referenced `evidence/gates/*.report.json` / deliverables).

- **Drift: UC-G6-DRIFT-REFERENCE (unresolvable references / unauthorized deps)**  
  - Trigger: write an unresolvable reference (e.g. `truth://no/such/file.md` or `capability://NO_SUCH_CAP`) into any `.md/.yaml` under the change package; run `skills/devbooks-delivery-workflow/scripts/reference-integrity-check.sh`.  
  - Expected failure: `evidence/gates/reference-integrity.report.json.status=fail` and `violations_count>0`.  
  - Expected `next_action`: `DevBooks` (in G6 semantics, default is to fix references / add evidence).  
  - Evidence output: `evidence/gates/reference-integrity.report.json`.
