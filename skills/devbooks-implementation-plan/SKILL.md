---
name: devbooks-implementation-plan
description: devbooks-implementation-plan: Derive coding plan (tasks.md) from design documents, output trackable mainline plan/temporary plan/breakpoint zones, and bind acceptance anchors. Use when the user says "write coding plan/Implementation Plan/tasks.md/task breakdown/parallel splitting/milestones/acceptance anchors" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Implementation Plan

## Workflow Position Awareness

> **Core Principle**: Implementation Plan executes after Design Doc, providing task list for Test Owner and Coder.

### My Position in the Overall Workflow

```
proposal → design → [Implementation Plan] → test-owner(phase1) → coder → ...
                            ↓
                    tasks.md (task list)
```

### Implementation Plan's Responsibilities

| Allowed | Prohibited |
|---------|------------|
| Derive tasks from design.md | ❌ Reference tests/ (avoid implementation bias) |
| Bind acceptance anchors (AC-xxx) | ❌ Write implementation code |
| Split parallel tasks | ❌ Execute tasks |

### Output: tasks.md Structure

```markdown
## Main Plan Area
- [ ] MP1.1 Task description (AC-001)
- [ ] MP1.2 Task description (AC-002)

## Temporary Plan Area
(urgent tasks)

## Breakpoint Area
(context switch resume info)
```

---

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Artifact Location

- Coding plan: `<change-root>/<change-id>/tasks.md`

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (Verifiability + Structural Quality Gating).
2) Strictly output according to the complete prompt: `references/implementation-plan-prompt.md` (Derive only from design, do not reference tests/).

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate running mode.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect whether `design.md` exists (input for the plan)
2. Detect whether `tasks.md` already exists
3. If exists, detect progress (completed/in-progress/pending)

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Create New Plan** | `tasks.md` does not exist | Derive complete plan from design.md |
| **Update Plan** | `tasks.md` exists, design.md has updates | Sync plan with design changes |
| **Add Temporary Task** | Discovered urgent task outside plan | Add to temporary plan zone |

### Planner Constraints

- Read only design.md and specs/
- **Must not reference tests/** (avoid implementation bias)
- Must not write implementation code

### Detection Output Example

```
Detection Result:
- design.md: exists, AC count 14
- tasks.md: does not exist
- Running mode: Create New Plan
```

---

## Next Step Recommendations

**Reference**: `skills/_shared/workflow-next-steps.md`

After completing implementation-plan, the **required** next step is:

| Condition | Next Skill | Reason |
|-----------|------------|--------|
| Always | `devbooks-test-owner` | Test Owner must produce Red baseline first |

**CRITICAL**:
- Test Owner **must work in a separate conversation/instance**
- Do NOT recommend `devbooks-coder` directly after implementation-plan
- The workflow order is:
```
implementation-plan → test-owner (Chat A) → coder (Chat B)
```

### Output Template

After completing implementation-plan, output:

```markdown
## Recommended Next Step

**Next: `devbooks-test-owner`** (MUST be in a separate conversation)

Reason: Implementation plan is complete. The next step is to have Test Owner create verification tests and produce a Red baseline. Test Owner and Coder must work in separate conversations to ensure role isolation.

### How to invoke (in a NEW conversation)
```
Run devbooks-test-owner skill for change <change-id>
```

**Important**: After Test Owner produces Red baseline, start another separate conversation for Coder:
```
Run devbooks-coder skill for change <change-id>
```
```

---

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

