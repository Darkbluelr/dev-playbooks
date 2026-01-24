---
name: devbooks-delivery-workflow
description: devbooks-delivery-workflow: Complete closed-loop orchestrator that runs in AI programming tools with sub-agent support, automatically orchestrating the full Proposal→Design→Spec→Plan→Test→Implement→Review→Archive workflow. Use when the user says "run closed-loop/complete delivery/end-to-end flow/automated change workflow" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
  - Task
---

# DevBooks: Delivery Acceptance Workflow (Complete Closed-Loop Orchestrator)

## Progressive Disclosure

### Base (must read)
Goal: complete a 12-stage closed-loop delivery by orchestrating sub-agents only.
Input: user goal, config mapping, existing change package artifacts and stage status.
Output: sub-agent call sequence, stage progress, and result summary.
Boundaries: main agent does not modify files directly; must call sub-agents via Task; enforce role isolation and gates.
Evidence: artifact paths, script outputs, and review notes per stage.

### Advanced (optional)
Use when you need: ban details, stage table, resume rules.

### Extended (optional)
Use when you need: gate handling, traceability templates, script pointers.

## Core Notes

- Orchestration only: do not directly write proposal/design/tests/implementation.
- 12 stages are mandatory; any failure triggers rollback to the corresponding stage.
- Run config discovery first (prefer `.devbooks/config.yaml`), then invoke sub-agents.

## References

- `skills/devbooks-delivery-workflow/references/orchestration-bans-and-stage-table.md`: bans, 12-stage table, resume notes.
- `skills/devbooks-delivery-workflow/references/subagent-invocation-spec.md`: sub-agent invocation format and isolation rules.
- `skills/devbooks-delivery-workflow/references/orchestration-logic-pseudocode.md`: orchestration main logic.
- `skills/devbooks-delivery-workflow/references/gate-checks-and-error-handling.md`: gate checkpoints and rollback strategy.
- `skills/devbooks-delivery-workflow/references/delivery-acceptance-workflow.md`: full workflow description.
- `skills/devbooks-delivery-workflow/references/9-change-verification-traceability-template.md`: verification & traceability templates.

## Recommended MCP Capability Types

- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)

