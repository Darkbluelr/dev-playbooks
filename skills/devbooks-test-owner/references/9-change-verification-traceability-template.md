# verification.md Template (inside a change package)

> Recommended path: `<change-root>/<change-id>/verification.md`
>
> Goal: make “Definition of Done” concrete with deterministic anchors and evidence, and provide traceability `AC-xxx -> Requirement/Scenario -> Test IDs -> Evidence`.

---

## Metadata

- Change ID: `<change-id>`
- Status: `Draft | Ready | Done | Archived`
- Links:
  - Proposal: `<change-root>/<change-id>/proposal.md`
  - Design: `<change-root>/<change-id>/design.md`
  - Tasks: `<change-root>/<change-id>/tasks.md`
  - Spec deltas: `<change-root>/<change-id>/specs/**`
- Owner: `<you>`
- Last updated: `YYYY-MM-DD`
- Test Owner (separate conversation): `<session/agent>`
- Coder (separate conversation): `<session/agent>`
- Red baseline evidence: `<change-root>/<change-id>/evidence/`

---

========================
A) Test Plan Instructions
========================

### Main Plan Area

- [ ] TP1.1 `<one-sentence goal>`
  - Why:
  - Acceptance criteria (reference AC-xxx / Requirement):
  - Test type: `unit | contract | integration | e2e | fitness | static`
  - Non-goals:
  - Candidate anchors (Test IDs / commands / evidence):

### Temporary Plan Area

- (empty / as needed)

### Context Switch Breakpoint Area

- Last progress:
- Current blocker:
- Shortest next path:

---

========================
B) Traceability Matrix
========================

> Recommended primary key: AC-xxx. If you maintain Requirements/Scenarios, include the corresponding items too.

| AC | Requirement/Scenario | Test IDs / Commands | Evidence / MANUAL-* | Status |
|---|---|---|---|---|
| AC-001 | `<capability>/Requirement...` | `TEST-...` / `pnpm test ...` | `MANUAL-001` / link | TODO |

---

========================
C) Deterministic Anchors
========================

### 1) Behavior

- unit:
- integration:
- e2e:

### 2) Contract

- OpenAPI/Proto/Schema:
- contract tests:

### 3) Structure (fitness functions)

- layering / dependency direction / no cycles:

### 4) Static & security

- lint/typecheck/build:
- SAST/secret scan:
- report formats: `json|xml` (prefer machine-readable)
- quality gates: complexity/duplication/dependency rules (if any)

---

========================
D) MANUAL-* Checklist (manual or hybrid acceptance)
========================

> Include only acceptance items that cannot be reliably automated. Each item must specify evidence requirements.

- [ ] MANUAL-001 `<acceptance item>`
  - Pass/Fail criteria:
  - Evidence (screenshots/video/links/logs):
  - Owner/sign-off:

---

========================
E) Risks and degradation (optional)
========================

- Risks:
- Degradation strategy:
- Rollback strategy:

========================
F) Structural guardrail record (optional)
========================

> If this change involves “proxy-metric-driven” requirements or structural risks, record decisions and alternative gates.

- Conflict:
- Impact assessment (cohesion/coupling/testability):
- Alternative gates (complexity/coupling/dependency direction/test quality):
- Decision and approval:

========================
G) Value stream and metrics (optional, but must explicitly write “none”)
========================

> Purpose: make “faster/safer/more valuable delivery” observable; avoid judging only by local coding speed.

- Value signal target: `<write “none” or specify metrics/dashboards/logs/business events>`
- Value-stream bottleneck hypothesis: `<write “none” or specify PR review / tests / release / manual acceptance queue points>`
- Delivery and stability metrics (optional DORA): `<write “none” or specify Lead Time / Deploy Frequency / Change Failure Rate / MTTR definitions>`
- Observation window and triggers: `<write “none” or specify when/what alerts/reports to watch after release>`
- Evidence: `<write “none” or provide links/screenshots/report paths (prefer under evidence/) >`
