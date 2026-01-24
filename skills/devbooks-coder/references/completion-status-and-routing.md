# Completion Status and Routing

## Completion Status Classification (MECE)

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | IMPLEMENTATION_DONE | Fast-track tests green, @full triggered, no deviations | Hand off to Test Owner (separate conversation) for Phase 2 evidence audit |
| ⚠️ | IMPLEMENTATION_DONE_WITH_DEVIATION | Fast-track green, deviation-log has pending records | `devbooks-design-backport` |
| 🔄 | HANDOFF | Found test issues needing modification | Hand off to Test Owner (separate conversation) to update tests |
| ❌ | BLOCKED | Needs external input/decision | Record breakpoint, wait for user |
| 💥 | FAILED | Fast-track tests not passing | Fix and retry |

## Status Determination Flow

```
1. Check if deviation-log.md has "| ❌" records
   → Yes: IMPLEMENTATION_DONE_WITH_DEVIATION

2. Check if need to modify tests/
   → Yes: HANDOFF to Test Owner (separate conversation)

3. Check if fast-track tests (@smoke + @critical) all pass
   → No: FAILED

4. Check if tasks.md all complete
   → No: BLOCKED or continue implementation

5. All above pass, trigger @full
   → IMPLEMENTATION_DONE
```

## Routing Output Template (Must Use)

After completing coder, **must** output in this format:

```markdown
## Completion Status

**Status**: ✅ IMPLEMENTATION_DONE / ⚠️ ... / 🔄 HANDOFF / ❌ BLOCKED / 💥 FAILED

**Task Progress**: X/Y completed

**Fast-track Tests**: @smoke ✅ / @critical ✅

**@full Tests**: Triggered (CI running async)

**Deviation Records**: Has N pending / None

## Next Step

**Recommended**: Hand off to Test Owner (new conversation/instance) for Phase 2 / wait for @full if needed

**Reason**: [specific reason]

**Note**: Can start next change, no need to wait for @full completion
```

## Specific Routing Rules

| My Status | Next Step | Reason |
|-----------|-----------|--------|
| IMPLEMENTATION_DONE | Hand off to Test Owner (separate conversation) | Fast-track green; Test Owner audits evidence after @full passes |
| IMPLEMENTATION_DONE_WITH_DEVIATION | `devbooks-design-backport` | Backport design first |
| HANDOFF (test issues) | Hand off to Test Owner (separate conversation) | Coder cannot modify tests |
| BLOCKED | Wait for user | Record breakpoint area |
| FAILED | Fix and retry | Analyze failure reason |

## Key Constraints

- Coder **can never modify** `tests/**`
- If test issues are found, hand off to Test Owner (separate conversation) to handle
- If deviations exist, must design-backport first before continuing
- **After Coder completion status is `Implementation Done`, must wait for @full to pass before entering Test Owner Phase 2**
- **Role isolation is mandatory**: do not switch roles within one conversation
