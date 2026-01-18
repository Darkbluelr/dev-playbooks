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

## Workflow Position Awareness

> **Core Principle**: Test Owner has **dual-phase responsibilities** in the overall workflow, achieving mental clarity through **mode labels** (not session isolation).

### My Position in the Overall Workflow

```
proposal → design → [TEST-OWNER] → [CODER] → [TEST-OWNER] → code-review → archive
                         ↓              ↓           ↓
                    Red baseline    Implement    Evidence audit
                   (incremental)   (@smoke)     (no @full rerun)
```

### AI Era Solo Development Optimization

> **Important Change**: This protocol is optimized for AI programming + solo development scenarios, **removing the mandatory "separate session" requirement**.

| Old Design | New Design | Reason |
|------------|------------|--------|
| Test Owner and Coder must use separate sessions | Same session, switch with `[TEST-OWNER]` / `[CODER]` mode labels | Reduce context rebuilding cost |
| Phase 2 reruns full tests | Phase 2 defaults to **evidence audit**, optional sampling rerun | Avoid slow test multiple runs |
| No test layering requirement | Mandatory test layering: `@smoke`/`@critical`/`@full` | Fast feedback loop |

### Test Owner's Dual-Phase Responsibilities

| Phase | Trigger | Core Responsibility | Test Run Method | Output |
|-------|---------|---------------------|-----------------|--------|
| **Phase 1: Red Baseline** | After design.md is complete | Write tests, produce failure evidence | Only run **incremental tests** (new/P0) | verification.md (Status=Ready), Red baseline |
| **Phase 2: Green Verification** | After Coder completes + @full passes | **Audit evidence**, check off AC matrix | Default no rerun, optional sampling | AC matrix checked, Status=Verified |

### Phase 2 Detailed Responsibilities (Critical!)

When user says "Coder is done, please verify" or similar, Test Owner enters **Phase 2**:

1. **Check prerequisites**: Confirm @full tests have passed (check CI results or `evidence/green-final/`)
2. **Audit evidence** (default mode):
   - Check test logs in `evidence/green-final/` directory
   - Verify commit hash matches current code
   - Confirm tests cover all ACs
3. **Optional sampling rerun**: Sample verify high-risk ACs or questionable tests
4. **Check off AC Coverage Matrix**: Change `[ ]` to `[x]` in verification.md AC Coverage Matrix
5. **Set status to Verified**: Indicates test verification passed, waiting for Code Review

### AC Coverage Matrix Checkbox Permissions (Important!)

| Checkbox Location | Who Can Check | When to Check |
|-------------------|---------------|---------------|
| `[ ]` in AC Coverage Matrix | **Test Owner** | Phase 2 after evidence audit confirmed |
| Status field `Verified` | **Test Owner** | After Phase 2 completion |
| Status field `Done` | Reviewer | After Code Review passes |

**Prohibited**: Coder cannot check AC Coverage Matrix, cannot modify verification.md.

---

## 🚨 ABSOLUTE RULES

> **These rules have no exceptions. Violation means failure.**

### Rule 1: No Stub Tests

```
❌ FORBIDDEN: Test function body is empty (pass / return)
❌ FORBIDDEN: Test contains skip / pytest.skip / @skip
❌ FORBIDDEN: Test contains TODO / FIXME / not_implemented
❌ FORBIDDEN: Test only has assert True or assert 1 == 1
❌ FORBIDDEN: Test raises NotImplementedError

✅ REQUIRED: Every test has real assertions
✅ REQUIRED: Every test can run independently
✅ REQUIRED: Test failures give meaningful error messages
```

**Stub Test Examples (All FORBIDDEN)**:

```python
# ❌ Empty function body
def test_login():
    pass

# ❌ Skip marker
def test_login():
    pytest.skip("not implemented yet")

# ❌ TODO placeholder
def test_login():
    # TODO: implement this test
    assert True

# ❌ Meaningless assertion
def test_login():
    assert 1 == 1

# ❌ Raises not implemented exception
def test_login():
    raise NotImplementedError("pending")
```

