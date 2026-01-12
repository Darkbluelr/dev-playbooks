---
name: devbooks-proposal-debate-workflow
description: devbooks-proposal-debate-workflow: Executes the "Author-Challenger-Judge" triangular debate workflow during the proposal phase, enforcing role isolation and writing back to the Decision Log. Use when the user mentions "proposal debate/three-role adversarial/Challenger/Judge/proposal debate/decision log" etc.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Proposal Debate Workflow

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
4. `project.md` (if exists) → Template protocol, use default mappings
5. If still undetermined → **Stop and ask the user**

**Key Constraints**:
- If the configuration specifies an `agents_doc` (rules document), **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Reference Skeleton (Read as Needed)

- Workflow: `references/proposal-debate-workflow.md`
- Template: `references/11-proposal-debate-template.md`

## Optional Check Script

- `proposal-debate-check.sh <change-id> --project-root <repo-root> --change-root <change-root>` (script located at `scripts/proposal-debate-check.sh` within this Skill)

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate debate phase.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Process

1. Detect whether `proposal.md` exists
2. Detect Decision Log status
3. Detect current debate round

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Proposal Phase** | No Decision Log | Author drafts proposal |
| **Challenge Phase** | Proposal complete but no challenge | Challenger initiates challenge |
| **Judgment Phase** | Challenge complete but no judgment | Judge issues ruling |
| **Completed** | Decision Log has final ruling | View only |

### Detection Output Example

```
Detection Result:
- proposal.md: Exists
- Decision Log: Has 1 round of challenges
- Current Round: Round 1
- Running Mode: Judgment Phase
```

---

## MCP Enhancement

This Skill does not depend on MCP services and requires no runtime detection.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`
