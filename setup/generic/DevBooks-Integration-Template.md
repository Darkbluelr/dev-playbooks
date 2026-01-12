# DevBooks Integration Template (Protocol Agnostic)

> Goal: Write DevBooks role isolation, DoD, directory anchors, and the `devbooks-*` Skills index into the project's context (no DevBooks dependency required).

---

## DevBooks Context (Protocol-Agnostic Conventions)

Append the following to your "project context index file" (filename depends on your context protocol; common candidates: `CLAUDE.md`, `AGENTS.md`, `PROJECT.md`, etc.):

- Root directories:
  - `<truth-root>`: current truth directory root (default `specs/`)
  - `<change-root>`: change package directory root (default `changes/`)

- Single change package locations (directory conventions):
  - `(<change-root>/<change-id>/proposal.md)`: proposal
  - `(<change-root>/<change-id>/design.md)`: design doc
  - `(<change-root>/<change-id>/tasks.md)`: implementation plan
  - `(<change-root>/<change-id>/verification.md)`: verification and traceability (trace matrix, MANUAL-* checklists, evidence requirements)
  - `(<change-root>/<change-id>/specs/**)`: spec delta for this change
  - `(<change-root>/<change-id>/evidence/**)`: evidence (as needed)

- Recommended "current truth" structure (not mandatory, but consistent):
  - `(<truth-root>/_meta/project-profile.md)`: project profile/constraints/gates/format conventions
  - `(<truth-root>/_meta/glossary.md)`: unified glossary
  - `(<truth-root>/architecture/c4.md)`: C4 architecture map (current truth)
  - `(<truth-root>/engineering/pitfalls.md)`: high-ROI pitfalls (optional)

---

## Role Isolation (Mandatory)

- Test Owner and Coder must operate in separate conversations/instances; parallel work allowed, but no shared context.
- Coder must not modify `tests/**`; test changes must be handed back to Test Owner.

---

## DoD (Definition of Done, MECE)

Each change must declare which gates are covered; missing items require reasons and mitigation plans (recommended in `(<change-root>/<change-id>/verification.md)`):

- Behavior: unit/integration/e2e (minimum set by project type)
- Contract: OpenAPI/Proto/Schema/event envelope + contract tests
- Structure: layering/dependency direction/no cycles (fitness tests)
- Static & Security: lint/typecheck/build + SAST/secret scan
- Evidence (as needed): screenshots/videos/reports (UI, performance, security triage)

---

## DevBooks Skills Index (Protocol Agnostic)

Add the index below to the project context index file as a "when to use which Skill" guide:

### Role-Based

- Router: `devbooks-router` -> route to next step/phase and output artifact locations (supports Prototype mode)
- Proposal Author: `devbooks-proposal-author` -> `(<change-root>/<change-id>/proposal.md)`
- Proposal Challenger: `devbooks-proposal-challenger` -> challenge report (may live outside change package)
- Proposal Judge: `devbooks-proposal-judge` -> verdict written back to `proposal.md`
- Impact Analyst: `devbooks-impact-analysis` -> impact analysis (recommended in proposal Impact section)
- Design Owner: `devbooks-design-doc` -> `(<change-root>/<change-id>/design.md)`
- Spec & Contract Owner: `devbooks-spec-contract` -> `(<change-root>/<change-id>/specs/**)` + contract plan (merged spec-delta + contract-data)
- Planner: `devbooks-implementation-plan` -> `(<change-root>/<change-id>/tasks.md)`
- Test Owner: `devbooks-test-owner` -> `(<change-root>/<change-id>/verification.md)` + `tests/**` (output management: truncate > 50 lines)
- Coder: `devbooks-coder` -> implementation (tests forbidden) (resume + output management)
- Reviewer: `devbooks-code-review` -> review feedback
- Spec Gardener: `devbooks-spec-gardener` -> prune `(<truth-root>/**)` before archive
- C4 Map Maintainer: `devbooks-c4-map` -> `(<truth-root>/architecture/c4.md)`
- Design Backport: `devbooks-design-backport` -> backport design gaps/conflicts

### Workflow-Based

- Proposal Debate: `devbooks-proposal-debate-workflow` -> Author/Challenger/Judge triangle debate
- Delivery Workflow: `devbooks-delivery-workflow` -> change loop + deterministic scripts (scaffold/check/evidence)
- Brownfield Bootstrap: `devbooks-brownfield-bootstrap` -> legacy project initialization (when `<truth-root>` is empty)

### Metrics-Based

- Entropy Monitor: `devbooks-entropy-monitor` -> system entropy metrics (structural/change/test/dependency) + refactor alerts

### Indexing

- Index Bootstrap: `devbooks-index-bootstrap` -> generate SCIP index and enable graph-based analysis
- Federation: `devbooks-federation` -> cross-repo federation analysis and contract sync (multi-repo projects)

---

## CI/CD Integration (Optional)

Copy templates from `templates/ci/` to project `.github/workflows/`:

- `devbooks-guardrail.yml`: auto-check complexity, hotspots, layering violations, cycles on PR
- `devbooks-cod-update.yml`: auto-update COD model after push (module graph, hotspots, concepts)

---

## Cross-Repo Federation (Optional)

For multi-repo projects, configure `.devbooks/federation.yaml` to define upstream/downstream dependencies:

```bash
cp skills/devbooks-federation/templates/federation.yaml .devbooks/federation.yaml
```

See `skills/devbooks-federation/SKILL.md`

---

## Automatic Skill Routing (Seamless Integration)

> These rules let the AI select Skills based on intent without explicit naming.

### Intent Recognition and Auto-Routing

| User Intent Pattern | Auto Skills |
|---------------------|------------|
| "Fix bug", "find issue", "why error" | `devbooks-impact-analysis` -> `devbooks-coder` |
| "Refactor", "optimize code", "remove duplication" | `devbooks-code-review` -> `devbooks-coder` |
| "New feature", "add XX", "implement XX" | `devbooks-router` -> full loop |
| "Write tests", "add tests" | `devbooks-test-owner` |
| "Continue", "next step" | check `tasks.md` -> `devbooks-coder` |
| "Review" | `devbooks-code-review` |

### Graph-Based Analysis Auto-Enablement

**Pre-check**: call `mcp__ckb__getStatus` to check index status
- If available: auto-use `analyzeImpact`/`findReferences`/`getCallGraph`/`getHotspots`
- If unavailable: degrade to `Grep`/`Glob` text search

### Hotspot File Auto-Warnings

Before running `devbooks-coder` or `devbooks-code-review`, **must** call `mcp__ckb__getHotspots`:
- 🔴 Critical (Top 5): warn + recommend more tests
- 🟡 High (Top 10): warn + focus review
- 🟢 Normal: proceed

### Change Package Status Auto-Detection

| Status | Auto Suggestion |
|--------|-----------------|
| Only `proposal.md` exists | -> `devbooks-design-doc` |
| `design.md` exists, no `tasks.md` | -> `devbooks-implementation-plan` |
| `tasks.md` exists, not complete | -> `devbooks-coder` |
| All tasks complete | -> `devbooks-code-review` or archive |
