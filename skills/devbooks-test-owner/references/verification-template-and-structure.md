# verification.md Enhanced Template

Test Owner must produce a structured `verification.md` that serves as both test plan and traceability document.

## Status Field Permissions

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

## Complete Template

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

## Manual Vern Checklist

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

## Required Test Layering Information in verification.md

```markdown
## Test Layering Strategy

| Type | Count | Covered Scenarios | Expected Execution Time |
|------|-------|-------------------|------------------------|
| Unit Tests | X | AC-001, AC-002 | < Ys |ion Tests | Y | AC-003 | < Zs |
| E2E Tests | Z | Critical paths | < Ws |

## Test Environment Requirements

| Test Type | Runtime Environment | Dependencies |
|-----------|---------------------|--------------|
| Unit Tests | Node.js | No external dependencies |
| Integration Tests | Node.js + Test Database | Docker |
| E2E Tests | Browser (Playwright) | Full application |
```
