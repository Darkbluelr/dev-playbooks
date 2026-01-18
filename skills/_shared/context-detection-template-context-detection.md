# Context Detection Template

> This template provides standardized context detection rules for all SKILL.md files.
>
> Artifact location: `skills/_shared/context-detection-template-context-detection.md`

---

## Overview

Context detection automatically identifies the current working state to help a Skill select the correct run mode. Detection is file-based and does not depend on external services.

---

## Detection Rules

### 1. Artifact Presence Detection

Check for key artifacts in the change package directory.

```bash
# Detection script example
detect_artifacts() {
  local change_root="$1"
  local change_id="$2"
  local change_dir="${change_root}/${change_id}"

  # Detect key artifacts
  local has_proposal=false
  local has_design=false
  local has_tasks=false
  local has_verification=false
  local has_specs=false

  [[ -f "${change_dir}/proposal.md" ]] && has_proposal=true
  [[ -f "${change_dir}/design.md" ]] && has_design=true
  [[ -f "${change_dir}/tasks.md" ]] && has_tasks=true
  [[ -f "${change_dir}/verification.md" ]] && has_verification=true
  [[ -d "${change_dir}/specs" ]] && has_specs=true

  echo "proposal:${has_proposal}"
  echo "design:${has_design}"
  echo "tasks:${has_tasks}"
  echo "verification:${has_verification}"
  echo "specs:${has_specs}"
}
```

### 2. Completeness Rules

Validate completeness of specs/ by Requirement blocks.

**Completeness criteria**:
1. Each REQ must have at least one Scenario
2. Each Scenario must have Given/When/Then
3. No placeholders (`[TODO]`, `[TBD]`)
4. All ACs map to a Requirement

```bash
# Completeness check example
# [m-001 fix] Output format matches tests/lib/completeness-check.sh
check_spec_completeness() {
  local spec_file="$1"

  # If file is missing or empty, treat as complete
  if [[ ! -f "$spec_file" ]] || [[ ! -s "$spec_file" ]]; then
    echo "complete:no reqs to check"
    return 0
  fi

  # Check placeholders
  if grep -qE '\\[TODO\\]|\\[TBD\\]' "$spec_file"; then
    echo "incomplete:placeholders present"
    return 1
  fi

  # Check Requirement blocks
  local req_count=$(grep -c '^## REQ-' "$spec_file" || echo 0)
  local scenario_count=$(grep -c '^### Scenario' "$spec_file" || echo 0)

  if [[ $req_count -gt 0 && $scenario_count -eq 0 ]]; then
    echo "incomplete:REQ missing Scenario"
    return 1
  fi

  # Check Given/When/Then
  local gwt_count=$(grep -cE '^\\s*-\\s*(Given|When|Then)' "$spec_file" || echo 0)
  if [[ $scenario_count -gt 0 && $gwt_count -lt $((scenario_count * 3)) ]]; then
    echo "incomplete:Scenario missing full Given/When/Then"
    return 1
  fi

  echo "complete:all checks passed"
  return 0
}
```

### 3. Phase Detection

Infer current phase based on existing artifacts.

| Phase | Condition |
|-------|-----------|
| **proposal** | `proposal.md` missing, or exists but not judged |
| **apply** | `proposal.md` exists and judged, `design.md` exists, implementation in progress |
| **archive** | All gates pass, ready to archive or already archived |

```bash
# Phase detection example
detect_phase() {
  local change_dir="$1"

  # Check artifact presence
  local has_proposal=false
  local has_design=false
  local has_evidence=false

  [[ -f "${change_dir}/proposal.md" ]] && has_proposal=true
  [[ -f "${change_dir}/design.md" ]] && has_design=true
  [[ -d "${change_dir}/evidence/green-final" ]] && has_evidence=true

  # Infer phase
  if ! $has_proposal; then
    echo "proposal"
  elif $has_evidence; then
    echo "archive"
  else
    echo "apply"
  fi
}
```

### 4. Run Mode Detection

Select Skill run mode based on context.

| Mode | Condition | Description |
|------|-----------|-------------|
| **create** | Target artifact missing | Create from scratch |
| **patch** | Artifact exists but incomplete | Fill missing parts |
| **sync** | Artifact complete, needs sync | Check and update for consistency |

```bash
# Mode detection example
detect_mode() {
  local artifact_path="$1"
  local artifact_type="$2"  # spec | design | c4

  if [[ ! -e "$artifact_path" ]]; then
    echo "create"
    return
  fi

  # Completeness check
  case "$artifact_type" in
    spec)
      local completeness=$(check_spec_completeness "$artifact_path")
      # [m-001 fix] Use the same format as runtime checks
      if [[ "$completeness" == complete:* ]]; then
        echo "sync"
      else
        echo "patch"
      fi
      ;;
    design)
      if grep -qE '\\[TODO\\]|\\[TBD\\]' "$artifact_path"; then
        echo "patch"
      else
        echo "sync"
      fi
      ;;
    c4)
      if [[ -f "$artifact_path" ]]; then
        echo "update"
      else
        echo "create"
      fi
      ;;
  esac
}
```

