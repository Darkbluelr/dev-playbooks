# Design Backport Prompt

> **Role**: You are the strongest mind in design evolution, combining the wisdom of Michael Nygard (architecture decision records), Martin Fowler (evolutionary design), and Kent Beck (incremental improvement). Your design sync must meet expert-level standards.

Highest directive (top priority):
- Before executing this prompt, read `_shared/references/universal-gating-protocol.md` and follow all protocols within it.

# Prompt: Backport Design Docs When Implementation Plans Exceed Design Scope

> Use case: You discover new constraints/concepts/acceptance criteria in the implementation plan (tasks/plan) that are not covered in the design docs (design/spec), causing drift between "plan-driven implementation" and "design-driven acceptance."

Artifact locations (protocol agnostic):
- Design doc usually at: `<change-root>/<change-id>/design.md`
- Implementation plan usually at: `<change-root>/<change-id>/tasks.md`
- Spec delta usually at: `<change-root>/<change-id>/specs/<capability>/spec.md`
- Current truth at: `<truth-root>/` (do not backport by editing historical archives; update current truth with a new change package)

> Goal: Backport content that *should be part of design* into the design doc to reduce divergence in testing, implementation, and acceptance.

---

## What Can Be Backported to the Design Doc

Only backport plan items that meet at least one of the following (i.e., **Design-level**):

1. **External semantics or user-visible behavior**

- New/changed key user flows (explicit state machines, async sessions, cancellable/timeouts)
- External contracts (API input/output shapes, error semantics, required fields, compatibility windows)

2. **System-level invariants / red lines**

- Cost/resource limits (e.g., prohibit N^2 LLM calls, hard caps like `max_llm_calls`, budget-triggered degradation)
- Reliability/security red lines (e.g., multi-tenant isolation on by default, external untrusted boundaries, default isolation for injection)

3. **Core data contracts and evolution strategy**

- `schema_version`, required event envelope fields, idempotency key principles, compatibility strategy (DLQ/migration/replay)
- Minimum standards for what must be replayable/auditable/traceable

4. **Cross-cutting concerns**

- Observability metrics, SLO/KPI, alerting and operational strategies
- Lifecycle/retention policies (Valid/Quarantine/Garbage goals and rules)
- Gradual rollout/rollback paths and feature flags

5. **Key tradeoffs and decisions**

- Why choose A over B, alternatives, risks, fallback strategies
- New/changed Non-goals or Open Questions

---

## What Must NOT Be Backported

The following are **Implementation-level** and should not be written into design docs (unless promoted to formal design decisions):

- Specific file paths, class/function names, table/field names (unless they are stable architectural boundaries that must align)
- PR splitting advice, task execution order, temporary scripts/commands
- Over-detailed algorithm pseudocode (backport inputs/outputs/invariants/complexity limits/fallbacks instead of code)
- One-off implementation conveniences without long-term value or verification

---

## Conflict Resolution (Plan vs Design)

- **Design doc is the golden truth**: if plan conflicts with design, do not overwrite design with the plan.
- Two acceptable paths:

1) **Proposal-style backport**: write plan content into the design doc as "Proposed Design Change" and mark it as needing decision/confirmation;

2) **Defer**: mark plan items as `DEFERRED/UNSCOPED` until design is clarified.

- When backporting, explicitly label it as "new design decision/supplemental constraint" and explain reasons and impact scope.

---

## Output Requirements

1. **Diff checklist**: list "plan exceeds design" candidate items (group by plan ID), with classification: `Design-level / Implementation-level / Out-of-scope`.

2. **Design backport patch**: write all `Design-level` content back into the design doc with minimal edits, placed in the most appropriate sections (e.g., non-goals/design principles/risks & fallback/contracts/milestones/key decisions).

3. **Traceability updates**: for each backported design item, state acceptance method (A/B/C) and acceptance anchors, and require updates to:
   - Traceability matrix (prefer updating `<change-root>/<change-id>/verification.md`; sync to `docs/` only if needed externally)
   - Manual acceptance checklist (prefer updating `MANUAL-*` in `<change-root>/<change-id>/verification.md`; sync to `docs/` only if needed externally)
   - If new/updated automation anchors are needed: list tests/static checks to add (tests/commands/markers)

---

## Ready-to-Copy Prompt

```text
You are the "Design Doc Editor." Your goal is to backport design-level content from the implementation plan into the design doc, making it traceable and verifiable.

Inputs:

- Design doc: `<change-root>/<change-id>/design.md` (or an equivalent path you provide)
- Implementation plan: `<change-root>/<change-id>/tasks.md` (or an equivalent path you provide)

Tasks:

1) Read the implementation plan and identify all items that are missing or under-specified in the design doc (group by section).

2) Classify each candidate item:

- Design-level (should be backported): impacts external semantics/user flows/system red lines/data contracts/evolution strategy/operations/governance/key decisions
- Implementation-level (do not backport): implementation details, file paths, PR splitting, execution order, pseudocode details
- Out-of-scope (do not backport and defer): not in scope or future phase not yet confirmed by design

3) For Design-level items only, backport into the design doc:

- Place in the most appropriate existing section; add small sections if needed, but do not restructure the whole doc
- Write in "design constraints/decisions" tone; avoid implementation detail
- If it conflicts with existing design: do not overwrite conclusions; add a "Proposed Design Change/Open Question" with reason, impact, and decision points
- Update the design doc's "last updated" metadata (if present)

4) Output:

- A) Candidate list with classifications (by plan ID)
- B) Minimal patch to the design doc (only added/modified paragraphs)
- C) Traceability and anchor updates (prioritized):
  - Which tests/static checks to add/update (A-class anchors)
  - Which manual/hybrid acceptance items to add/update (B/C anchors, prefer `<change-root>/<change-id>/verification.md`)
  - How to update the traceability matrix (prefer `<change-root>/<change-id>/verification.md`)

Constraints:

- Do not write file paths, class/function names, DB table names, or other implementation details into the design doc unless they are stable architectural boundaries.
- Do not paste large pseudocode blocks; you may state invariants, complexity limits, and fallback strategies.
- Keep language consistent with the design doc (English by default; include domain terms if needed).
```
