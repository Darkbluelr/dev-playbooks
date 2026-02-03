# Role Handoff Record

## Handoff Metadata

- **Change ID**: <change-id>
- **Handoff from role**: <Test Owner / Design Owner / Planner / ...>
- **Handoff to role**: <Coder / Reviewer / ...>
- **Handoff time**: <YYYY-MM-DD HH:MM>
- **Conversation/instance ID**: <session-id>

## Handoff Content

### Completed Deliverables

- [ ] `design.md` - Design doc produced and reviewed
- [ ] `tasks.md` - Implementation plan produced
- [ ] `verification.md` - Acceptance tests defined
- [ ] `tests/**` - Test code implemented
- [ ] Red baseline recorded in `evidence/red-baseline/`

### Context Information

> Fill in key information the receiving role needs.

- **Current status**: <brief progress summary>
- **Key decisions**: <important decisions to know>
- **Known issues**: <risks or issues likely to be encountered>
- **References**: `RUNBOOK.md#Context Capsule` (required when risk_level=medium|high OR request_kind=epic|governance OR intervention_level=team|org); <other documents to read>

### Must-run Anchors

> List copy-pastable verification anchors. Keep aligned with `RUNBOOK.md#Context Capsule`.
> If there are no additional anchors, write `N/A` (do not leave it blank).

- <C-xxx> <invocation_ref / command>

### Weak-Link Obligations

> List code-external sync points / weak-link obligations (docs/config/release/ops/migration).
> Prefer `completion.contract.yaml::obligations[]` `O-###` + its evidence output under `evidence/**`.
> If there are no weak-link obligations, write `N/A` (do not leave it blank).

- <O-xxx> <what to sync> -> evidence: <evidence/path>

### Remaining Work

> List work the receiving role needs to complete.
> If there is nothing left, write `N/A` (do not keep `<...>` placeholders).

1. <remaining item 1>
2. <remaining item 2>

## Confirmation Signatures

> After handoff, both sides confirm here.

- [ ] **From-side confirmation**: I confirm the deliverables above are complete and the information is accurate.
- [ ] **To-side confirmation**: I confirm I have received the handoff content and understand current status and remaining work.

---

## Notes

> Optional: additional information to record.

<fill in additional notes or leave blank>
