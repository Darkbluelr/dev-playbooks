#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF' >&2
usage: change-scaffold.sh <change-id> [--project-root <dir>] [--change-root <dir>] [--truth-root <dir>] [--force] [--prototype]

Creates a DevBooks change package skeleton under:
  <change-root>/<change-id>/

Defaults (can be overridden by flags or env):
  DEVBOOKS_PROJECT_ROOT: pwd
  DEVBOOKS_CHANGE_ROOT:  changes
  DEVBOOKS_TRUTH_ROOT:   specs

Options:
  --prototype   Create prototype track skeleton (prototype/src + prototype/characterization).
                Use this for "Plan to Throw One Away" exploratory work.
                Prototype code is physically isolated from production code.

Notes:
- Use --change-root and --truth-root to customize paths for your project layout.
- It writes markdown templates for proposal/design/tasks/verification and creates specs/ + evidence/ directories.
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 2
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

change_id="$1"
shift

project_root="${DEVBOOKS_PROJECT_ROOT:-$(pwd)}"
change_root="${DEVBOOKS_CHANGE_ROOT:-changes}"
truth_root="${DEVBOOKS_TRUTH_ROOT:-specs}"
force=false
prototype=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --project-root)
      project_root="${2:-}"
      shift 2
      ;;
    --change-root)
      change_root="${2:-}"
      shift 2
      ;;
    --truth-root)
      truth_root="${2:-}"
      shift 2
      ;;
    --force)
      force=true
      shift
      ;;
    --prototype)
      prototype=true
      shift
      ;;
    *)
      usage
      exit 2
      ;;
  esac
done

if [[ -z "$change_id" || "$change_id" == "-"* || "$change_id" =~ [[:space:]] ]]; then
  echo "error: invalid change-id: '$change_id'" >&2
  exit 2
fi

if [[ -z "$project_root" || -z "$change_root" || -z "$truth_root" ]]; then
  usage
  exit 2
fi

change_root="${change_root%/}"
truth_root="${truth_root%/}"
project_root="${project_root%/}"

