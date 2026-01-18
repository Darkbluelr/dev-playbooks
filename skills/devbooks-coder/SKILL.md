---
name: devbooks-coder
description: devbooks-coder: As the Coder role, strictly implements functionality according to tasks.md and runs gate tests, prohibited from modifying tests/, with tests/static checks as the sole completion criteria. Use when users say "implement according to plan/fix test failures/make gates green/implement task items/don't modify tests", or when executing as coder during DevBooks apply phase.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Implementation Lead (Coder)

## Quick Start

My responsibilities:
1. **Strictly implement functionality according to tasks.md**
2. **Run fast-track tests** (@smoke + @critical)
3. **Trigger @full tests** (CI async)
4. **Prohibited from modifying tests/**

## Workflow Position

```
proposal → design → [TEST-OWNER] → [CODER] → [TEST-OWNER] → code-review → archive
                                      ↓              ↓
                               Implement+fast-track  Evidence audit+check off
                              (@smoke/@critical)     (no @full rerun)
```

## AI Era Optimization

| Old Design | New Design | Reason |
|------------|------------|--------|
| Test Owner and Coder must use separate sessions | Same session, switch with `[TEST-OWNER]` / `[CODER]` mode labels | Reduce context rebuilding cost |
| Coder runs full tests and waits for results | Coder runs fast-track (`@smoke`/`@critical`), `@full` triggered async | Fast iteration |
| Directly hand to Test Owner after completion | Status becomes `Implementation Done` after completion, wait for @full | Async doesn't block, archive syncs |

---

## Prerequisites: Configuration Discovery

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol
3. `project.md` (if exists) → Template protocol
4. If still unable to determine → **Stop and ask user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **must read that document first** before performing any operations
- Do not guess directory roots

---

## 📚 Reference Documentation

### Must Read (Read Immediately)

1. **AI Behavior Guidelines**: `~/.claude/skills/_shared/references/ai-behavior-guidelines.md`
   - Verifiability gating, structural quality gating, completeness gating
   - Foundation rules for all skills

2. **Code Implementation Prompt**: `references/code-implementation-prompt.md`
   - Complete code implementation guide
   - Strictly follow this prompt

### Read as Needed

3. **Test Execution Strategy**: `references/test-execution-strategy.md`
   - @smoke/@critical/@full label details
   - Async vs sync boundaries
   - When to read: When needing to understand test run strategy

4. **Completion Status and Routing**: `references/completion-status-and-routing.md`
   - Completion status classification (MECE)
   - Routing output template
   - When to read: When outputting status upon task completion

5. **Hotspot Awareness and Risk Assessment**: `references/hotspot-awareness-and-risk-assessment.md`
   - MCP enhancement features
   - Hotspot file warnings
   - When to read: When needing risk assessment

6. **Low Risk Modification Techniques**: `references/low-risk-modification-techniques.md`
   - Safe refactoring techniques
   - When to read: When needing refactoring

7. **Coding Style Guidelines**: `references/coding-style-guidelines.md`
   - Code style specifications
   - When to read: When uncertain about code style

8. **Logging Standard**: `references/logging-standard.md`
   - Log levels and formats
   - When to read: When needing to add logs

9. **Error Code Standard**: `references/error-code-standard.md`
   - Error code design
   - When to read: When needing to define error codes

---

## Core Workflow

### 1. Resume from Checkpoint

**Must** execute before each start:

1. **Read progress**: Open `<change-root>/<change-id>/tasks.md`, identify checked `- [x]` tasks
2. **Locate resume point**: Find first `- [ ]` after "last `[x]`"
3. **Output confirmation**: Clearly inform user of current progress, e.g.:
   ```
   Detected T1-T6 completed (6/10), continuing from T7.
   ```

### 2. Real-time Progress Updates

> **Core Principle**: Complete one task, check off one immediately. Don't wait until all complete to batch check.

**Check-off Timing**:

| Timing | Action |
|--------|--------|
| Code writing complete | Don't check yet |
| Compilation passes | Don't check yet |
| Related tests pass | **Check immediately** |
| Multiple tasks complete together | Check one by one, don't batch |

### 3. Implement Code

Strictly follow `references/code-implementation-prompt.md`.

### 4. Run Tests

```bash
# During development: frequently run @smoke
npm test -- --grep "@smoke"

# Before commit: run @critical
npm test -- --grep "@smoke|@critical"

# After commit: CI automatically runs @full (Coder doesn't wait)
git push  # Trigger CI
```

### 5. Output Completion Status

Reference `references/completion-status-and-routing.md`.

---

## Key Constraints

### Role Boundaries

| Allowed | Prohibited |
|---------|------------|
| Modify `src/**` code | ❌ Modify `tests/**` |
| Check off `tasks.md` task items | ❌ Modify `verification.md` |
| Record deviations to `deviation-log.md` | ❌ Check off AC coverage matrix |
| Run fast-track tests (`@smoke`/`@critical`) | ❌ Set verification.md Status to Verified/Done |
| Trigger `@full` tests (CI/background) | ❌ Wait for @full completion (can start next change) |

### Code Quality Constraints

#### Prohibited Patterns for Commit

| Pattern | Detection Command | Reason |
|---------|-------------------|--------|
| `test.only` | `rg '\.only\s*\(' src/` | Skips other tests |
| `console.log` | `rg 'console\.log' src/` | Debug code remnants |
| `debugger` | `rg 'debugger' src/` | Debug breakpoint remnants |
| `// TODO` without issue | `rg 'TODO(?!.*#\d+)' src/` | Untraceable todos |
| `any` type | `rg ': any[^a-z]' src/` | Type safety holes |
| `@ts-ignore` | `rg '@ts-ignore' src/` | Hides type errors |

#### Pre-commit Checks Required

```bash
# 1. Compilation check (mandatory)
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

---

## Output Management

Prevent large outputs from polluting context:

| Scenario | Handling |
|----------|----------|
| Command output > 50 lines | Keep only first and last 10 lines + middle summary |
| Test output | Extract key failure info, don't paste full output in dialogue |
| Log output | Write to disk at `<change-root>/<change-id>/evidence/`, only reference path in dialogue |
| Large file contents | Reference path, don't inline |

---

## Evidence Path Convention

**Green evidence must be saved**:
```
<change-root>/<change-id>/evidence/green-final/
```

**Correct path examples**:
```bash
# Dev-Playbooks default path
dev-playbooks/changes/<change-id>/evidence/green-final/test-$(date +%Y%m%d-%H%M%S).log

# Using script
devbooks change-evidence <change-id> --label green-final -- npm test
```

---

## Deviation Detection and Persistence

**Reference**: `~/.claude/skills/_shared/references/deviation-detection-routing-protocol.md`

During implementation, **must immediately** write to `deviation-log.md` in these situations:

| Situation | Type | Example |
|-----------|------|---------|
| Added functionality not in tasks.md | NEW_FEATURE | Added warmup() method |
| Modified constraints in design.md | CONSTRAINT_CHANGE | Timeout changed to 60s |
| Found boundary case not covered by design | DESIGN_GAP | Concurrent write scenario |
| Public interface inconsistent with design | API_CHANGE | Parameter added |

---

## Context Awareness

Detection rules reference: `~/.claude/skills/_shared/context-detection-template.md`

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Initial Implementation** | All tasks.md are `[ ]` | Start from MP1.1 |
| **Resume from Checkpoint** | tasks.md has some `[x]` | Continue from first `[ ]` after last `[x]` |
| **Gate Fixing** | Test failures need fixing | Prioritize failed items |

### Prerequisite Checks

- [ ] `tasks.md` exists
- [ ] `verification.md` exists
- [ ] Test Owner not executed in current session
- [ ] `tests/**` has test files
