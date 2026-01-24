# DevBooks Skill Details

> This document details the 19 Skills of DevBooks, including the features, functions, and usage scenarios of each Skill.

---

## Positioning and Text Specifications

DevBooks itself is a non-MCP tool but provides optional MCP integration points to access external capabilities as needed, while retaining a few self-check scripts as guardrails.
DevBooks focuses on protocols, workflows, and text specifications, ensuring skill descriptions are traceable and verifiable.

**Constraint**: Skill descriptions need to be stable, scannable, and reusable.
**Trade-off**: Prioritize unified structural expression, reduce personalized narrative.
**Impact**: Maintenance costs decrease, cross-role understanding is consistent.

---

## Table of Contents

- [Workflow Entry](#workflow-entry)
- [Proposal Phase](#proposal-phase)
- [Design Phase](#design-phase)
- [Spec Phase](#spec-phase)
- [Plan Phase](#plan-phase)
- [Test Phase](#test-phase)
- [Implementation Phase](#implementation-phase)
- [Review Phase](#review-phase)
- [Archive Phase](#archive-phase)
- [Quality Assurance](#quality-assurance)
- [Brownfield Projects](#brownfield-projects)
- [Full Loop](#full-loop)

---

## Workflow Entry

### devbooks-router

**Role**: Workflow Guide

**Features**:
- Detects current project status.
- Determines which skill to start with.
- Provides the shortest closed-loop path.

**Usage Scenarios**:
- Unsure what to do next.
- Project status is unclear.
- Need workflow guidance.

**Invocation**:
```bash
/devbooks-router
```

**Output**:
- Analysis of current project status.
- Recommended next skill.
- Full loop path suggestion.

---

## Proposal Phase

### devbooks-proposal-author

**Role**: Proposal Author

**Features**:
- Drafts change proposal (Why/What/Impact).
- Includes Debate Packet.
- Presents design options to users for decision-making.

**Usage Scenarios**:
- Start new feature development.
- Major refactoring.
- Breaking changes.

**Invocation**:
```bash
/devbooks-proposal-author
```

**Output**:
- `proposal.md`: Includes Why/What/Impact/Open Questions.
- Design options (if any).

**Key Constraints**:
- Must explain the background and goal of the change.
- Must analyze the scope of impact and risks.
- Must raise unresolved questions.

---

### devbooks-proposal-challenger

**Role**: Challenger

**Features**:
- Challenges proposal.md.
- Points out risks/omissions/inconsistencies.
- Identifies missing acceptance criteria and uncovered scenarios.

**Usage Scenarios**:
- Proposal review.
- Risk assessment.
- Gap analysis.

**Invocation**:
```bash
/devbooks-proposal-challenger
```

**Output**:
- Challenge report.
- Risk list.
- Improvement suggestions.

**Key Constraints**:
- Challenge based on evidence-first, declared doubt principles.
- Do not blindly trust proposal content.

---

### devbooks-proposal-judge

**Role**: Judge

**Features**:
- Adjudicates the proposal phase.
- Outputs Approved/Revise/Rejected.
- Writes back Decision Log to proposal.md.

**Usage Scenarios**:
- Final decision on proposal.
- End of proposal review.

**Invocation**:
```bash
/devbooks-proposal-judge
```

**Output**:
- Adjudication result (Approved/Revise/Rejected).
- Decision Log.

**Key Constraints**:
- Must provide a clear adjudication result.
- Must write back Decision Log.

---

## Design Phase

### devbooks-design-doc

**Role**: Design Owner

**Features**:
- Produces design document (design.md) for the change package.
- Writes only What/Constraints and AC-xxx.
- Does NOT write implementation steps.

**Usage Scenarios**:
- Define functional requirements.
- Define acceptance criteria.
- Define constraints.

**Invocation**:
```bash
/devbooks-design-doc
```

**Output**:
- `design.md`: Includes What/Constraints/AC-xxx/C4 Delta.

**Key Constraints**:
- Cannot contain implementation steps.
- Must define clear AC-xxx.
- Must specify constraints.

---

## Spec Phase

### devbooks-spec-contract

**Role**: Spec Owner

**Features**:
- Defines external behavior specs and contracts.
- Includes Requirements/Scenarios/API/Schema.
- Defines compatibility strategy and migration plan.
- Suggests or generates contract tests.

**Usage Scenarios**:
- Define API interfaces.
- Define data models.
- Define external contracts.

**Invocation**:
```bash
/devbooks-spec-contract
```

**Output**:
- `spec.md`: Includes API/Schema/Compatibility Strategy.
- Contract Tests (Optional).

**Key Constraints**:
- Must define clear external contracts.
- Must consider compatibility.

---

## Plan Phase

### devbooks-implementation-plan

**Role**: Planner

**Features**:
- Derives coding plan (tasks.md) from design docs.
- Outputs trackable mainline plan/temporary plan/breakpoint zones.
- Binds acceptance anchors.

**Usage Scenarios**:
- Create implementation plan.
- Task breakdown.
- Parallel splitting.

**Invocation**:
```bash
/devbooks-implementation-plan
```

**Output**:
- `tasks.md`: Includes mainline plan/temporary plan/acceptance anchors.

**Key Constraints**:
- Cannot reference `tests/` directory.
- Must bind AC-xxx.

---

## Test Phase

### devbooks-test-owner

**Role**: Test Owner

**Features**:
- Converts design/specs into executable acceptance tests.
- Emphasizes independent conversation from implementation (Coder).
- Runs Red baseline first.

**Usage Scenarios**:
- Write acceptance tests.
- Write contract tests.
- Write fitness tests.

**Invocation**:
```bash
# In an independent conversation
/devbooks-test-owner
```

**Output**:
- `verification.md`: Test strategy and traceability doc.
- `tests/`: Test code.

**Key Constraints**:
- Must work in an independent conversation.
- Must run Red baseline first.
- Cannot see Coder's implementation.

---

### devbooks-test-reviewer

**Role**: Test Reviewer

**Features**:
- Reviews `tests/` quality.
- Checks coverage, boundaries, readability, maintainability.
- Only outputs review comments, does not modify code.

**Usage Scenarios**:
- Test code review.
- Test quality check.

**Invocation**:
```bash
/devbooks-test-reviewer
```

**Output**:
- Test review report.
- Improvement suggestions.

**Key Constraints**:
- Do not modify test code.
- Only review quality.

---

## Implementation Phase

### devbooks-coder

**Role**: Coder

**Features**:
- Strictly implements features according to tasks.md.
- Prohibited from modifying `tests/`.
- Tests/static checks are the sole completion criteria.

**Usage Scenarios**:
- Feature implementation.
- Bug fixing.

**Invocation**:
```bash
# In an independent conversation
/devbooks-coder
```

**Output**:
- Implementation code.
- Green evidence (tests passed).

**Key Constraints**:
- Cannot modify `tests/` directory.
- Cannot modify design documents.
- Completion criteria is tests passing, not self-assessment.

---

## Review Phase

### devbooks-reviewer

**Role**: Code Reviewer

**Features**:
- reviews readability/consistency/dependency health/code smells.
- Only outputs review comments and actionable suggestions.
- Does not discuss business correctness.

**Usage Scenarios**:
- Code review.
- Maintainability check.

**Invocation**:
```bash
/devbooks-reviewer
```

**Output**:
- Code review report.
- Improvement suggestions.

**Key Constraints**:
- Do not review business correctness (guaranteed by tests).
- Focus only on maintainability.

---

## Archive Phase

### devbooks-archiver

**Role**: Archiver

**Features**:
- The sole entry point for the archive phase.
- Responsible for the complete archive loop:
  - Auto Design Backport.
  - Spec Merge to Truth.
  - Docs Consistency Check.
  - Move change package to archive.

**Usage Scenarios**:
- Archive after change completion.
- Merge to truth.

**Invocation**:
```bash
/devbooks-archiver
```

**Output**:
- Updated truth directory.
- Archived change package.

**Key Constraints**:
- Must archive only after all quality gates pass.

---

### devbooks-docs-consistency

**Role**: Docs Consistency Checker

**Features**:
- Checks and maintains consistency between project docs and code.
- Supports incremental scan, custom rules, completeness check.
- Can run on-demand within a change package or globally.

**Usage Scenarios**:
- Docs consistency check.
- Pre-archive verification.
- Global doc audit.

**Invocation**:
```bash
# Incremental scan (change package context)
/devbooks-docs-consistency

# Global scan
/devbooks-docs-consistency --global

# Check only, no modification
/devbooks-docs-consistency --check
```

**Output**:
- Docs consistency check report.
- Completeness check report.

**Key Constraints**:
- Check only, do not modify code.

---

## Quality Assurance

### devbooks-impact-analysis

**Role**: Impact Analyzer

**Features**:
- Performs impact analysis before cross-module/cross-file/external contract changes.
- Produces Impact section directly writable to proposal.md.
- Includes Scope/Impacts/Risks/Minimal Diff/Open Questions.

**Usage Scenarios**:
- Pre-change impact assessment.
- Risk analysis.
- Change surface control.

**Invocation**:
```bash
/devbooks-impact-analysis
```

**Output**:
- Impact analysis report.
- Affected module list.
- Risk assessment.

**Key Constraints**:
- Must analyze cross-module impacts.

---

### devbooks-convergence-audit

**Role**: Convergence Auditor

**Features**:
- Assesses if effective progress is made after multiple change package loops.
- Detects anti-patterns like "fix-break-fix" and "circular spinning".
- Audits based on evidence-first, declared doubt principles.

**Usage Scenarios**:
- Assessing real progress after running a few change package loops.
- Detecting "fixing one bug introduces two bugs" loops.
- Workflow health audit.

**Invocation**:
```bash
/devbooks-convergence-audit
```

**Output**:
- Convergence assessment report.
- Anti-pattern detection results.
- Improvement suggestions.

**Key Constraints**:
- Evidence-based, do not trust declarations.
- Requires history of at least 2-3 change packages.

---

### devbooks-entropy-monitor

**Role**: Entropy Monitor

**Features**:
- Periodically collects system entropy metrics (Structural/Change/Test/Dependency).
- Generates quantitative reports.
- Suggests refactoring when metrics exceed thresholds.

**Usage Scenarios**:
- System health monitoring.
- Technical debt measurement.
- Refactoring warning.

**Invocation**:
```bash
/devbooks-entropy-monitor
```

**Output**:
- Entropy metric report.
- Trend analysis.
- Refactoring suggestions.

**Key Constraints**:
- Run periodically to track trends.

---

## Brownfield Projects

### devbooks-brownfield-bootstrap

**Role**: Brownfield Bootstrap

**Features**:
- Generates project profile, glossary, baseline specs when current truth directory is empty.
- Avoids "patching specs while changing behavior".
- Establishes minimal verification anchors.

**Usage Scenarios**:
- Adopting DevBooks in existing projects.
- Establishing baseline specs.
- Generating project profile.

**Invocation**:
```bash
/devbooks-brownfield-bootstrap
```

**Output**:
- `project-profile.md`: Project profile.
- `glossary.md`: Glossary.
- Baseline specs.
- Minimal verification anchors.

**Key Constraints**:
- Run only when truth directory is empty.

---

## Full Loop

### devbooks-delivery-workflow

**Role**: Delivery Workflow

**Features**:
- Full loop orchestrator.
- Invoked in AI coding tools supporting sub-agents.
- Automatically orchestrates Proposal → Design → Spec → Plan → Test → Implement → Review → Archive full process.

**Usage Scenarios**:
- Automate complete workflow.
- Run full loop from start to finish.

**Invocation**:
```bash
/devbooks-delivery-workflow
```

**Output**:
- Complete change package.
- Artifacts from all phases.

**Key Constraints**:
- Requires AI tool supporting sub-agents.

---

## Skill Comparison Table

| Skill | Phase | Role | Independent Chat | Main Output |
|-------|-------|------|------------------|-------------|
| devbooks-router | Entry | Guide | No | Path Suggestion |
| devbooks-proposal-author | Proposal | Author | No | proposal.md |
| devbooks-proposal-challenger | Proposal | Challenger | No | Challenge Report |
| devbooks-proposal-judge | Proposal | Judge | No | Decision Log |
| devbooks-design-doc | Design | Design Owner | No | design.md |
| devbooks-spec-contract | Spec | Spec Owner | No | spec.md |
| devbooks-implementation-plan | Plan | Planner | No | tasks.md |
| devbooks-test-owner | Test | Test Owner | Yes | tests/ + verification.md |
| devbooks-test-reviewer | Review | Test Reviewer | No | Test Review Report |
| devbooks-coder | Implement | Coder | Yes | Impl Code + Green Evidence |
| devbooks-reviewer | Review | Reviewer | No | Code Review Report |
| devbooks-archiver | Archive | Archiver | No | Archived Change Package |
| devbooks-docs-consistency | Archive | Docs Checker | No | Docs Consistency Report |
| devbooks-impact-analysis | Quality | Analyzer | No | Impact Analysis Report |
| devbooks-convergence-audit | Quality | Auditor | No | Convergence Report |
| devbooks-entropy-monitor | Quality | Monitor | No | Entropy Report |
| devbooks-brownfield-bootstrap | Init | Bootstrap | No | Profile + Baseline |
| devbooks-delivery-workflow | Full | Orchestrator | No | Complete Change Package |

---

## Usage Suggestions

### Minimal Workflow

If you just want to get started quickly:

```bash
1. /devbooks-design-doc
2. /devbooks-test-owner (Independent Chat)
3. /devbooks-coder (Independent Chat)
4. /devbooks-archiver
```

### Full Workflow

To strictly follow DevBooks specifications:

```bash
1. /devbooks-proposal-author
2. /devbooks-proposal-challenger
3. /devbooks-proposal-judge
4. /devbooks-design-doc
5. /devbooks-spec-contract
6. /devbooks-implementation-plan
7. /devbooks-test-owner (Independent Chat)
8. /devbooks-coder (Independent Chat)
9. /devbooks-reviewer
10. /devbooks-archiver
```

### Brownfield Project Workflow

If adopting an existing project:

```bash
1. /devbooks-brownfield-bootstrap
2. /devbooks-convergence-audit
3. Start normal workflow
```

---

## Summary

DevBooks provides 19 Skills covering the complete workflow from proposal to archival:

- **Entry Guide**: router
- **Proposal Phase**: proposal-author, proposal-challenger, proposal-judge
- **Design Phase**: design-doc, design-backport
- **Spec Phase**: spec-contract
- **Plan Phase**: implementation-plan
- **Test Phase**: test-owner, test-reviewer
- **Implementation Phase**: coder
- **Review Phase**: reviewer
- **Archive Phase**: archiver, docs-consistency
- **Quality Assurance**: impact-analysis, convergence-audit, entropy-monitor
- **Brownfield**: brownfield-bootstrap
- **Full Loop**: delivery-workflow

Each Skill has a clear role definition and constraints. Combining them allows building high-quality AI-assisted development workflows.

---

**Related Documentation**:
- [Usage Guide](./Usage-Guide.md)
