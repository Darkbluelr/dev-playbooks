---
name: devbooks-design-doc
description: devbooks-design-doc: Produce design documents (design.md) for change packages, focusing only on What/Constraints and AC-xxx, without implementation steps. Use when user says "write design doc/Design Doc/architecture design/constraints/acceptance criteria/AC/C4 Delta" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Design Document (Design Doc)

## Workflow Position Awareness

> **Core Principle**: Design Doc executes after Proposal is approved, serving as the starting point for implementation phase.

### My Position in the Overall Workflow

```
proposal → [Design Doc] → spec-contract → implementation-plan → test-owner → coder → ...
                 ↓
        Define What/Constraints/AC
```

### Design Doc's Output

- **What**: What to do (not how to do it)
- **Constraints**: Constraint conditions
- **AC-xxx**: Acceptance criteria (testable)

**Key**: Design Doc does not write implementation steps, that's implementation-plan's responsibility.

---

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
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

## Architecture Impact Statement (Required)

Design documents **must** include an "Architecture Impact" section declaring the impact of this change on system architecture. This is a key mechanism to ensure architecture changes go through verification closed-loops.

> **Design Decision**: C4 architecture changes are no longer written directly to the truth directory by a standalone `devbooks-c4-map` skill. Instead, they are part of design.md and merged into truth by `devbooks-archiver` after change acceptance.

### Template

```markdown
## Architecture Impact

<!-- Required: Choose one of the following -->

### No Architecture Changes

- [x] This change does not affect module boundaries, dependency directions, or component structure
- Reason: <Brief explanation of why there's no architecture impact>

### Has Architecture Changes

#### C4 Level Impact

| Level | Change Type | Impact Description |
|-------|-------------|-------------------|
| Context | None / Add / Modify / Delete | <description> |
| Container | None / Add / Modify / Delete | <description> |
| Component | None / Add / Modify / Delete | <description> |

#### Container Changes

- [Add/Modify/Delete] `<container-name>`: <change description>

#### Component Changes

- [Add/Modify/Delete] `<component-name>` in `<container>`: <change description>

#### Dependency Changes

| Source | Target | Change Type | Notes |
|--------|--------|-------------|-------|
| `<source>` | `<target>` | Add/Delete/Direction Change | <notes> |

#### Layering Constraint Impact

- [ ] This change follows existing layering constraints
- [ ] This change requires modifying layering constraints (explain below)

Layering constraint modification notes: <if any>
```

### Detection Rules

When executing design-doc skill, **must check** the following conditions to determine architecture changes:

| Check Item | Detection Method | Has Architecture Change |
|------------|------------------|------------------------|
| New/deleted directories | Check changed file paths | May affect module boundaries |
| Cross-module imports | Check import statement changes | May affect dependency direction |
| New external dependencies | Check package.json/go.mod etc. | Affects Container level |
| New services/processes | Check Dockerfile/docker-compose | Affects Container level |
| New API endpoint groups | Check route definitions | May affect Component level |

### Trigger Rules

The following change types **require** filling in architecture change details:

| Change Type | Requirement |
|-------------|-------------|
| New module/directory | Must describe Component changes |
| New service/container | Must describe Container changes |
| Modified inter-module dependencies | Must describe dependency changes |
| Introduced new external system | Must describe Context changes |

---

## Execution Method

1) First read and follow: `~/.claude/skills/_shared/references/universal-gating-protocol.md` (verifiability + structural quality gates).
2) Strictly follow complete prompt output: `references/design-doc-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate running mode.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

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

## Next Step Recommendations

**Reference**: `skills/_shared/workflow-next-steps-workflow-next-steps.md`

After completing design-doc, the next step depends on the change scope:

| Condition | Next Skill | Reason |
|-----------|------------|--------|
| External behavior/contract changes | `devbooks-spec-contract` | Must define contracts before planning |
| No external contract changes | `devbooks-implementation-plan` | Go directly to task planning |

**CRITICAL**: Do NOT recommend `devbooks-test-owner` or `devbooks-coder` directly after design-doc. The workflow order is:
```
design-doc → [spec-contract] → implementation-plan → test-owner → coder
```

### Output Template

After completing design-doc, output:

```markdown
## Recommended Next Step

**Next: `devbooks-spec-contract`** (if external behavior/contract changes)
OR
**Next: `devbooks-implementation-plan`** (if no external contract changes)

Reason: Design is complete. The next step is to [define external contracts / create implementation plan].

### How to invoke
```
Run devbooks-<skill-name> skill for change <change-id>
```
```

---

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template-mcp-enhancement.md`

