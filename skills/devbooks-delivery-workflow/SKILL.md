---
name: devbooks-delivery-workflow
description: "devbooks-delivery-workflow: Complete closed-loop orchestrator that runs in AI programming tools with sub-agent support, automatically orchestrating the full Proposal→Design→Spec→Plan→Test→Implement→Review→Archive workflow. Use when the user says 'run closed-loop/complete delivery/end-to-end flow/automated change workflow' etc."
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
  - Task
---

# DevBooks: Delivery Acceptance Workflow (Complete Closed-Loop Orchestrator)

> **Positioning**: This Skill is a **pure orchestration layer**, not an execution layer. It only **calls sub-agents**, never performs any change work itself.

---

## 🚨 ABSOLUTE RULES

> **These rules have no exceptions. Violation means failure.**

### Rule 1: Main Agent Must Not Work Directly

```
❌ FORBIDDEN: Main Agent writing proposal.md / design.md / tests/ / src/ directly
❌ FORBIDDEN: Main Agent modifying any change package content directly
❌ FORBIDDEN: Main Agent skipping sub-agent calls

✅ REQUIRED: All work completed through Task tool sub-agent calls
✅ REQUIRED: Every stage has corresponding sub-agent call
✅ REQUIRED: Main Agent only orchestrates, waits, and verifies
```

### Rule 2: Must Not Skip Any Mandatory Stage

```
❌ FORBIDDEN: Skipping Challenger/Judge stages
❌ FORBIDDEN: Skipping Test-Reviewer stage
❌ FORBIDDEN: Skipping Code-Review stage
❌ FORBIDDEN: Skipping Green-Verify stage
❌ FORBIDDEN: Archiving without passing strict check

✅ REQUIRED: Complete execution of all 12 mandatory stages
✅ REQUIRED: Sub-agent must return success before continuing to next stage
```

### Rule 3: Must Not Archive with Fake Completion

```
❌ FORBIDDEN: Archiving when evidence/green-final/ doesn't exist or is empty
❌ FORBIDDEN: Archiving when verification.md AC coverage < 100%
❌ FORBIDDEN: Archiving when tasks.md has incomplete tasks
❌ FORBIDDEN: Archiving when change-check.sh --mode strict fails

✅ REQUIRED: Archiver sub-agent runs check script first
✅ REQUIRED: All checks pass before executing archive
```

---

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) -> template protocol, use default mappings
4. If still undetermined -> **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Complete Closed-Loop Flow (12 Mandatory Stages)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                      Mandatory Flow (No Optional Stages)                  │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────┐   ┌───────────┐   ┌─────────┐   ┌─────────┐                │
│  │1.Propose│──▶│2.Challenge│──▶│ 3.Judge │──▶│4.Design │                │
│  └─────────┘   └───────────┘   └─────────┘   └─────────┘                │
│       │                                            │                     │
│       │              ┌─────────────────────────────┘                     │
│       │              ▼                                                   │
│       │        ┌─────────┐   ┌─────────┐   ┌─────────┐                  │
│       │        │ 5.Spec  │──▶│ 6.Plan  │──▶│7.Test-R │                  │
│       │        └─────────┘   └─────────┘   └─────────┘                  │
│       │                                          │                       │
│       │              ┌───────────────────────────┘                       │
│       │              ▼                                                   │
│       │        ┌─────────┐   ┌──────────┐   ┌──────────┐                │
│       │        │ 8.Code  │──▶│9.TestRev │──▶│10.CodeRev│                │
│       │        └─────────┘   └──────────┘   └──────────┘                │
│       │                                            │                     │
│       │              ┌─────────────────────────────┘                     │
│       │              ▼                                                   │
│       │        ┌───────────┐   ┌─────────┐                              │
│       └───────▶│11.GreenV  │──▶│12.Archive│                              │
│                └───────────┘   └─────────┘                              │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

### Stage Details and Sub-Agent Calls

