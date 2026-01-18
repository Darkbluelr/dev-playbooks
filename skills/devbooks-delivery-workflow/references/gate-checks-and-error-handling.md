# Gate Checks and Error Handling

## Phase Gates

| Checkpoint | Timing | Command |
|------------|--------|---------|
| Proposal complete | After Phase 3 | `change-check.sh <change-id> --mode proposal` |
| Design complete | After Phase 6 | `change-check.sh <change-id> --mode apply --role test-owner` |
| Implementation complete | After Phase 10 | `change-check.sh <change-id> --mode apply --role coder` |
| Pre-archive | Before Phase 12 | `change-check.sh <change-id> --mode strict` |

## Pre-Archive Mandatory Checks

Archiver subagent must verify:

| Check Item | Requirement |
|------------|-------------|
| evidence/green-final/ | Exists and non-empty |
| verification.md AC coverage | 100% (all ACs have corresponding tests) |
| tasks.md task completion rate | 100% (all [x] or SKIP-APPROVED) |
| change-check.sh --mode strict | All pass |

## Error Handling

### Judge Returns REVISE

```
Phase 3 returns REVISE
    ↓
Notify user of judgment
    ↓
Return to Phase 1, carry modification suggestions
    ↓
Re-execute Phases 1-3
```

### Review Returns REVISE REQUIRED

```
Phase 9 (Test-Review) returns REVISE REQUIRED
    ↓
Return to Phase 7, fix test issues
    ↓
Re-execute Phases 7-9

Phase 10 (Code-Review) returns REVISE REQUIRED
    ↓
Return to Phase 8, fix code issues
    ↓
Re-execute Phases 8-10
```

### Archive Check Fails

```
Phase 12 check fails
    ↓
Output failure reason (missing evidence / AC not covered / tasks incomplete)
    ↓
Return to corresponding phase to fix
    ↓
Re-execute to Phase 12
```

## Rollback Execution Flow

```
Test-Review REVISE REQUIRED:
    → Return to Phase 7 (Test-Red)
    → Fix test issues
    → Re-execute Phases 7-9
    → Loop until Test-Review passes

Code-Review REVISE REQUIRED:
    → Return to Phase 8 (Code)
    → Fix code issues
    → Re-execute Phases 8-10
    → Loop until Code-Review passes
```
