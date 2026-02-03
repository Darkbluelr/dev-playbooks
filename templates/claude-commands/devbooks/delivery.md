---
skill: devbooks-delivery-workflow
---

# DevBooks: Delivery Workflow

Use devbooks-delivery-workflow as the **single entry**: it classifies the request and routes to the **minimal sufficient closed loop** (`debug|change|epic|void|bootstrap|governance`).

## Usage

/devbooks:delivery [args]

## Args

$ARGUMENTS

## Notes

You don’t need to memorize other entry commands; everything starts here.

Routing results are written as auditable artifacts (at minimum: `proposal.md` front matter with `request_kind` / `change_type` / `risk_level`, plus a matching `RUNBOOK.md`).

If the project does not have an upstream SSOT library, Delivery will first scaffold a minimal SSOT pack under `<truth-root>/ssot/` (`SSOT.md` + `requirements.index.yaml`), then continue the routed loop.

Closed-loop selection principles:
- `request_kind=debug`: reproduce → locate → fix/diagnose → verify (escalate to change package if needed)
- `request_kind=change`: single change-package loop (gates derived by risk + contracts)
- `request_kind=epic`: Knife slicing is mandatory → convergent slice queue
- `request_kind=void`: high-entropy research/prototyping → decision record → flow back
- `request_kind=bootstrap`: baseline + glossary/boundaries/scenarios (block if DoR is not met)
- `request_kind=governance`: protocol/gates/truth-artifacts governance (stricter evidence + archive rules)
  - Includes: SSOT maintenance, syncing `requirements.index.yaml`, and refreshing `requirements.ledger.yaml` (derived cache)
