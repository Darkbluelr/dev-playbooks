#!/bin/bash
# skills/devbooks-delivery-workflow/scripts/spec-rollback.sh
# Spec rollback script
#
# Rolls back spec staging operations.
#
# Usage:
#   ./spec-rollback.sh <change-id> [options]
#   ./spec-rollback.sh --help
#
# Exit codes:
#   0 - success
#   1 - failure
#   2 - usage error

set -euo pipefail

VERSION="1.0.0"

project_root="."
truth_root="specs"
change_root="changes"
target="staged"
dry_run=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
Spec rollback script (spec-rollback.sh)

usage:
  ./spec-rollback.sh <change-id> [options]

options:
  --project-root DIR  Project root
  --truth-root DIR    Truth root
  --change-root DIR   Change root
  --target TARGET     Target: staged | draft
  --dry-run           Dry run
  --help, -h          Show help

targets:
  staged - clear the staging layer (keep spec deltas in the change package)
  draft  - roll back to change-package state (clear staging; do not touch specs)

EOF
}

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; }

main() {
    local change_id=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h) show_help; exit 0 ;;
            --version|-v) echo "spec-rollback.sh v${VERSION}"; exit 0 ;;
            --project-root) project_root="${2:-.}"; shift 2 ;;
            --truth-root) truth_root="${2:-specs}"; shift 2 ;;
            --change-root) change_root="${2:-changes}"; shift 2 ;;
            --target) target="${2:-staged}"; shift 2 ;;
            --dry-run) dry_run=true; shift ;;
            -*) log_error "Unknown option: $1"; exit 2 ;;
            *) change_id="$1"; shift ;;
        esac
    done

    if [[ -z "$change_id" ]]; then
        log_error "Missing change-id"
        exit 2
    fi

    case "$target" in
        staged|draft) ;;
        *) log_error "Invalid target: $target"; exit 2 ;;
    esac

    local staged_dir="${project_root}/${truth_root}/_staged/${change_id}"

    log_info "rolling back change: ${change_id}"
    log_info "target: ${target}"

    case "$target" in
        staged)
            # Clear staging layer
            if [[ -d "$staged_dir" ]]; then
                if [[ "$dry_run" == true ]]; then
                    log_info "[DRY-RUN] would remove: ${staged_dir}"
                else
                    rm -rf "$staged_dir"
                    log_pass "cleared staging: ${staged_dir}"
                fi
            else
                log_info "staging is empty; nothing to do"
            fi
            ;;

        draft)
            # Roll back to change-package state (clear staging)
            if [[ -d "$staged_dir" ]]; then
                if [[ "$dry_run" == true ]]; then
                    log_info "[DRY-RUN] would remove: ${staged_dir}"
                else
                    rm -rf "$staged_dir"
                    log_pass "rolled back to draft state"
                fi
            else
                log_info "already in draft state"
            fi
            ;;
    esac

    exit 0
}

main "$@"
