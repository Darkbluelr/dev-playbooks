# Convergence Audit Rules

## Core Principle: Anti-Confusion Design

> Golden Rule: Evidence > Declaration. Never trust assertions in documents; they must be confirmed by verifiable evidence.

### Scenes Where AI is Easily Confused (Must Prevent)

| Confusing Scene | AI Incorrect Behavior | Correct Behavior |
|-----------------|-----------------------|------------------|
| Doc says `Status: Done` | Believes it is done | Verify: Are tests really all green? Does evidence exist? |
| AC matrix all `[x]` | Believes full coverage | Verify: Does the test file for each AC exist and pass? |
| Doc says "Tests Passed" | Believes passed | Verify: Run actual tests or check CI log timestamps |
| `evidence/` dir exists | Believes evidence exists | Verify: Is dir non-empty? Is content valid test logs? |
| tasks.md all `[x]` | Believes implemented | Verify: Do corresponding code files exist with substance? |
| Commit msg "Fixed" | Believes fixed | Verify: Did relevant tests turn from red to green? |

### Anti-Confusion Three Principles

```
1. Distrust Declarations
   - Any "Done/Passed/Covered" declaration in docs is a hypothesis to be verified
   - Default stance: Declarations might be wrong, outdated, or optimistic

2. Evidence First
   - Code/Test results are the only truth
   - Log timestamps must be later than the last code modification
   - Empty dir/file = No evidence

3. Cross Validation
   - Declaration vs Evidence: Check for consistency
   - Code vs Test: Check for matching
   - Multiple Docs: Check for contradictions
```

--- 

## Verification Checklists (Execute Item by Item)

### Check 1: Status Field Truth Verification

Doc Declaration: `Status: Done` or `Status: Archived` in `verification.md`

Verification Steps:
```bash
# 1. Check if verification.md exists
[[ -f "verification.md" ]] || echo "❌ verification.md does not exist"

# 2. Check if evidence/green-final/ has content
if [[ -z "$(ls -A evidence/green-final/ 2>/dev/null)" ]]; then
  echo "❌ Status claims Done, but evidence/green-final/ is empty"
fi

# 3. Check if evidence timestamp is later than code last modified
code_mtime=$(stat -f %m src/ 2>/dev/null || stat -c %Y src/)
evidence_mtime=$(stat -f %m evidence/green-final/* 2>/dev/null | sort -n | tail -1)
if [[ $evidence_mtime -lt $code_mtime ]]; then
  echo "❌ Evidence time is earlier than code mod, evidence might be stale"
fi
```

Confusion Detection:
- ⚠️ Status=Done but evidence/ empty → Fake Completion
- ⚠️ Status=Done but evidence stale → Stale Evidence
- ⚠️ Status=Done but tests actually fail → False Status

--- 

### Check 2: AC Coverage Matrix Truth Verification

Doc Declaration: `[x]` in AC matrix means covered

Verification Steps:
```bash
# 1. Extract all ACs claimed to be covered
grep -E '^\| AC-[0-9]+.*[x]' verification.md | while read line; do
  ac_id=$(echo "$line" | grep -oE 'AC-[0-9]+')
  test_id=$(echo "$line" | grep -oE 'T-[0-9]+')

  # 2. Verify corresponding test exists
  if ! grep -rq "$test_id\|$ac_id" tests/; then
    echo "❌ $ac_id claimed covered, but test not found"
  fi
done

# 3. Actual test run verification (Most reliable)
npm test 2>&1 | tee /tmp/test-output.log
if grep -q "FAIL\|Error\|failed" /tmp/test-output.log; then
  echo "❌ AC claimed full coverage, but tests actually failed"
fi
```

Confusion Detection:
- ⚠️ AC checked but test file missing → Fake Coverage
- ⚠️ AC checked but test failed → False Green
- ⚠️ AC checked but test content empty → Placeholder Test

--- 

### Check 3: tasks.md Completion Truth Verification

Doc Declaration: `[x]` in tasks.md means completed

Verification Steps:
```bash
# 1. Extract all claimed completed tasks
grep -E '^\- \[x\]' tasks.md | while read line; do
  # 2. Extract keywords from task description (func name/file/feature)
  keywords=$(echo "$line" | grep -oE '[A-Za-z]+[A-Za-z0-9]*' | head -5)

  # 3. Verify implementation in code
  for kw in $keywords; do
    if ! grep -rq "$kw" src/; then
      echo "⚠️ Task claimed done, but keyword not found in code: $kw"
    fi
  done
done

# 4. Check for "Skeleton Code" (signature only, no impl)
grep -rE 'throw new Error(.*not implemented|TODO|FIXME|pass$|\.\.\.}' src/ && \
  echo "⚠️ Found unimplemented placeholder code"
```