| # | Stage | Sub-Agent | Skill | Artifact | Mandatory |
|---|-------|-----------|-------|----------|-----------|
| 1 | Propose | `devbooks-proposal-author` | devbooks-proposal-author | proposal.md | ✅ |
| 2 | Challenge | `devbooks-challenger` | devbooks-proposal-challenger | Challenge opinions | ✅ |
| 3 | Judge | `devbooks-judge` | devbooks-proposal-judge | Decision Log | ✅ |
| 4 | Design | `devbooks-designer` | devbooks-design-doc | design.md | ✅ |
| 5 | Spec | `devbooks-spec-owner` | devbooks-spec-contract | specs/*.md | ✅ |
| 6 | Plan | `devbooks-planner` | devbooks-implementation-plan | tasks.md | ✅ |
| 7 | Test-Red | `devbooks-test-owner` | devbooks-test-owner | verification.md + tests/ | ✅ |
| 8 | Code | `devbooks-coder` | devbooks-coder | src/ implementation | ✅ |
| 9 | Test-Review | `devbooks-reviewer` | devbooks-test-reviewer | Test review opinions | ✅ |
| 10 | Code-Review | `devbooks-reviewer` | devbooks-code-review | Code review opinions | ✅ |
| 11 | Green-Verify | `devbooks-test-owner` | devbooks-test-owner | evidence/green-final/ | ✅ |
| 12 | Archive | `devbooks-archiver` | devbooks-archiver | Archived to archive/ | ✅ |

---

## Orchestration Logic (Pseudocode)

```python
def run_delivery_workflow(user_requirement):
    """
    Main Agent only executes this orchestration logic, does no actual work
    """

    # ==================== Stage 1: Propose ====================
    change_id = call_subagent("devbooks-proposal-author", {
        "task": "Create change proposal",
        "requirement": user_requirement
    })
    verify_output(f"{change_root}/{change_id}/proposal.md")

    # ==================== Stage 2: Challenge ====================
    challenge_result = call_subagent("devbooks-challenger", {
        "task": "Challenge proposal",
        "change_id": change_id
    })
    # Never skip, run even if no challenges found

    # ==================== Stage 3: Judge ====================
    judge_result = call_subagent("devbooks-judge", {
        "task": "Adjudicate proposal",
        "change_id": change_id,
        "challenge_result": challenge_result
    })
    if judge_result == "REJECTED":
        return "Proposal rejected, workflow terminated"
    if judge_result == "REVISE":
        # Return to Stage 1, rewrite proposal
        return run_delivery_workflow(revised_requirement)
    # judge_result == "APPROVED" continue

    # ==================== Stage 4: Design ====================
    call_subagent("devbooks-designer", {
        "task": "Create design document",
        "change_id": change_id
    })
    verify_output(f"{change_root}/{change_id}/design.md")

    # ==================== Stage 5: Spec ====================
    call_subagent("devbooks-spec-owner", {
        "task": "Define spec contracts",
        "change_id": change_id
    })
    # specs/ directory may be empty (when no external contracts)

    # ==================== Stage 6: Plan ====================
    call_subagent("devbooks-planner", {
        "task": "Create implementation plan",
        "change_id": change_id
    })
    verify_output(f"{change_root}/{change_id}/tasks.md")

    # ==================== Stage 7: Test-Red ====================
    # Must use independent Agent session
    call_subagent("devbooks-test-owner", {
        "task": "Write tests and establish Red baseline",
        "change_id": change_id,
        "isolation": "required"  # Mandatory isolation
    })
    verify_output(f"{change_root}/{change_id}/verification.md")
    verify_output(f"{change_root}/{change_id}/evidence/red-baseline/")

    # ==================== Stage 8: Code ====================
    # Must use independent Agent session
    call_subagent("devbooks-coder", {
        "task": "Implement features per tasks.md",
        "change_id": change_id,
        "isolation": "required"  # Mandatory isolation
    })

    # ==================== Stage 9: Test-Review ====================
    test_review_result = call_subagent("devbooks-reviewer", {
        "task": "Review test quality",
        "change_id": change_id,
        "review_type": "test-review"
    })
    if test_review_result == "REVISE REQUIRED":
        # Return to Stage 7, fix test issues
        goto_stage(7)

    # ==================== Stage 10: Code-Review ====================
    code_review_result = call_subagent("devbooks-reviewer", {
        "task": "Review code quality",
        "change_id": change_id,
        "review_type": "code-review"
    })
    if code_review_result == "REVISE REQUIRED":
        # Return to Stage 8, fix code issues
        goto_stage(8)

    # ==================== Stage 11: Green-Verify ====================
    # Must use independent Agent session (same Test Owner as Stage 7)
    call_subagent("devbooks-test-owner", {
        "task": "Run all tests and collect Green evidence",
        "change_id": change_id,
        "isolation": "required",
        "phase": "green-verify"
    })
    verify_output(f"{change_root}/{change_id}/evidence/green-final/")

    # ==================== Stage 12: Archive ====================
    # Archiver will automatically run change-check.sh --mode strict
    call_subagent("devbooks-archiver", {
        "task": "Execute archive",
        "change_id": change_id
    })

    return "Closed-loop complete"
```

---

## Sub-Agent Call Templates

### Call Format

Use Task tool to call sub-agents:

```markdown
## Calling devbooks-proposal-author sub-agent

Please execute the following task:
- Use devbooks-proposal-author skill
- Create change proposal for: [requirement description]
- Generate compliant change-id
- Output change-id and proposal.md path when done
```

### Stage Call Examples

| Stage | Sub-Agent | Call Prompt |
|-------|-----------|-------------|
| 1 | devbooks-proposal-author | "Use devbooks-proposal-author skill to create proposal for [requirement]" |
| 2 | devbooks-challenger | "Use devbooks-proposal-challenger skill to challenge change [change-id]" |
| 3 | devbooks-judge | "Use devbooks-proposal-judge skill to adjudicate change [change-id]" |
| 4 | devbooks-designer | "Use devbooks-design-doc skill to create design doc for change [change-id]" |
| 5 | devbooks-spec-owner | "Use devbooks-spec-contract skill to define specs for change [change-id]" |
| 6 | devbooks-planner | "Use devbooks-implementation-plan skill to create plan for change [change-id]" |
| 7 | devbooks-test-owner | "Use devbooks-test-owner skill to write tests and establish Red baseline for change [change-id]" |
| 8 | devbooks-coder | "Use devbooks-coder skill to implement features for change [change-id]" |
| 9 | devbooks-reviewer | "Use devbooks-test-reviewer skill to review tests for change [change-id]" |
| 10 | devbooks-reviewer | "Use devbooks-code-review skill to review code for change [change-id]" |
| 11 | devbooks-test-owner | "Use devbooks-test-owner skill to run all tests and collect Green evidence for change [change-id]" |
| 12 | devbooks-archiver | "Use devbooks-archiver skill to archive change [change-id]" |

---

## Role Isolation Constraints

**Key Principle**: Test Owner and Coder must use **independent Agent instances/sessions**.

| Role | Isolation Requirement | Reason |
|------|----------------------|--------|
| Test Owner | Independent Agent | Prevent Coder from tampering with tests |
| Coder | Independent Agent | Prevent Coder from seeing test implementation details |
| Reviewer | Independent Agent (recommended) | Maintain review objectivity |

### Gate Checkpoints

After each stage completes, call `change-check.sh` to verify:

```bash
# Proposal stage check
change-check.sh <change-id> --mode proposal

# Implementation stage check (Test Owner)
change-check.sh <change-id> --mode apply --role test-owner

# Implementation stage check (Coder)
change-check.sh <change-id> --mode apply --role coder

# Pre-archive check
change-check.sh <change-id> --mode archive
```

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