**Proper Test Example**:

```python
# ✅ Real test with assertions
def test_login_returns_jwt():
    # Arrange
    user = create_test_user(email="test@example.com", password="secret")

    # Act
    result = login_service.login(email="test@example.com", password="secret")

    # Assert
    assert result.token is not None
    assert result.token.startswith("eyJ")
    assert result.user_id == user.id
```

### Rule 2: No Demo Mode (NO DEMO MODE)

```
❌ FORBIDDEN: Treating test writing as "demonstration" or "showcase"
❌ FORBIDDEN: Claiming "tests written" when files are empty or don't exist
❌ FORBIDDEN: Outputting test plan without actually creating test files
❌ FORBIDDEN: Using "simulate", "assume" instead of actually writing tests

✅ REQUIRED: Every claimed test must be a real file
✅ REQUIRED: Files must contain executable test code
✅ REQUIRED: Red baseline evidence must come from actually running tests
```

### Rule 3: Tests Must Not Be Decoupled from AC

```
❌ FORBIDDEN: Tests not associated with any AC
❌ FORBIDDEN: AC without corresponding tests
❌ FORBIDDEN: Tests pass but AC not actually verified

✅ REQUIRED: Every AC has at least one test
✅ REQUIRED: Every test is linked to a specific AC-xxx
✅ REQUIRED: verification.md AC Coverage Matrix has 100% test mapping
```

---

## Test Layering and Run Strategy (Critical!)

> **Core Principle**: Test layering is key to solving "slow tests blocking development".

### Test Layering Labels (Must Use)

| Label | Purpose | Who Runs | Expected Time | When to Run |
|-------|---------|----------|---------------|-------------|
| `@smoke` | Fast feedback, core paths | Coder runs frequently | Seconds | After each code change |
| `@critical` | Key functionality verification | Coder before commit | Minutes | Before commit |
| `@full` | Complete acceptance tests | CI runs async | Can be slow (hours) | Background/CI |

### Test Run Strategy by Phase

| Phase | What to Run | Purpose | Blocking/Async |
|-------|-------------|---------|----------------|
| **Test Owner Phase 1** | Only **newly written tests** | Confirm Red status | Sync (but incremental only) |
| **Coder during dev** | `@smoke` | Fast feedback loop | Sync |
| **Coder before commit** | `@critical` | Key path verification | Sync |
| **Coder on completion** | `@full` (trigger CI) | Complete acceptance | **Async** (doesn't block dev) |
| **Test Owner Phase 2** | **No run** (audit evidence) | Independent verification | N/A |

### Async vs Sync Boundary (Critical!)

```
✅ Async: Dev iteration (Coder can start next change after completion, no waiting for @full)
❌ Sync: Archive gate (Archive must wait for @full to pass)

Timeline example:
T1: Coder completes implementation, triggers @full async test → Status = Implementation Done
T2: Coder can start next change (not blocked)
T3: @full tests pass → Status = Ready for Phase 2
T4: Test Owner audits evidence + checks off → Status = Verified
T5: Code Review → Status = Done
T6: Archive (at this point @full has definitely passed)
```

---

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
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
| `Implementation Done` | Implementation complete, waiting for @full tests | **Coder** |
| `Verified` | @full passed + evidence audit complete | **Test Owner** |
| `Done` | Review passed | Reviewer (Test Owner/Coder prohibited) |
| `Archived` | Archived | Archiver |

**Key Constraints**:
- `Verified` status requires @full tests to have passed
- Only changes with `Verified` or `Done` status can be archived
- Test Owner sets `Ready` after completing test plan, sets `Verified` after evidence audit

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
# Dev-Playbooks default path
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

1) First read and follow: `~/.claude/skills/_shared/references/universal-gating-protocol.md` (Verifiability + Structural Quality Gates).
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

### Phase Awareness (Critical!)

Test Owner has two phases, completion status varies by phase:

| Current Phase | How to Determine | Next Step After Completion |
|---------------|------------------|---------------------------|
| **Phase 1** | verification.md doesn't exist or Red baseline not produced | → `[CODER]` mode |
| **Phase 2** | User says "verify/check off" and @full tests have passed | → Code Review |

