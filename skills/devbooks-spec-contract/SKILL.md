---
name: devbooks-spec-contract
description: devbooks-spec-contract: Define external behavior specifications and contracts (Requirements/Scenarios/API/Schema/compatibility strategies/migrations), and suggest or generate contract tests. Combines the functionality of the original spec-delta and contract-data. Use when the user says "write spec/specification/contract/OpenAPI/Schema/compatibility strategy/contract tests" etc.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Spec & Contract

> This skill combines the functionality of the original `devbooks-spec-delta` and `devbooks-contract-data`, reducing decision fatigue.

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> DevBooks 2.0 protocol, use default mappings
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

1) First read and follow: `_shared/references/universal-gating-protocol.md`
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

Detection rules reference: `skills/_shared/context-detection-template.md`

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

**Reference**: `skills/_shared/workflow-next-steps.md`

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

Reason: Spec and contract are now defined. The next step is to create an implementation plan (tasks.md) that breaks down the work into trackable tasks with verification anchors.

### How to invoke
```
Run devbooks-implementation-plan skill for change <change-id>
```
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Dependent MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__findReferences` | Detect contract reference scope | 2s |
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Process

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available -> Use `findReferences` to detect reference scope of contract symbols
3. If timeout or failure -> Fallback to Grep text search

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Reference detection | Symbol-level precise matching | Grep text search |
| Contract impact scope | Call graph analysis | Direct reference counting |
| Compatibility risk | Automatic assessment | Manual judgment |

### Fallback Notice

When MCP is unavailable, output the following notice:

```
Warning: CKB unavailable, using Grep text search for contract reference detection.
Results may be less precise. Consider manually generating SCIP index for more precise results.
```
