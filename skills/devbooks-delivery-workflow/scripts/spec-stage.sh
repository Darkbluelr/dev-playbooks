#!/bin/bash
# skills/devbooks-delivery-workflow/scripts/spec-stage.sh
# Spec staging script
#
# Syncs a change package's spec deltas into the staging layer.
#
# Usage:
#   ./spec-stage.sh <change-id> [options]
#   ./spec-stage.sh --help
#
# Exit codes:
#   0 - success
#   1 - failure (conflicts)
#   2 - usage error

set -euo pipefail

VERSION="1.0.0"

project_root="."
change_root="changes"
truth_root="specs"
dry_run=false
force=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
Spec staging script (spec-stage.sh)

usage:
  ./spec-stage.sh <change-id> [options]

options:
  --project-root DIR  Project root
  --change-root DIR   Change root
  --truth-root DIR    Truth root
  --dry-run           Dry run (no filesystem changes)
  --force             Force stage (ignore conflicts)
  --help, -h          Show help

exit codes:
  0 - success
  1 - failure
  2 - usage error

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
            --version|-v) echo "spec-stage.sh v${VERSION}"; exit 0 ;;
            --project-root) project_root="${2:-.}"; shift 2 ;;
            --change-root) change_root="${2:-changes}"; shift 2 ;;
            --truth-root) truth_root="${2:-specs}"; shift 2 ;;
            --dry-run) dry_run=true; shift ;;
            --force) force=true; shift ;;
            -*) log_error "Unknown option: $1"; exit 2 ;;
            *) change_id="$1"; shift ;;
        esac
    done

    if [[ -z "$change_id" ]]; then
        log_error "Missing change-id"
        exit 2
    fi

    local change_dir="${project_root}/${change_root}/${change_id}"
    local staged_dir="${project_root}/${truth_root}/_staged/${change_id}"
    local specs_delta_dir="${change_dir}/specs"

    log_info "staging change: ${change_id}"

    if [[ ! -d "$specs_delta_dir" ]]; then
        log_info "no spec deltas; skipping"
        exit 0
    fi

    # Use spec-preview to check for conflicts
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [[ "$force" != true && -x "${script_dir}/spec-preview.sh" ]]; then
        if ! "${script_dir}/spec-preview.sh" "$change_id" --project-root "$project_root" --change-root "$change_root" --truth-root "$truth_root"; then
            log_error "conflicts detected; use --force to stage anyway"
            exit 1
        fi
    fi

    # Execute staging
    if [[ "$dry_run" == true ]]; then
        log_info "[DRY-RUN] would create: ${staged_dir}"
        log_info "[DRY-RUN] would copy: ${specs_delta_dir}/* -> ${staged_dir}/"
    else
        mkdir -p "$staged_dir"
        cp -r "$specs_delta_dir"/* "$staged_dir"/
        log_pass "staged to: ${staged_dir}"
    fi

    exit 0
}

main "$@"
