# RUNBOOK: <change-id>

## 0) Quick Start (two things only)
1. [AI] Execute by "Route A or B" (do not invent your own steps).
2. [CMD] Only run the verification anchors listed in this RUNBOOK, and write outputs to `evidence/`.

## 1) Routing Result (filled by Delivery)
- request_kind: <debug|change|epic|void|bootstrap|governance>
- change_type: <feature|hotfix|refactor|migration|compliance|spike-prototype|docs|protocol...>
- risk_level: <low|medium|high>
- intervention_level: <local|team|org>
- deliverable_quality: <outline|draft|complete|operational>
- need_bootstrap: <yes/no>
- need_void: <yes/no>
- need_knife: <yes/no>
- need_spec_delta: <yes/no>
- platform_targets: <0..N tool ids; only when configured/enabled>
- spec_targets: <0..N canonical paths; only when need_spec_delta=yes>

## 2) Input Checklist
- Request text: <paste or reference>
- References index: `inputs/index.md`

## Cover View (derived cache; safe to delete and rebuild)

> NOTE: For `risk_level=medium|high` OR `request_kind=epic|governance` OR `intervention_level=team|org`, G6 (`archive|strict`) will block archive if this RUNBOOK no longer contains the `## Cover View` and `## Context Capsule` headings. **Do not delete the headings.**

<!-- DEVBOOKS_DERIVED_COVER_VIEW:START -->
> Generate via `skills/devbooks-delivery-workflow/scripts/runbook-derive.sh <change-id> --project-root . --change-root dev-playbooks/changes --truth-root dev-playbooks/specs` (derived cache; safe to delete and rebuild)
<!-- DEVBOOKS_DERIVED_COVER_VIEW:END -->

## Context Capsule (<=2 pages; index + constraints only; do not paste long logs/outputs)

<!-- DEVBOOKS_DERIVED_CONTEXT_CAPSULE:START -->
> Generate via `skills/devbooks-delivery-workflow/scripts/runbook-derive.sh <change-id> --project-root . --change-root dev-playbooks/changes --truth-root dev-playbooks/specs` (derived cache; safe to delete and rebuild)
<!-- DEVBOOKS_DERIVED_CONTEXT_CAPSULE:END -->

### 1) One-line goal (align with `completion.contract.yaml: intent.summary`)
- summary: <one line; same meaning as intent.summary>

### 2) Invariants (3–7 items; include 1 reference anchor each)
- <invariant 1> (source: path/to/doc.md#Heading)
- <invariant 2> (source: path/to/doc.md#Heading)

### 3) Impact boundaries (allowed/forbidden; at least directory/module level)
- Allowed:
  - <allowed-1>
- Forbidden:
  - <forbidden-1>

### 4) Must-run verification anchors (invocation_ref only; do not paste outputs)
- <C-xxx> <invocation_ref>

### 5) Default investigation path (must-check list: entry/config/scripts/templates)
- Entry: <system/project entrypoints and commands>
- Config: <key config files/locations that affect behavior>
- Scripts: <key scripts/contracts to read/run>
- Templates: <templates and sources that may need sync/update>
- SSOT: <canonical spec paths referenced by spec_targets>

### 6) Shortcut blacklist (3–7 forbidden actions)
- <blacklist-1>

## 3) Two execution routes

### A) Automated closed loop (if your environment supports multi-agent / isolated sessions)
[AI | Automated Closed Loop Prompt (copy/paste)]
You are the orchestrator. Follow this RUNBOOK strictly and write all artifacts to disk.
If role isolation is required:
1) If you can create separate sub-agents/sessions: create and run Test Owner and Coder (and Challenger/Judge when needed).
2) If you cannot: clearly tell me "I need you to open a new conversation/new instance manually", then pause and wait for my confirmation.
Forbidden: writing tests and implementation in the same context; drafting a proposal and judging it yourself in the same context.

### B) Manual closed loop (no multi-agent / cannot spawn sessions)
**Windows you must prepare**:
- Window 1: Delivery / main thread (summary + checks only)
- Window 2: Test Owner (only `tests/**` + `verification.md` + `evidence/**`)
- Window 3: Coder (implementation only; must not modify `tests/**`)
(If proposal debate/judgement is needed, open additional windows for Author/Challenger/Judge.)

## 4) Artifact checklist and done criteria
- Required files: `proposal.md`, `design.md`, `tasks.md`, `verification.md`
- Evidence directories:
  - `evidence/red-baseline/`
  - `evidence/green-final/`
  - `evidence/gates/`
    - Note: before archive, produce `evidence/gates/G6-archive-decider.json` (hint only; not wired)
  - `evidence/risks/`
- Done criteria: `change-check.sh --mode strict` + Green Evidence (no verbal self-certification)

## 5) Rollback and stop-loss
- DoR not met → back to Bootstrap
- Repeated failures / missing external inputs → back to Void
- Budget exceeded / slicing does not converge → back to Knife