### Phase 1 Completion Status Classification (MECE)

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | PHASE1_COMPLETED | Red baseline produced, no deviations | Switch to `[CODER]` mode |
| ⚠️ | PHASE1_COMPLETED_WITH_DEVIATION | Red baseline produced, deviation-log has pending records | `devbooks-design-backport` |
| ❌ | BLOCKED | Needs external input/decision | Record breakpoint, wait for user |
| 💥 | FAILED | Test framework issues etc. | Fix and retry |

### Phase 2 Completion Status Classification (MECE)

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | PHASE2_VERIFIED | Evidence audit passed, AC matrix checked | `devbooks-code-review` |
| ⏳ | PHASE2_WAITING | @full tests still running | Wait for CI to complete |
| ❌ | PHASE2_FAILED | @full tests not passing | Notify Coder to fix |
| 🔄 | PHASE2_HANDOFF | Found issues with tests themselves | Fix tests then re-verify |

### Phase Determination Flow

```
1. Check which phase we're in:
   - verification.md doesn't exist → Phase 1
   - verification.md exists but AC matrix all [ ] → Phase 1 or Phase 2 (depends on user request)
   - User explicitly says "verify/check off/Coder is done" → Phase 2

2. Phase 1 status determination:
   a. Check if deviation-log.md has "| ❌" records
      → Yes: PHASE1_COMPLETED_WITH_DEVIATION
   b. Check if Red baseline is produced
      → No: BLOCKED or FAILED
   c. All above pass → PHASE1_COMPLETED

3. Phase 2 status determination:
   a. Check if @full tests have completed
      → No: PHASE2_WAITING
   b. Check if @full tests passed
      → No: PHASE2_FAILED
   c. Check if tests themselves have issues
      → Yes: PHASE2_HANDOFF
   d. Audit evidence, confirm coverage → PHASE2_VERIFIED
```

### Routing Output Template (Required)

After completing test-owner, **must** output in this format:

```markdown
## Completion Status

**Phase**: Phase 1 (Red Baseline) / Phase 2 (Green Verification)

**Status**: ✅ PHASE1_COMPLETED / ✅ PHASE2_VERIFIED / ⏳ PHASE2_WAITING / ...

**Red Baseline**: Produced / Not completed (Phase 1 only)

**@full Tests**: Passed / Running / Failed (Phase 2 only)

**Evidence Audit**: Completed / Pending (Phase 2 only)

**AC Matrix**: Checked N/M / Not checked (Phase 2 only)

**Deviation Records**: Has N pending / None

## Next Step

**Recommended**: Switch to `[CODER]` mode / `devbooks-xxx skill`

**Reason**: [specific reason]
```

### Specific Routing Rules

| My Status | Next Step | Reason |
|-----------|-----------|--------|
| PHASE1_COMPLETED | Switch to `[CODER]` mode | Red baseline produced, Coder implements to make Green |
| PHASE1_COMPLETED_WITH_DEVIATION | `devbooks-design-backport` | Backport design first, then hand to Coder |
| PHASE2_VERIFIED | `devbooks-code-review` | Evidence audit passed, can proceed to code review |
| PHASE2_WAITING | Wait for CI | @full tests still running |
| PHASE2_FAILED | Notify Coder to fix | Tests not passing, need Coder to fix |
| PHASE2_HANDOFF | Fix tests | Tests themselves have issues, Test Owner fixes |
| BLOCKED | Wait for user | Record breakpoint area |
| FAILED | Fix and retry | Analyze failure reason |

**Critical Constraints**:
- **Mode switching replaces session isolation**: Use `[TEST-OWNER]` / `[CODER]` labels to switch modes
- If deviations exist, must design-backport first before handing to Coder
- **Phase 2 AC matrix checking can only be done by Test Owner**
- **Phase 2 can only check off after @full tests have passed**

---

## MCP Enhancement

This Skill does not depend on MCP services, no runtime detection required.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

