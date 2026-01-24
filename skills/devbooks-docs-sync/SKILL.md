---
name: devbooks-docs-sync
description: devbooks-docs-sync: Deprecated alias. Use devbooks-docs-consistency for documentation consistency checks.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Edit
  - Write
  - Bash
---

# DevBooks: Docs Sync (Deprecated Alias)

## Progressive Disclosure

### Base (Required)
Goal: Route to `devbooks-docs-consistency`.
Inputs: user request and project/change context.
Outputs: deprecation notice + next step.
Boundaries: this alias should not add new behavior.
Evidence: reference the target skill path.

### Advanced (Optional)
Use when you need: compatibility notes for existing automation.

### Extended (Optional)
Use when you need: faster search/impact via optional MCP capabilities.

## Recommended MCP Capability Types
- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)

## Deprecation

- Old name: `devbooks-docs-sync`
- Current name: `devbooks-docs-consistency`
- Use `skills/devbooks-docs-consistency/SKILL.md`

## Next

Run `devbooks-docs-consistency` for the same context (change-scoped or global).
