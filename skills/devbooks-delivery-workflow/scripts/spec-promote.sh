#!/bin/bash
# skills/devbooks-delivery-workflow/scripts/spec-promote.sh
# Spec promotion script
#
# Promotes staged spec deltas into the truth root.
#
# Usage:
#   ./spec-promote.sh <change-id> [options]
#   ./spec-promote.sh --help
#
# Exit codes:
#   0 - success
#   1 - failure
#   2 - usage error

set -euo pipefail

VERSION="1.0.0"

project_root="."
truth_root="specs"
dry_run=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
Spec promotion script (spec-promote.sh)

usage:
  ./spec-promote.sh <change-id> [options]

options:
  --project-root DIR  Project root
  --truth-root DIR    Truth root
  --dry-run           Dry run
  --help, -h          Show help

flow:
  1. Verify preconditions (already staged)
  2. Copy _staged/<change-id>/ into specs/
  3. Remove _staged/<change-id>/

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
            --version|-v) echo "spec-promote.sh v${VERSION}"; exit 0 ;;
            --project-root) project_root="${2:-.}"; shift 2 ;;
            --truth-root) truth_root="${2:-specs}"; shift 2 ;;
            --dry-run) dry_run=true; shift ;;
            -*) log_error "Unknown option: $1"; exit 2 ;;
            *) change_id="$1"; shift ;;
        esac
    done

    if [[ -z "$change_id" ]]; then
        log_error "Missing change-id"
        exit 2
    fi

    local staged_dir="${project_root}/${truth_root}/_staged/${change_id}"
    local specs_dir="${project_root}/${truth_root}"

    log_info "promoting change: ${change_id}"

    # Preconditions
    if [[ ! -d "$staged_dir" ]]; then
        log_error "staged content not found: ${staged_dir}"
        log_error "run spec-stage.sh first"
        exit 1
    fi

    # Promote files
    local promoted=0
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        local relative_path="${file#$staged_dir/}"
        local target_path="${specs_dir}/${relative_path}"
        local target_dir
        target_dir=$(dirname "$target_path")

        if [[ "$dry_run" == true ]]; then
            log_info "[DRY-RUN] ${relative_path} -> ${target_path}"
        else
            mkdir -p "$target_dir"
            cp "$file" "$target_path"
        fi
        promoted=$((promoted + 1))
    done < <(find "$staged_dir" -type f 2>/dev/null)

    # Cleanup staged directory
    if [[ "$dry_run" == true ]]; then
        log_info "[DRY-RUN] would remove: ${staged_dir}"
    else
        rm -rf "$staged_dir"
    fi

    log_pass "promoted ${promoted} file(s) into truth root"
    exit 0
}

main "$@"
