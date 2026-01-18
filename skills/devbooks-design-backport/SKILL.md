---
name: devbooks-design-backport
description: devbooks-design-backport: Backport newly discovered constraints, conflicts, or gaps from implementation back to design.md (keeping design as the golden truth), with annotated decisions and impacts. Use when the user says "backport design/update design doc/Design Backport/design-implementation mismatch/need to clarify constraints" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Design Backport

## Workflow Position Awareness

> **Core Principle**: Design Backport is now **primarily auto-invoked by Archiver during archive phase**, users typically don't need to call it manually.

### My Position in the Overall Workflow

```
proposal → design → test-owner → coder → test-owner(verify) → code-review → [Archive/Spec Gardener]
                                    ↓                                              ↓
                             Record deviations to deviation-log.md     Auto-invoke design-backport
```

### Design Decision: Auto Backport

**Old Flow** (manual judgment required):
```
coder has deviations → user manually calls design-backport → then archive
```

**New Flow** (auto handling):
```
coder has deviations → archiver auto-detects and backports during archive → archive
```

### When Manual Call is Still Needed

| Scenario | Need Manual Call? |
|----------|-------------------|
| Normal flow (deviations in deviation-log.md) | ❌ Auto-handled during archive |
| Need immediate backport (don't wait for archive) | ✅ Manual call |
| Severe design-implementation conflict needs decision | ✅ Manual call and discuss |

---

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
4. If still undetermined → **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **you must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Execution Method

1) First read and follow: `~/.claude/skills/_shared/references/universal-gating-protocol.md` (verifiability + structural quality gating).
2) Strictly execute according to the complete prompt: `references/design-backport-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution, identifying content that needs to be backported.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

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

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template-mcp-enhancement.md`

