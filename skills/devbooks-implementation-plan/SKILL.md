---
name: devbooks-implementation-plan
description: devbooks-implementation-plan: Derive coding plan (tasks.md) from design documents, output trackable mainline plan/temporary plan/breakpoint zones, and bind acceptance anchors. Use when the user says "write coding plan/Implementation Plan/tasks.md/task breakdown/parallel splitting/milestones/acceptance anchors" etc.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Implementation Plan

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
4. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Artifact Location

- Coding plan: `<change-root>/<change-id>/tasks.md`

## Execution Method

1) First read and follow: `_shared/references/通用守门协议.md` (Verifiability + Structural Quality Gating).
2) Strictly output according to the complete prompt: `references/编码计划提示词.md` (Derive only from design, do not reference tests/).

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

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

