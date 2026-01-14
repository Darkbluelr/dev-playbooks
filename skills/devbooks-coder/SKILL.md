---
name: devbooks-coder
description: "devbooks-coder: Implements features strictly following tasks.md as the Coder role and runs quality gates. Modifying tests/ is prohibited; tests and static checks serve as the sole completion criteria. Use when the user says 'implement as planned/fix failing tests/make all gates green/implement task items/don't modify tests', or when executing as coder during the DevBooks apply phase."
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Implementation Lead (Coder)

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, you **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) -> template protocol, use default mappings
5. If still unable to determine -> **Stop and ask the user**

**Key Constraints**:
- If the configuration specifies `agents_doc` (rules document), **you must read that document first** before performing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Checkpoint Resume Protocol (Plan Persistence)

You **must** perform the following steps at the start of each session:

1. **Read Progress**: Open `<change-root>/<change-id>/tasks.md`, identify tasks marked with `- [x]`
2. **Locate Resume Point**: Find the first `- [ ]` after the "last `[x]`"
3. **Output Confirmation**: Clearly inform the user of current progress, for example:
   ```
   Detected T1-T6 completed (6/10), resuming from T7.
   ```
4. **Check Breakpoint Area**: If tasks.md has a "Breakpoint Area" record, prioritize restoring the breakpoint state
5. **Exception Handling**: If you find tasks that are "unchecked but code already exists", prompt the user for confirmation

### Breakpoint Area Format (at the end of tasks.md)

```markdown
### Breakpoint Area (Context Switch Breakpoint Area)
- Last progress: T6 completed, T7 started but not finished
- Current blocker: <blocking reason>
- Next shortest path: <suggested action>
```

---

## Real-time Progress Update Protocol

> **Core principle**: Complete one task, check it off immediately. Never batch-check at the end.

**Must follow**:

### Check Off Immediately After Each Task

After completing each task item in tasks.md, **immediately** change it from `- [ ]` to `- [x]`:

```markdown
# Before task completion
- [ ] MP1.1 Implement cache manager base structure

# After task completion, update immediately
- [x] MP1.1 Implement cache manager base structure
```

### Why Real-time Checking is Required

1. **Checkpoint Recovery**: Know exactly where to continue after interruption
2. **Visible Progress**: Both user and AI can clearly see current progress
3. **Avoid Forgetting**: Batch checking often leads to missing items
4. **Complete Evidence Chain**: Each checkmark represents a completed milestone

### When to Check Off

| Timing | Action |
|--------|--------|
| Code writing complete | Do not check yet |
| Compilation passes | Do not check yet |
| Related tests pass | **Check immediately** |
| Multiple tasks completed together | Check one by one, not in batch |

### Forbidden Behaviors

- ❌ Do not wait until all tasks are done to batch-check
- ❌ Do not consider "code written = complete" without checking off
- ❌ Do not uncheck a checked item (unless rolling back code)

---

## Output Management Constraints (Observation Masking)

Prevent large outputs from polluting the context:

| Scenario | Handling Method |
|----------|-----------------|
| Command output > 50 lines | Keep only first and last 10 lines + middle summary |
| Test output | Extract key failure information, do not paste full output into conversation |
| Log output | Write to `<change-root>/<change-id>/evidence/`, only reference the path in conversation |
| Large file content | Reference path, do not inline |

**Example**:
```
BAD: Pasting 2000 lines of test logs
GOOD: 3 tests failed, see <change-root>/<change-id>/evidence/green-final/test-output.log
      Key error: FAIL src/order.test.ts:45 - Expected 400, got 500
```

---

## Evidence Path Convention (Mandatory)

**Green evidence must be saved to the change package directory**:
```
<change-root>/<change-id>/evidence/green-final/
```

**Forbidden paths**:
- ❌ `./evidence/` (project root)
- ❌ `evidence/` (relative to current working directory)

**Correct path examples**:
```bash
# DevBooks 2.0 default path
dev-playbooks/changes/<change-id>/evidence/green-final/test-$(date +%Y%m%d-%H%M%S).log

# Using the script
devbooks change-evidence <change-id> --label green-final -- npm test
```

---

## Key Constraints

### Role Boundary Constraints
- **Modifying `tests/**` is prohibited** (changes to tests must be handed back to Test Owner)
- **Modifying `verification.md` is prohibited** (maintained by Test Owner)
- **Modifying `.devbooks/`, `build/`, or engineering configuration files is prohibited** (unless explicitly stated in proposal.md)

### Code Quality Constraints

#### Prohibited Patterns

| Pattern | Detection Command | Reason |
|---------|-------------------|--------|
| `test.only` | `rg '\.only\s*\(' src/` | Skips other tests |
| `console.log` | `rg 'console\.log' src/` | Debug code residue |
| `debugger` | `rg 'debugger' src/` | Debug breakpoint residue |
| `// TODO` without issue | `rg 'TODO(?!.*#\d+)' src/` | Untrackable todos |
| `any` type | `rg ': any[^a-z]' src/` | Type safety vulnerability |
| `@ts-ignore` | `rg '@ts-ignore' src/` | Hides type errors |

#### Pre-Commit Checks (Required)

```bash
# 1. Compile check (mandatory)
npm run compile || exit 1

# 2. Lint check (mandatory)
npm run lint || exit 1

# 3. Test check (mandatory)
npm test || exit 1

# 4. test.only check (mandatory)
if rg -l '\.only\s*\(' tests/ src/**/test/; then
  echo "error: found .only() in tests" >&2
  exit 1
fi

# 5. Debug code check (mandatory)
if rg -l 'console\.(log|debug)|debugger' src/ --type ts; then
  echo "error: found debug statements" >&2
  exit 1
fi
```

