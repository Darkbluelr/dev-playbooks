---
name: devbooks-knife
description: devbooks-knife: Slice an Epic into a topologically-sortable Slice queue, and write a machine-readable Knife Plan (required by the G3 gate for epic requests and/or high-risk changes).
recommended_experts: ["System Architect", "Product Manager"]
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Knife (Epic slicing + Knife Plan)

## Goal

Turn an Epic-sized request into a convergent **Slice queue** (DAG), and write a **machine-readable Knife Plan** that binds validation anchors and change package IDs.

## When it is required (MUST)

You MUST run Knife and write a Knife Plan when any of the following is true:

- `risk_level=high`
- `request_kind=epic`

Rationale: strict gating treats Knife Plan as a **mandatory G3 input** (missing/misaligned will block).

## Inputs

Minimum inputs (typically from Bootstrap/Proposal):

- `epic_id` (stable, globally unique)
- Epic-level AC set (or an enumerable acceptance set)
- `request_kind`
- `risk_level`
- dependencies and assumptions (may be incomplete, but must be explicit)

## Outputs (must be written to disk)

### 1) Knife Plan (machine-readable, MUST)

Location (MUST):

- `dev-playbooks/specs/_meta/epics/<epic_id>/knife-plan.yaml` (or `knife-plan.json`)

Consistency (MUST):

- `knife-plan.(yaml|json)` must contain `epic_id` matching `<epic_id>`
- If the change package declares `slice_id`, Knife Plan `slice_id` must match it

### 2) Slice queue (recommended)

Model a DAG via `slices[]`. Each slice SHOULD include:

- `slice_id`
- `change_id` (recommended to pre-allocate the change package directory name)
- `ac_subset[]` (MECE subset)
- `verification_anchors[]` (deterministic anchors: commands/tests/evidence paths)
- `rollback_strategy` (short summary or pointer)

## Execution notes (prompt-level)

1. Run config discovery first (prefer `.devbooks/config.yaml`), read `agents_doc` and `constitution.md`.
2. Confirm `epic_id` / `request_kind` / `risk_level` (if missing, route to Delivery/Void first).
3. Produce a Slice DAG: each slice must fit into a single change package loop (≤12 tasks).
4. Write the Knife Plan to the required path and bind `epic_id` / `slice_id`.
5. Output the next shortest-loop routing + upgrade conditions.

## Parallel Execution Scheduling

When a Knife Plan contains multiple Slices, you can generate a parallel execution schedule using `knife-parallel-schedule.sh`:

```bash
# Generate Markdown format parallel schedule
knife-parallel-schedule.sh <epic-id> --format md --out parallel-schedule.md

# Generate JSON format (for programmatic consumption)
knife-parallel-schedule.sh <epic-id> --format json --out parallel-schedule.json
```

### Output Contents

1. **Maximum Parallelism**: Maximum number of Agents that can start simultaneously
2. **Layered Execution Schedule**:
   - Layer 0: No dependencies, can start immediately
   - Layer 1: Depends on Layer 0 completion
   - Layer N: Depends on Layer N-1 completion
3. **Critical Path**: Serial dependency depth
4. **Launch Command Templates**: Agent launch command for each Slice
5. **Traceability Info**: Epic ID, Plan ID, Plan Revision

### Use Case

Since current AI programming tools do not support second-level sub-agent invocation, after Epic slicing, humans need to coordinate multiple independent Agents in parallel:

1. Run `knife-parallel-schedule.sh` to generate the schedule
2. Launch multiple independent Agents for Layer 0 Slices
3. Wait for all Layer 0 to complete, then launch Layer 1
4. Repeat until all Layers complete
5. Run `requirements-ledger-derive.sh` to update the ledger

## References

- `dev-playbooks/specs/knife/spec.md`
- `dev-playbooks/specs/_meta/epics/README.md`
- `skills/devbooks-delivery-workflow/scripts/knife-parallel-schedule.sh` (parallel scheduling script)
