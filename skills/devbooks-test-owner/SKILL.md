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

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **must read that document first** before performing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Artifact Locations

- Test plan and traceability: `<change-root>/<change-id>/verification.md`
- Test code: Per repository conventions (e.g., `tests/**`)
- Red baseline evidence: `<change-root>/<change-id>/evidence/red-baseline/`

---

## verification.md Enhanced Template (Required Structure)

Test Owner must produce a structured `verification.md` that serves as both test plan and traceability document.

### Status Field Permissions

| Status | Meaning | Who Can Set |
|--------|---------|-------------|
| `Draft` | Initial state | Auto-generated |
| `Ready` | Test plan ready | **Test Owner** |
| `Done` | Review passed | Reviewer (Test Owner/Coder prohibited) |
| `Archived` | Archived | Spec Gardener |

**Constraint**: After completing the test plan, Test Owner should set Status to `Ready`.

```markdown
# Verification Plan: <change-id>

## Test Strategy

### Test Type Distribution
| Test Type | Count | Purpose | Expected Time |
|-----------|-------|---------|---------------|
| Unit Tests | X | Core logic, edge cases | < 5s |
| Integration Tests | Y | API contracts, data flow | < 30s |
| E2E Tests | Z | Critical user paths | < 60s |
| Contract Tests | W | External API compatibility | < 10s |

### Test Environment
| Test Type | Environment | Dependencies |
|-----------|-------------|--------------|
| Unit | Node.js | None (all mocked) |
| Integration | Node.js + Test DB | Docker |
| E2E | Browser (Playwright) | Full application |

---

## AC Coverage Matrix

| AC-ID | Description | Test Type | Test ID | Priority | Status |
|-------|-------------|-----------|---------|----------|--------|
| AC-001 | User login returns JWT | unit | T-001 | P0 | [ ] |
| AC-002 | Wrong password returns 401 | unit | T-002 | P0 | [ ] |
| AC-003 | Token expires after 24h | integration | T-003 | P1 | [ ] |

**Coverage Summary**:
- Total ACs: X
- Covered by tests: Y
- Coverage rate: Y/X = Z%

---

## Boundary Conditions Checklist

### Input Validation
- [ ] Empty input / null values
- [ ] Maximum length exceeded
- [ ] Invalid format (email, phone, etc.)
- [ ] SQL injection / XSS attempts

### State Boundaries
- [ ] First item (index 0)
- [ ] Last item (index n-1)
- [ ] Empty collection
- [ ] Single item collection
- [ ] Maximum capacity

### Concurrency & Timing
- [ ] Concurrent access to same resource
- [ ] Request timeout handling
- [ ] Race condition scenarios
- [ ] Retry after failure

### Error Handling
- [ ] Network failure
- [ ] Database connection lost
- [ ] External API unavailable
- [ ] Invalid response format

---

## Test Priority

| Priority | Definition | Red Baseline Requirement |
|----------|------------|--------------------------|
| P0 | Blocks release, core functionality | MUST fail in Red baseline |
| P1 | Important, should be covered | Should fail in Red baseline |
| P2 | Nice to have, can be added later | Optional in Red baseline |

### P0 Tests (Must be in Red Baseline)
1. T-001: <test description>
2. T-002: <test description>

### P1 Tests (Should be in Red Baseline)
1. T-003: <test description>

---

## Manual Verification Checklist

### MANUAL-001: <Manual check description>
- [ ] Step 1
- [ ] Step 2
- [ ] Expected result

---

## Traceability Matrix

| Requirement | Design (AC) | Test | Evidence |
|-------------|-------------|------|----------|
| REQ-001 | AC-001, AC-002 | T-001, T-002 | evidence/red-baseline/*.log |
```

---

## Evidence Path Convention (Mandatory)

**Red baseline evidence must be saved to the change package directory**:
```
<change-root>/<change-id>/evidence/red-baseline/
```

