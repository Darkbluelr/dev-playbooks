# DevBooks Skill Development Guide

This document defines the design principles and constraints you must follow when creating a new DevBooks Skill.

---

## 1) Core Design Principles

### 1.1 Single-Responsibility Principle (UNIX philosophy)

- **One Skill, one job**: a Skill should have one clear responsibility; do not mix unrelated responsibilities.
- **Communicate via the filesystem**: Skills exchange data through files under `<change-root>/<change-id>/`, not through shared memory or implicit session state.
- **Artifacts must be plain text**: all outputs should be Markdown/JSON so they are versionable and reviewable.

### 1.2 Idempotency (mandatory)

**Definition**: rerunning the same operation produces the same result and does not accumulate side effects.

| Skill type | Idempotency requirement | Examples |
|---|---|---|
| **Verification / checks** | Must be idempotent (must not modify files) | `change-check.sh`, `guardrail-check.sh`, `devbooks-code-review` |
| **Generators** | Must explicitly define “overwrite vs incremental” behavior | `change-scaffold.sh`, `devbooks-design-doc`, `devbooks-proposal-author` |
| **Editors** | Must be safe to rerun | `devbooks-spec-gardener`, `devbooks-design-backport` |

**Verification/check Skills MUST**:
- [ ] Not modify any files (read-only)
- [ ] Not modify databases, caches, or external state
- [ ] Produce identical output when inputs are identical
- [ ] Leave no partial state on failure

**Generator Skills MUST**:
- [ ] Clearly declare whether they run in “overwrite mode” or “incremental mode”
- [ ] Overwrite mode: reruns produce the same result
- [ ] Incremental mode: reruns do not duplicate content (must detect existing content)
- [ ] Roll back on failure (or explicitly state that rollback is not possible)

**Editor Skills MUST**:
- [ ] Back up original files before edits (or make it recoverable via git)
- [ ] Avoid cumulative side effects across reruns
- [ ] Provide a “dry-run” mode to preview changes

### 1.3 Verification-First Principle (inspired by VS Code)

**Core requirement**: after a generator/editor Skill writes files, it **must run verification**, and must not proceed to the next step if verification fails.

| Skill type | Verification requirement | Failure handling |
|---|---|---|
| Code generation | Compile/typecheck (TypeScript/ESLint, etc.) | Must fix before continuing |
| Test generation | Run tests (expected Red or Green) | Record results in `verification.md` |
| Config generation | Format/schema validation (JSON/YAML schema) | Must fix before continuing |
| Documentation | Link checks / formatting checks | Warn-only is acceptable |

**Verification-first checklist**

```markdown
## Verification-first checklist (generator/editor Skills must execute)

- [ ] Immediately run relevant verification commands after writing files
- [ ] Record command outputs into evidence files
- [ ] Never claim “done” when verification fails
- [ ] On failure, attempt a fix or report the reason precisely
- [ ] Never “assume success” — check actual command output
```

**Example: verification flow after code generation**

```bash
# 1) Generate code
write_code_to_file "$output_file"

# 2) Verify immediately (mandatory)
if ! npm run compile 2>&1 | tee "$evidence_dir/compile.log"; then
  echo "error: compilation failed, cannot proceed" >&2
  exit 1
fi

# 3) Run lint checks
if ! npm run lint 2>&1 | tee "$evidence_dir/lint.log"; then
  echo "error: lint failed, cannot proceed" >&2
  exit 1
fi

# 4) Only proceed after verification passes
echo "ok: verification passed"
```

### 1.4 Long-Running Task Output Monitoring

**Requirement**: for long-running tasks, actively observe output to avoid the “assume success” trap.

- [ ] Background tasks must have a timeout
- [ ] Always check the process exit code
- [ ] Read and analyze command output
- [ ] Do not claim success just because “the command finished”

### 1.5 Truth Source Separation

