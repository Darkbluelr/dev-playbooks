---
name: devbooks-proposal-challenger
description: devbooks-proposal-challenger: Challenge proposal.md as Challenger + gap analysis, identifying risks/omissions/inconsistencies and providing conclusions, discovering missing acceptance criteria and uncovered scenarios. Use when user says "challenge proposal/critique/risk assessment/proposal debate challenger/gap analysis" etc.
tools:
  - Glob
  - Grep
  - Read
---

# DevBooks: Proposal Challenge + Gap Analysis (Proposal Challenger)

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
4. If still undetermined → **Stop and ask user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in config, **must read that document first** before any operation
- Do not guess directory roots
- Do not skip rules document reading

## Core Responsibilities

1. **Challenge Review**: Conduct strict constraint review of proposals, identifying risks, inconsistencies, and design flaws
2. **Gap Analysis**: Proactively discover omissions in proposals, including:
   - Missing acceptance criteria (AC)
   - Uncovered edge cases
   - Undefined rollback strategies
   - Omitted dependency analysis
   - Missing evidence checkpoints

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gating).
2) Strictly output challenge report per complete prompt: `references/proposal-challenge-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution to ensure role isolation.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect if `proposal.md` exists
2. Detect if current session has already executed Author role
3. Detect if Challenger's challenge opinions already exist

### Supported Modes for This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Initial Challenge** | No challenge record | Execute complete challenge flow |
| **Supplementary Challenge** | Existing challenge, Author modified | Add challenges for modified parts |

### Role Isolation Check

- [ ] Current session has not executed Author
- [ ] Current session has not executed Judge

### Detection Output Example

```
Detection Result:
- proposal.md: Exists
- Role Isolation: ✓ (Current session has not executed Author/Judge)
- Challenge History: None
- Run Mode: Initial Challenge
```

---

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection needed.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

