---
name: devbooks-convergence-audit
description: devbooks-convergence-audit: Evaluates DevBooks workflow convergence using "evidence first, distrust declarations" principle, detects "Sisyphus anti-patterns" and "fake completion". Actively verifies rather than trusting document claims. Use when user says "evaluate convergence/check upgrade health/Sisyphus detection/workflow audit" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash
---

# DevBooks: Convergence Audit

## Core Principle: Anti-Deception Design

> **Golden Rule**: **Evidence > Declarations**. Never trust any assertions in documents; must confirm through verifiable evidence.

### Scenarios Where AI Gets Deceived (Must Prevent)

| Deception Scenario | AI Wrong Behavior | Correct Behavior |
|--------------------|-------------------|------------------|
| Document says `Status: Done` | Believes it's complete | Verify: Are tests actually all green? Does evidence exist? |
| AC matrix all `[x]` | Believes full coverage | Verify: Does test file for each AC exist and pass? |
| Document says "tests passed" | Believes passed | Verify: Actually run tests or check CI log timestamps |
| `evidence/` directory exists | Believes evidence exists | Verify: Is directory non-empty? Is content valid test logs? |
| tasks.md all `[x]` | Believes implemented | Verify: Do corresponding code files exist with substance? |
| Commit message says "fixed" | Believes fixed | Verify: Did related tests change from red to green? |

### Three Anti-Deception Principles

```
1. Distrust Declarations
   - Any "complete/passed/covered" claims in documents are hypotheses to verify
   - Default stance: Claims may be wrong, outdated, or optimistic

2. Evidence First
   - Code/test results are the only truth
   - Log timestamps must be later than last code modification
   - Empty directory/file = no evidence

3. Cross Validation
   - Declaration vs evidence: Check consistency
   - Code vs tests: Check if they match
   - Multiple documents: Check for contradictions
```

---

## Verification Checklist (Execute Each)

### Check 1: Status Field Truthfulness Verification

**Document Claim**: `verification.md` contains `Status: Done` or `Status: Verified`

**Verification Steps**:
```bash
# 1. Check if verification.md exists
[[ -f "verification.md" ]] || echo "❌ verification.md does not exist"

# 2. Check if evidence/green-final/ has content
if [[ -z "$(ls -A evidence/green-final/ 2>/dev/null)" ]]; then
  echo "❌ Status claims complete, but evidence/green-final/ is empty"
fi

# 3. Check if evidence timestamp is later than last code modification
code_mtime=$(stat -f %m src/ 2>/dev/null || stat -c %Y src/)
evidence_mtime=$(stat -f %m evidence/green-final/* 2>/dev/null | sort -n | tail -1)
if [[ $evidence_mtime -lt $code_mtime ]]; then
  echo "❌ Evidence time is earlier than code modification, evidence may be stale"
fi
```

**Deception Detection**:
- ⚠️ Status=Done but evidence/ empty → **Fake Completion**
- ⚠️ Status=Done but evidence timestamp too old → **Stale Evidence**
- ⚠️ Status=Done but tests actually fail → **False Status**

---

### Check 2: AC Coverage Matrix Truthfulness Verification

**Document Claim**: `[x]` in AC matrix means covered

**Verification Steps**:
```bash
# 1. Extract all ACs claimed as covered
grep -E '^\| AC-[0-9]+.*\[x\]' verification.md | while read line; do
  ac_id=$(echo "$line" | grep -oE 'AC-[0-9]+')
  test_id=$(echo "$line" | grep -oE 'T-[0-9]+')

  # 2. Verify corresponding test exists
  if ! grep -rq "$test_id\|$ac_id" tests/; then
    echo "❌ $ac_id claims covered, but no corresponding test found"
  fi
done

# 3. Actually run tests to verify (most reliable)
npm test 2>&1 | tee /tmp/test-output.log
if grep -q "FAIL\|Error\|failed" /tmp/test-output.log; then
  echo "❌ ACs claim full coverage, but tests actually have failures"
fi
```

**Deception Detection**:
- ⚠️ AC checked but corresponding test file doesn't exist → **False Coverage**
- ⚠️ AC checked but test actually fails → **Fake Green**
- ⚠️ AC checked but test content is empty/placeholder → **Placeholder Test**

---

### Check 3: tasks.md Completion Truthfulness Verification

**Document Claim**: `[x]` in tasks.md means completed

