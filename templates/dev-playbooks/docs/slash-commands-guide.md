# DevBooks Slash Commands Guide

This guide explains the usage timing of each Slash command, organized by the stages of the change lifecycle.

> **MCP Auto-Detection**: Each Skill automatically detects MCP availability at execution time (2s timeout), no manual selection of "Basic" or "Enhanced" mode required.

---

## Stage Overview

| Stage | Core Commands | Description |
|-------|---------------|-------------|
| **Proposal** | proposal → impact → challenger/judge → design → spec → c4 → plan | No code writing allowed |
| **Apply** | test → code → backport (if needed) | Mandatory role isolation |
| **Review** | review → test-review | Review code and tests |
| **Archive** | backport → spec → c4 → gardener | Merge to source of truth |
| **Independent** | router / bootstrap / entropy / federation / index | Not part of a single change |

---

## Proposal Stage

> **Core Principle**: No implementation code allowed, only design documents

### 1. `/devbooks:proposal` - Create Change Proposal (Required)

**When to Use**: Starting point for every change

```
/devbooks:proposal <your requirement>
```

**Output**: `<change-root>/<change-id>/proposal.md`

**Contents**:
- Why (reason for the change)
- What (what to change)
- Impact (scope of impact)
- Debate Packet (risks/alternatives/constraints)

---

### 2. `/devbooks:impact` - Impact Analysis (Required for cross-module/unclear impact)

**When to Use**:
- Change involves multiple modules
- Uncertain about affected scope
- Potential compatibility breakage

```
/devbooks:impact <change-id>
```

**Output**: Updates the Impact section of `proposal.md`

**MCP Enhancement**:
- CKB available: Uses `analyzeImpact`, `getCallGraph`, `findReferences`
- CKB unavailable: Falls back to Grep + Glob text search

---

### 3. `/devbooks:challenger` - Proposal Challenge (For high risk/controversial changes)

**When to Use**:
- High risk, controversial changes
- Need strong constraint review
- Recommended to execute in a new conversation (role isolation)

```
/devbooks:challenger <change-id>
```

**Output**: Challenge report (conclusion must be `Approve | Revise | Reject`)

---

### 4. `/devbooks:judge` - Proposal Judgment (Required if Challenger was used)

**When to Use**:
- Challenger report exists, final judgment needed
- Recommended to execute in a new conversation (role isolation)

```
/devbooks:judge <change-id>
```

**Output**: Updates `proposal.md` Decision Log (`Approved | Revise | Rejected`, Pending not allowed)

---

### 5. `/devbooks:debate` - Triangle Debate Process (For high risk/controversial changes)

**When to Use**:
- Replaces separate challenger + judge calls
- Automatically orchestrates Author → Challenger → Judge process

```
/devbooks:debate <change-id>
```

**Output**:
- Challenge report
- Judgment result
- Updated `proposal.md`

---

### 6. `/devbooks:design` - Design Document (Recommended for non-trivial changes)

**When to Use**:
- Not a bug fix or single-line change
- Need clear constraints and acceptance criteria

```
/devbooks:design <change-id>
```

**Output**: `<change-root>/<change-id>/design.md`

**Contents**:
- What (specific design)
- Constraints (constraints and boundaries)
- AC-xxx (acceptance criteria)
- **Prohibited**: Implementation steps

---

### 7. `/devbooks:spec` - Specification and Contract (For external behavior/contract changes)

**When to Use**:
- External API changes
- Data contract/Schema changes
- Need compatibility strategy

```
/devbooks:spec <change-id>
```

**Output**:
- `<change-root>/<change-id>/specs/<capability>/spec.md` (Requirements/Scenarios)
- Updates Contract section of `design.md`

---

### 8. `/devbooks:c4` - C4 Architecture Map (For boundary/dependency changes)

**When to Use**:
- Module boundary changes
- Dependency direction changes
- Adding/removing components

```
/devbooks:c4 <change-id>
```

**Proposal Stage Behavior**:
- **Does not modify** current truth `<truth-root>/architecture/c4.md`
- Outputs C4 Delta to `design.md`

---