Confusion Detection:
- ⚠️ Task checked but code missing → Fake Completion
- ⚠️ Task checked but placeholder code → Skeleton Code
- ⚠️ Task checked but feature unreachable → Dead Code

--- 

### Check 4: Evidence Validity Verification

Doc Declaration: `evidence/` dir contains test evidence

Verification Steps:
```bash
# 1. Check dir exists and non-empty
if [[ ! -d "evidence" ]] || [[ -z "$(ls -A evidence/)" ]]; then
  echo "❌ evidence/ missing or empty"
  exit 1
fi

# 2. Check evidence file has substantial content
for f in evidence/**/*; do
  if [[ -f "$f" ]]; then
    lines=$(wc -l < "$f")
    if [[ $lines -lt 5 ]]; then
      echo "⚠️ Evidence file too small: $f ($lines lines)"
    fi

    # 3. Check if valid test log (contains test framework output traits)
    if ! grep -qE 'PASS|FAIL|✓|✗|passed|failed|test|spec' "$f"; then
      echo "⚠️ Evidence file does not look like test log: $f"
    fi
  fi
done

# 4. Check red-baseline evidence is truly red (has failures)
if [[ -d "evidence/red-baseline" ]]; then
  if ! grep -rqE 'FAIL|Error|✗|failed' evidence/red-baseline/; then
    echo "❌ red-baseline claims red, but no failures found"
  fi
fi

# 5. Check green-final evidence is truly green (all pass)
if [[ -d "evidence/green-final" ]]; then
  if grep -rqE 'FAIL|Error|✗|failed' evidence/green-final/; then
    echo "❌ green-final claims green, but contains failures"
  fi
fi
```

Confusion Detection:
- ⚠️ evidence/ exists but empty → Empty Evidence
- ⚠️ Evidence file too small (< 5 lines) → Placeholder Evidence
- ⚠️ red-baseline no failures → Fake Red
- ⚠️ green-final has failures → Fake Green

--- 

### Check 5: Git History Cross-Validation

Principle: Git history doesn't lie, use it to verify doc declarations

Verification Steps:
```bash
# 1. Check if claimed completed change has corresponding commits
change_id="xxx"
commits=$(git log --oneline --all --grep="$change_id" | wc -l)
if [[ $commits -eq 0 ]]; then
  echo "❌ Change $change_id claimed done, but no git commits found"
fi

# 2. Check if test files added after code (TDD violation)
for test_file in tests/**/*.test.*; do
  test_added=$(git log --format=%at --follow -- "$test_file" | tail -1)
  # Find corresponding src file
  src_file=$(echo "$test_file" | sed 's/tests/src/' | sed 's/.test//')
  if [[ -f "$src_file" ]]; then
    src_added=$(git log --format=%at --follow -- "$src_file" | tail -1)
    if [[ $test_added -gt $src_added ]]; then
      echo "⚠️ Test added after code (Non-TDD): $test_file"
    fi
  fi
done

# 3. Check for "One-time Big Commit" (Process bypass)
git log --oneline -20 | while read line; do
  commit=$(echo "$line" | cut -d' ' -f1)
  files_changed=$(git show --stat "$commit" | grep -E '[0-9]+ file' | grep -oE '[0-9]+' | head -1)
  if [[ $files_changed -gt 20 ]]; then
    echo "⚠️ Big commit detected: $commit changed $files_changed files, possibly bypassing incremental verification"
  fi
done
```

Confusion Detection:
- ⚠️ Claimed done but no git commit → Fake Change
- ⚠️ Test added after code → Post-hoc Testing
- ⚠️ Large file batch commit → Bypass Incremental Verification

--- 

### Check 6: Live Test Run Verification (Most Reliable)

Principle: Distrust logs, run actual tests

