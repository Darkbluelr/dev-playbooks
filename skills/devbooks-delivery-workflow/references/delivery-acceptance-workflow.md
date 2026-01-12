# Delivery Acceptance Workflow (Design → Plan → Trace → Verify)

> This file is the workflow skeleton for a “development operations manual”, designed for solo work and agentic (AI-assisted) development.

Directory conventions (protocol-agnostic):
- Truth root: `<truth-root>/`
- Change package: `<change-root>/<change-id>/` (proposal/design/tasks/spec deltas/verification/evidence)
- Archive: merge deltas into `<truth-root>/` and move the change package into an archive area (prefer an `archive` command if your protocol provides one)

Goal: define objective, executable, traceable criteria for “delivery done”, avoiding the illusion of “tests are green but a large part of the plan is still unfinished”.

---

## 0) Role isolation and test integrity (mandatory)

- Test Owner and Coder must run in separate conversations/instances. Parallel work is allowed, but do not share context.
- Test Owner produces `tests/` and `verification.md` based on design/spec only, and first establishes a **Red** baseline. Store failure evidence under `<change-root>/<id>/evidence/` (recommended: `change-evidence.sh <id> -- <test-command>`).
- Coder implements strictly per `tasks.md` and runs gates. **Coder must not modify `tests/`.** If tests need adjustment, hand back to Test Owner.

## 0.1) Structural quality gates (mandatory)

- If “proxy-metric-driven” requirements appear (line counts/file counts/mechanical splitting/naming formats), evaluate impact on cohesion/coupling/testability.
- If risk triggers, stop the line: record the decision as a design/proposal issue; do not execute blindly.
- Gate priority: complexity, coupling, dependency direction, change frequency, test quality > proxy metrics.

---

## 1) What belongs in `tests/`?

`tests/` is the set of **executable acceptance anchors**: anything a machine can deterministically judge as Pass/Fail should be automated.

### 1.1 Recommended in `tests/` (hard constraints; regression-friendly)

1. **Automated tests (behavior/contract)**
   - unit: pure logic, no IO
   - integration: multiple components; prefer fakes/mocks for external deps
   - e2e: minimal critical path (offline if possible)
   - contract: schema/event envelope/API input/output shapes/backward compatibility
2. **Architecture fitness functions (structure)**
   - dependency direction, layering boundaries, no cycles, module responsibility boundaries

### 1.2 Not recommended inside `tests/` directly (but should be automated)

3. **Static checks (lint/SAST/typecheck/build)**
   - Prefer running as separate CI steps or via `scripts/`.
   - Wrapping static tools as tests is possible but often reduces clarity and slows runs.

### 1.3 Must not be in `tests/`

4. **Manual acceptance steps**
   - UX walkthroughs, visual copy consistency, product experience, etc.
   - Put these as `MANUAL-*` items in the change package’s `verification.md` with evidence requirements and sign-off.
   - Only sync to external `docs/` when it’s truly user-facing/ops-facing documentation.

Conclusion: **automated tests + fitness functions** belong in `tests/`; **static checks** should be automated but typically separate; **manual acceptance** does not belong in `tests/`.

---

## 2) MECE classification of acceptance methods

Classify by “who is the oracle (judge)”:

### A) Machine judge (automated / deterministic)

- Dynamic tests: unit/contract/integration/e2e/snapshot/golden-master/property-based
- Fitness functions: dependency direction, boundaries, layering, no cycles, restricted packages
- Static checks: lint/typecheck/SAST/license/secret scans/schema validation/breaking-change detection
- Build/release validation: build/package/image build/migration validation/config/template rendering validation
- Automated runtime checks: smoke tests/health checks/minimal replay/offline regression packs (if environment is controlled)

### B) Human judge + tool evidence (hybrid)

- Performance/cost baselines: benchmark output, cost reports, capacity evaluations
- Observability validation: dashboards and logs as evidence, human sign-off for “good enough”
- Compliance review evidence: privacy/security checklists with tool outputs + reviewer sign-off

### C) Pure manual acceptance

- UX/product walkthroughs, UI copy/visual inspection, manual ops steps where automation is unstable

---

## 3) Definition of Done (DoD) and traceability

The strongest DoD combines:
- Task completion (from `tasks.md`)
- Anchor completion (tests/commands/evidence)
- Traceability completeness (AC-xxx → anchors)

Guardrails:
- No “DONE without evidence”: status changes require passing anchors or explicit manual sign-off evidence.
- No “green tests but unfinished plan”: the plan is a source of truth; strict mode should require 100% completion unless a task is explicitly deferred with approval.

---

## 4) Final checks before archive

Recommended:

```bash
change-check.sh <change-id> --mode strict --project-root "$(pwd)" --change-root <change-root> --truth-root <truth-root>
```

Checklist:
- [ ] All A-class anchors (tests/static checks/build) pass
- [ ] All B/C-class anchors are signed off with evidence
- [ ] Traceability matrix has no `TODO` rows
- [ ] `evidence/` includes Red baseline evidence and Green final evidence

---

## 5) Standard workflow (canonical)

### Step 0: Define delivery scope (mandatory)

- Choose phase/milestone (MVP/Beta/Prod)
- Clarify non-goals
- Output: scope statement + version identifier in design doc

### Step 1: Create Design Doc

- Define goals/non-goals, key decisions, acceptance criteria (AC-xxx)
- Write external semantics and invariants in testable language

### Step 2: Create Implementation Plan (tasks)

- Decompose into executable plan items (e.g., `MPx.y`)
- Each plan item declares:
  - deliverables
  - impact scope (modules/files)
  - validation method (A/B/C) and candidate anchors (Test IDs/commands/checklists)

### Step 3: Build traceability matrix

- Map **ACs** to plan items and anchors
- Close gaps immediately:
  1. AC exists but no anchor → add tests/static checks/checklists
  2. task exists but no design source → defer or add design/ADR first

### Step 4: Produce verification anchors

- A-class anchors (machine judge): tests/fitness functions/static checks/build validation, derived only from design/spec
- For refactors/migrations, prefer snapshot/golden-master safety nets
- B/C anchors: checklists with evidence requirements (screenshots/recordings/dashboards/logs/sign-off)
- Maintain same-source isolation: anchors come from design/spec, not tasks
- Backfill traceability matrix with anchor IDs and paths

### Step 5: Implement

- Coder implements per `tasks.md` only
- Coder must not modify `tests/`; Test Owner owns tests
- Use traceability matrix as a work board: prefer tasks with bound anchors; do not “declare done” without anchors

### Step 6: Verify

- Run all A-class anchors in scope (tests + static checks + build)
- Prefer machine-readable outputs (json/xml) for traceability and tooling
- Execute B/C anchors with evidence
- Optional review: use `devbooks-code-review` for maintainability feedback

### Step 7: Close-out

- Update traceability statuses (DONE/BLOCKED/DEFERRED)
- Update plan progress based on anchors only
- Update value-stream evidence links in `verification.md`
- Spec gardening (optional): use `devbooks-spec-gardener` to dedupe/merge/cleanup truth root

---

## 6) Directory map (quick reference)

- Design: `<change-root>/<change-id>/design.md`
- Plan: `<change-root>/<change-id>/tasks.md`
- Spec deltas: `<change-root>/<change-id>/specs/<capability>/spec.md`
- Verification/traceability: `<change-root>/<change-id>/verification.md`
- Executable acceptance: `tests/` (unit/contract/integration/e2e + fitness functions)
- Archive: merge deltas into `<truth-root>/` and archive the change package
