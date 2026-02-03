# AI-Native Workflow

This guide describes the DevBooks AI-native workflow, role boundaries, and evidence loop.

## Entry

- Single entrypoint: `/devbooks:delivery` (routes by `request_kind`, and materializes `RUNBOOK.md` + `inputs/index.md` when needed)
- Optional: run `skills/devbooks-delivery-workflow/scripts/runbook-derive.sh <change-id> --project-root . --change-root dev-playbooks/changes --truth-root dev-playbooks/specs` to populate derived `Cover View` and derived `Context Capsule` blocks into `RUNBOOK.md` (discardable & rebuildable).
- Delivery freezes `deliverable_quality` into `completion.contract.yaml#intent.deliverable_quality` (an input to archive adjudication)
- If you already know what you need, call the corresponding Skill directly (but entry routing is still `request_kind` via Delivery)
- When `risk_level=high` or `request_kind=epic`: run Knife first to produce a Knife Plan (G3), then execute the slice/change-package loop

## Roles and boundaries

| Role | Responsibility | Key constraint |
| --- | --- | --- |
| Test Owner | Produce acceptance tests and verification traceability | Separate conversation from Coder |
| Coder | Implement according to `tasks.md` | Must not modify `tests/` |
| Reviewer | Maintainability and consistency review | Must not modify `tests/` |

## Action norms (P3-3)

> These norms keep execution convergent, artifacts traceable, and evidence auditable (avoid cross-change confusion, missing on-disk artifacts, and fake completion).

1. **Role isolation**: Test Owner and Coder must work in separate conversations; Coder must not modify `tests/**`.
2. **Write to the change package**: all artifacts must be written to disk under the change package (proposal/design/tasks/verification/specs/evidence); do not "deliver" only in chat.
3. **Avoid cross-change confusion**: when multiple changes exist, always state the current `change-id`; check change package progress before continuing.
4. **Done criteria**: "done" means Green Evidence + gates pass; always execute through Archive (do not stop at Review/Test).
5. **High-risk precondition**: when `risk_level=high` or `request_kind=epic`, Knife Plan is mandatory (G3).

## Workflow stages

DevBooks does not require a fixed stage list. Delivery routes by `request_kind` and runs the minimal sufficient loop:

- `debug`: reproduce → locate → fix/diagnose → verify → archive
- `change`: proposal/design/spec/plan/test/code/review → verify → archive (skip parts only when not required)
- `epic`: Knife slicing → slice queue of change packages → verify → archive
- `void`: research artifacts + Freeze/Thaw → route back to bootstrap/knife/change/debug
- `bootstrap`: baseline/glossary/boundaries/scenarios → route into change/epic/governance
- `governance`: protocol/gates/truth-artifacts governance → stricter evidence → archive

## Evidence and gates

- Evidence folders: `evidence/red-baseline/`, `evidence/green-final/`, `evidence/gates/`, `evidence/risks/`
- Gate model: G0–G6 covering proposal/apply/risk/archive
- Before archive, Green Evidence logs must exist
- Gate report: `evidence/gates/G0-<mode>.report.json` (G0–G6)
- Protocol coverage report: `evidence/gates/protocol-v1.1-coverage.report.json`
- Dependency audit evidence: `evidence/risks/dependency-audit.log`
- Weak links (docs/config/release/ops) must be encoded as obligations tagged `weak_link`, covered by checks, and backed by fresh evidence artifacts (stale/missing artifacts block G6 in `archive|strict`).
- Gate validation case matrix (T9): `docs/gate-validation-cases.md`

## Common commands

- `/devbooks:delivery`: single entrypoint (routes by `request_kind`)
- `/devbooks:knife`: Epic slicing + Knife Plan (high-risk / epic)
- `/devbooks:proposal`: proposal
- `/devbooks:design`: design
- `/devbooks:spec`: spec
- `/devbooks:plan`: plan
- `/devbooks:test`: tests
- `/devbooks:code`: implementation
- `/devbooks:review`: review
- `/devbooks:archive`: archive

## FAQ

- Not sure where to start: use `/devbooks:delivery`
- Scope unclear: complete Proposal + Impact first
- Tests failing: Coder fixes, but must not modify `tests/`