Verification Steps:
```bash
# 1. Run full tests
echo "=== Live Test Verification ==="
npm test 2>&1 | tee /tmp/live-test.log

# 2. Check results
if grep -qE 'FAIL|Error|failed' /tmp/live-test.log; then
  echo "❌ Live test failed, doc declaration untrustworthy"
  grep -E 'FAIL|Error|failed' /tmp/live-test.log
else
  echo "✅ Live test passed"
fi

# 3. Compare live results with evidence file
if [[ -f "evidence/green-final/latest.log" ]]; then
  live_pass=$(grep -c 'PASS|✓|passed' /tmp/live-test.log)
  evidence_pass=$(grep -c 'PASS|✓|passed' evidence/green-final/latest.log)
  if [[ $live_pass -ne $evidence_pass ]]; then
    echo "⚠️ Live pass count ($live_pass) ≠ Evidence pass count ($evidence_pass)"
  fi
fi
```

Confusion Detection:
- ⚠️ Evidence says green but live run fails → Stale Evidence/Fake Green
- ⚠️ Live pass count mismatch → Evidence Forgery/Env Diff

--- 

## Scoring Algorithm

### Trustworthiness Score (0-100)

```python
def calculate_trustworthiness(checks):
    score = 100

    # Critical Issues (-20 each)
    critical = [
        "Evidence empty",
        "Live test failed",
        "Status claims Done but test failed",
        "green-final contains failures"
    ]

    # Warnings (-10 each)
    warnings = [
        "Evidence stale",
        "AC missing test",
        "Placeholder code",
        "Big commit detected"
    ]

    # Minor Issues (-5 each)
    minor = [
        "Test added after code",
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

### Convergence Verdict

| Trustworthiness | Verdict | Recommendation |
|-----------------|---------|----------------|
| 90-100 | ✅ Trusted Converged | Continue process |
| 70-89 | ⚠️ Partially Trusted | Need supplementary verification |
| 50-69 | 🟠 Suspicious | Need rework on some parts |
| < 50 | 🔴 Untrusted | Sisyphus dilemma, needs full audit |

--- 

## Output Format

```markdown
# DevBooks Convergence Audit Report (Anti-Confusion Ed.)

## Audit Principles
Report adopts "Evidence First, Distrust Declarations" principle. All conclusions based on verifiable evidence, not doc assertions.

## Declaration vs Evidence Comparison

| Check Item | Doc Declaration | Actual Verification | Conclusion |
|------------|-----------------|---------------------|------------|
| Status | Done | Live test failed | ❌ Fake Completion |
| AC Coverage | 5/5 Checked | 2 ACs missing tests | ❌ Fake Coverage |
| Test Status | All Green | Live run 3 failed | ❌ Stale Evidence |
| tasks.md | 10/10 Done | 3 tasks code missing | ❌ Fake Completion |
| evidence/ | Exists | Dir non-empty, valid | ✅ Valid |

## Trustworthiness Score

**Total**: 45/100 🔴 Untrusted

**Deduction Detail**:
- -20: Status=Done but live test failed
- -20: AC claims full coverage but 2 missing tests
- -10: tasks.md 3 tasks missing code
- -5: Evidence timestamp earlier than code mod

## Confusion Detection Results

### 🔴 Detected Fake Completion
1. `change-auth`: Status=Done, but `npm test` failed 3
2. `fix-cache`: AC-003 Checked, but `tests/cache.test.ts` missing

### 🟡 Suspicious Items
1. `refactor-api`: evidence/green-final/ timestamp 2 days older than code
2. `feature-login`: tasks.md all checked, but `src/login.ts` contains TODO

## Real Status Verdict

| Change Pkg | Declared Status | Real Status | Gap |
|------------|-----------------|-------------|-----|
| change-auth | Done | Test Failed | 🔴 Critical |
| fix-cache | Done | Incomplete Coverage | 🟠 Medium |
| refactor-api | Ready | Stale Evidence | 🟡 Minor |

## Recommended Actions

### Immediate Actions
1. Revert `change-auth` status to `In Progress`
2. Add tests for `fix-cache` AC-003

### Short-term Improvements
1. Establish evidence freshness check (Evidence must be newer than code)
2. Force run corresponding tests before checking AC

### Process Improvements
1. Ban manual Status modification; only update via script verification
2. CI integrate convergence check to block fake completion merge
```

--- 

## Completion Status

**Status**: ✅ AUDIT_COMPLETED

**Core Findings**:
- Doc Trustworthiness: X%
- Detected Fake Completions: N
- Changes needing rework: M

**Next Steps**:
- Fake Completion → Immediate status revert, re-verify
- Suspicious → Supplement evidence or re-run tests
- Trusted → Continue process
```
