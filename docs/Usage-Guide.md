# DevBooks Usage Guide

> This guide introduces the best practices and recommended workflows for DevBooks.

---

## Quick Start: Don't know how to use it?

**If you are unsure how to use DevBooks, the simplest way is:**

```bash
/devbooks-delivery-workflow
```

This skill automatically orchestrates the complete development loop, from proposal to archival, executing the entire process in one go.

### What does delivery-workflow do?

`devbooks-delivery-workflow` is a full-loop orchestrator that automatically executes the following steps:

1. **Proposal** - Analyze requirements and draft a change proposal.
2. **Design** - Define functional requirements and acceptance criteria.
3. **Spec** - Define external behavior contracts.
4. **Plan** - Create an implementation plan and breakdown tasks.
5. **Test** - Write acceptance tests (in a separate conversation).
6. **Implement** - Implement features (in a separate conversation).
7. **Review** - Code review.
8. **Archive** - Archive the change package.

**Applicable Scenarios**:
- New feature development
- Major refactoring
- Unfamiliar with DevBooks workflows
- Want to automate the entire process

**Note**: Requires AI tools that support sub-agents (e.g., Claude Code).

---

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

DevBooks itself is a non-MCP tool but provides optional MCP integration points to access external capabilities as needed, while retaining a few self-check scripts as guardrails.
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
/devbooks-proposal-author

# 2. Write Design
/devbooks-design-doc

# 3. Define Spec
/devbooks-spec-contract

# 4. Create Plan
/devbooks-implementation-plan

# 5. Write Tests (Independent Conversation)
/devbooks-test-owner

# 6. Implement (Independent Conversation)
/devbooks-coder

# 7. Code Review
/devbooks-reviewer

# 8. Archive Change
/devbooks-archiver
```

### Brownfield Initialization

```bash
# Generate project profile, glossary, and baseline specs
/devbooks-brownfield-bootstrap
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
/devbooks-proposal-author

# 2. Challenge Proposal
/devbooks-proposal-challenger

# 3. Adjudicate Proposal
/devbooks-proposal-judge
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
/devbooks-test-owner

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
/devbooks-coder

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
/devbooks-reviewer
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
/devbooks-archiver
```

Archive Process:
1. Auto Design Backport.
2. Spec Merge to Truth.
3. Docs Consistency Check.
4. Move Change Package to Archive.

---

## Common Scenarios

### Scenario 1: New Feature

```bash
# 1. Proposal
/devbooks-proposal-author

# 2. Design
/devbooks-design-doc

# 3. Spec
/devbooks-spec-contract

# 4. Plan
/devbooks-implementation-plan

# 5. Test (Independent)
/devbooks-test-owner

# 6. Implement (Independent)
/devbooks-coder

# 7. Review
/devbooks-reviewer

# 8. Archive
/devbooks-archiver
```

### Scenario 2: Bug Fix

```bash
# 1. Impact Analysis
/devbooks-impact-analysis

# 2. Design Fix
/devbooks-design-doc

# 3. Supplement Tests (Independent)
/devbooks-test-owner

# 4. Implement Fix (Independent)
/devbooks-coder

# 5. Archive
/devbooks-archiver
```

### Scenario 3: Refactoring

```bash
# 1. Proposal (Describe Refactoring Scope)
/devbooks-proposal-author

# 2. Design (Define Refactoring Goals)
/devbooks-design-doc

# 3. Impact Analysis
/devbooks-impact-analysis

# 4. Implement (Keep Tests Unchanged)
/devbooks-coder

# 5. Review
/devbooks-reviewer

# 6. Archive
/devbooks-archiver
```

### Scenario 4: Brownfield Project Adoption

```bash
# 1. Initialize
/devbooks-brownfield-bootstrap

# 2. Start First Change
/devbooks-proposal-author
```

### Scenario 5: Evaluate Workflow Convergence

When you have run a few change package loops and want to assess if there is real progress:

```bash
# Assess if change packages are effectively progressing
/devbooks-convergence-audit
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

### Fitness Functions

```bash
# Define Architectural Constraints
# dev-playbooks/specs/architecture/fitness-rules.md

# Verify Constraints
/devbooks-convergence-audit
```

### Entropy Metrics

```bash
# Monitor System Entropy
/devbooks-entropy-monitor
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
/devbooks-docs-consistency

# Or automatically check during archival
/devbooks-archiver
```

### Issue 4: Change Package Confusion

**Symptom**: Multiple change packages modified crossing over.

**Solution**:
1. Use `devbooks-router` to determine current state.
2. Handle only one change package at a time.
3. Archive immediately upon completion.

### Issue 5: Brownfield Project Confusion

**Symptom**: Don't know how to use DevBooks in an existing codebase.

**Solution**:
```bash
# Run Brownfield Initialization
/devbooks-brownfield-bootstrap
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
# Run Complete Workflow
/devbooks-delivery-workflow
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
