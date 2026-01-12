---
name: devbooks-design-doc
description: devbooks-design-doc: Produce design documents (design.md) for change packages, focusing only on What/Constraints and AC-xxx, without implementation steps. Use when user says "write design doc/Design Doc/architecture design/constraints/acceptance criteria/AC/C4 Delta" etc.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Design Document (Design Doc)

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
4. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask user**

**Key Constraints**:
- If configuration specifies `agents_doc` (rules document), **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading rules document

## Artifact Location

- Design document: `<change-root>/<change-id>/design.md`

## Documentation Impact Statement (Required)

Design documents **must** include a "Documentation Impact" section declaring the impact of this change on user documentation. This is a key mechanism to ensure documentation stays in sync with code.

### Template

```markdown
## Documentation Impact

### Documents Requiring Updates

| Document | Update Reason | Priority |
|----------|---------------|----------|
| README.md | New feature X requires usage instructions | P0 |
| docs/user-guide.md | New script Y requires usage documentation | P0 |
| CHANGELOG.md | Record this change | P1 |

### Documents Not Requiring Updates

- [ ] This change is internal refactoring, does not affect user-visible functionality
- [ ] This change only fixes bugs, does not introduce new features or change usage patterns

### Documentation Update Checklist

- [ ] New scripts/commands are documented in usage documentation
- [ ] New configuration options are documented in configuration documentation
- [ ] New workflows/processes are documented in guides
- [ ] API/interface changes are updated in relevant documentation
```

### Trigger Rules

The following change types **require** updating corresponding documentation:

| Change Type | Documents to Update |
|-------------|---------------------|
| New script (*.sh) | User guide, README |
| New Skill | README, Skills list |
| Workflow changes | Related guide documentation |
| New configuration options | Configuration documentation |
| New commands/CLI parameters | User guide |
| External API changes | API documentation |

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gates).
2) Strictly follow complete prompt output: `references/design-doc-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate running mode.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Process

1. Detect if `proposal.md` exists (input for design document)
2. Detect if `design.md` already exists
3. If exists, check completeness (whether it has AC-xxx, whether it has `[TODO]`)

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Create Design** | `design.md` does not exist | Create complete design document |
| **Supplement Design** | `design.md` exists but has `[TODO]` | Fill in missing sections |
| **Add AC** | Design exists but AC is incomplete | Add acceptance criteria |

### Detection Output Example

```
Detection Results:
- proposal.md: Exists
- design.md: Exists, has 5 [TODO]s
- AC count: 8
- Running mode: Supplement Design
```

---

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

