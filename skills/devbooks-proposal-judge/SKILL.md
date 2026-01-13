---
name: devbooks-proposal-judge
description: "devbooks-proposal-judge: Make rulings (Judge) on proposals during the proposal phase, output Approved/Revise/Rejected and write back to the Decision Log in proposal.md. Use when user says 'judge proposal/proposal review/Approved Revise Rejected/decision log' etc."
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Proposal Judge

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **you must read that document first** before performing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (Verifiability + Structural Quality Gating).
2) Strictly output rulings according to the complete prompt: `references/proposal-judge-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution to ensure role isolation.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Process

1. Detect whether `proposal.md` exists
2. Detect whether there are challenge opinions from the Challenger
3. Detect whether the Author/Challenger role has already been executed in the current session

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **First Ruling** | No ruling record | Comprehensively evaluate the proposal and challenges, output ruling |
| **Reconsideration Ruling** | Author resubmits after modifications | Re-evaluate the modified content |

### Role Isolation Check

- [ ] Current session has not executed Author
- [ ] Current session has not executed Challenger

### Detection Output Example

```
Detection Result:
- proposal.md: Exists
- Challenger opinions: Exist (3 risk points)
- Role isolation: ✓
- Running mode: First Ruling
```

---

## MCP Enhancement

This Skill does not depend on MCP services and requires no runtime detection.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

