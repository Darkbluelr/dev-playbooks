# DevBooks Usage Guide

> This guide introduces the best practices and recommended workflows for DevBooks.

---

## Quick Start: Don't know where to start?

**If you are unsure how to use DevBooks, the simplest way is:**

```bash
/devbooks:delivery
```

Delivery is the **single entrypoint**: it routes by `request_kind` and runs the **minimal sufficient closed loop**, escalating gates and evidence only when required.

### What does Delivery do?

Delivery will:
1. Ask the minimal questions to determine `request_kind`, `change_type`, `risk_level`, and `deliverable_quality`.
2. Materialize auditable on-disk artifacts (`RUNBOOK.md`, `inputs/index.md`, `proposal.md` front matter) and derive required gates.
3. Orchestrate the minimal loop (debug/change/epic/void/bootstrap/governance) and drive it to archive (or explicitly route to Void/Bootstrap when prerequisites are missing).

> High-risk or epic: when `risk_level=high` or `request_kind=epic`, Knife Plan is mandatory (G3). Delivery will route you to `/devbooks:knife` when required.

**Applicable Scenarios**:
- New feature development
- Major refactoring
- Unfamiliar with DevBooks workflows
- Want to automate the entire process

**Note**: Requires AI tools that support sub-agents (e.g., Claude Code).

### P3-3 Action Norms (must read)

To avoid multi-change cross-contamination, missing on-disk artifacts, and end-step amnesia (“forgot to archive”), read:

- `skills/devbooks-delivery-workflow/references/orchestration-bans-and-stage-table.md` (includes **P3-3 Action Norms**)

---

## Single entrypoint: Delivery (no Start/Router)

DevBooks uses **Delivery as the single entrypoint**. If you want to start lighter, keep `risk_level=low` and let Delivery choose the minimal loop.

## Table of Contents

