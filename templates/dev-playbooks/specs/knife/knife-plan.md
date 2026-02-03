# Knife Plan Template (notes)

> Knife Plan MUST be machine-readable. Prefer `knife-plan.yaml` in the same folder (this file only documents fields).

## Metadata

- plan_id: <plan-id>
- epic_id: <epic-id>
- slice_id: <slice-id>
- ac_ids: [AC-001]
- acceptance_ids: [ACC-001]
- change_type: feature
- risk_level: medium
- dependencies: []
- assumptions: <assumptions>

## Validation Anchors

| anchor_id | gate_id | evidence_type | success_criteria | owner |
| --- | --- | --- | --- | --- |
| ANCHOR-001 | G3 | checklist | All anchor fields present | planner |
