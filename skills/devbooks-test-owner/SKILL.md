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

## Quick Start

My responsibilities:
1. **Phase 1 (Red Baseline)**: Write tests → Produce failure evidence
2. **Phase 2 (Green Verification)**: Audit evidence → Check off AC matrix

## Workflow Position

```
proposal → design → [TEST-OWNER] → [CODER] → [TEST-OWNER] → code-review → archive
                         ↓              ↓           ↓
                    Red baseline    Implement    Evidence audit
                   (incremental)   (@smoke)     (no @full rerun)
```

## Dual-Phase Responsibilities

| Phase | Trigger | Core Responsibility | Test Run Method | Output |
|-------|---------|---------------------|-----------------|--------|
| **Phase 1: Red Baseline** | After design.md is complete | Write tests, produce failure evidence | Only run **incremental tests** (new/P0) | verification.md (Status=Ready), Red baseline |
| **Phase 2: Green Verification** | After Coder completes + @full passes | **Audit evidence**, check off AC matrix | Default no rerun, optional sampling | AC matrix checked, Status=Verified |

### AI Era Optimization

| Old Design | New Design | Reason |
|------------|------------|--------|
| Test Owner and Coder must use separate sessions | Same session, switch with `[TEST-OWNER]` / `[CODER]` mode labels | Reduce context rebuilding cost |
| Phase 2 reruns full tests | Phase 2 defaults to **evidence audit**, optional sampling rerun | Avoid slow test multiple runs |
| No test layering requirement | Mandatory test layering: `@smoke`/`@critical`/`@full` | Fast feedback loop |

---

## Prerequisites: Configuration Discovery

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
4. If still unable to determine → **Stop and ask user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **must read that document first** before performing any operations
- Do not guess directory roots

## Artifact Locations

- Test plan and traceability: `<change-root>/<change-id>/verification.md`
- Test code: Per repository conventions (e.g., `tests/**`)
- Red baseline evidence: `<change-root>/<change-id>/evidence/red-baseline/`
- Green evidence: `<change-root>/<change-id>/evidence/green-final/`

---

## 📚 Reference Documentation

### Must Read (Read Immediately)

1. **AI Behavior Guidelines**: `~/.claude/skills/_shared/references/ai-behavior-guidelines.md`
   - Verifiability gating, structural quality gating, completeness gating
   - Foundation rules for all skills

2. **Absolute Rules and Constraints**: `references/absolute-rules-and-constraints.md`
   - No stub tests, no demo mode, tests must not be decoupled from AC
   - AC coverage matrix checkbox permissions
   - Test isolation and stability requirements

3. **Test Code Prompt**: `references/test-code-prompt.md`
   - Complete test writing guide
   - Strictly follow this prompt

### Read as Needed for Phase 1 (When Writing Tests)

4. **Test Driven Development**: `references/test-driven-development.md`
   - Complete TDD methodology
   - Red-Green-Refactor cycle
   - When to read: When needing to understand TDD principles

5. **Test Layering Strategy**: `references/test-layering-strategy.md`
   - Unit/Integration/E2E test layering
   - Test pyramid principles
   - When to read: When planning test type distribution

6. **Test Layering and Execution Strategy**: `references/test-layering-and-execution-strategy.md`
   - @smoke/@critical/@full label details
   - Test run strategy by phase
   - Async vs sync boundaries
   - When to read: When needing to understand test run strategy

7. **Decoupling Techniques Cheatsheet**: `references/decoupling-techniques-cheatsheet.md`
   - Mock/Stub/Fake techniques
   - Dependency injection patterns
   - When to read: When needing to isolate external dependencies

8. **Async System Test Strategy**: `references/async-system-test-strategy.md`
   - Async code testing techniques
   - Event-driven system testing
   - When to read: When testing async functionality

9. **Verification Template and Structure**: `references/verification-template-and-structure.md`
   - Complete verification.md template
   - Status field permissions
   - AC coverage matrix structure
   - When to read: When creating verification.md

10. **Change Verification and Traceability Template**: `references/9-change-verification-traceability-template.md`
    - Traceability matrix template
    - Boundary condition checklist
    - When to read: When needing complete template reference

### Must Read for Phase 2 (When Auditing Evidence)

11. **Phase 2 Evidence Audit Checklist**: `references/phase2-evidence-audit-checklist.md`
    - Complete evidence audit steps
    - When to sample rerun
    - How to check off AC matrix
    - When to read: Immediately upon entering Phase 2

---

## Core Workflow

### Phase 1: Red Baseline (Write Tests)

1. **Read design documents**:
   ```bash
   # Read design.md and ACs
   cat <change-root>/<change-id>/design.md
   ```

2. **Create verification.md**:
   - Use `references/verification-template-and-structure.md`
   - Establish AC coverage matrix
   - Set Status = `Draft`

3. **Write tests**:
   - Strictly follow `references/absolute-rules-and-constraints.md`
   - Reference `references/test-code-prompt.md`
   - At least one test per AC

4. **Run tests to produce Red baseline**:
   ```bash
   # Only run newly written tests (incremental)
   npm test -- --grep "AC-001|AC-002"

   # Save failure evidence
   npm test 2>&1 | tee <change-root>/<change-id>/evidence/red-baseline/test-$(date +%Y%m%d-%H%M%S).log
   ```

5. **Update verification.md**:
   - Set Status = `Ready`
   - Record Red baseline evidence path

6. **Check for deviations**:
   - If design gaps found, record to `deviation-log.md`
   - Reference `~/.claude/skills/_shared/references/deviation-detection-routing-protocol.md`