### Verification Prerequisites Constraints

**Core Requirement**: After each code modification, you must run verification commands and confirm they pass.

- [ ] Run `npm run compile` immediately after modifying code
- [ ] Run `npm run lint` after compilation passes
- [ ] Run `npm test` after lint passes
- [ ] Declaring "task complete" while verification fails is prohibited
- [ ] Verification command output must be recorded to evidence files

### Resource Cleanup Constraints

- [ ] Temporary files must be deleted when the task ends
- [ ] Background processes must be terminated when the task ends
- [ ] Cleanup must be performed regardless of success or failure

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gating).
2) Read low-risk modification techniques: `references/low-risk-modification-techniques.md` (read when needed).
3) Execute strictly according to the complete prompt: `references/code-implementation-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution to ensure prerequisites are met.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect if `tasks.md` exists
2. Detect if `verification.md` exists (Test Owner has completed)
3. Detect if the current session has already executed the Test Owner role
4. Identify progress in tasks.md (completed/pending)

### Supported Modes for This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **First Implementation** | All items in tasks.md are `[ ]` | Start from MP1.1 |
| **Checkpoint Resume** | tasks.md has some `[x]` | Continue from the first `[ ]` after the last `[x]` |
| **Gate Fix** | Tests failed and need fixing | Prioritize fixing failed items |

### Prerequisites Checklist

- [ ] `tasks.md` exists
- [ ] `verification.md` exists
- [ ] Current session has not executed Test Owner
- [ ] `tests/**` has test files

### Detection Output Example

```
Detection Results:
- Artifact existence: tasks.md OK, verification.md OK
- Role isolation: OK (current session has not executed Test Owner)
- Progress: 6/10 completed
- Run mode: Checkpoint resume, continuing from MP1.7
```

---

## Deviation Detection and Persistence Protocol

**Reference**: `skills/_shared/references/deviation-detection-routing-protocol.md`

### Real-time Persistence Requirements

During implementation, you **must immediately** write to `deviation-log.md` in these situations:

| Situation | Type | Example |
|-----------|------|---------|
| Added functionality not in tasks.md | NEW_FEATURE | Added warmup() method |
| Modified constraint from design.md | CONSTRAINT_CHANGE | Timeout changed to 60s |
| Found edge case not covered by design | DESIGN_GAP | Concurrency scenario |
| Public interface differs from design | API_CHANGE | Added parameter |

### deviation-log.md Format

```markdown
# Deviation Log

## Pending Backport Records

| Time | Type | Description | Affected Files | Backported |
|------|------|-------------|----------------|:----------:|
| 2024-01-15 10:30 | NEW_FEATURE | Added cache warmup feature | src/cache.ts | ❌ |
```

### Compact Protection

**Important**: deviation-log.md is a persistent file unaffected by compact. Even if the conversation is compressed, deviation information is preserved.

---

## Completion Status and Routing

### Completion Status Classification (MECE)

| Code | Status | Determination Criteria | Next Step |
|:----:|--------|------------------------|-----------|
| ✅ | COMPLETED | All tasks done, no deviations | `devbooks-code-review` |
| ⚠️ | COMPLETED_WITH_DEVIATION | Tasks done, deviation-log has pending records | `devbooks-design-backport` |
| 🔄 | HANDOFF | Found test issues needing modification | `devbooks-test-owner` |
| ❌ | BLOCKED | Needs external input/decision | Record breakpoint, wait for user |
| 💥 | FAILED | Gates not passed | Fix and retry |

### Status Determination Flow

```
1. Check if deviation-log.md has "| ❌" records
   → Yes: COMPLETED_WITH_DEVIATION

2. Check if tests/ modification needed
   → Yes: HANDOFF to test-owner

3. Check if tasks.md is fully completed
   → No: BLOCKED or FAILED

4. All checks passed
   → COMPLETED
```

### Routing Output Template (Required)

After completing coder, you **must** output in this format:

```markdown
## Completion Status

**Status**: ✅ COMPLETED / ⚠️ COMPLETED_WITH_DEVIATION / 🔄 HANDOFF / ❌ BLOCKED / 💥 FAILED

**Task Progress**: X/Y completed

**Deviation Records**: Has N pending / None

## Next Step

**Recommended**: `devbooks-xxx skill`

**Reason**: [specific reason]

### How to invoke
Run devbooks-xxx skill for change <change-id>
```

### Specific Routing Rules

| My Status | Next Step | Reason |
|-----------|-----------|--------|
| COMPLETED | `devbooks-code-review` | Review readability/consistency |
| COMPLETED_WITH_DEVIATION | `devbooks-design-backport` | Backport design first, then review |
| HANDOFF (test issue) | `devbooks-test-owner` | Coder cannot modify tests |
| BLOCKED | Wait for user | Record breakpoint area |
| FAILED | Fix and retry | Analyze failure reason |

**Critical Constraints**:
- Coder **can never modify** `tests/**`
- If test issues found, must HANDOFF to Test Owner (separate session)
- If deviations exist, must design-backport first before continuing

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Required MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getHotspots` | Detect hotspot files, output warnings | 2s |
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available -> Call `mcp__ckb__getHotspots` to get hotspot files
3. If timeout or failure -> Degrade to basic mode (no hotspot warnings)

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Hotspot file warnings | CKB real-time analysis | Not available |
| Risk file identification | Automatic highlighting of high-hotspot changes | Manual identification |
| Code navigation | Symbol-level jumping | File-level search |

### Degradation Notice

When MCP is unavailable, output the following notice:

```
WARNING: CKB unavailable, skipping hotspot detection.
To enable hotspot warnings, manually generate SCIP the index.
```