if [[ "$change_root" = /* ]]; then
  change_dir="${change_root}/${change_id}"
else
  change_dir="${project_root}/${change_root}/${change_id}"
fi

mkdir -p "${change_dir}/specs" "${change_dir}/evidence"

write_file() {
  local path="$1"
  shift || true

  if [[ -f "$path" && "$force" != true ]]; then
    echo "skip: $path"
    cat >/dev/null
    return 0
  fi

  mkdir -p "$(dirname "$path")"
  cat >"$path"
  echo "wrote: $path"
}

escape_sed_repl() {
  printf '%s' "$1" | sed -e 's/[\\/&|]/\\&/g'
}

esc_change_id="$(escape_sed_repl "$change_id")"
esc_change_root="$(escape_sed_repl "$change_root")"
esc_truth_root="$(escape_sed_repl "$truth_root")"

render_template() {
  sed \
    -e "s|__CHANGE_ID__|${esc_change_id}|g" \
    -e "s|__CHANGE_ROOT__|${esc_change_root}|g" \
    -e "s|__TRUTH_ROOT__|${esc_truth_root}|g"
}

cat <<'EOF' | render_template | write_file "${change_dir}/proposal.md"
# Proposal: __CHANGE_ID__

> Output path: `__CHANGE_ROOT__/__CHANGE_ID__/proposal.md`
>
> Note: during the proposal phase, do not write implementation details; define only Why/What/Impact/Risks/Validation + debate topics.

## Why

- Problem:
- Goal:

## What Changes

- In scope:
- Out of scope (Non-goals):
- Scope (modules/capabilities/external contracts/data invariants):

## Impact

- External contracts (API/Schema/Event):
- Data & migrations:
- Affected modules & dependencies:
- Tests & quality gates:
- Value signal target: none (or specify metrics/dashboards/logs/business events)
- Value-stream bottleneck hypothesis: none (or describe likely queue points + mitigations)

## Risks & Rollback

- Risks:
- Degradation strategy:
- Rollback strategy:

## Validation

- Candidate acceptance anchors (tests/static checks/build/manual evidence):
- Evidence path: `__CHANGE_ROOT__/__CHANGE_ID__/evidence/` (recommended: `change-evidence.sh <change-id> -- <command>`)

## Debate Packet

- Contested points / questions that require judgment (<= 7):

## Decision Log

- Decision: Pending
- Summary:
- Questions for judgment:
EOF

cat <<'EOF' | render_template | write_file "${change_dir}/design.md"
# Design: __CHANGE_ID__

> Output path: `__CHANGE_ROOT__/__CHANGE_ID__/design.md`
>
> Write only What/Constraints + AC-xxx; do not write implementation steps or function body code.

## Problem Context

- Current behavior (observable facts):
- Key constraints (performance/security/compatibility/dependency direction):

## Goals / Non-goals

- Goals:
- Non-goals:

## Design Principles and Red Lines

- Principles:
- Red lines (non-negotiable):

## Target Architecture (optional)

- Boundaries and dependency direction:
- Extension points:

## Data and Contracts (as needed)

- Artifacts / Events / Schema：
- Compatibility strategy (versioning/migration/replay):

## Observability and Acceptance (as needed)

- Metrics/KPI/SLO:

## Documentation Impact

- [ ] No documentation update required
- [ ] New scripts
- [ ] New configuration
- [ ] New workflows
- [ ] API docs

| Doc | Required | Updated |
|-----|----------|---------|
| README.md | TBD | TBD |
| CHANGELOG.md | TBD | TBD |
| docs/<doc>.md | TBD | TBD |

## Design Rationale

- Why this approach:
- Alternatives considered:
- Why alternatives were rejected:

## Trade-offs

- What we give up:
- Known imperfections accepted:

## Acceptance Criteria

- AC-001 (A/B/C): <observable Pass/Fail criteria> (candidate anchors: tests/commands/evidence)
EOF

cat <<'EOF' | render_template | write_file "${change_dir}/tasks.md"
# Tasks: __CHANGE_ID__

> Output path: `__CHANGE_ROOT__/__CHANGE_ID__/tasks.md`
>
> Derive tasks only from `__CHANGE_ROOT__/__CHANGE_ID__/design.md`; do not derive the plan from `tests/`.

========================
Main Plan Area
========================

- [ ] MP1.1 <one-sentence goal>
  - Why:
  - Acceptance Criteria (AC-xxx):
  - Candidate Anchors (tests/commands/evidence):
  - Dependencies：
  - Risks：

========================
Temporary Plan Area
========================

- (empty / as needed)

========================
Context Switch Breakpoint Area
========================

- Last progress:
- Current blocker:
- Shortest next path:
EOF

cat <<'EOF' | render_template | write_file "${change_dir}/verification.md"
# verification.md (__CHANGE_ID__)

> Recommended path: `__CHANGE_ROOT__/__CHANGE_ID__/verification.md`
>
> Goal: make “Definition of Done” concrete with deterministic anchors and evidence, and provide traceability `AC-xxx -> Requirement/Scenario -> Test IDs -> Evidence`.

---

## Metadata

- Change ID: `__CHANGE_ID__`
- Status: Draft
  > Status lifecycle: Draft → Ready → Done → Archived
  > - Draft: Initial state
  > - Ready: Test plan ready (set by Test Owner)
  > - Done: All tests passed + Review approved (set by **Reviewer only**)
  > - Archived: Archived (set by Spec Gardener)
  > **Constraint: Coder is prohibited from modifying Status field**
- Links:
  - Proposal: `__CHANGE_ROOT__/__CHANGE_ID__/proposal.md`
  - Design: `__CHANGE_ROOT__/__CHANGE_ID__/design.md`
  - Tasks: `__CHANGE_ROOT__/__CHANGE_ID__/tasks.md`
  - Spec deltas: `__CHANGE_ROOT__/__CHANGE_ID__/specs/**`
- Owner: <you>
- Last updated: YYYY-MM-DD
- Test Owner (separate conversation): <session/agent>
- Coder (separate conversation): <session/agent>
- Red baseline evidence: `__CHANGE_ROOT__/__CHANGE_ID__/evidence/`

---

========================
A) Test Plan Instructions
========================

### Main Plan Area

- [ ] TP1.1 <one-sentence goal>
  - Why:
  - Acceptance criteria (AC-xxx / Requirement):
  - Test type: unit | contract | integration | e2e | fitness | static
  - Non-goals:
  - Candidate anchors (Test IDs / commands / evidence):

### Temporary Plan Area

- (empty / as needed)

### Context Switch Breakpoint Area

- Last progress:
- Current blocker:
- Shortest next path:

---

========================
B) Traceability Matrix
========================

| AC | Requirement/Scenario | Test IDs / Commands | Evidence / MANUAL-* | Status |
|---|---|---|---|---|
| AC-001 | <capability>/Requirement... | TEST-... / pnpm test ... | MANUAL-001 / link | TODO |

---

========================
C) Deterministic Anchors
========================

### 1) Behavior

- unit:
- integration:
- e2e:

### 2) Contract

- OpenAPI/Proto/Schema：
- contract tests：

### 3) Structure (fitness functions)

- layering / dependency direction / no cycles:

### 4) Static & security

- lint/typecheck/build：
- SAST/secret scan：
- report formats: json|xml (prefer machine-readable)

---

========================
D) MANUAL-* Checklist (manual or hybrid acceptance)
========================

- [ ] MANUAL-001 <acceptance item>
  - Pass/Fail criteria:
  - Evidence (screenshots/video/links/logs):
  - Owner/sign-off:

---

========================
E) Risks and degradation (optional)
========================

- Risks:
- Degradation strategy:
- Rollback strategy:

========================
F) Structural guardrail record
========================

- Conflict: none
- Impact assessment (cohesion/coupling/testability): none
- Alternative gates (complexity/coupling/dependency direction/test quality): none
- Decision and approval: none

========================
G) Value stream and metrics (optional, but must explicitly write "none")
========================

- Value signal target: none
- Delivery & stability metrics (optional DORA): none
- Observation window and triggers: none
- Evidence: none
EOF

specs_readme_path="${change_dir}/specs/README.md"
if [[ ! -f "$specs_readme_path" || "$force" == true ]]; then
  printf '%s\n' "# specs/" "" "Create one subdirectory per capability and write \`spec.md\` within it:" "" "- \`${change_root}/${change_id}/specs/<capability>/spec.md\`" "" | write_file "$specs_readme_path"
fi

# Prototype mode: create prototype track skeleton
if [[ "$prototype" == true ]]; then
  mkdir -p "${change_dir}/prototype/src" "${change_dir}/prototype/characterization"

  cat <<'EOF' | render_template | write_file "${change_dir}/prototype/PROTOTYPE.md"
# Prototype Declaration: __CHANGE_ID__

> This directory contains prototype code and must not be merged directly into production code.
>
> Source: The Mythical Man-Month, Ch. 11 “Plan to Throw One Away”

## Directory structure

```
prototype/
├── PROTOTYPE.md          # this file: declaration and status
├── src/                  # prototype implementation code (tech debt allowed)
└── characterization/     # characterization tests (record behavior, not acceptance)
```

## Status

- [ ] Prototype complete
- [ ] Characterization tests ready (behavior snapshots recorded)
- [ ] Decision made: promote / drop / iterate

## Constraints (must follow)

1. **Physical isolation**: prototype code stays under `prototype/src/`; do not copy directly into repo production code
2. **Role isolation unchanged**: Test Owner and Coder must use separate conversations/instances
3. **Characterization tests first**: Test Owner produces characterization tests (record behavior), not acceptance tests
4. **Promotion must be explicit**: run `prototype-promote.sh __CHANGE_ID__` and complete the checklist

## Prototype promotion checklist (must complete before promotion)

- [ ] Create production-grade `design.md` (distill What/Constraints/AC-xxx from prototype learnings)
- [ ] Test Owner produces acceptance verification in `verification.md` (replacing characterization tests)
- [ ] Run `prototype-promote.sh __CHANGE_ID__` and pass all gates
- [ ] Archive characterization tests to `tests/archived-characterization/__CHANGE_ID__/`

## Prototype drop checklist (when dropping)

- [ ] Record key learnings into the Decision Log in `proposal.md`
- [ ] Delete the `prototype/` directory

## Learning log

> What did we learn during prototyping? These insights should inform the production implementation.

- Technical findings:
- Risks clarified:
- Design constraints updated:
EOF

  echo "ok: created prototype track at ${change_dir}/prototype/"
fi

echo "ok: scaffolded ${change_dir}"
