# Verification Document Template

> This template defines the standard structure for verification.md to ensure acceptance is clear, testable, and traceable.

## File Location

```
<change-root>/<change-id>/verification.md
```

## Standard Structure

```markdown
# <Change Title> - Verification Document

## 🎯 Bottom Line Up Front (30-second read)

**This verification will result in**:
- ✅ Run [X] test cases
- ✅ Verify accuracy >[X]%
- ✅ Verify performance <[X] seconds

**This verification will NOT result in**:
- ❌ Won't modify code
- ❌ Won't affect functionality

**Acceptance criteria**:
- ✅ All tests pass
- ✅ Accuracy >[X]%
- ✅ Performance <[X] seconds

---

## ✅ Verification Approval (30 seconds)

**Test results**:
- ✅ Unit tests: [X]/[Y] passed
- ✅ Integration tests: [X]/[Y] passed
- ✅ Performance tests: Passed ([X] seconds)

**If you agree**:
- [ ] ✅ Verification passed, ready to archive

**If you disagree**:
- [ ] ❌ Verification failed (please explain reason)

**Default choice**: ✅ Verification passed (auto-approved after 12 hours)

---

## ✅ Approval Process (1 minute)

**Current status**:
- 📝 Status: Pending approval
- ⏰ Created at: [time]
- ⏰ Timeout at: [time] (after 12 hours)

**If you agree**:
- [ ] ✅ Approve verification, start archiving

**If you disagree**:
- [ ] ❌ Reject verification, reason: [reason]

**Default choice**: ✅ Approve verification (auto-approved after 12 hours)

---

## 📋 Detailed Verification (AI reading)

### Test Coverage

#### Unit Tests

| Test Case | Status | Description |
|-----------|--------|-------------|
| test_xxx_1 | ✅ Passed | [Description] |
| test_xxx_2 | ✅ Passed | [Description] |

**Coverage**: [X]%

---

#### Integration Tests

| Test Case | Status | Description |
|-----------|--------|-------------|
| test_integration_1 | ✅ Passed | [Description] |
| test_integration_2 | ✅ Passed | [Description] |

---

#### Performance Tests

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Response time | <[X]ms | [Y]ms | ✅ Passed |
| Throughput | >[X] QPS | [Y] QPS | ✅ Passed |
| Memory usage | <[X]MB | [Y]MB | ✅ Passed |

---

### Acceptance Criteria Traceability

#### AC-001: [Acceptance Criteria Title]

**Source**: design.md AC-001

**Acceptance conditions**:
- [x] [Condition 1] - Test case: test_xxx_1
- [x] [Condition 2] - Test case: test_xxx_2

**Verification result**: ✅ Passed

---

#### AC-002: [Acceptance Criteria Title]

**Source**: design.md AC-002

**Acceptance conditions**:
- [x] [Condition 1] - Test case: test_xxx_3
- [x] [Condition 2] - Test case: test_xxx_4

**Verification result**: ✅ Passed

---

### Regression Testing

#### Existing Functionality Verification

| Feature | Test Case | Status | Description |
|---------|-----------|--------|-------------|
| [Feature 1] | test_regression_1 | ✅ Passed | Not affected |
| [Feature 2] | test_regression_2 | ✅ Passed | Not affected |

---

### Documentation Verification

#### Documentation Update Check

- [x] README.md updated
- [x] User documentation updated
- [x] API documentation updated
- [x] CHANGELOG.md updated

---

## Approval History

| Time | Phase | Action | Actor | Reason |
|------|-------|--------|-------|--------|
| [Time] | Verification | Created | AI | - |
| [Time] | Verification | Approved | User | [Reason] |
```

## Usage Guide

### 1. Purpose of Bottom Line Up Front

- **30-second quick understanding**: Let users immediately know the core content of verification
- **Test results**: Clearly state test results
- **Reduce cognitive load**: Use plain language, avoid technical jargon

### 2. Purpose of Verification Approval

- **Quick decision**: Users only need to confirm "pass" or "fail"
- **Default approval**: Auto-approved after 12 hours (shorter than other phases)
- **Retain control**: Users can reject verification at any time

### 3. Purpose of Acceptance Criteria Traceability

- **Traceable**: Each acceptance criterion should correspond to an AC in Design
- **Verifiable**: Each acceptance condition should have a corresponding test case
- **Completeness check**: Ensure all ACs are verified

### 4. Purpose of Regression Testing

- **Prevent breakage**: Ensure existing functionality is not affected
- **Quality assurance**: Ensure changes don't introduce new issues

### 5. Purpose of Documentation Verification

- **Documentation sync**: Ensure documentation is in sync with code
- **User experience**: Ensure users can correctly use new features
