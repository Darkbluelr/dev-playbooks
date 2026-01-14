---
name: devbooks-delivery-workflow
description: devbooks-delivery-workflow: Run a change through a traceable closed-loop workflow (Design->Plan->Trace->Verify->Implement->Archive), with clear DoD, traceability matrix, and role isolation (Test Owner and Coder separation). Use when the user says "run closed-loop/delivery acceptance/traceability matrix/DoD/close and archive/acceptance workflow" etc.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Delivery Acceptance Workflow (Closed-Loop Skeleton)

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) -> template protocol, use default mappings
4. If still undetermined -> **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Reference Skeleton (Read as Needed)

- Workflow: `references/delivery-acceptance-workflow.md`
- Template: `references/9-change-verification-traceability-template.md`

## Optional Check Scripts

Scripts are located in this Skill's `scripts/` directory (executable; prefer "run script and get results" over reading script content into context).

- Initialize change package skeleton: `change-scaffold.sh <change-id> --project-root <repo-root> --change-root <change-root> --truth-root <truth-root>`
- One-click change package validation: `change-check.sh <change-id> --mode <proposal|apply|review|archive|strict> --role <test-owner|coder|reviewer> --project-root <repo-root> --change-root <change-root> --truth-root <truth-root>`
- Structural guardrail decision validation (strict mode calls automatically): `guardrail-check.sh <change-id> --project-root <repo-root> --change-root <change-root>`
- Initialize spec delta skeleton: `change-spec-delta-scaffold.sh <change-id> <capability> --project-root <repo-root> --change-root <change-root>`
- Evidence collection (save tests/command output to evidence): `change-evidence.sh <change-id> --label <name> --project-root <repo-root> --change-root <change-root> -- <command> [args...]`
- Large-Scale Change (LSC) codemod script skeleton: `change-codemod-scaffold.sh <change-id> --name <codemod-name> --project-root <repo-root> --change-root <change-root>`
- Hygiene check (temporary files/process cleanup): `hygiene-check.sh <change-id> --project-root <repo-root> --change-root <change-root>`

## Quality Gate Scripts (v2)

The following scripts are used to strengthen quality gates and block "false completions":

- Role handoff check: `handoff-check.sh <change-id> --project-root <repo-root> --change-root <change-root>`
- Environment declaration check: `env-match-check.sh <change-id> --project-root <repo-root> --change-root <change-root>`
- Audit full scope scan: `audit-scope.sh <directory> --format <markdown|json>`
- Progress dashboard: `progress-dashboard.sh <change-id> --project-root <repo-root> --change-root <change-root>`
- v2 gate migration: `migrate-to-v2-gates.sh <change-id> --project-root <repo-root> --change-root <change-root>`

### change-check.sh v2 New Check Items

| Check Item | Trigger Mode | Description | AC |
|------------|--------------|-------------|-----|
| `check_evidence_closure()` | archive, strict | Verify `evidence/green-final/` exists and is non-empty | AC-001 |
| `check_task_completion_rate()` | strict | Verify 100% task completion rate (supports SKIP-APPROVED) | AC-002 |
| `check_role_boundaries()` | apply --role | Verify role boundaries (extended from check_no_tests_changed) | AC-003 |
| `check_skip_approval()` | strict | Verify P0 task skips have approval records | AC-005 |
| `check_env_match()` | archive, strict | Call env-match-check.sh to check environment declarations | AC-006 |
| `check_test_failure_in_evidence()` | archive, strict | Detect failure patterns in Green evidence | AC-007 |

### change-check.sh Basic Check Items

| Check Item | Trigger Mode | Description |
|------------|--------------|-------------|
| `check_proposal()` | All modes | Check proposal.md format and decision status |
| `check_design()` | All modes | Check design.md structure (AC list, Problem Context, etc.) |
| `check_tasks()` | All modes | Check tasks.md structure (mainline plan section, breakpoint section) |
| `check_verification()` | All modes | Check verification.md four required sections |
| `check_spec_deltas()` | All modes | Check spec delta format in specs/ directory |
| `check_implicit_changes()` | apply, archive, strict | Detect implicit changes (dependencies, config, build) |

### Role Boundary Constraints

| Role | Prohibited Modifications |
|------|-------------------------|
| Coder | `tests/**`, `verification.md`, `.devbooks/` |
| Test Owner | `src/**` |
| Reviewer | Code files (`.ts`, `.js`, `.py`, `.sh`, etc.) |

For detailed explanation, see: `docs/quality-gates-guide.md`

## Architecture Compliance Check (Dependency Guardian)

Perform architecture compliance checks before merge to prevent dependency direction violations.

### guardrail-check.sh Complete Options

```bash
guardrail-check.sh <change-id> [options]

Options:
  --project-root <dir>   Project root directory
  --change-root <dir>    Change package directory
  --truth-root <dir>     Truth directory (contains architecture/c4.md)
  --role <role>          Role permission check (coder|test-owner|reviewer)
  --check-lockfile       Check if lockfile changes are declared
  --check-engineering    Check if engineering system changes are declared
  --check-layers         Check layer constraint violations (Dependency Guardian core)
  --check-cycles         Check circular dependencies
  --check-hotspots       Warn about hotspot file changes
```

### Layer Constraint Check Content

`--check-layers` detects the following violations:

| Violation Type | Example | Severity |
|----------------|---------|----------|
| Lower layer references upper layer | `base/` imports `platform/` | Critical |
| common references browser/node | `common/` imports `browser/` | Critical |
| common uses DOM API | `document.` in common | Critical |
| core references contrib | Violates extension point design | High |

### Recommended Usage

```bash
# Complete architecture check (before merge)
guardrail-check.sh <change-id> \
  --truth-root devbooks \
  --check-layers \
  --check-cycles \
  --check-hotspots \
  --check-lockfile \
  --check-engineering

# Quick check (daily development)
guardrail-check.sh <change-id> --check-layers --check-cycles
```

### CI Integration Example

```yaml
# .github/workflows/pr.yml
- name: Architecture Compliance Check
  run: |
    ./scripts/guardrail-check.sh ${{ github.event.pull_request.number }} \
      --truth-root devbooks \
      --check-layers \
      --check-cycles
```

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate workflow stage.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect if change package exists
2. Detect current stage (proposal/apply/archive)
3. Detect gate status

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Initialize Mode** | Change package does not exist | Create change package skeleton |
| **Check Mode** | With --check parameter | Run gate checks only |
| **Full Closed-Loop** | No special parameters | Execute complete Design->Archive flow |

### Detection Output Example

```
Detection Results:
- Change Package: exists
- Current Stage: apply
- Gate Status: proposal OK, design OK, tasks OK
- Run Mode: Check mode (apply stage)
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Dependent MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. Mark index availability in workflow status report
3. If unavailable -> Suggest generating index before apply stage

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Architecture Check | Precise dependency analysis | Based on import statements |
| Hotspot Warning | CKB real-time analysis | Unavailable |
| Impact Assessment | Call graph analysis | File-level estimation |

### Degradation Notice

When MCP is unavailable, output the following notice:

```
Warning: CKB index unavailable, architecture check will use basic mode.
Consider manually generating SCIP index for precise checks.
```
