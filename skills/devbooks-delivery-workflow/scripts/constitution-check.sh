#!/bin/bash
# skills/devbooks-delivery-workflow/scripts/constitution-check.sh
# Constitution compliance check script
#
# Checks whether constitution.md exists and has the required structure.
#
# Usage:
#   ./constitution-check.sh [project-root]
#   ./constitution-check.sh --help
#
# Exit codes:
#   0 - constitution exists and is valid
#   1 - constitution missing or invalid
#   2 - usage error

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Help
show_help() {
    cat << 'EOF'
Constitution compliance check (constitution-check.sh)

usage:
  ./constitution-check.sh [options] [project-root]

options:
  --help, -h       Show this help
  --version, -v    Show version
  --quiet, -q      Quiet mode (errors only)

args:
  project-root     Project root (default: current directory)

checks:
  1. constitution.md exists
  2. Contains a "Part Zero" section
  3. Contains at least one "GIP-" rule heading
  4. Contains an "Escape Hatch(es)" section

exit codes:
  0 - constitution exists and is valid
  1 - constitution missing or invalid
  2 - usage error

examples:
  ./constitution-check.sh                    # check current directory
  ./constitution-check.sh /path/to/project   # check a specific directory
  ./constitution-check.sh --quiet            # quiet mode

EOF
}

# Version output
show_version() {
    echo "constitution-check.sh v${VERSION}"
}

# Logging helpers
log_info() {
    [[ "$QUIET" == "false" ]] && echo -e "${GREEN}[INFO]${NC} $*"
}

log_warn() {
    [[ "$QUIET" == "false" ]] && echo -e "${YELLOW}[WARN]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $*" >&2
}

log_pass() {
    [[ "$QUIET" == "false" ]] && echo -e "${GREEN}[PASS]${NC} $*"
}

# Resolve truth root
# Prefer dev-playbooks/, fallback to devbooks/
resolve_truth_root() {
    local root="$1"

    # Check root mapping from .devbooks/config.yaml
    if [[ -f "${root}/.devbooks/config.yaml" ]]; then
        local config_root
        config_root=$(grep "^root:" "${root}/.devbooks/config.yaml" 2>/dev/null | sed 's/root: *//' | tr -d "'" | tr -d '"' | tr -d '/' || true)
        if [[ -n "$config_root" && -d "${root}/${config_root}" ]]; then
            echo "${root}/${config_root}"
            return 0
        fi
    fi

    # Prefer dev-playbooks/
    if [[ -d "${root}/dev-playbooks" ]]; then
        echo "${root}/dev-playbooks"
        return 0
    fi

    # Fallback to devbooks/
    if [[ -d "${root}/devbooks" ]]; then
        echo "${root}/devbooks"
        return 0
    fi

    # Not found
    echo ""
    return 1
}

# Check constitution
check_constitution() {
    local root="${1:-.}"
    local errors=0
    local checks_passed=0
    local total_checks=4

    # Resolve truth root
    local config_root
    config_root=$(resolve_truth_root "$root") || {
        log_error "cannot locate truth root (dev-playbooks/ or devbooks/)"
        return 1
    }

    local constitution="${config_root}/constitution.md"

    log_info "checking constitution file: $constitution"

    # Check 1: file exists
    if [[ -f "$constitution" ]]; then
        log_pass "constitution.md exists"
        ((checks_passed++))
    else
        log_error "constitution.md not found: $constitution"
        ((errors++))
    fi

    # If file is missing, return early
    if [[ ! -f "$constitution" ]]; then
        echo ""
        log_error "constitution check failed: $errors error(s)"
        return 1
    fi

    # Check 2: Part Zero section
    if grep -qE "^#+ *Part Zero" "$constitution" 2>/dev/null; then
        log_pass "contains 'Part Zero' section"
        ((checks_passed++))
    else
        log_error "missing 'Part Zero' section"
        ((errors++))
    fi

    # Check 3: GIP rules
    local gip_count
    gip_count=$(grep -cE "^#+ *GIP-[0-9]+" "$constitution" 2>/dev/null || echo "0")
    if [[ "$gip_count" -gt 0 ]]; then
        log_pass "contains GIP rules (${gip_count})"
        ((checks_passed++))
    else
        log_error "missing GIP rules (need at least 1 GIP-xxx heading)"
        ((errors++))
    fi

    # Check 4: Escape Hatch(es) section
    if grep -qE "^#+ *Escape Hatches?" "$constitution" 2>/dev/null; then
        log_pass "contains 'Escape Hatch(es)' section"
        ((checks_passed++))
    else
        log_error "missing 'Escape Hatch(es)' section"
        ((errors++))
    fi

    # Summary
    echo ""
    if [[ "$errors" -eq 0 ]]; then
        log_info "constitution checks passed: ${checks_passed}/${total_checks}"
        return 0
    else
        log_error "constitution checks failed: ${checks_passed}/${total_checks} passed, ${errors} error(s)"
        return 1
    fi
}

# Main
main() {
    QUIET="false"
    local project_root="."

    # Parse args
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                show_version
                exit 0
                ;;
            --quiet|-q)
                QUIET="true"
                shift
                ;;
            -*)
                log_error "unknown option: $1"
                echo "hint: use --help" >&2
                exit 2
                ;;
            *)
                project_root="$1"
                shift
                ;;
        esac
    done

    # Validate project root
    if [[ ! -d "$project_root" ]]; then
        log_error "project root not found: $project_root"
        exit 2
    fi

    # Run checks
    if check_constitution "$project_root"; then
        exit 0
    else
        exit 1
    fi
}

# Run
main "$@"
