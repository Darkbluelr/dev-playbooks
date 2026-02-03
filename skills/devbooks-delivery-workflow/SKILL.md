---
name: devbooks-delivery-workflow
description: devbooks-delivery-workflow: Single entrypoint + router + orchestrator. Routes by request_kind and runs the minimal sufficient closed loop (debug/change/epic/void/bootstrap/governance), escalating gates and evidence only when required.
recommended_experts: ["System Architect", "Product Manager"]
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
  - Task
---

# DevBooks: Delivery (Single Entry / Routing / Closed-Loop Orchestrator)

## Progressive Disclosure

### Base (must read)
Goal: use **Delivery as the single entrypoint**, route by `request_kind`, and orchestrate the **minimal sufficient closed loop** until it is archivable (or explicitly route into Void/Bootstrap to satisfy prerequisites).
Input: user goal/context, config mapping, existing change package artifacts and current status.
Output: routing result (`request_kind` + minimal loop + upgrade conditions) and the corresponding on-disk artifacts (proposal/design/spec/tasks/verification/evidence/gate reports…).
Boundaries: orchestration + verification only; when artifacts are needed, must call the corresponding sub-skills; enforce role isolation (especially Test Owner vs Coder) and gates.
Evidence: artifact paths, gate script reports, review outputs, and archive result.

### Advanced (optional)
Use when you need: orchestration bans, routing table, resume rules.

### Extended (optional)
Use when you need: gate handling, traceability templates, script pointers.

## Core Notes

- Orchestration only: do not directly write proposal/design/tests/implementation.
- **No fixed “12-stage mandatory loop”**: `request_kind` drives “do what is required, skip what is not” — but never skip mandatory gates/evidence for the chosen loop.
- Run config discovery first (prefer `.devbooks/config.yaml` when present), then invoke sub-agents.
- `request_kind` is the primary axis: `debug|change|epic|void|bootstrap|governance`.
- **SSOT maintenance (auto-create when absent)**: when the project has no upstream SSOT, the `request_kind=bootstrap` path must first scaffold a minimal SSOT pack: `<truth-root>/ssot/SSOT.md` + `<truth-root>/ssot/requirements.index.yaml` (and you may derive a progress view via `requirements-ledger-derive.sh`).
- **SSOT change sync (governance path)**: when the request is “edit/sync SSOT or index/ledger”, route to `request_kind=governance` and call `devbooks-ssot-maintainer` (delta → index sync → optional ledger refresh).
- Follow **P3-3 Action Norms** in `references/orchestration-bans-and-stage-table.md` (orchestration-only, artifact numbering, multi-change anti-contamination, Archiver-required Done).

## References

- `skills/devbooks-delivery-workflow/references/orchestration-bans-and-stage-table.md`: orchestration bans, `request_kind` routing table, resume notes.
- `skills/devbooks-delivery-workflow/references/subagent-invocation-spec.md`: sub-agent invocation format and isolation rules.
- `skills/devbooks-delivery-workflow/references/orchestration-logic-pseudocode.md`: orchestration main logic.
- `skills/devbooks-delivery-workflow/references/gate-checks-and-error-handling.md`: gate checkpoints and rollback strategy.
- `skills/devbooks-delivery-workflow/references/delivery-acceptance-workflow.md`: full workflow description.
- `skills/devbooks-delivery-workflow/references/9-change-verification-traceability-template.md`: verification & traceability templates.
