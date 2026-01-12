---
name: devbooks-design-backport
description: devbooks-design-backport: Backport newly discovered constraints, conflicts, or gaps from implementation back to design.md (keeping design as the golden truth), with annotated decisions and impacts. Use when the user says "backport design/update design doc/Design Backport/design-implementation mismatch/need to clarify constraints" etc.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Design Backport

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
4. `project.md` (if exists) → Template protocol, use default mappings
5. If still undetermined → **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **you must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gating).
2) Strictly execute according to the complete prompt: `references/design-backport-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution, identifying content that needs to be backported.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect whether `design.md` exists
2. Detect whether new discoveries (conflicts/constraints/gaps) were found during implementation
3. Compare differences between design and implementation

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Conflict Backport** | Design-implementation conflict detected | Record conflict points and resolutions |
| **Constraint Backport** | New implementation constraints discovered | Add constraint conditions to design |
| **Gap Backport** | Scenarios not covered by design detected | Add missing design decisions |

### Detection Output Example

```
Detection Results:
- design.md: Exists
- Discoveries: 2 new constraints, 1 design conflict
- Running Mode: Constraint Backport + Conflict Backport
```

---

## MCP Enhancement

This Skill does not depend on MCP services; no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

