# Phase 2: Evidence Audit Checklist

> **Core Principle**: Test Owner Phase 2 responsibility is **auditing evidence**, not rerunning tests.

## Trigger Condition

When user says "Coder is done, please verify" or similar, Test Owner enters **Phase 2**.

## Prerequisite Checks

- [ ] `@full` tests have passed (check CI results or `evidence/green-final/`)
- [ ] `verification.md` exists and Status = `Ready` or `Implementation Done`
- [ ] AC coverage matrix is established

## Audit Steps (Default Mode)

### 1. Check Evidence Directory

```bash
# Check if green-final directory exists
ls -la <change-root>/<change-id>/evidence/green-final/

# Expected contents:
# - test-*.log (test logs)
# - coverage-*.html (coverage report, optional)
# - commit-hash.txt (code version)
```

### 2. Verify Commit Hash

```bash
# Read commit hash from evidence
cat <change-root>/<change-id>/evidence/green-final/commit-hash.txt

# Compare with current code version
git rev-parse HEAD

# Must match, otherwise evidence is stale
```

### 3. Audit Test Logs

Check `evidence/green-final/test-*.log`:

- [ ] All tests passed (no FAIL / ERROR)
- [ ] Test count matches AC coverage matrix in verification.md
- [ ] No skipped tests (SKIP)
- [ ] No flaky tests (inconsistent results across runs)

### 4. Verify AC Coverage

Cross-reference with verification.md AC coverage matrix:

- [ ] Every AC has corresponding test
- [ ] Test IDs match test names in logs
- [ ] All P0 tests ran and passed
- [ ] All P1 tests ran and passed

### 5. Optional Sampling Rerun

Sample verify high-risk ACs or questionable tests:

```bash
# Rerun specific test
npm test -- --grep "AC-001"

# Or rerun @critical tests
npm test -- --grep "@critical"
```

**When to sample rerun**:
- Evidence commit hash doesn't match current code
- Test logs show anomalies (timeouts, warnings)
- AC description doesn't match test name
- High-risk functionality (payments, permissions)

### 6. Check Off AC Coverage Matrix

In verification.md AC coverage matrix, change `[ ]` to `[x]`:

```markdown
| AC-ID | Description | Test Type | Test ID | Priority | Status |
|-------|-------------|-----------|---------|----------|--------|
| AC-001 | User login returns JWT | unit | T-001 | P0 | [x] |
| AC-002 | Wrong password returns 401 | unit | T-002 | P0 | [x] |
| AC-003 | Token expires after 24h | integration | T-003 | P1 | [x] |
```

### 7. Set Status to Verified

Update status at top of verification.md:

```markdown
**Status**: Verified
**Verified By**: Test Owner
**Verified At**: 2024-01-15 14:30
**Commit Hash**: abc123def456
```

## Completion Status Classification

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | PHASE2_VERIFIED | Evidence audit passed, AC matrix checked | `devbooks-reviewer` |
| ⏳ | PHASE2_WAITING | @full tests still running | Wait for CI to complete |
| ❌ | PHASE2_FAILED | @full tests not passing | Notify Coder to fix |
| 🔄 | PHASE2_HANDOFF | Found issues with tests themselves | Fix tests then re-verify |

## Output Management

Prevent large outputs from polluting context:

| Scenario | Handling |
|----------|----------|
| Test output > 50 lines | Keep only first and last 10 lines + failure summary |
| Green evidence logs | Write to `evidence/green-final/`, only reference path in dialogue |
| Large test case lists | Use table summary, do not paste item by item |

**Example**:
```
✅ Evidence audit passed, AC matrix checked (15/15)
   See evidence/green-final/test-2024-01-15.log
   Commit: abc123def456
   Coverage: 92%
```
