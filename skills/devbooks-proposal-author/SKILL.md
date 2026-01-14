---
name: devbooks-proposal-author
description: "devbooks-proposal-author: Author change proposals (proposal.md) with Why/What/Impact + Debate Packet, serving as the entry point for subsequent Design/Spec/Plan phases. For design decisions, presents options to users for their choice. Use when the user mentions 'write proposal/proposal/why change/impact scope/bad smell refactoring proposal' etc."
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Proposal Author

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) -> Template protocol, use default mappings
4. If still undetermined -> **Stop and ask the user**

**Key Constraints**:
- If the configuration specifies `agents_doc` (rules document), **you must read that document first** before performing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Core Responsibilities

1. **Proposal Authoring**: Produce clear, reviewable, and actionable change proposals
2. **Design Decision Interaction**: For design choices that cannot be objectively judged as better or worse (where A and B are both viable depending on preferences), present options to users for their decision rather than deciding unilaterally

## Artifact Location

- Proposal: `<change-root>/<change-id>/proposal.md`

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gating).
2) Strictly follow the complete prompt output: `references/proposal-authoring-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution to select the appropriate operating mode.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect whether the change package exists
2. Detect whether `proposal.md` already exists
3. If it exists, check whether there is a Decision Log (whether it has been adjudicated)

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Create New Proposal** | Change package does not exist or `proposal.md` does not exist | Create complete proposal document |
| **Revise Proposal** | `proposal.md` exists, Judge requires Revise | Modify proposal based on adjudication feedback |
| **Supplement Impact** | `proposal.md` exists but lacks Impact section | Add impact analysis section |

### Detection Output Example

```
Detection Results:
- Change package status: Exists
- proposal.md: Exists
- Adjudication status: Revise (modification required)
- Operating mode: Revise Proposal
```

---

## Next Step Recommendations

**Reference**: `skills/_shared/workflow-next-steps.md`

After completing proposal-author, the next step depends on the situation:

| Condition | Next Skill | Reason |
|-----------|------------|--------|
| Cross-module impact unclear | `devbooks-impact-analysis` | Clarify impact scope first |
| High risk / controversial | `devbooks-proposal-challenger` | Challenge before proceeding |
| Impact clear, ready for design | `devbooks-design-doc` | Create design document |

**CRITICAL**: Do NOT recommend `devbooks-test-owner` or `devbooks-coder` directly after proposal-author. The workflow order is:
```
proposal-author → [impact-analysis] → design-doc → [spec-contract] → implementation-plan → test-owner → coder
```

### Output Template

After completing proposal-author, output:

```markdown
## Recommended Next Step

**Next: `devbooks-design-doc`** (most common)
OR
**Next: `devbooks-impact-analysis`** (if cross-module impact unclear)
OR
**Next: `devbooks-proposal-challenger`** (if high risk, optional)

Reason: Proposal is complete. The next step is to [clarify impact / create design document].

### How to invoke
```
Run devbooks-<skill-name> skill for change <change-id>
```
```

---

## MCP Enhancement

This Skill does not depend on MCP services and requires no runtime detection.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

