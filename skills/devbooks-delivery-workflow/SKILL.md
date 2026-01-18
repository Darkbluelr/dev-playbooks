---
name: devbooks-delivery-workflow
description: devbooks-delivery-workflow: Complete closed-loop orchestrator that runs in AI programming tools with sub-agent support, automatically orchestrating the full Proposal→Design→Spec→Plan→Test→Implement→Review→Archive workflow. Use when the user says "run closed-loop/complete delivery/end-to-end flow/automated change workflow" etc.
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

### Rule 4: No Demo Mode (NO DEMO MODE)

```
❌ FORBIDDEN: Treating workflow as "demonstration" or "showcase"
❌ FORBIDDEN: Outputting "demo complete", "workflow demonstration" etc.
❌ FORBIDDEN: Claiming completion when artifacts don't exist or are empty
❌ FORBIDDEN: Using "simulate", "assume", "if" instead of actual execution

✅ REQUIRED: Every stage must produce real, verifiable artifacts
✅ REQUIRED: Artifacts must be written to filesystem (verifiable via ls/cat)
✅ REQUIRED: Use "executed", "completed", "created" for actual actions
✅ REQUIRED: If cannot actually execute, stop immediately and inform user
```

**Signs of Demo Mode**:
- Using words like "demonstration", "showcase", "simulate"
- Claiming completion without actual file writes
- Providing "Option A/B" instead of executing next step
- Outputting "recommendations for next steps" instead of continuing

### Rule 5: Must Not Ignore REVISE REQUIRED

```
❌ FORBIDDEN: Continuing to next stage after receiving REVISE REQUIRED
❌ FORBIDDEN: Claiming "completed" after receiving REVISE REQUIRED
❌ FORBIDDEN: Providing "options" for user to choose after REVISE REQUIRED
❌ FORBIDDEN: Continuing execution after receiving REJECTED

✅ REQUIRED: Judge returns REVISE → go back to Stage 1 to rewrite proposal
✅ REQUIRED: Judge returns REJECTED → stop workflow, inform user
✅ REQUIRED: Test-Review returns REVISE REQUIRED → go back to Stage 7 to fix tests
✅ REQUIRED: Code-Review returns REVISE REQUIRED → go back to Stage 8 to fix code
✅ REQUIRED: After fixing, re-execute review stage until it passes
```

### Rule 6: Must Not Proceed with Partial Completion

```
❌ FORBIDDEN: Entering next stage when tasks.md completion rate < 100%
❌ FORBIDDEN: Entering next stage when test coverage < AC requirements
❌ FORBIDDEN: Entering Code stage when stub tests exist (skip/todo/not_implemented)
❌ FORBIDDEN: Entering Review stage when unimplemented functions exist (raise NotImplementedError)

✅ REQUIRED: When Stage 7 completes, all tests must be real and executable
✅ REQUIRED: When Stage 8 completes, tasks.md all tasks 100% complete
✅ REQUIRED: If scope too large, must split change package, cannot partially complete
```

---

## Prerequisites: Configuration Discovery

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol
3. `project.md` (if exists) → Template protocol
4. If still unable to determine → **Stop and ask user**

---

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

## 📚 Reference Documentation

### Must Read (Read Immediately)

1. **Subagent Invocation Specification**: `references/subagent-invocation-spec.md`
   - Invocation format and examples
   - Role isolation constraints
   - When to read: Before starting orchestration

2. **Orchestration Logic Pseudocode**: `references/orchestration-logic-pseudocode.md`
   - Complete orchestration logic
   - Detailed implementation of 12 stages
   - When to read: When needing to understand orchestration logic

### Read as Needed

3. **Gate Checks and Error Handling**: `references/gate-checks-and-error-handling.md`
   - Stage gate checkpoints
   - Error handling flow
   - Rollback execution rules
   - When to read: When encountering errors or needing rollback

4. **Delivery Acceptance Workflow**: `references/delivery-acceptance-workflow.md`
   - Complete workflow description
   - When to read: When needing detailed workflow understanding

5. **Change Verification and Traceability Template**: `references/9-change-verification-traceability-template.md`
   - Verification template
   - When to read: When needing template reference

---

## Context Awareness

### Detection Flow

1. Detect if change package exists
2. Detect current stage (which stages completed)
3. Resume from checkpoint

### Resume from Checkpoint

If change package already has partial artifacts, continue from most recently completed stage:

```
Detection results:
- Change package: exists
- Completed stages: 1-6 (proposal, challenge, judge, design, spec, plan)
- Next stage: 7 (Test-Red)
- Run mode: Resume from checkpoint
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

### Dependent MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. Mark index availability in workflow status report
3. If unavailable → Suggest generating index before apply stage

---

## Optional Check Scripts

Scripts are located in this Skill's `scripts/` directory:

- Initialize change package skeleton: `change-scaffold.sh`
- One-click change package validation: `change-check.sh`
- Structural guardrail decision validation: `guardrail-check.sh`
- Evidence collection: `change-evidence.sh`
- Progress dashboard: `progress-dashboard.sh`
