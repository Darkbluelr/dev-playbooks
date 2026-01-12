#!/bin/bash
# skills/devbooks-delivery-workflow/scripts/ac-trace-check.sh
# AC-ID trace coverage checker
#
# Checks trace coverage of AC-IDs from design to tests.
#
# Usage:
#   ./ac-trace-check.sh <change-id> [options]
#   ./ac-trace-check.sh --help
#
# Options:
#   --threshold N       Coverage threshold (default: 80)
#   --output FORMAT     Output format (text|json, default: text)
#   --project-root DIR  Project root
#   --change-root DIR   Change root
#
# Exit codes:
#   0 - coverage meets threshold
#   1 - coverage below threshold
#   2 - usage error

set -euo pipefail

# Version
VERSION="1.0.0"

# Defaults
threshold=80
output_format="text"
project_root="."
change_root="changes"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Help
show_help() {
    cat << 'EOF'
AC-ID trace coverage checker (ac-trace-check.sh)

usage:
  ./ac-trace-check.sh <change-id> [options]

options:
  --threshold N       Coverage threshold, default 80 (percent)
  --output FORMAT     Output format: text | json, default text
  --project-root DIR  Project root, default: current directory
  --change-root DIR   Change root, default: changes
  --help, -h          Show help
  --version, -v       Show version

algorithm:
  1. Extract all AC-xxx from design.md
  2. Extract referenced AC-xxx from tasks.md
  3. Extract AC-xxx from tests/
  4. Coverage = (covered AC count) / (total AC count) × 100%
  5. Compare to threshold and return exit code

exit codes:
  0 - coverage meets threshold
  1 - coverage below threshold
  2 - usage error

examples:
  ./ac-trace-check.sh my-feature                     # default threshold
  ./ac-trace-check.sh my-feature --threshold 90      # 90% threshold
  ./ac-trace-check.sh my-feature --output json       # JSON output
  ./ac-trace-check.sh my-feature --change-root dev-playbooks/changes

EOF
}

# Version output
show_version() {
    echo "ac-trace-check.sh v${VERSION}"
}

# Logging helpers
log_info() {
    [[ "$output_format" == "text" ]] && echo -e "${BLUE}[INFO]${NC} $*" >&2
}

log_pass() {
    [[ "$output_format" == "text" ]] && echo -e "${GREEN}[PASS]${NC} $*"
}

log_fail() {
    [[ "$output_format" == "text" ]] && echo -e "${RED}[FAIL]${NC} $*"
}

log_warn() {
    [[ "$output_format" == "text" ]] && echo -e "${YELLOW}[WARN]${NC} $*"
}

# Extract AC-IDs
extract_ac_ids() {
    local file="$1"
    grep -oE "AC-[A-Z0-9]+" "$file" 2>/dev/null | sort -u || true
}

# Extract AC-IDs from a directory
extract_ac_ids_from_dir() {
    local dir="$1"
    local pattern="${2:-*.test.*}"
    find "$dir" -type f \( -name "*.test.ts" -o -name "*.test.js" -o -name "*.spec.ts" -o -name "*.spec.js" -o -name "*.bats" -o -name "*_test.py" -o -name "*_test.go" \) 2>/dev/null | while read -r file; do
        grep -oE "AC-[A-Z0-9]+" "$file" 2>/dev/null || true
    done | sort -u
}

