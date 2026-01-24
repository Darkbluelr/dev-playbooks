---
name: devbooks-proposal-challenger
description: devbooks-proposal-challenger: Challenge proposal.md as Challenger + gap analysis, identifying risks/omissions/inconsistencies and providing conclusions, discovering missing acceptance criteria and uncovered scenarios. Use when user says "challenge proposal/critique/risk assessment/proposal debate challenger/gap analysis" etc.
allowed-tools:
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
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
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

1) First read and follow: `~/.claude/skills/_shared/references/ai-behavior-guidelines.md` (verifiability + structural quality gating).
2) Strictly output challenge report per complete prompt: `references/proposal-challenge-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution to ensure role isolation.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

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


## Progressive Disclosure
### Base (Required)
Goal: Clarify this Skill's core outputs and usage scope.
Inputs: User goals, existing documents, change package context, or project path.
Outputs: Executable artifacts, next-step guidance, or recorded paths.
Boundaries: Does not replace other roles; does not touch `tests/`.
Evidence: Reference output paths or execution records.

### Advanced (Optional)
Use when you need to refine strategy, boundaries, or risk notes.

### Extended (Optional)
Use when you need to coordinate with external systems or optional tools.

## Recommended MCP Capability Types
- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)