**Verification Steps**:
```bash
# 1. Extract all tasks claimed as complete
grep -E '^\- \[x\]' tasks.md | while read line; do
  # 2. Extract keywords from task description (function name/file name/feature)
  keywords=$(echo "$line" | grep -oE '[A-Za-z]+[A-Za-z0-9]*' | head -5)

  # 3. Verify code has corresponding implementation
  for kw in $keywords; do
    if ! grep -rq "$kw" src/; then
      echo "⚠️ Task claims complete, but keyword not found in code: $kw"
    fi
  done
done

# 4. Check for "skeleton code" (only function signatures without implementation)
grep -rE 'throw new Error\(.*not implemented|TODO|FIXME|pass$|\.\.\.}' src/ && \
  echo "⚠️ Found unimplemented placeholder code"
```

**Deception Detection**:
- ⚠️ Task checked but code doesn't exist → **False Completion**
- ⚠️ Task checked but code is placeholder → **Skeleton Code**
- ⚠️ Task checked but feature not callable → **Dead Code**

---

### Check 4: Evidence Validity Verification

**Document Claim**: `evidence/` directory contains test evidence

**Verification Steps**:
```bash
# 1. Check if directory exists and is non-empty
if [[ ! -d "evidence" ]] || [[ -z "$(ls -A evidence/)" ]]; then
  echo "❌ evidence/ does not exist or is empty"
  exit 1
fi

# 2. Check if evidence files have substantial content
for f in evidence/**/*; do
  if [[ -f "$f" ]]; then
    lines=$(wc -l < "$f")
    if [[ $lines -lt 5 ]]; then
      echo "⚠️ Evidence file has too little content: $f ($lines lines)"
    fi

    # 3. Check if it's a valid test log (contains test framework output characteristics)
    if ! grep -qE 'PASS|FAIL|✓|✗|passed|failed|test|spec' "$f"; then
      echo "⚠️ Evidence file doesn't look like test log: $f"
    fi
  fi
done

# 4. Check if red-baseline evidence really is red (has failures)
if [[ -d "evidence/red-baseline" ]]; then
  if ! grep -rqE 'FAIL|Error|✗|failed' evidence/red-baseline/; then
    echo "❌ red-baseline claims to be red, but no failure records"
  fi
fi

# 5. Check if green-final evidence really is green (all pass)
if [[ -d "evidence/green-final" ]]; then
  if grep -rqE 'FAIL|Error|✗|failed' evidence/green-final/; then
    echo "❌ green-final claims to be green, but contains failure records"
  fi
fi
```

**Deception Detection**:
- ⚠️ evidence/ exists but content is empty → **Empty Evidence**
- ⚠️ Evidence file too small (< 5 lines) → **Placeholder Evidence**
- ⚠️ red-baseline has no failure records → **Fake Red**
- ⚠️ green-final contains failure records → **Fake Green**

---

### Check 5: Git History Cross Validation

**Principle**: Git history doesn't lie; use it to verify document claims

**Verification Steps**:
```bash
# 1. Check if claimed-complete change has corresponding code commits
change_id="xxx"
commits=$(git log --oneline --all --grep="$change_id" | wc -l)
if [[ $commits -eq 0 ]]; then
  echo "❌ Change $change_id claims complete, but no related commits in git history"
fi

# 2. Check if test files were added after code (TDD violation detection)
for test_file in tests/**/*.test.*; do
  test_added=$(git log --format=%at --follow -- "$test_file" | tail -1)
  # Find corresponding source file
  src_file=$(echo "$test_file" | sed 's/tests/src/' | sed 's/.test//')
  if [[ -f "$src_file" ]]; then
    src_added=$(git log --format=%at --follow -- "$src_file" | tail -1)
    if [[ $test_added -gt $src_added ]]; then
      echo "⚠️ Test added after code (non-TDD): $test_file"
    fi
  fi
done

# 3. Check for "one-time big commits" (may be bypassing process)
git log --oneline -20 | while read line; do
  commit=$(echo "$line" | cut -d' ' -f1)
  files_changed=$(git show --stat "$commit" | grep -E '[0-9]+ file' | grep -oE '[0-9]+' | head -1)
  if [[ $files_changed -gt 20 ]]; then
    echo "⚠️ Big commit detected: $commit modified $files_changed files, may bypass incremental verification"
  fi
done
```

**Deception Detection**:
- ⚠️ Claims complete but no git commits → **Fake Change**
- ⚠️ Tests added after code → **Retroactive Testing**
- ⚠️ Many files in one commit → **Bypassing Incremental Verification**

---

### Check 6: Live Test Run Verification (Most Reliable)

**Principle**: Don't trust any logs; actually run tests

