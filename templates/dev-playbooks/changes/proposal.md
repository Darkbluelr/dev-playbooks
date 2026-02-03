---
schema_version: 1.0.0
change_id: <change-id>
request_kind: change
change_type: docs
risk_level: low
intervention_level: local
state: pending
state_reason: ""
next_action: DevBooks
epic_id: ""
slice_id: ""
ac_ids: []
acceptance_ids: []
truth_refs: {}
risk_flags: {}
required_gates:
  - G0
  - G1
  - G2
  - G4
  - G6
completion_contract: completion.contract.yaml
deliverable_quality: outline
approvals:
  security: ""
  compliance: ""
  devops: ""
escape_hatch: null
---

# Proposal: <change-id>

> Output location: `dev-playbooks/changes/<change-id>/proposal.md`
>
> Note: Proposal must not include implementation steps; define only Why/What/Impact/Risks/Validation + Debate/Judge records.

## Why

- Problem:
- Goal:

## What Changes

- In scope:
- Out of scope (Non-goals):
- Impact scope (modules/capabilities/external contracts/data invariants):

## Impact

- External contracts (API/Schema/Event):
- Data and migration:
- Affected modules and dependencies:
- Testing and quality gates:
- Value signal and observation: none
- Value stream bottleneck hypothesis: none

## Risks

- Risks:
- Degradation strategy:
- Rollback strategy:

## Validation

- Candidate acceptance anchors (tests/static checks/build/manual evidence):
- Evidence location: `dev-playbooks/changes/<change-id>/evidence/`

## Debate Packet

- Debate points/questions requiring decision (<=7 items):

## Decision Log

- Decision status: Pending
- Decision summary:
- Questions requiring decision:
