# Router: routing rules and output templates (reference)

This file carries the detailed rules and examples for Router, to keep `skills/devbooks-router/SKILL.md` small and stable.

## Config discovery (protocol-agnostic, mandatory)

- `<truth-root>`: truth directory root
- `<change-root>`: change package root

Discovery order (stop at the first match):
1. `.devbooks/config.yaml` (if exists) → parse mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks default mapping
3. `project.md` (if exists) → template default mapping
4. If still unknown → stop and ask the user

Constraints:
- If `agents_doc` is specified, read it before doing anything.
- Do not guess directory roots.

## Structured analysis capability check (automatic)

Before routing, check whether structured code analysis is available (dependency/ref tracking):

- If unavailable: warn that impact analysis/review will degrade to text search; continue routing.
- If available: continue silently.

## Output template (mandatory)

1) Ask 2 minimum key questions (skip if already known from context):
- What is the `<change-id>`?
- What are the final values of `<truth-root>` / `<change-root>` in this project?

2) Output 3–6 next-step routing items:
- Each item: Skill to use + artifact path + why it’s needed.

3) If the user asks to “start producing file content”, switch to the target Skill’s output mode.

## Start entry rules (default entrypoint)

Start is the default entrypoint. When Start is triggered, follow these rules:

1) If `<change-id>` is unclear, ask for `<change-id>` and confirm `<truth-root>/<change-root>`.
2) If the change package state can be inferred (e.g. `pending/in_progress/review/completed`), recommend the next entrypoint:
   - `pending` → `proposal`
   - `in_progress` → `design/spec/plan` (recommend based on missing artifacts)
   - `review` → `review`
   - `completed` → `archive`
3) Keep the routing output to 3–6 items, each including Skill + path + rationale.

## Default routing rules

### A) Proposal phase

Signals: “proposal/why/risks/scope/refactor proposal/don’t write code yet”.

Default:
- `devbooks-proposal-author` → `(<change-root>/<change-id>/proposal.md)`
- `devbooks-design-doc` → `(<change-root>/<change-id>/design.md)`
- `devbooks-implementation-plan` → `(<change-root>/<change-id>/tasks.md)`

Add when needed:
- cross-module / unclear impact → `devbooks-impact-analysis`
- high risk / trade-offs → `devbooks-proposal-challenger` + `devbooks-proposal-judge`
- external behavior / contract change → `devbooks-spec-contract` → `(<change-root>/<change-id>/specs/**)`

### B) Apply phase (Test Owner / Coder)

Signals: “start implementing/run tests/fix failures/make gates green”.

Default (role isolation):
- Test Owner (separate conversation): `devbooks-test-owner` → `(<change-root>/<change-id>/verification.md)` + `tests/**`
- Coder (separate conversation): `devbooks-coder` (must not modify `tests/**`)

### C) Review phase

Signals: “review/maintainability/smells/consistency”.

Default:
- `devbooks-reviewer`
- `devbooks-test-reviewer`

### D) Docs sync

Signals: “update docs/sync docs/README update”.

Default:
- `devbooks-docs-consistency`

### E) Archive phase

Signals: “archive/close the loop/merge specs”.

Default:
- `devbooks-archiver`

Pre-archive check (recommended):
- `change-check.sh <change-id> --mode strict ...`

### F) Prototype track

Signals: “prototype/spike/throwaway prototype/--prototype”.

Default:
1. `change-scaffold.sh <change-id> --prototype ...`
2. Test Owner: `devbooks-test-owner --prototype`
3. Coder: `devbooks-coder --prototype` (write under `(<change-root>/<change-id>/prototype/src/)`)
4. Promote explicitly: `prototype-promote.sh <change-id>`

## Optional: Impact profile parsing

If `proposal.md` includes an `impact_profile:` YAML block, Router can use it to refine routing.

Example:
```yaml
impact_profile:
  external_api: true/false
  architecture_boundary: true/false
  data_model: true/false
  cross_repo: true/false
  risk_level: high/medium/low
  affected_modules:
    - name: <module-path>
      type: add/modify/delete
      files: <count>
```

## Context detection (resume)

Infer phase from existing artifacts:
- `proposal.md`, `design.md`, `tasks.md`, `verification.md`
- `evidence/green-final/`
