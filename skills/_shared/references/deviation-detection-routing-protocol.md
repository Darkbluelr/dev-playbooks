# Deviation Detection and Routing Protocol

> This protocol defines the deviation detection, recording, and routing mechanisms during skill execution.
> All Apply phase skills (coder, test-owner, reviewer) must follow this protocol.

## Core Problem

During long tasks (e.g., coder), the following may occur:
1. Unplanned feature modifications or additions
2. Discovery that design document constraints need adjustment
3. Context overflow triggers compact, causing deviation information loss

**Solution**: Real-time persistence + completion-time detection + structured routing

---

## Completion Status Classification (MECE)

Each skill must identify and declare its current status upon completion:

| Code | Status | Meaning | Next Step |
|:----:|--------|---------|-----------|
| ✅ | COMPLETED | Completed normally, no deviations | Enter next skill |
| ⚠️ | COMPLETED_WITH_DEVIATION | Completed but with deviations/additions | design-backport first, then next step |
| 🔄 | HANDOFF | Needs another role to handle | Return to specified skill |
| ❌ | BLOCKED | Blocked, needs external input | Record breakpoint, wait |
| 💥 | FAILED | Failed, gates not passed | Fix and retry |

### Status Determination Rules

```
If deviation-log.md has unwritten records
  → COMPLETED_WITH_DEVIATION

If tasks.md has incomplete items
  → BLOCKED or FAILED (depends on reason)

If tests/ modification needed (for coder)
  → HANDOFF to test-owner

If all tasks completed and no deviations
  → COMPLETED
```

---

## Deviation Log Protocol

### File Location

```
<change-root>/<change-id>/deviation-log.md
```

### File Format

```markdown
# Deviation Log

> This file records all deviations, additions, and temporary decisions during implementation.
> **Important**: This file persists after compact, ensuring information is not lost.

## Pending Backport Records

| Time | Type | Description | Affected Files | Backported |
|------|------|-------------|----------------|:----------:|
| YYYY-MM-DD HH:mm | NEW_FEATURE | Added X feature | src/x.ts | ❌ |
| YYYY-MM-DD HH:mm | CONSTRAINT_CHANGE | Timeout changed to 60s | config.ts | ❌ |
| YYYY-MM-DD HH:mm | DESIGN_GAP | Found uncovered edge case | - | ❌ |

## Completed Backport Records

(Move here after design-backport completes)

| Time | Type | Description | Backported To |
|------|------|-------------|---------------|
```

### Deviation Type Definitions

| Type | Code | Description | Example |
|------|------|-------------|---------|
| New Feature | NEW_FEATURE | Added feature not in design | New warmup() method |
| Constraint Change | CONSTRAINT_CHANGE | Modified constraint/config from design | Timeout from 30s to 60s |
| Design Gap | DESIGN_GAP | Found scenario not covered by design | Concurrency not considered |
| API Change | API_CHANGE | Public interface differs from design | Added options parameter |
| Dependency Change | DEPENDENCY_CHANGE | Introduced unplanned dependency | Added lodash |

---

## Real-time Persistence Protocol

### When to Write to deviation-log.md

**Must write immediately** in these situations:

1. **Added new files/functions** not in tasks.md
2. **Modified config/constraints** inconsistent with design.md
3. **Found edge cases** not covered by design.md
4. **Temporary decisions** needing later confirmation

### How to Write

```markdown
## Example: Found need to add feature

Append a line to deviation-log.md:

| 2024-01-15 10:30 | NEW_FEATURE | Added cache warmup for better first-access performance | src/cache.ts | ❌ |
```

### Compact Protection

deviation-log.md is a **persistent file** unaffected by compact. Even if conversation context is compressed:
- File content still exists
- Next skill can read and process

---

## Next Step Routing Rules

### General Routing Table

| Current Skill | Completion Status | Next Step |
|---------------|-------------------|-----------|
| Any | COMPLETED_WITH_DEVIATION | `devbooks-design-backport` |
| coder | COMPLETED | `devbooks-code-review` |
| coder | HANDOFF (test issue) | `devbooks-test-owner` |
| test-owner | COMPLETED | `devbooks-coder` |
| test-owner | HANDOFF (design issue) | `devbooks-design-backport` |
| code-review | COMPLETED (has spec delta) | `devbooks-archiver` |
| code-review | COMPLETED (no spec delta) | Archive complete |
| Any | BLOCKED | Record breakpoint, wait for user |
| Any | FAILED | Fix and retry current skill |

### Routing Output Template

After completing a skill, must output in this format:

```markdown
## Completion Status

**Status**: [COMPLETED / COMPLETED_WITH_DEVIATION / HANDOFF / BLOCKED / FAILED]

**Deviation Records**: [Has N pending / None]

## Next Step

**Recommended**: `devbooks-xxx skill`

**Reason**: [specific reason]

**How to invoke**:
Run devbooks-xxx skill for change <change-id>
```

---

## Interaction with design-backport

### Trigger Conditions

When deviation-log.md has **pending records** (Backported=❌), must execute design-backport first.

### Backport Completion Marking

After design-backport completes:
1. Move record from "Pending" to "Completed"
2. Update "Backported" column to ✅
3. Record specific location backported to

---

## Detection Script (Optional)

```bash
# Check for pending deviation backports
check_deviation() {
  local change_dir="$1"
  local log_file="${change_dir}/deviation-log.md"

  if [[ ! -f "$log_file" ]]; then
    echo "NO_DEVIATION"
    return 0
  fi

  if grep -q "| ❌" "$log_file"; then
    echo "HAS_PENDING_DEVIATION"
    return 1
  fi

  echo "ALL_BACKPORTED"
  return 0
}
```

---

*This protocol is core to the DevBooks Apply phase. All implementation skills must follow it.*
