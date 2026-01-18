# Test Execution Strategy

## Test Layering Labels

| Label | Purpose | When Coder Runs | Expected Time |
|-------|---------|-----------------|---------------|
| `@smoke` | Fast feedback, core paths | After each code change | Seconds |
| `@critical` | Key functionality verification | Before commit | Minutes |
| `@full` | Complete acceptance tests | **Doesn't run**, triggers CI async | Can be slow |

## Coder's Test Run Strategy

```bash
# During development: frequently run @smoke
npm test -- --grep "@smoke"

# Before commit: run @critical
npm test -- --grep "@smoke|@critical"

# After commit: CI automatically runs @full (Coder doesn't wait)
git push  # Trigger CI
# → Coder can start next task
```

## Async vs Sync Boundary

| Action | Blocking/Async | Description |
|--------|----------------|-------------|
| `@smoke` tests | Sync | Run immediately after each change |
| `@critical` tests | Sync | Must pass before commit |
| `@full` tests | **Async** | CI runs in background, doesn't block Coder |
| Start next change | **Not blocked** | Coder can start immediately |
| Archive | **Blocking** | Must wait for @full to pass |

## Core Principle

> **Key**: Coder only runs fast-track tests, @full tests triggered async, doesn't block dev iteration.

### Workflow After Coder Completion

1. **Fast-track tests green**: `@smoke` + `@critical` pass
2. **Trigger @full**: Commit code, CI starts async @full tests
3. **Status change**: Set change status to `Implementation Done`
4. **Can start nextge** (not blocked)
5. **Wait for @full result**:
   - @full passes → Test Owner enters Phase 2 to audit evidence
   - @full fails → Coder fixes

**Key Reminder**:
- After Coder completion, status is `Implementation Done`, **not directly into Code Review**
- Dev iteration is async (can start next change), but archive is sync (must wait for @full to pass)
