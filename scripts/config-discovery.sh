#!/bin/bash
# scripts/config-discovery.sh
# DevBooks protocol discovery layer - configuration discovery script
#
# Purpose: discover and output the current project's DevBooks configuration
# Output: key=value (one per line), parseable by shell or an AI assistant
#
# Priority:
#   1. .devbooks/config.yaml (prefer root: dev-playbooks/)
#   2. dev-playbooks/ (when config.yaml is missing)
#   3. project.md (generic template protocol)
#
# Usage:
#   ./config-discovery.sh [project-root]
#   source <(./config-discovery.sh)  # import as shell variables
#
# Features:
#   - Supports dev-playbooks/ layout
#   - Loads constitution.md when present
#   - Pure Bash YAML parsing (no yq dependency)
#   - Deprecation warning: truth_root/change_root aliases (migrate to paths.specs/paths.changes)

set -euo pipefail

PROJECT_ROOT="${1:-.}"

# Log to stderr only
log_info() { echo "[INFO] $*" >&2; }
log_warn() { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# ============================================
# Pure Bash YAML parsing (no yq)
# ============================================

# Read a simple key/value pair
get_yaml_value() {
    local file="$1" key="$2"
    grep "^${key}:" "$file" 2>/dev/null | sed 's/^[^:]*: *//' | tr -d '"'"'" | tr -d '/' || true
}

# Read a nested key (1 level deep)
get_yaml_nested_value() {
    local file="$1" parent="$2" key="$3"
    # Look for key: under parent:
    awk -v parent="$parent" -v key="$key" '
        $0 ~ "^" parent ":" { in_parent = 1; next }
        in_parent && /^[a-z]/ { in_parent = 0 }
        in_parent && $0 ~ "^  " key ":" {
            gsub(/^[^:]*: */, "")
            gsub(/["'"'"']/, "")
            print
            exit
        }
    ' "$file" 2>/dev/null || true
}

# ============================================
# Resolve truth root
# ============================================

resolve_truth_root() {
    local root="$1"

    # Read root from config.yaml
    if [[ -f "${root}/.devbooks/config.yaml" ]]; then
        local config_root
        config_root=$(get_yaml_value "${root}/.devbooks/config.yaml" "root")
        if [[ -n "$config_root" && -d "${root}/${config_root}" ]]; then
            echo "${config_root}"
            return 0
        fi
    fi

    # Check dev-playbooks/ directory
    if [[ -d "${root}/dev-playbooks" ]]; then
        echo "dev-playbooks"
        return 0
    fi

    # Not found
    echo ""
    return 1
}

# ============================================
# Load constitution
# ============================================

load_constitution() {
    local config_root="$1"
    local constitution_file="${PROJECT_ROOT}/${config_root}/constitution.md"

    if [[ -f "$constitution_file" ]]; then
        log_info "Loading constitution from: $constitution_file"
        echo "constitution_loaded=true"
        echo "constitution_path=${config_root}/constitution.md"
        return 0
    else
        # Check whether constitution is required
        local require_constitution="false"
        if [[ -f "${PROJECT_ROOT}/.devbooks/config.yaml" ]]; then
            require_constitution=$(get_yaml_nested_value "${PROJECT_ROOT}/.devbooks/config.yaml" "constraints" "require_constitution")
        fi

        if [[ "$require_constitution" == "true" ]]; then
            log_error "Constitution file missing: $constitution_file"
            echo "constitution_loaded=false"
            echo "constitution_path="
            echo "constitution_error=missing"
            return 1
        fi

        log_warn "Constitution file not found (optional): $constitution_file"
        echo "constitution_loaded=false"
        echo "constitution_path="
        return 0
    fi
}

# ============================================
# Check whether a file exists
# ============================================

check_file() {
    [[ -f "$PROJECT_ROOT/$1" ]]
}

# ============================================
# Output config
# ============================================

output_config() {
    echo "config_source=$1"
    echo "protocol=$2"
    echo "truth_root=$3"
    echo "change_root=$4"
    echo "agents_doc=$5"

    # Optional fields
    [[ -n "${6:-}" ]] && echo "project_profile=$6"
    [[ -n "${7:-}" ]] && echo "apply_requires_role=$7"
}

# ============================================
# New format output (Dev-Playbooks)
# ============================================

output_config_v2() {
    local config_root="$1"

    echo "# Dev-Playbooks Configuration"
    echo "devbooks_version=2.0"
    echo "config_root=${config_root}"

    # Read paths from config.yaml
    if [[ -f "${PROJECT_ROOT}/.devbooks/config.yaml" ]]; then
        local specs_path changes_path staged_path
        specs_path=$(get_yaml_nested_value "${PROJECT_ROOT}/.devbooks/config.yaml" "paths" "specs")
        changes_path=$(get_yaml_nested_value "${PROJECT_ROOT}/.devbooks/config.yaml" "paths" "changes")
        staged_path=$(get_yaml_nested_value "${PROJECT_ROOT}/.devbooks/config.yaml" "paths" "staged")

        echo "specs_dir=${config_root}/${specs_path:-specs/}"
        echo "changes_dir=${config_root}/${changes_path:-changes/}"
        echo "staged_dir=${config_root}/${staged_path:-specs/_staged/}"
    else
        echo "specs_dir=${config_root}/specs/"
        echo "changes_dir=${config_root}/changes/"
        echo "staged_dir=${config_root}/specs/_staged/"
    fi

    # Fitness configuration
    if [[ -f "${PROJECT_ROOT}/.devbooks/config.yaml" ]]; then
        local fitness_mode fitness_rules
        fitness_mode=$(get_yaml_nested_value "${PROJECT_ROOT}/.devbooks/config.yaml" "fitness" "mode")
        fitness_rules=$(get_yaml_nested_value "${PROJECT_ROOT}/.devbooks/config.yaml" "fitness" "rules_file")

        echo "fitness_mode=${fitness_mode:-warn}"
        echo "fitness_rules=${config_root}/${fitness_rules:-specs/architecture/fitness-rules.md}"
    fi

    # AC tracing configuration
    if [[ -f "${PROJECT_ROOT}/.devbooks/config.yaml" ]]; then
        local coverage_threshold
        coverage_threshold=$(get_yaml_nested_value "${PROJECT_ROOT}/.devbooks/config.yaml" "tracing" "coverage_threshold")
        echo "ac_coverage_threshold=${coverage_threshold:-80}"
    fi
}

# ============================================
# Main logic
# ============================================

main() {
    # Resolve truth root
    local truth_root
    truth_root=$(resolve_truth_root "$PROJECT_ROOT") || {
        log_warn "No DevBooks configuration found"
        log_warn "Searched for:"
        log_warn "  - .devbooks/config.yaml with root: dev-playbooks/"
        log_warn "  - dev-playbooks/"
        log_warn "  - dev-playbooks/project.md"
        log_warn "  - project.md"

        echo "config_source=none"
        echo "protocol=unknown"
        echo "truth_root="
        echo "change_root="
        echo "agents_doc="

        exit 1
    }

    log_info "Found configuration root: $truth_root"

    # Load constitution (if present)
    load_constitution "$truth_root" || {
        log_error "Constitution loading failed"
        exit 1
    }

    # Determine protocol type
    case "$truth_root" in
        dev-playbooks)
            # DevBooks protocol
            log_info "Using DevBooks protocol"

            output_config \
                ".devbooks/config.yaml" \
                "devbooks" \
                "${truth_root}/specs/" \
                "${truth_root}/changes/" \
                "${truth_root}/project.md" \
                "${truth_root}/specs/_meta/project-profile.md" \
                "true"

            echo ""
            output_config_v2 "$truth_root"
            ;;

        *)
            # Template protocol
            log_info "Using template protocol"

            output_config \
                "project.md" \
                "template" \
                "specs/" \
                "changes/" \
                "project.md" \
                "specs/_meta/project-profile.md" \
                "false"
            ;;
    esac

    exit 0
}

# Run main
main