**Forbidden paths**:
- ❌ `./evidence/` (project root)
- ❌ `evidence/` (relative to current working directory)

**Correct path examples**:
```bash
# DevBooks 2.0 default path
dev-playbooks/changes/<change-id>/evidence/red-baseline/test-$(date +%Y%m%d-%H%M%S).log

# Using the script
devbooks change-evidence <change-id> --label red-baseline -- npm test
```

---

## Output Management Constraints (Observation Masking)

Prevent large outputs from polluting context:

| Scenario | Handling |
|----------|----------|
| Test output > 50 lines | Keep only first and last 10 lines + failure summary |
| Red baseline logs | Write to `evidence/red-baseline/`, only reference path in dialogue |
| Green evidence logs | Write to `evidence/green-final/`, only reference path in dialogue |
| Large test case lists | Use table summary, do not paste item by item |

**Example**:
```
❌ Wrong: Pasting 500 lines of test output
✅ Correct: Red baseline established, 3 tests failed, see evidence/red-baseline/test-2024-01-05.log
        Failure summary:
        - FAIL test_pagination_invalid_page (expected 400, got 500)
        - FAIL test_pagination_boundary (assertion error)
        - FAIL test_sorting_desc (timeout)
```

---

## Test Layering Conventions (Inspired by VS Code)

### Test Types and Naming Conventions

| Test Type | File Naming | Directory Location | Expected Execution Time |
|-----------|-------------|-------------------|------------------------|
| Unit Tests | `*.test.ts` / `*.test.js` | `src/**/test/` or `tests/unit/` | < 5s/file |
| Integration Tests | `*.integrationTest.ts` | `tests/integration/` | < 30s/file |
| E2E Tests | `*.e2e.ts` / `*.spec.ts` | `tests/e2e/` | < 60s/file |
| Contract Tests | `*.contract.ts` | `tests/contract/` | < 10s/file |
| Smoke Tests | `*.smoke.ts` | `tests/smoke/` | Variable |

### Test Pyramid Ratio Recommendations

```
        /\
       /E2E\        ≈ 10% (Critical user paths)
      /─────\
     /Integration\  ≈ 20% (Module boundaries)
    /─────────────\
   /  Unit Tests   \ ≈ 70% (Business logic)
  /─────────────────\
```

### Required Test Layering Information in verification.md

```markdown
## Test Layering Strategy

| Type | Count | Covered Scenarios | Expected Execution Time |
|------|-------|-------------------|------------------------|
| Unit Tests | X | AC-001, AC-002 | < Ys |
| Integration Tests | Y | AC-003 | < Zs |
| E2E Tests | Z | Critical paths | < Ws |

## Test Environment Requirements

| Test Type | Runtime Environment | Dependencies |
|-----------|---------------------|--------------|
| Unit Tests | Node.js | No external dependencies |
| Integration Tests | Node.js + Test Database | Docker |
| E2E Tests | Browser (Playwright) | Full application |
```

### Test Isolation Requirements

- [ ] Each test must run independently, not dependent on execution order of other tests
- [ ] Integration tests must have `beforeEach`/`afterEach` cleanup
- [ ] Shared mutable state is prohibited
- [ ] Tests must clean up created files/data after completion

### Test Stability Requirements

- [ ] Committing `test.only` / `it.only` / `describe.only` is prohibited
- [ ] Flaky tests must be marked and fixed within a deadline (no more than 1 week)
- [ ] Test timeouts must be reasonably set (unit tests < 5s, integration tests < 30s)
- [ ] External network dependencies are prohibited (mock all external calls)

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (Verifiability + Structural Quality Gates).
2) Read methodology reference: `references/test-driven-development.md` (read when needed).
3) Read test layering guide: `references/test-layering-strategy.md`.
4) Strictly follow the complete prompt: `references/test-code-prompt.md`.
5) Templates (as needed): `references/9-change-verification-traceability-template.md`.

---

## Context Awareness

