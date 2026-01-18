# Test Layering and Execution Strategy

> **Core Principle**: Test layering is key to solving "slow tests blocking development".

## Test Layering Labels (Must Use)

| Label | Purpose | Who Runs | Expected Time | When to Run |
|-------|---------|----------|---------------|-------------|
| `@smoke` | Fast feedback, core paths | Coder runs frequently | Seconds | After each code change |
| `@critical` | Key functionality verification | Coder before commit | Minutes | Before commit |
| `@full` | Complete acceptance tests | CI runs async | Can be slow (hours) | Background/CI |

## Test Run Strategy by Phase

| Phase | What to Run | Purpose | Blocking/Async |
|-------|-------------|---------|----------------|
| **Test Owner Phase 1** | Only **newly written tests** | Confirm Red status | Sync (but incremental only) |
| **Coder during dev** | `@smoke` | Fast feedback loop | Sync |
| **Coder before commit** | `@critical` | Key path verification | Sync |
| **Coder on completion** | `@full` (trigger CI) | Complete acceptance | **Async** (doesn't block dev) |
| **Test Owner Phase 2** | **No run** (audit evidence) | Independent verification | N/A |

## Async vs Sync Boundary (Critical!)

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

## Test Types and Naming Conventions

| Test Type | File Naming | Directory Location | Expected Execution Time |
|-----------|-------------|-------------------|------------------------|
| Unit Tests | `*.test.ts` / `*.test.js` | `src/**/test/` or `tests/unit/` | < 5s/file |
| Integration Tests | `*.integrationTest.ts` | `tests/integration/` | < 30s/file |
| E2E Tests | `*.e2e.ts` / `*.spec.ts` | `tests/e2e/` | < 60s/file |
| Contract Tests | `*.contract.ts` | `tests/contract/` | < 10s/file |
| Smoke Tests | `*.smoke.ts` | `tests/smoke/` | Variable |

## Test Pyramid Ratio Recommendations

```
        /\
       /E2E\        ≈ 10% (Critical user paths)
      /─────\
     /Integration\  ≈ 20% (Module boundaries)
    /─────────────\
   /  Unit Tests   \ ≈ 70% (Business logic)
  /─────────────────\
```

## Test Priority

| Priority | Definition | Red Baseline Requirement |
|----------|------------|--------------------------|
| P0 | Blocks release, core functionality | MUST fail in Red baseline |
| P1 | Important, should be covered | Should fail in Red baseline |
| P2 | Nice to have, can be added later | Optional in Red baseline |
