---
name: devbooks-reviewer
description: devbooks-reviewer: Perform readability/consistency/dependency health/code smell reviews as a Reviewer role, outputting only review comments and actionable suggestions without discussing business correctness. Use when user says "help me do code review/review maintainability/code smells/dependency risks/consistency suggestions", or when executing as reviewer during DevBooks apply phase.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash
---

# DevBooks: Code Review (Reviewer)

## Progressive Disclosure

### Base (Required)
Goal: Produce review comments focused on maintainability (readability, consistency, dependencies), without changing code.
Inputs: change package context, diffs, key touched modules, and Green evidence availability.
Outputs: review notes and actionable suggestions for follow-up changes.
Boundaries: do not modify code or `tests/**`; do not discuss business correctness; do not check off AC matrix.
Evidence: reference reviewed paths and any detected risks.

### Advanced (Optional)
Use when you need: resource management checks, smell detection, dependency health deep-dive.

### Extended (Optional)
Use when you need: faster search/refs/impact via code intelligence or reference tools.

## Workflow Position Awareness

> **Core Principle**: Code Review executes after Test Owner Phase 2 verification, as the final review step before archiving.

### My Position in the Overall Workflow

```
proposal → design → test-owner(phase1) → coder → test-owner(phase2) → [Code Review] → archive
                                                                          ↓
                                                              Readability/consistency/dependency review
```

### Code Review's Responsibility Boundaries

| Allowed | Prohibited |
|---------|------------|
| Review code readability/consistency | ❌ Modify code files |
| Set verification.md Status = Done | ❌ Discuss business correctness (that's Test Owner's job) |
| Suggest improvements | ❌ Check off AC coverage matrix (that's Test Owner's job) |

### Prerequisites

- [ ] Test Owner Phase 2 completed (AC matrix checked)
- [ ] Tests all green
- [ ] evidence/green-final/ exists

---

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) -> Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) -> template protocol, use default mappings
4. If still undetermined -> **Stop and ask user**

**Key Constraints**:
- If configuration specifies `agents_doc` (rules document), **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading rules document

## Review Dimensions

### 1. Readability Review
- Naming consistency (PascalCase/camelCase)
- Function length and complexity
- Comment quality and necessity
- Code formatting

### 2. Dependency Health Review
- Layer constraint compliance (see `<truth-root>/architecture/c4.md`)
- Circular dependency detection
- Internal module encapsulation (prohibit deep imports of *Internal files)
- Dependency direction correctness

### 3. Resource Management Review

**Resource leak patterns that must be checked**:

| Check Item | Violation Pattern | Correct Pattern |
|------------|-------------------|-----------------|
| Unsubscribed subscriptions | `event.on(...)` without corresponding `off()` | Register to DisposableStore |
| Uncleaned timers | `setInterval()` without `clearInterval()` | Clean up in dispose() |
| Unreleased listeners | `addEventListener()` without `removeEventListener()` | Use AbortController |
| Unclosed streams | `createReadStream()` without `close()` | Use try-finally or using |
| Unreleased connections | `connect()` without `disconnect()` | Use connection pool or dispose pattern |

**DisposableStore Pattern Checks**:

```typescript
// Violation: mutable disposable field
private disposable = new DisposableStore(); // should be readonly

// Violation: dispose() not calling super.dispose()
dispose() {
  this.cleanup(); // missing super.dispose()
}

// Correct pattern
private readonly _disposables = new DisposableStore();

override dispose() {
  this._disposables.dispose();
  super.dispose();
}
```

**Resource Management Checklist**:
- [ ] Are DisposableStore fields declared as `readonly` or `const`?
- [ ] Does the dispose() method call `super.dispose()`?
- [ ] Are subscriptions/listeners registered to DisposableStore?
- [ ] Do tests include `ensureNoDisposablesAreLeakedInTestSuite()`?

### 4. Type Safety Review

- [ ] Are there `as any` type assertions?
- [ ] Are there dangerous `{} as T` assertions?
- [ ] Is `unknown` used instead of `any`?
- [ ] Are generic constraints strict enough?

### 5. Code Smell Detection

See: `references/code-smell-cheatsheet.md`

### 6. Test Quality Review

- [ ] Are there `test.only` / `describe.only`?
- [ ] Do tests have cleanup logic (afterEach)?
- [ ] Are tests independent (not dependent on execution order)?
- [ ] Are mocks properly reset?

## Execution Method

1) First read and follow: `~/.claude/skills/_shared/references/ai-behavior-guidelines.md` (verifiability + structural quality gates).
2) Read resource management guide: `references/resource-management-checklist.md`.
3) Strictly follow the complete prompt to output review comments: `references/code-review-prompt.md`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate review scope.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

### Detection Flow

1. Detect if change package exists
2. Detect if there are code changes (git diff)
3. Detect hotspot files (based on change history and complexity analysis)

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Change Package Review** | change-id provided | Review code changes related to that change package |
| **File Review** | Specific file path provided | Review specified files |
| **Hotspot Priority Review** | Hotspot file changes detected | Prioritize reviewing high-risk hotspots |

### Detection Output Example

```
Detection Results:
- Change package status: exists
- Code changes: 12 files
- Hotspot files: 3 (require focused attention)
- Running mode: Change package review + Hotspot priority
```

---

## Next Step Recommendations

**Reference**: `skills/_shared/workflow-next-steps-workflow-next-steps.md`

After completing code-review, the next step depends on the situation:

| Condition | Next Skill | Reason |
|-----------|------------|--------|
| Spec deltas exist | `devbooks-archiver` | Merge specs into truth before archive |
| No spec deltas | Archive complete | No further skills needed |
| Major issues found | Hand back to `devbooks-coder` | Fix issues before archive |

### Reviewer Exclusive Permission: Set verification.md Status

**Only Reviewer can set `verification.md` Status to `Done`**.

After review passes, Reviewer must:
1. Open `<change-root>/<change-id>/verification.md`
2. Change `- Status: Ready` to `- Status: Done`
3. This is a prerequisite for archive (`change-check.sh --mode archive` will verify)

### Output Template

After completing code-review, output:

```markdown
## Recommended Next Step

**Next: `devbooks-archiver`** (if spec deltas exist)
OR
**Archive complete** (if no spec deltas)

Next: merge spec deltas into truth / complete archiving.

### How to invoke (if spec deltas exist)
```
Run devbooks-archiver skill for change <change-id>
```

---