---

## 7 Boundary Test Cases

| ID | Scenario | Input State | Expected Output | Notes |
|----|----------|-------------|-----------------|-------|
| **CD-001** | Empty change package | `change-dir/` empty | phase=proposal, mode=create | Initial state |
| **CD-002** | Proposal only | `proposal.md` exists | phase=proposal, waiting for judgment | Proposal drafted |
| **CD-003** | Proposal + design | both files exist | phase=apply | Design complete, implementation starts |
| **CD-004** | Specs incomplete | `specs/` exists with `[TODO]` | mode=patch | Needs spec completion |
| **CD-005** | Specs complete | `specs/` exists without placeholders | mode=sync | Check consistency with implementation |
| **CD-006** | Gates passed | `evidence/green-final/` exists | phase=archive | Ready to archive |
| **CD-007** | c4.md missing | `specs/architecture/c4.md` missing | mode=create | Needs architecture map |

### Test Script

```bash
#!/bin/bash
# context-detection-test.sh
# Run boundary tests for context detection

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR=$(mktemp -d)
trap "rm -rf $TEST_DIR" EXIT

echo "=== Context Detection Boundary Tests ==="

# CD-001: Empty change package
echo -n "CD-001 empty change package... "
mkdir -p "$TEST_DIR/CD-001"
phase=$(detect_phase "$TEST_DIR/CD-001")
[[ "$phase" == "proposal" ]] && echo "PASS" || echo "FAIL (got: $phase)"

# CD-002: Proposal only
echo -n "CD-002 proposal only... "
mkdir -p "$TEST_DIR/CD-002"
touch "$TEST_DIR/CD-002/proposal.md"
phase=$(detect_phase "$TEST_DIR/CD-002")
[[ "$phase" == "proposal" || "$phase" == "apply" ]] && echo "PASS" || echo "FAIL (got: $phase)"

# CD-003: Proposal + design
echo -n "CD-003 proposal + design... "
mkdir -p "$TEST_DIR/CD-003"
touch "$TEST_DIR/CD-003/proposal.md"
touch "$TEST_DIR/CD-003/design.md"
phase=$(detect_phase "$TEST_DIR/CD-003")
[[ "$phase" == "apply" ]] && echo "PASS" || echo "FAIL (got: $phase)"

# CD-004: Specs incomplete
echo -n "CD-004 specs incomplete... "
mkdir -p "$TEST_DIR/CD-004/specs"
echo "[TODO] to fill" > "$TEST_DIR/CD-004/specs/spec.md"
mode=$(detect_mode "$TEST_DIR/CD-004/specs/spec.md" "spec")
[[ "$mode" == "patch" ]] && echo "PASS" || echo "FAIL (got: $mode)"

# CD-005: Specs complete
echo -n "CD-005 specs complete... "
mkdir -p "$TEST_DIR/CD-005/specs"
cat > "$TEST_DIR/CD-005/specs/spec.md" << 'EOF'
## REQ-001 Sample Requirement
### Scenario: Happy path
- Given precondition
- When action executed
- Then expected result
EOF
mode=$(detect_mode "$TEST_DIR/CD-005/specs/spec.md" "spec")
[[ "$mode" == "sync" ]] && echo "PASS" || echo "FAIL (got: $mode)"

# CD-006: Gates passed
echo -n "CD-006 gates passed... "
mkdir -p "$TEST_DIR/CD-006/evidence/green-final"
touch "$TEST_DIR/CD-006/proposal.md"
phase=$(detect_phase "$TEST_DIR/CD-006")
[[ "$phase" == "archive" ]] && echo "PASS" || echo "FAIL (got: $phase)"

# CD-007: c4.md missing
echo -n "CD-007 c4.md missing... "
mkdir -p "$TEST_DIR/CD-007/specs/architecture"
mode=$(detect_mode "$TEST_DIR/CD-007/specs/architecture/c4.md" "c4")
[[ "$mode" == "create" ]] && echo "PASS" || echo "FAIL (got: $mode)"

echo "=== Tests complete ==="
```

---

## Skill Reference

In SKILL.md, reference this template:

```markdown
## Context Awareness

This Skill detects context before execution and selects an appropriate run mode.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

### Detection Flow

1. Detect artifact presence
2. Determine completeness
3. Infer current phase
4. Select run mode

### Modes Supported by This Skill

| Mode | Trigger | Behavior |
|------|---------|----------|
| create | <condition> | <behavior> |
| patch | <condition> | <behavior> |
| sync | <condition> | <behavior> |
```

---

## Detection Output Format

Standardized detection results:

```
Detection Results:
- Artifact presence: <present/absent>
- Completeness: <complete/incomplete (missing: ...)>
- Current phase: <proposal/apply/archive>
- Run mode: <create/patch/sync>
```

---

**Doc Version**: v1.0.0  
**Last Updated**: 2026-01-12
