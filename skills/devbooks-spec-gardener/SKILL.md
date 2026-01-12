---
name: devbooks-spec-gardener
description: devbooks-spec-gardener: Prune and maintain <truth-root> before archiving (deduplicate/merge, remove obsolete, organize directories, fix inconsistencies) to prevent specs from accumulating out of control. Use when user says "spec gardener/deduplicate specs/pre-archive cleanup/clean obsolete specs", or during DevBooks archive/pre-archive finalization.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: Spec Gardener

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
4. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask the user**

**Critical Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Execution Method

1) First read and follow: `_shared/references/universal-gate-protocol.md` (verifiability + structural quality gates).
2) Strictly execute the complete prompt: `references/spec-gardener-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate maintenance mode.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect `<truth-root>/` directory status
2. If change-id is provided, detect change package archive conditions
3. Detect duplicate/obsolete specs

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Archive Mode** | change-id provided and gates pass | Merge change package artifacts into truth-root |
| **Maintenance Mode** | No change-id | Execute deduplication, cleanup, organization operations |
| **Check Mode** | With --dry-run parameter | Output suggestions only, no actual modifications |

### Detection Output Example

```
Detection Results:
- truth-root: Exists, contains 12 spec files
- Change package: Exists, all gates green
- Running mode: Archive mode
```

---

## MCP Enhancement

This Skill does not depend on MCP services; no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