### Phase 2: Green Verification (Audit Evidence)

**Complete steps detailed in**: `references/phase2-evidence-audit-checklist.md`

Brief workflow:
1. Check `@full` tests have passed
2. Audit `evidence/green-final/` directory
3. Verify commit hash consistency
4. Audit test logs
5. Verify AC coverage
6. Optional sampling rerun
7. Check off AC matrix
8. Set Status = `Verified`

---

## Key Constraints

### Role Boundaries

| Allowed | Prohibited |
|---------|------------|
| Write tests in `tests/**` | ❌ Modify `src/**` code |
| Check off AC matrix (Phase 2) | ❌ Modify `tasks.md` |
| Set verification.md Status to Ready/Verified | ❌ Set Status to Done (Reviewer only) |
| Record deviations to `deviation-log.md` | ❌ Modify design.md directly |
| Run incremental tests (Phase 1) | ❌ Skip Red baseline |
| Audit evidence (Phase 2) | ❌ Check off AC matrix before @full passes |

### Code Quality Constraints

#### Test Isolation Requirements

- [ ] Each test must run independently, not dependent on execution order of other tests
- [ ] Integration tests must have `beforeEach`/`afterEach` cleanup
- [ ] Shared mutable state is prohibited
- [ ] Tests must clean up created files/data after completion

#### Test Stability Requirements

- [ ] Committing `test.only` / `it.only` / `describe.only` is prohibited
- [ ] Flaky tests must be marked and fixed within a deadline (no more than 1 week)
- [ ] Test timeouts must be reasonably set (unit tests < 5s, integration tests < 30s)
- [ ] External network dependencies are prohibited (mock all external calls)

---

## Output Management

Prevent large outputs from polluting context:

| Scenario | Handling |
|----------|----------|
| Test output > 50 lines | Keep only first and last 10 lines + failure summary |
| Red baseline logs | Write to `evidence/red-baseline/`, only reference path in dialogue |
| Green evidence logs | Write to `evidence/green-final/`, only reference path in dialogue |
| Large test case lists | Use table summary, do not paste item by item |

---

## Evidence Path Convention

**Green evidence must be saved**:
```
<change-root>/<change-id>/evidence/green-final/
```

**Correct path examples**:
```bash
# Dev-Playbooks default path
dev-playbooks/changes/<change-id>/evidence/green-final/test-$(date +%Y%m%d-%H%M%S).log

# Using the script
devbooks change-evidence <change-id> --label green-final -- npm test
```

---

## Deviation Detection and Persistence

**Reference**: `~/.claude/skills/_shared/references/deviation-detection-routing-protocol.md`

During test writing, **must immediately** write to `deviation-log.md` in these situations:

| Situation | Type | Example |
|-----------|------|---------|
| Found boundary case not covered by design.md | DESIGN_GAP | Concurrent write scenario |
| Found additional constraints needed | CONSTRAINT_CHANGE | Need to add parameter validation |
| Found interface adjustment needed | API_CHANGE | Need to add return field |
| Found configuration change needed | CONSTRAINT_CHANGE | Need new config parameter |

---

## Context Awareness

This Skill automatically detects context before execution to ensure role isolation and prerequisite satisfaction.

Detection rules reference: `~/.claude/skills/_shared/context-detection-template.md`

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Initial Writing** | `verification.md` does not exist | Create complete acceptance test suite |
| **Supplementary Tests** | `verification.md` exists but has `[TODO]` | Add missing test cases |
| **Red Baseline Verification** | Tests exist, need to confirm Red status | Run tests and record failure logs |
| **Evidence Audit** | User says "verify/check off" and @full passes | Audit evidence and check off AC matrix |

---

## Completion Status and Next Step Routing

### Phase 1 Completion Status

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | PHASE1_COMPLETED | Red baseline produced, no deviations | Switch to `[CODER]` mode |
| ⚠️ | PHASE1_COMPLETED_WITH_DEVIATION | Red baseline produced, deviation-log has pending records | `devbooks-design-backport` |
| ❌ | BLOCKED | Needs external input/decision | Record breakpoint, wait for user |
| 💥 | FAILED | Test framework issues etc. | Fix and retry |

### Phase 2 Completion Status

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | PHASE2_VERIFIED | Evidence audit passed, AC matrix checked | `devbooks-code-review` |
| ⏳ | PHASE2_WAITING | @full tests still running | Wait for CI to complete |
| ❌ | PHASE2_FAILED | @full tests not passing | Notify Coder to fix |
| 🔄 | PHASE2_HANDOFF | Found issues with tests themselves | Fix tests then re-verify |

### Routing Output Template (Must Use)

```markdown
## Completion Status

**Phase**: Phase 1 (Red Baseline) / Phase 2 (Green Verification)

**Status**: ✅ PHASE1_COMPLETED / ✅ PHASE2_VERIFIED / ...

**Red Baseline**: Produced / Not completed (Phase 1 only)

**@full Tests**: Passed / Running / Failed (Phase 2 only)

**Evidence Audit**: Completed / Pending (Phase 2 only)

**AC Matrix**: Checked N/M / Not checked (Phase 2 only)

**Deviation Records**: Has N pending / None

## Next Step

**Recommended**: Switch to `[CODER]` mode / `devbooks-xxx skill`

**Reason**: [specific reason]
```

---

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection required.

MCP enhancement rules reference: `~/.claude/skills/_shared/mcp-enhancement-template.md`