- [Quick Start](#quick-start-dont-know-how-to-use-it)
- [Core Concepts](#core-concepts)
- [Workflow](#workflow)
- [Best Practices](#best-practices)
- [Common Scenarios](#common-scenarios)
- [Quality Assurance](#quality-assurance)
- [Troubleshooting](#troubleshooting)

---

## Positioning and Text Specifications

DevBooks is a local workflow tool and retains a small set of self-check scripts as guardrails.
DevBooks focuses on the unified description of protocols, workflows, and text specifications, emphasizing traceability and verifiability of processes.

**Constraint**: Guidance content needs to remain scannable and reusable.
**Trade-off**: Reduce verbose narrative, prioritize structured key points.
**Impact**: Collaboration consensus is more stable, and consultation costs are reduced.

---

## Core Concepts

### 1. Role Isolation

**Test Owner and Coder must work in independent conversations.**

This is a core constraint of DevBooks, not a suggestion:

- **Test Owner**: Writes acceptance tests based on design/specs, first establishing a Red baseline.
- **Coder**: Implements features based on tasks, strictly prohibited from modifying the `tests/` directory.
- **Completion Criteria**: Tests passed + Build successful, not AI self-assessment.

**Isolation State Comparison**

| Non-Isolated State | Isolated State |
|--------------------|----------------|
| Tests become "pass-oriented" | Tests truly verify specs |
| AI self-assesses "Completed" | Evidence-based completion |
| Missed edge cases | Independent perspective finds issues |

### 2. Spec-Driven

**All code must be traceable to AC-xxx (Acceptance Criteria).**

```
Requirements → Proposal → Design (AC-001, AC-002) → Spec → Tasks → Tests → Code
```

- Design docs define What/Constraints + AC-xxx.
- Spec docs define external behavior contracts.
- Task docs define implementation steps.
- Verification docs define test strategies.

### 3. Evidence-First

**Completion is defined by evidence, not AI declaration.**

Required Evidence:
- Tests passed (Green evidence)
- Build successful
- Static checks passed
- Task completion rate 100%

---

## Workflow

### Full Loop

```
1. Proposal
   ↓
2. Design
   ↓
3. Spec
   ↓
4. Plan
   ↓
5. Test
   ↓
6. Implement
   ↓
7. Review
   ↓
8. Archive
```

### Quick Start (New Feature)

```bash
# 1. Create Proposal
/devbooks:proposal

# 2. Write Design
/devbooks:design

# 3. Define Spec
/devbooks:spec

# 4. Create Plan
/devbooks:plan

# 5. Write Tests (Independent Conversation)
/devbooks:test

# 6. Implement (Independent Conversation)
/devbooks:code

# 7. Code Review
/devbooks:review

# 8. Archive Change
/devbooks:archive
```

### Brownfield Initialization

```bash
# Generate project profile, glossary, and baseline specs
/devbooks:bootstrap
```

---

## Best Practices

### 1. Proposal Phase

**Use the Triangular Debate Mechanism**

- **Author**: Drafts proposal (Why/What/Impact).
- **Challenger**: Challenges proposal (Risks/Omissions/Inconsistencies).
- **Judge**: Adjudicates proposal (Approved/Revise/Rejected).

```bash
# 1. Draft Proposal
/devbooks:proposal

# 2. Challenge Proposal
/devbooks:challenger

# 3. Adjudicate Proposal
/devbooks:judge
```

**Proposal Structure Key Points**

- **Why**: Background and goals of the change.
- **What**: Scope and content of the change.
- **Impact**: Scope of impact, risks, minimal change surface.
- **Open Questions**: Unresolved issues.

### 2. Design Phase

**Write only What/Constraints, not How.**

Design documents should contain:
- What needs to be done (What)
- Constraints (Constraints)
- Acceptance Criteria (AC-xxx)
- C4 Architecture Diagram (Optional)

**Should NOT contain**:
- Implementation steps
- Code examples
- Technical details

### 3. Spec Phase

**Define External Behavior Contracts.**

Spec documents should contain:
- API Interface Definitions
- Data Model Schema
- Compatibility Strategy
- Migration Plan
- Contract Tests

### 4. Test Phase

**Test Owner runs a Red baseline first.**

```bash
# In an independent conversation
/devbooks:test

# Verify Red Baseline
npm test  # Should fail
```

**Test Strategy**

- **Contract Tests**: Verify external contracts.
- **Fitness Tests**: Verify architectural constraints.
- **Unit Tests**: Verify unit logic.
- **Integration Tests**: Verify integration scenarios.

### 5. Implementation Phase

**Coder strictly implements according to tasks.md.**

```bash
# In an independent conversation
/devbooks:code

# Verify Green Evidence
npm test  # Should pass
npm run build  # Should succeed
```

**Coder Constraints**

- Cannot modify `tests/` directory.
- Cannot modify design documents.
- Completion criteria is tests passing, not self-assessment.

### 6. Review Phase

**Reviewer only reviews maintainability.**

```bash
/devbooks:review
```

**Review Dimensions**

- Readability
- Consistency
- Dependency Health
- Code Smells
- Architectural Constraints

**Do NOT Review**: Business correctness (guaranteed by tests).

### 7. Archive Phase

**Automated Loop Closure**

```bash
/devbooks:archive
```

Archive Process:
1. Auto Design Backport.
2. Spec Merge to Truth.
3. Docs Consistency Check.
4. Move Change Package to Archive.

#### Release preflight checks (packlist / entrypoint)

Before publishing the npm package (or doing a release audit), run the entrypoint and packlist checks and store the outputs as auditable evidence:

```bash
# One-shot verification (slash commands + npm metadata)
bash skills/devbooks-delivery-workflow/scripts/verify-all.sh --project-root "/path/to/dev-playbooks"

# Release boundary (packlist is the final truth)
npm pack --dry-run
```

To write the packlist output into the change package (recommended):

```bash
bash skills/devbooks-delivery-workflow/scripts/change-evidence.sh <change-id> \
  --project-root "/path/to/dev-playbooks" \
  --change-root dev-playbooks/changes \
  --out gates/npm-pack-dry-run.log -- npm pack --dry-run
```

#### Protocol coverage report and risk evidence

In `strict/archive`, the coverage report and risk evidence are blocking items:

```bash
# Coverage report (v1.1)
bash scripts/generate-protocol-v1.1-coverage-report.sh \
  --project-root "/path/to/dev-playbooks" \
  --change-id <change-id> \
  --change-root dev-playbooks/changes

# Dependency audit log
bash scripts/dependency-audit.sh \
  --project-root "/path/to/dev-playbooks" \
  --output dev-playbooks/changes/<change-id>/evidence/risks/dependency-audit.log
```

Evidence paths:
- `evidence/gates/protocol-v1.1-coverage.report.json`
- `evidence/risks/dependency-audit.log`

---

## Common Scenarios

### Scenario 1: New Feature

```bash
# 1. Proposal
/devbooks:proposal

# 2. Design
/devbooks:design

# 3. Spec
/devbooks:spec

# 4. Plan
/devbooks:plan

# 5. Test (Independent)
/devbooks:test

# 6. Implement (Independent)
/devbooks:code

# 7. Review
/devbooks:review

# 8. Archive
/devbooks:archive
```

### Scenario 2: Bug Fix

```bash
# 1. Impact Analysis
/devbooks:impact

# 2. Design Fix
/devbooks:design

# 3. Supplement Tests (Independent)
/devbooks:test

# 4. Implement Fix (Independent)
/devbooks:code

# 5. Archive
/devbooks:archive
```

### Scenario 3: Refactoring

```bash
# 1. Proposal (Describe Refactoring Scope)
/devbooks:proposal

# 2. Design (Define Refactoring Goals)
/devbooks:design

# 3. Impact Analysis
/devbooks:impact

# 4. Implement (Keep Tests Unchanged)
/devbooks:code

# 5. Review
/devbooks:review

# 6. Archive
/devbooks:archive
```

### Scenario 4: Brownfield Project Adoption

```bash
# 1. Initialize
/devbooks:bootstrap

# 2. Start First Change
/devbooks:proposal
```

### Scenario 5: Evaluate Workflow Convergence

When you have run a few change package loops and want to assess if there is real progress:

```bash
# Assess if change packages are effectively progressing
devbooks-convergence-audit
```

This skill checks for:
- "Fix one, break two" loops.
- "Fixing one bug introduces two bugs".
- Real progress between change packages.

---

## Quality Assurance

### Quality Gates

DevBooks provides multiple quality gates:

1. **Green Evidence Check**: Tests must pass.
2. **Task Completion Rate**: Tasks in tasks.md must be 100% complete.
3. **Role Boundary Check**: Coder cannot modify tests/.
4. **Architectural Constraint Check**: Fitness Rules verification.
5. **Docs Consistency Check**: Code and docs synchronization.

### Completion Contract and upstream claims (G6)

To avoid “tests are green but the claimed upstream obligations were not actually delivered”, use `upstream_claims` in `completion.contract.yaml`:

- Provide a machine-readable `requirements.index.yaml` in truth (`schema_version: 1.0.0`).
- If the project has no upstream SSOT library, first scaffold a minimal Project SSOT pack: `<truth-root>/ssot/SSOT.md` + `<truth-root>/ssot/requirements.index.yaml` (you can generate a skeleton via `skills/devbooks-delivery-workflow/scripts/ssot-scaffold.sh`).
- If the project has an upstream SSOT library (e.g., `SSOT docs/`), configure it in `.devbooks/config.yaml`:
  - `truth_mapping: { ssot_root: "SSOT docs/" }` (index/anchor only; do not copy long docs into change packages)
- After you edit/sync SSOT, use `devbooks-ssot-maintainer` to keep the index/ledger aligned:
  - Write delta: `<change-root>/<change-id>/inputs/ssot.delta.yaml`
  - Run: `skills/devbooks-ssot-maintainer/scripts/ssot-index-sync.sh --delta <path> --apply --refresh-ledger`
- Declare whether you claim `complete` or `subset` coverage in `completion.contract.yaml`.
- During archival, G6 emits `evidence/gates/G6-archive-decider.json` and evaluates each claim into `upstream_claims_evaluation[]` (must coverage, uncovered list, deferred, and `next_action` resolvability).

Example (block list to avoid YAML-subset pitfalls):

```yaml
upstream_claims:
  - set_ref: truth://ssot/requirements.index.yaml
    claim: subset
    covered:
      - R-001
    deferred:
      - R-002
    next_action_ref: change://20260101-0000-next-change/proposal.md
```

### Fitness Functions

```bash
# Define Architectural Constraints
# dev-playbooks/specs/architecture/fitness-rules.md

# Verify Constraints
devbooks-convergence-audit
```

### Entropy Metrics

```bash
# Monitor System Entropy
/devbooks:entropy
```

Metric Dimensions:
- Structural Entropy: Module coupling.
- Change Entropy: Frequency of changes.
- Test Entropy: Test coverage.
- Dependency Entropy: Dependency complexity.

---

## Troubleshooting

### Issue 1: Tests Fail

**Symptom**: Coder claims completion, but tests fail.

**Solution**:
1. Check if Test Owner established a Red baseline first.
2. Check if Coder modified `tests/`.
3. Check if task completion rate is 100%.

### Issue 2: Role Isolation Failure

**Symptom**: Writing both tests and code in the same conversation.

**Solution**:
1. Enable `role_isolation: true` configuration.
2. Use separate conversations to invoke test-owner and coder.

### Issue 3: Documentation and Code Inconsistency

**Symptom**: Documentation description does not match actual behavior.

**Solution**:
```bash
# Run Docs Consistency Check
/devbooks:gardener

# Or automatically check during archival
/devbooks:archive
```

### Issue 4: Change Package Confusion

**Symptom**: Multiple change packages modified crossing over.

**Solution**:
1. Use `/devbooks:delivery` to determine current state and route the next step.
2. Handle only one change package at a time.
3. Archive immediately upon completion.

### Issue 5: Brownfield Project Confusion

**Symptom**: Don't know how to use DevBooks in an existing codebase.

**Solution**:
```bash
# Run Brownfield Initialization
/devbooks:bootstrap
```

---

## Advanced Tips

### 1. Custom Configuration

Edit `.devbooks/config.yaml`:

```yaml
# Role Isolation
constraints:
  role_isolation: true
  coder_no_tests: true

# Fitness Functions
fitness:
  mode: error  # error | warn | off
  rules_file: specs/architecture/fitness-rules.md

# Proposal Debate
proposal:
  enable_debate: true
  require_impact_analysis: true
```

### 2. Custom Documentation Rules

Edit `.devbooks/docs-rules.yaml`:

```yaml
global_cleanup:
  - name: "Unify Terminology"
    pattern: "ChangeSet"
    replace: "ChangePackage"
    scope: "all_docs"
```

### 3. Full Loop Automation

```bash
# Run via the single entrypoint
/devbooks:delivery
```

---

## Summary

The core values of DevBooks:

1. **Role Isolation**: Test Owner and Coder work independently.
2. **Spec-Driven**: All code traceable to AC-xxx.
3. **Evidence-First**: Completion verified by tests/builds.
4. **Quality Gates**: Multiple checks ensure quality.
5. **Full Loop**: Complete process from proposal to archival.

**Remember**: DevBooks is not just a tool, but a workflow. Follow the constraints, and quality will naturally improve.

---

**Related Documentation**:
- [Skill Details](./Skill-Details.md)
