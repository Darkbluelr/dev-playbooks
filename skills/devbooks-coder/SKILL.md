---
name: devbooks-coder
description: devbooks-coder: As the Coder role, strictly implements functionality according to tasks.md and runs gate tests, prohibited from modifying tests/, with tests/static checks as the sole completion criteria. Use when users say "implement according to plan/fix test failures/make gates green/implement task items/don't modify tests", or when executing as coder during DevBooks apply phase.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Implementation Lead (Coder)

## Progressive Disclosure

### Base (Required)
Goal: Implement only what is specified in `tasks.md` and produce Green evidence.
Inputs: user goal, `tasks.md`, project codebase, change package context.
Outputs: implementation changes, updated `tasks.md`, Green evidence logs under `evidence/green-final/`.
Boundaries: do not modify `tests/**`; do not edit `verification.md` or the AC matrix.
Evidence: reference gate outputs and log paths.

### Advanced (Optional)
Use when you need: risk notes, minimal-diff planning, deviation recording.

### Extended (Optional)
Use when you need: faster search/impact via optional MCP capabilities.

## Recommended MCP Capability Types

- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)

## Role Isolation (Mandatory)

- Test Owner and Coder must be separate conversations/instances.
- Do not switch roles within one conversation.
- If tests or `verification.md` require changes, hand off to Test Owner.

## Core Responsibilities

1. Implement strictly according to `<change-root>/<change-id>/tasks.md`.
2. Run the gate checks required by the change (tests/build/static checks).
3. Save Green evidence to `<change-root>/<change-id>/evidence/green-final/`.
4. Check off tasks only when relevant gates pass.
5. Record discoveries that require design/spec updates to `deviation-log.md`.

## Hard Boundaries

- Allowed: implementation code, `tasks.md`, `deviation-log.md`, evidence logs.
- Prohibited: `tests/**`, edits to `verification.md`, checking off the AC matrix.

## Prerequisites: Configuration Discovery

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) -> Template protocol, use default mappings
4. If still undetermined -> **Stop and ask the user**

If the configuration specifies `agents_doc` (rules document), you **must read that document first** before performing any operations.

## Minimal Workflow

1. Read `<change-root>/<change-id>/tasks.md` and resume from the first unchecked item.
2. Implement tasks with a minimal diff.
3. Run relevant gates; if any gate fails, fix implementation (not tests) and rerun.
4. Write logs to `evidence/green-final/` and reference them in your output.
5. Check off completed tasks; do not batch-check.
6. If you find gaps in design/spec/tasks, write them to `deviation-log.md` and hand off.

## References

Required:
- `~/.claude/skills/_shared/references/ai-behavior-guidelines.md`
- `references/code-implementation-prompt.md`

As needed:
- `references/test-execution-strategy.md`
- `references/completion-status-and-routing.md`
- `references/hotspot-awareness-and-risk-assessment.md`
- `references/low-risk-modification-techniques.md`
- `references/coding-style-guidelines.md`
- `references/logging-standard.md`
- `references/error-code-standard.md`
- `~/.claude/skills/_shared/references/deviation-detection-routing-protocol.md`