This Skill automatically detects context before execution to ensure role isolation and prerequisite satisfaction.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect if `design.md` exists
2. Detect if Coder role has been executed in current session
3. Detect if `verification.md` already exists
4. Detect `tests/` directory status

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Initial Writing** | `verification.md` does not exist | Create complete acceptance test suite |
| **Supplementary Tests** | `verification.md` exists but has `[TODO]` | Add missing test cases |
| **Red Baseline Verification** | Tests exist, need to confirm Red status | Run tests and record failure logs |

### Prerequisite Checks

- [ ] `design.md` exists
- [ ] Coder has not been executed in current session
- [ ] AC-xxx available for traceability

### Detection Output Example

```
Detection results:
- Artifact existence: design.md ✓, verification.md ✗
- Role isolation: ✓ (Coder not executed in current session)
- AC count: 14
- Execution mode: Initial writing
```

---

## Deviation Detection and Persistence Protocol

**Reference**: `skills/_shared/references/deviation-detection-routing-protocol.md`

### Real-time Persistence Requirements

During test writing, you **must immediately** write to `deviation-log.md` in these situations:

| Situation | Type | Example |
|-----------|------|---------|
| Found boundary case not covered by design.md | DESIGN_GAP | Concurrent write scenario |
| Found additional constraints needed | CONSTRAINT_CHANGE | Need to add parameter validation |
| Found interface adjustment needed | API_CHANGE | Need to add return field |
| Found configuration change needed | CONSTRAINT_CHANGE | Need new config parameter |

### deviation-log.md Format

```markdown
# Deviation Log

## Pending Backport Records

| Time | Type | Description | Affected Files | Backported |
|------|------|-------------|----------------|:----------:|
| 2024-01-15 09:30 | DESIGN_GAP | Found concurrent scenario not covered | tests/concurrent.test.ts | ❌ |
```

### Compact Protection

**Important**: deviation-log.md is a persistent file unaffected by compact. Even if conversation is compressed, deviation information is preserved.

---

## Completion Status and Routing

### Completion Status Classification (MECE)

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | COMPLETED | Red baseline produced, no deviations | `devbooks-coder` (separate session) |
| ⚠️ | COMPLETED_WITH_DEVIATION | Red baseline produced, deviation-log has pending records | `devbooks-design-backport` |
| ❌ | BLOCKED | Needs external input/decision | Record breakpoint, wait for user |
| 💥 | FAILED | Test framework issues etc. | Fix and retry |

### Status Determination Flow

```
1. Check if deviation-log.md has "| ❌" records
   → Yes: COMPLETED_WITH_DEVIATION

2. Check if Red baseline is produced
   - verification.md exists with traceability matrix
   - evidence/red-baseline/ exists
   → No: BLOCKED or FAILED

3. All checks passed
   → COMPLETED
```

### Routing Output Template (Required)

After completing test-owner, **must** output in this format:

```markdown
## Completion Status

**Status**: ✅ COMPLETED / ⚠️ COMPLETED_WITH_DEVIATION / ❌ BLOCKED / 💥 FAILED

**Red Baseline**: Produced / Not completed

**Deviation Records**: Has N pending / None

## Next Step

**Recommended**: `devbooks-xxx skill` (separate session)

**Reason**: [specific reason]

### How to invoke
Run devbooks-xxx skill for change <change-id>
```

### Specific Routing Rules

| My Status | Next Step | Reason |
|-----------|-----------|--------|
| COMPLETED | `devbooks-coder` (separate session) | Red baseline produced, Coder implements to make Green |
| COMPLETED_WITH_DEVIATION | `devbooks-design-backport` | Backport design first, then hand to Coder |
| BLOCKED | Wait for user | Record breakpoint area |
| FAILED | Fix and retry | Analyze failure reason |

**Critical Constraints**:
- **Role Isolation**: Coder must work in a **separate conversation/instance**
- Test Owner and Coder cannot share the same session context
- If deviations exist, must design-backport first before handing to Coder

---

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