### 9. `/devbooks:plan` - Implementation Plan (Required)

**When to Use**:
- After design.md is complete
- Final step of the Proposal stage

```
/devbooks:plan <change-id>
```

**Output**: `<change-root>/<change-id>/tasks.md`

**Contents**:
- Main Path
- Temp Path (if any)
- Breakpoint Zone
- Verification anchors for each task

---

## Apply Stage

> **Core Principle**: Test Owner and Coder must be in separate conversations/instances

### 1. `/devbooks:test` - Test Owner (Required, must be new conversation)

**When to Use**:
- First step of Apply stage
- Must execute before Coder

```
/devbooks:test <change-id>
```

**Role Constraints**:
- Read-only: `proposal.md`, `design.md`, `specs/**`
- Prohibited: Referencing `tasks.md`

**Output**:
- `<change-root>/<change-id>/verification.md` (traceability matrix)
- `tests/**`
- Failure evidence under `evidence/`

**Requirement**: Must first establish **Red** baseline

---

### 2. `/devbooks:code` - Coder (Required, must be new conversation)

**When to Use**:
- After Test Owner completes
- Must execute in a separate conversation

```
/devbooks:code <change-id>
```

**Role Constraints**:
- Strictly follow `tasks.md` for implementation
- **Prohibited**: Modifying `tests/**`
- If tests need changes, hand back to Test Owner

**Completion Criteria**: tests/static checks/build all green

**MCP Enhancement**:
- CKB available: Outputs hotspot check report
- Top 5 hotspots: Refactor before modifying

---

### 3. `/devbooks:backport` - Design Backport (When design gaps/conflicts discovered)

**When to Use**:
- Design omissions discovered during implementation
- Decisions that need to be elevated to design level

```
/devbooks:backport <change-id>
```

**Output**: Updates `design.md`

**Follow-up Actions**:
- Re-run Planner (update tasks.md)
- Test Owner re-confirms/adds tests

---

## Review Stage

### 1. `/devbooks:review` - Code Review (Required)

**When to Use**:
- After Apply stage completes
- Before PR merge

```
/devbooks:review <change-id>
```

**Review Contents**:
- Readability
- Dependency direction
- Consistency
- Complexity
- Code smells

**Does Not Discuss**: Business correctness

**MCP Enhancement**:
- CKB available: Hotspot-first review (Top 5 deep review)

---

### 2. `/devbooks:test-review` - Test Review (Optional)

**When to Use**:
- Test quality needs special attention
- Coverage/boundary conditions need review

```
/devbooks:test-review <change-id>
```

**Review Contents**:
- Test coverage
- Boundary conditions
- Consistency with `verification.md`

---

## Archive Stage

### 1. `/devbooks:backport` - Complete Missing Decisions

**When to Use**: Undocumented design decisions found before archiving

---

### 2. `/devbooks:spec` - Update Source of Truth

**When to Use**: Need to update specifications/contracts to `<truth-root>` before archiving

---

### 3. `/devbooks:c4` - Update Source of Truth

**When to Use**: Update/verify `<truth-root>/architecture/c4.md` before archiving

**Archive Stage Behavior**: Updates current truth (not just Delta)

---

### 4. `/devbooks:gardener` - Spec Gardener (When spec deltas exist)

**When to Use**:
- This change produced spec deltas
- Need to merge to source of truth

```
/devbooks:gardener <change-id>
```

**Operations**:
- Deduplicate/merge/categorize/delete outdated
- Only modifies `<truth-root>/**`
- Does not modify change package contents

---

## Independent Commands (Not Part of Single Change Stages)

### `/devbooks:router` - Route Suggestion (When unsure of next step)

**When to Use**:
- Unsure which stage you're in
- Need AI to suggest shortest closed-loop path

```
/devbooks:router <your requirement>
```

---

### `/devbooks:bootstrap` - Brownfield Project Initialization

**When to Use**:
- `<truth-root>` is empty
- Legacy project first time adopting DevBooks

```
/devbooks:bootstrap
```

**Output**:
- Project profile
- Glossary (optional)
- Baseline specifications
- Minimal verification anchors

