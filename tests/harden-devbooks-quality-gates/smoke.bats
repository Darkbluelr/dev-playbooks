#!/usr/bin/env bats

PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."

CHANGE_CHECK="${PROJECT_ROOT}/skills/devbooks-delivery-workflow/scripts/change-check.sh"
HANDOFF_CHECK="${PROJECT_ROOT}/skills/devbooks-delivery-workflow/scripts/handoff-check.sh"
ENV_MATCH_CHECK="${PROJECT_ROOT}/skills/devbooks-delivery-workflow/scripts/env-match-check.sh"
PROGRESS_DASHBOARD="${PROJECT_ROOT}/skills/devbooks-delivery-workflow/scripts/progress-dashboard.sh"
AUDIT_SCOPE="${PROJECT_ROOT}/skills/devbooks-delivery-workflow/scripts/audit-scope.sh"

setup() {
  TEST_TMP="$(mktemp -d "${TMPDIR:-/tmp}/devbooks-bats.XXXXXX")"
}

teardown() {
  if [[ -n "${TEST_TMP:-}" && -d "${TEST_TMP:-}" ]]; then
    rm -rf "$TEST_TMP"
  fi
}

create_change_dir() {
  local change_id="$1"
  mkdir -p "${TEST_TMP}/changes/${change_id}"
  echo "${TEST_TMP}/changes/${change_id}"
}

@test "Makefile test target exists" {
  [ -f "${PROJECT_ROOT}/Makefile" ]
  run make -C "$PROJECT_ROOT" -n test
  [ "$status" -eq 0 ]
}

@test "change-check.sh supports --help" {
  [ -x "$CHANGE_CHECK" ]
  run "$CHANGE_CHECK" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^usage: ]]
}

@test "handoff-check.sh fails when handoff.md is missing" {
  [ -x "$HANDOFF_CHECK" ]
  create_change_dir "ac004-no-handoff" >/dev/null

  run "$HANDOFF_CHECK" "ac004-no-handoff" --project-root "$TEST_TMP" --change-root "changes"
  [ "$status" -ne 0 ]
  [[ "$output" =~ handoff\.md ]]
}

@test "handoff-check.sh passes with complete confirmation" {
  local change_dir
  change_dir="$(create_change_dir "ac004-signed")"
  cat > "${change_dir}/handoff.md" <<'EOF'
# Role Handoff Record

## Confirmation
- [x] Test Owner confirms handoff complete
- [x] Coder confirms receipt
EOF

  run "$HANDOFF_CHECK" "ac004-signed" --project-root "$TEST_TMP" --change-root "changes"
  [ "$status" -eq 0 ]
}

@test "env-match-check.sh fails without environment section" {
  local change_dir
  change_dir="$(create_change_dir "ac006-no-env")"
  cat > "${change_dir}/verification.md" <<'EOF'
# Verification: test-change

## A) Test Plan
Test plan.
EOF

  run "$ENV_MATCH_CHECK" "ac006-no-env" --project-root "$TEST_TMP" --change-root "changes"
  [ "$status" -ne 0 ]
  [[ "$output" =~ environment ]]
}

@test "env-match-check.sh passes with environment section heading" {
  local change_dir
  change_dir="$(create_change_dir "ac006-with-env")"
  cat > "${change_dir}/verification.md" <<'EOF'
# Verification: test-change

## Test Environment Declaration
- Runtime: macOS / Linux
- Database: N/A
- External: none
EOF

  run "$ENV_MATCH_CHECK" "ac006-with-env" --project-root "$TEST_TMP" --change-root "changes"
  [ "$status" -eq 0 ]
}

@test "progress-dashboard.sh generates output" {
  local change_dir
  change_dir="$(create_change_dir "ac010-dashboard")"
  cat > "${change_dir}/proposal.md" <<'EOF'
# Proposal: ac010-dashboard
EOF

  run "$PROGRESS_DASHBOARD" "ac010-dashboard" --project-root "$TEST_TMP" --change-root "changes"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Progress Dashboard" ]]
}

@test "audit-scope.sh supports --help" {
  [ -x "$AUDIT_SCOPE" ]
  run "$AUDIT_SCOPE" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^usage: ]]
}