# Calculate coverage
calculate_coverage() {
    local design_acs="$1"
    local tasks_acs="$2"
    local test_acs="$3"

    # Build AC lists
    local design_list=()
    local tasks_list=()
    local test_list=()
    local covered_list=()
    local uncovered_list=()

    while IFS= read -r ac; do
        [[ -n "$ac" ]] && design_list+=("$ac")
    done <<< "$design_acs"

    while IFS= read -r ac; do
        [[ -n "$ac" ]] && tasks_list+=("$ac")
    done <<< "$tasks_acs"

    while IFS= read -r ac; do
        [[ -n "$ac" ]] && test_list+=("$ac")
    done <<< "$test_acs"

    local total=${#design_list[@]}

    if [[ $total -eq 0 ]]; then
        # No ACs: treat as 100% coverage
        echo "100 0 0"
        return
    fi

    # Count covered ACs
    local covered=0
    for ac in "${design_list[@]}"; do
        local in_test=false
        for test_ac in "${test_list[@]}"; do
            if [[ "$ac" == "$test_ac" ]]; then
                in_test=true
                covered_list+=("$ac")
                break
            fi
        done
        if [[ "$in_test" == false ]]; then
            uncovered_list+=("$ac")
        else
            covered=$((covered + 1))
        fi
    done

    local rate=0
    if [[ $total -gt 0 ]]; then
        rate=$((covered * 100 / total))
    fi

    echo "$rate $covered $total"

    # Output uncovered list to stderr
    if [[ ${#uncovered_list[@]} -gt 0 && "$output_format" == "text" ]]; then
        echo "uncovered: ${uncovered_list[*]}" >&2
    fi
}

# Main
main() {
    local change_id=""

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
            --threshold)
                threshold="${2:-80}"
                shift 2
                ;;
            --output)
                output_format="${2:-text}"
                shift 2
                ;;
            --project-root)
                project_root="${2:-.}"
                shift 2
                ;;
            --change-root)
                change_root="${2:-changes}"
                shift 2
                ;;
            -*)
                echo "error: unknown option: $1" >&2
                echo "Use --help for usage" >&2
                exit 2
                ;;
            *)
                change_id="$1"
                shift
                ;;
        esac
    done

    # Validate args
    if [[ -z "$change_id" ]]; then
        echo "error: missing change-id" >&2
        echo "Use --help for usage" >&2
        exit 2
    fi

    # Build paths
    local change_dir
    if [[ "$change_root" = /* ]]; then
        change_dir="${change_root}/${change_id}"
    else
        change_dir="${project_root}/${change_root}/${change_id}"
    fi

    local design_file="${change_dir}/design.md"
    local tasks_file="${change_dir}/tasks.md"
    local tests_dir="${project_root}/tests"

    log_info "checking change: ${change_id}"
    log_info "design file: ${design_file}"
    log_info "tasks file: ${tasks_file}"
    log_info "tests dir: ${tests_dir}"

    # Check file existence
    if [[ ! -f "$design_file" ]]; then
        if [[ "$output_format" == "json" ]]; then
            echo '{"error": "design.md not found", "coverage": 0}'
        else
            log_fail "design.md not found: ${design_file}"
        fi
        exit 1
    fi

    # Extract AC-IDs
    local design_acs tasks_acs test_acs

    design_acs=$(extract_ac_ids "$design_file")
    tasks_acs=""
    if [[ -f "$tasks_file" ]]; then
        tasks_acs=$(extract_ac_ids "$tasks_file")
    fi

    test_acs=""
    if [[ -d "$tests_dir" ]]; then
        test_acs=$(extract_ac_ids_from_dir "$tests_dir")
    fi

    # Calculate coverage
    local result
    result=$(calculate_coverage "$design_acs" "$tasks_acs" "$test_acs")
    read -r rate covered total <<< "$result"

    # Output results
    if [[ "$output_format" == "json" ]]; then
        local uncovered_json="[]"
        # Recompute uncovered list
        local uncovered_acs=""
        while IFS= read -r ac; do
            [[ -z "$ac" ]] && continue
            if ! echo "$test_acs" | grep -qx "$ac"; then
                if [[ -z "$uncovered_acs" ]]; then
                    uncovered_acs="\"$ac\""
                else
                    uncovered_acs="${uncovered_acs},\"$ac\""
                fi
            fi
        done <<< "$design_acs"

        cat << EOF
{
  "change_id": "${change_id}",
  "coverage": ${rate},
  "threshold": ${threshold},
  "covered": ${covered},
  "total": ${total},
  "uncovered": [${uncovered_acs}],
  "pass": $([ "$rate" -ge "$threshold" ] && echo "true" || echo "false")
}
EOF
    else
        echo ""
        echo "AC trace coverage report"
        echo "================"
        echo "change: ${change_id}"
        echo "total ACs: ${total}"
        echo "covered: ${covered}"
        echo "coverage: ${rate}%"
        echo "threshold: ${threshold}%"
        echo ""

        if [[ $rate -ge $threshold ]]; then
            log_pass "coverage ${rate}% >= ${threshold}%: pass"
            exit 0
        else
            log_fail "coverage ${rate}% < ${threshold}%: fail"
            exit 1
        fi
    fi

    # Exit code (json mode)
    if [[ $rate -ge $threshold ]]; then
        exit 0
    else
        exit 1
    fi
}

# Run
main "$@"