---

### `/devbooks:entropy` - Entropy Measurement (Regular health check)

**When to Use**:
- Regular code health check
- Get quantitative data before refactoring

```
/devbooks:entropy
```

**Output**: Entropy measurement report (structural entropy/change entropy/test entropy/dependency entropy)

---

### `/devbooks:federation` - Cross-Repository Federation Analysis

**When to Use**:
- Change involves external API/contracts
- Multi-repository project needs downstream impact analysis

```
/devbooks:federation
```

**Prerequisite**: `.devbooks/federation.yaml` exists in project root

---

### `/devbooks:index` - Index Bootstrap

**When to Use**:
- `mcp__ckb__getStatus` shows SCIP backend unavailable
- Need to activate graph-based code understanding capabilities

```
/devbooks:index
```

**Output**: SCIP index file

---

## Typical Flow Examples

### Small Change (bug fix)

```
1. /devbooks:proposal <bug description>
2. /devbooks:plan <change-id>
3. /devbooks:test <change-id>    # new conversation
4. /devbooks:code <change-id>    # new conversation
5. /devbooks:review <change-id>
6. /devbooks:gardener <change-id>
```

### Medium Change (new feature)

```
1. /devbooks:proposal <feature requirement>
2. /devbooks:impact <change-id>   # when cross-module
3. /devbooks:design <change-id>
4. /devbooks:spec <change-id>     # when contract changes
5. /devbooks:plan <change-id>
6. /devbooks:test <change-id>     # new conversation
7. /devbooks:code <change-id>     # new conversation
8. /devbooks:review <change-id>
9. /devbooks:gardener <change-id>
```

### Large/High-Risk Change

```
1. /devbooks:proposal <requirement>
2. /devbooks:impact <change-id>
3. /devbooks:debate <change-id>   # triangle debate
4. /devbooks:design <change-id>
5. /devbooks:spec <change-id>
6. /devbooks:c4 <change-id>       # when architecture changes
7. /devbooks:plan <change-id>
8. /devbooks:test <change-id>     # new conversation
9. /devbooks:code <change-id>     # new conversation
10. /devbooks:review <change-id>
11. /devbooks:gardener <change-id>
```

---

## Command Summary (24 Commands)

### Core Commands (21)

| Stage | Command | Corresponding Skill |
|-------|---------|---------------------|
| Proposal | `/devbooks:proposal` | `devbooks-proposal-author` |
| | `/devbooks:impact` | `devbooks-impact-analysis` |
| | `/devbooks:challenger` | `devbooks-proposal-challenger` |
| | `/devbooks:judge` | `devbooks-proposal-judge` |
| | `/devbooks:debate` | `devbooks-proposal-debate-workflow` |
| | `/devbooks:design` | `devbooks-design-doc` |
| | `/devbooks:spec` | `devbooks-spec-contract` |
| | `/devbooks:c4` | `devbooks-c4-map` |
| | `/devbooks:plan` | `devbooks-implementation-plan` |
| Apply | `/devbooks:test` | `devbooks-test-owner` |
| | `/devbooks:code` | `devbooks-coder` |
| | `/devbooks:backport` | `devbooks-design-backport` |
| Review | `/devbooks:review` | `devbooks-code-review` |
| | `/devbooks:test-review` | `devbooks-test-reviewer` |
| Archive | `/devbooks:gardener` | `devbooks-spec-gardener` |
| | `/devbooks:delivery` | `devbooks-delivery-workflow` |
| Independent | `/devbooks:router` | `devbooks-router` |
| | `/devbooks:bootstrap` | `devbooks-brownfield-bootstrap` |
| | `/devbooks:entropy` | `devbooks-entropy-monitor` |
| | `/devbooks:federation` | `devbooks-federation` |
| | `/devbooks:index` | `devbooks-index-bootstrap` |

### Backward Compatible Commands (3)

| Command | Equivalent To |
|---------|---------------|
| `/devbooks:coder` | `/devbooks:code` |
| `/devbooks:tester` | `/devbooks:test` |
| `/devbooks:reviewer` | `/devbooks:review` |
