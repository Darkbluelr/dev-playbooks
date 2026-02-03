---
name: devbooks-spec-contract
description: devbooks-spec-contract: Define external behavior specifications and contracts (Requirements/Scenarios/API/Schema/compatibility strategies/migrations), and suggest or generate contract tests. Combines the functionality of the original spec-delta and contract-data. Use when the user says "write spec/specification/contract/OpenAPI/Schema/compatibility strategy/contract tests" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Spec & Contract

## Progressive Disclosure

### Base (Required)
Goal: Produce a spec delta and external contract notes for a change, without implementation steps.
Inputs: `proposal.md`, `design.md`, existing truth specs, and change scope.
Outputs: spec deltas under `<change-root>/<change-id>/specs/<capability>/spec.md` and contract notes (as required).
Boundaries: spec stage only; do not write implementation steps; do not modify code or `tests/**`.
Evidence: reference spec paths, contract IDs, and evidence outputs.

### Advanced (Optional)
Use when you need: compatibility strategy, migration notes, implicit change detection.

### Extended (Optional)
Use when you need: faster search/impact via code intelligence or reference tools.

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) -> Template protocol, use default mappings
5. If still unable to determine -> **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **you must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

---

## Artifact Destinations

| Artifact Type | Destination Path |
|---------------|------------------|
| Spec delta | `<change-root>/<change-id>/specs/<capability>/spec.md` |
| Contract plan | `<change-root>/<change-id>/design.md` (Contract section) or standalone `contract-plan.md` |
| Contract Test IDs | Written to traceability matrix in `verification.md` |
| Implicit change report | `<change-root>/<change-id>/evidence/implicit-changes.json` |

---

## Use Case Determination

| Scenario | What to Do |
|----------|------------|
| Behavior changes only (no API/Schema) | Output only spec.md (Requirements/Scenarios) |
| API/Schema/event changes | Output spec.md + contract plan + Contract Test IDs |
| Compatibility risks | Additionally output compatibility strategy, deprecation policy, migration plan |
| Dependency/configuration/build changes | Run implicit change detection |

---

## Execution Method

### Standard Process

1) First read and follow: `~/.claude/skills/_shared/references/ai-behavior-guidelines.md`
2) Specification part: Output Requirements/Scenarios per `references/spec-change-prompt.md`
3) Contract part: Output contract plan per `references/contract-and-data-definition-prompt.md`
4) **Implicit change detection (as needed)**: `references/implicit-change-detection-prompt.md`

### Output Structure (Single Output)

```markdown
## Spec Delta

### Requirements
- REQ-XXX-001: <requirement description>

### Scenarios
- SC-001: <scenario description>
  - Given: ...
  - When: ...
  - Then: ...

---

## Contract Plan

### API Changes
- New/modified endpoint: `POST /api/v1/orders`
- OpenAPI diff location: `contracts/openapi/orders.yaml`

### Compatibility Strategy
- Backward compatible: Yes/No
- Deprecation policy: <if applicable>
- Migration plan: <if applicable>

### Contract Test IDs
| Test ID | Type | Covered Scenario |
|---------|------|------------------|
| CT-001 | schema | REQ-XXX-001 |
| CT-002 | behavior | SC-001 |
```

---

## Scripts

- Implicit change detection: `scripts/implicit-change-detect.sh <change-id> [--base <commit>] [--project-root <dir>] [--change-root <dir>]`

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate operating mode.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

### Detection Process

1. Detect whether `<change-root>/<change-id>/specs/` exists
2. If exists, assess completeness (whether there are placeholders, whether REQs have Scenarios)
3. Select operating mode based on detection results

### Supported Modes for This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Create from scratch** | `specs/` directory doesn't exist or is empty | Create complete spec document structure, including Requirements/Scenarios |
| **Gap-filling mode** | `specs/` exists but incomplete (has `[TODO]`, REQ missing Scenario) | Fill in missing Requirements/Scenarios, preserve existing content |
| **Sync mode** | `specs/` complete, needs synchronization with implementation | Check consistency between implementation and specs, output diff report |

### Detection Output Example

```
Detection Results:
- Artifact existence: specs/ exists
- Completeness: Incomplete (missing: REQ-002 has no Scenario)
- Current phase: apply
- Operating mode: Gap-filling mode
```

---

## Implicit Change Detection (Extended Feature)

> Source: "The Mythical Man-Month" Chapter 7 "The Tower of Babel" - "Teams slowly modify the functions of their own programs, implicitly changing the conventions"

Implicit changes = changes that are not explicitly declared but alter system behavior.

**Detection Scope**:
- Dependency changes (package.json / requirements.txt / go.mod etc.)
- Configuration changes (*.env / *.config.* / *.yaml etc.)
- Build changes (tsconfig.json / Dockerfile / CI configs etc.)

**Integration with change-check.sh**:
- Automatically checks implicit change reports in `apply` / `archive` / `strict` modes
- High-risk implicit changes must be declared in `design.md`

---

## Next Step Recommendations

**Reference**: `skills/_shared/workflow-next-steps-workflow-next-steps.md`

After completing spec-contract, the **required** next step is:

| Condition | Next Skill | Reason |
|-----------|------------|--------|
| Always | `devbooks-implementation-plan` | Must create tasks.md before apply stage |

**CRITICAL**: Do NOT recommend `devbooks-test-owner` or `devbooks-coder` directly after spec-contract. The workflow order is:
```
spec-contract → implementation-plan → test-owner → coder
```

### Output Template

After completing spec-contract, output:

```markdown
## Recommended Next Step

**Next: `devbooks-implementation-plan`**

Next: Create an implementation plan (`tasks.md`) with trackable tasks and acceptance anchors.

### How to invoke
```
Run devbooks-implementation-plan skill for change <change-id>
```

---