**Verification Steps**:
```bash
# 1. Run full tests
echo "=== Live Test Verification ==="
npm test 2>&1 | tee /tmp/live-test.log

# 2. Check results
if grep -qE 'FAIL|Error|failed' /tmp/live-test.log; then
  echo "❌ Live tests failed, document claims not trustworthy"
  grep -E 'FAIL|Error|failed' /tmp/live-test.log
else
  echo "✅ Live tests passed"
fi

# 3. Compare live results with evidence files
if [[ -f "evidence/green-final/latest.log" ]]; then
  live_pass=$(grep -c 'PASS\|✓\|passed' /tmp/live-test.log)
  evidence_pass=$(grep -c 'PASS\|✓\|passed' evidence/green-final/latest.log)
  if [[ $live_pass -ne $evidence_pass ]]; then
    echo "⚠️ Live pass count ($live_pass) ≠ evidence pass count ($evidence_pass)"
  fi
fi
```

**Deception Detection**:
- ⚠️ Evidence says green but live run fails → **Stale Evidence/Fake Green**
- ⚠️ Live pass count differs from evidence → **Evidence Fabrication/Environment Difference**

---

## Composite Scoring Algorithm

### Trustworthiness Score (0-100)

```python
def calculate_trustworthiness(checks):
    score = 100

    # Critical issues (each -20 points)
    critical = [
        "Evidence empty",
        "Live tests failed",
        "Status claims complete but tests fail",
        "green-final contains failure records"
    ]

    # Warning issues (each -10 points)
    warnings = [
        "Evidence timestamp too old",
        "AC corresponding test doesn't exist",
        "Placeholder code",
        "Big commit detected"
    ]

    # Minor issues (each -5 points)
    minor = [
        "Tests added after code",
        "Evidence file too small"
    ]

    for issue in checks.critical_issues:
        score -= 20
    for issue in checks.warnings:
        score -= 10
    for issue in checks.minor_issues:
        score -= 5

    return max(0, score)
```

### Convergence Determination

| Trustworthiness | Determination | Recommendation |
|-----------------|---------------|----------------|
| 90-100 | ✅ Trustworthy Convergence | Continue current process |
| 70-89 | ⚠️ Partially Trustworthy | Need supplementary verification |
| 50-69 | 🟠 Questionable | Need to rework some steps |
| < 50 | 🔴 Untrustworthy | Sisyphus trap, need comprehensive review |

---

## Output Format

```markdown
# DevBooks Convergence Audit Report (Anti-Deception Edition)

## Audit Principle
This report uses "evidence first, distrust declarations" principle. All conclusions are based on verifiable evidence, not document claims.

## Declaration vs Evidence Comparison

| Check Item | Document Claim | Actual Verification | Conclusion |
|------------|----------------|---------------------|------------|
| Status | Done | Tests actually fail | ❌ Fake Completion |
| AC Coverage | 5/5 checked | 2 ACs have no corresponding tests | ❌ False Coverage |
| Test Status | All green | Live run 3 failures | ❌ Stale Evidence |
| tasks.md | 10/10 complete | 3 tasks have no code | ❌ False Completion |
| evidence/ | Exists | Non-empty, content valid | ✅ Valid |

## Trustworthiness Score

**Total Score**: 45/100 🔴 Untrustworthy

**Deduction Details**:
- -20: Status=Done but live tests fail
- -20: ACs claim full coverage but 2 have no tests
- -10: tasks.md 3 tasks have no code
- -5: Evidence timestamp earlier than code modification

## Deception Detection Results

### 🔴 Detected Fake Completions
1. `change-auth`: Status=Done, but `npm test` fails 3
2. `fix-cache`: AC-003 checked, but `tests/cache.test.ts` doesn't exist

### 🟡 Suspicious Items
1. `refactor-api`: evidence/green-final/ timestamp 2 days earlier than last code commit
2. `feature-login`: tasks.md all checked, but `src/login.ts` contains TODO

## True Status Determination

| Change Package | Claimed Status | True Status | Gap |
|----------------|----------------|-------------|-----|
| change-auth | Done | Tests failing | 🔴 Severe |
| fix-cache | Verified | Coverage incomplete | 🟠 Medium |
| refactor-api | Ready | Evidence stale | 🟡 Minor |

## Recommended Actions

### Immediate Action
1. Revert `change-auth` status to `In Progress`
2. Add tests for `fix-cache` AC-003

### Short-term Improvement
1. Establish evidence timeliness check (evidence must be later than code)
2. Force run corresponding tests before AC check-off

### Process Improvement
1. Prohibit manual Status modification; only allow auto-update after script verification
2. Integrate convergence check in CI, block fake completion from merging
```

---

## Completion Status

**Status**: ✅ AUDIT_COMPLETED

**Core Findings**:
- Document claim trustworthiness: X%
- Detected fake completions: N
- Changes needing rework: M

**Next Step**:
- Fake completion → Immediately revert status, re-verify
- Suspicious items → Supplement evidence or re-run tests
- Trustworthy items → Continue current process
