---
name: devbooks-test-owner
description: devbooks-test-owner: As the Test Owner role, converts design/specs into executable acceptance tests and traceability documentation (verification.md), emphasizing independent dialogue from implementation (Coder) and establishing Red baseline first. Use when users say "write tests/acceptance tests/traceability matrix/verification.md/Red-Green/contract tests/fitness tests", or when executing as test owner during DevBooks apply phase.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Test Owner

## Progressive Disclosure

### Base (Required)
Goal: Author acceptance tests and `verification.md`, produce a Red baseline first, then audit Green evidence before checking off the AC matrix.
Inputs: design/specs, change package context, project test conventions.
Outputs: `tests/**`, `<change-root>/<change-id>/verification.md`, evidence logs under `evidence/red-baseline/` and `evidence/green-final/`.
Boundaries: do not modify implementation code (e.g. `src/**`); do not edit `tasks.md`.
Evidence: reference test logs and evidence paths.

### Advanced (Optional)
Use when you need: test layering, edge cases, isolation techniques, deviation routing.

### Extended (Optional)
Use when you need: faster search/impact via optional MCP capabilities.

## Recommended MCP Capability Types

- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)

## Role Isolation (Mandatory)

- Test Owner and Coder must be separate conversations/instances.
- Do not switch roles within one conversation.
- This role only produces `tests/**` and `verification.md`.

## Core Responsibilities

- Maintain `<change-root>/<change-id>/verification.md` (traceability + status).
- Phase 1 (Red baseline): write tests and capture failing evidence.
- Phase 2 (Green verification): audit Green evidence after full gates pass, then check off the AC matrix.
- Record design/spec gaps to `deviation-log.md` for backporting.

## Hard Boundaries

- Allowed: `tests/**`, `verification.md`, evidence logs.
- Prohibited: implementation changes, editing `tasks.md`.

## Prerequisites: Configuration Discovery

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) -> Template protocol, use default mappings
4. If still undetermined -> **Stop and ask the user**

If the configuration specifies `agents_doc` (rules document), you **must read that document first** before performing any operations.

## Minimal Workflow

### Phase 1: Red Baseline
1. Read `design.md` and relevant specs.
2. Create or update `verification.md` with an AC coverage matrix.
3. Write tests under `tests/**`.
4. Run incremental tests and save Red baseline logs under `evidence/red-baseline/`.
5. Set verification status to `Ready` and reference the Red evidence path.

### Phase 2: Green Verification
1. Confirm Green evidence exists under `evidence/green-final/`.
2. Audit logs and consistency of commit hashes (if applicable).
3. Optionally rerun a small sampling set when evidence is insufficient.
4. Check off the AC matrix and set status to `Verified`.

## References

Required:
- `~/.claude/skills/_shared/references/ai-behavior-guidelines.md`
- `references/absolute-rules-and-constraints.md`
- `references/test-code-prompt.md`
- `references/verification-template-and-structure.md`
- `references/phase2-evidence-audit-checklist.md`

As needed:
- `references/test-driven-development.md`
- `references/test-layering-strategy.md`
- `references/test-layering-and-execution-strategy.md`
- `references/decoupling-techniques-cheatsheet.md`
- `references/async-system-test-strategy.md`
- `references/9-change-verification-traceability-template.md`
- `~/.claude/skills/_shared/references/deviation-detection-routing-protocol.md`