- **Read-only truth**: Skills may read from `<truth-root>/` but must not modify it directly (except for archive-related Skills such as `archiver`).
- **Write to workspace**: Skills should write to `<change-root>/<change-id>/`.
- **Archive is merge**: archiving merges workspace outputs back into truth.

### 1.6 Resource Cleanup (inspired by VS Code)

**Requirement**: clean up temporary resources on both success and failure.

- [ ] Temporary files must be deleted on exit
- [ ] Background processes must be terminated on exit
- [ ] Database connections must be closed on exit
- [ ] Use `trap` so cleanup runs even on abnormal exits

```bash
# Example: ensure cleanup with trap
cleanup() {
  rm -rf "$TEMP_DIR"
  kill "$BG_PID" 2>/dev/null || true
}
trap cleanup EXIT
```

---

## 2) Skill Directory Structure

```
skills/
└── devbooks-<skill-name>/
    ├── SKILL.md           # Skill definition (required)
    ├── references/        # Reference docs (optional)
    │   ├── *.md           # prompts, templates, checklists, etc.
    │   └── ...
    └── scripts/           # Executable scripts (optional)
        ├── *.sh           # shell scripts
        └── ...
```

### 2.1 SKILL.md template

```markdown
---
name: devbooks-<skill-name>
description: One sentence describing the Skill’s responsibility and when to use it
---

# DevBooks: <Skill name>

## Prereq: directory roots (protocol-agnostic)

- `<truth-root>`: truth root directory (current specs/rules)
- `<change-root>`: change package root directory

## Responsibility

<Describe what this Skill does>

## Idempotency

- Type: verifier / generator / editor
- Idempotent: yes / no (explain why)
- Rerun behavior: <describe behavior on reruns>

## References

- `references/<doc-name>.md`

## Scripts (if any)

- `scripts/<script-name>.sh`
```

---

## 3) Script Development Conventions

### 3.1 Required arguments

All scripts must support the following standard arguments:

```bash
--project-root <path>    # project root (required)
--change-root <path>     # change package root (required)
--truth-root <path>      # truth root (required)
--dry-run                # preview mode; do not modify (recommended)
--help                   # show help (required)
```

### 3.2 Exit codes

| Exit code | Meaning |
|---:|---|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Prerequisites not met |
| 4 | Verification failed (for checker scripts) |

### 3.3 Output conventions

- Normal output goes to stdout
- Errors go to stderr
- Support `--json` for machine-readable output (recommended)
- Avoid ANSI colors unless a TTY is detected

---

## 4) Quality Checklist

Before submitting a new Skill, ensure:

- [ ] **Single responsibility**: the Skill does one thing
- [ ] **Idempotency declared**: `SKILL.md` clearly states rerun behavior
- [ ] **Truth separation**: does not edit `<truth-root>/` directly (unless an archive-related Skill)
- [ ] **Args complete**: scripts support standard args (`--project-root`, `--change-root`, `--truth-root`)
- [ ] **Help text**: `--help` outputs clear usage
- [ ] **Exit codes**: uses standard exit codes
- [ ] **No side effects**: checker Skills do not modify files
- [ ] **Testability**: has test cases or a verification method

---

## 5) Example: idempotency for a checker Skill

```bash
#!/usr/bin/env bash
# change-check.sh - checker script example

set -euo pipefail

# Checker script: read-only, must not modify any files
readonly MODE="readonly"

check_change() {
    local change_id="$1"
    local change_path="$CHANGE_ROOT/$change_id"

    # Read-only: verify required files exist
    [[ -f "$change_path/proposal.md" ]] || return 4
    [[ -f "$change_path/design.md" ]] || return 4
    [[ -f "$change_path/tasks.md" ]] || return 4

    # Read-only: validate content format
    grep -q "^## Acceptance Criteria" "$change_path/design.md" || return 4

    return 0
}

# Multiple runs: same output, no side effects
check_change "$1"
```

