#!/bin/bash
# skills/devbooks-delivery-workflow/scripts/migrate-from-openspec.sh
# OpenSpec → DevBooks 2.0 migration script
#
# Migrates `openspec/` directory structure into `dev-playbooks/`.
# Supports idempotent execution, checkpoints, and reference updates.
#
# Usage:
#   ./migrate-from-openspec.sh [options]
#   ./migrate-from-openspec.sh --help
#
# Exit codes:
#   0 - success
#   1 - failure
#   2 - usage error

set -euo pipefail

VERSION="1.0.0"

# Defaults
project_root="."
dry_run=false
keep_old=false
force=false
checkpoint_file=""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    cat << 'EOF'
OpenSpec → DevBooks 2.0 migration (migrate-from-openspec.sh)

usage:
  ./migrate-from-openspec.sh [options]

options:
  --project-root DIR  Project root (default: current directory)
  --dry-run           Dry run (no filesystem changes)
  --keep-old          Keep `openspec/` after migration
  --force             Force re-run of all steps (ignore checkpoints)
  --help, -h          Show help

steps:
  1. [STRUCTURE] Create `dev-playbooks/` directory structure
  2. [CONTENT]   Migrate specs/ and changes/ content
  3. [CONFIG]    Create/update `.devbooks/config.yaml`
  4. [REFS]      Update path references in docs/scripts
  5. [CLEANUP]   Cleanup (optionally keep old directory)

features:
  - idempotent: safe to re-run
  - checkpoints: resume support
  - reference updates: batch path replacement
  - rollback: keep `openspec/` via --keep-old

EOF
}

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $*"; }

# Checkpoint management
init_checkpoint() {
    checkpoint_file="${project_root}/.devbooks/.migrate-checkpoint"
    if [[ "$force" == true ]]; then
        rm -f "$checkpoint_file" 2>/dev/null || true
    fi
}

save_checkpoint() {
    local step="$1"
    if [[ "$dry_run" == false ]]; then
        mkdir -p "$(dirname "$checkpoint_file")"
        echo "$step" >> "$checkpoint_file"
    fi
}

is_step_done() {
    local step="$1"
    if [[ -f "$checkpoint_file" ]]; then
        grep -qx "$step" "$checkpoint_file" 2>/dev/null
        return $?
    fi
    return 1
}

# Step 1: Create directory structure
step_structure() {
    log_step "1. Create directory structure"

    if is_step_done "STRUCTURE" && [[ "$force" == false ]]; then
        log_info "directory structure already created (skipping)"
        return 0
    fi

    local dirs=(
        "dev-playbooks"
        "dev-playbooks/specs"
        "dev-playbooks/specs/_meta"
        "dev-playbooks/specs/_meta/anti-patterns"
        "dev-playbooks/specs/_staged"
        "dev-playbooks/specs/architecture"
        "dev-playbooks/changes"
        "dev-playbooks/changes/archive"
        "dev-playbooks/scripts"
    )

    for dir in "${dirs[@]}"; do
        local full_path="${project_root}/${dir}"
        if [[ ! -d "$full_path" ]]; then
            if [[ "$dry_run" == true ]]; then
                log_info "[DRY-RUN] mkdir -p $full_path"
            else
                mkdir -p "$full_path"
            fi
        fi
    done

    save_checkpoint "STRUCTURE"
    log_pass "directory structure created"
}

# Step 2: Migrate content
step_content() {
    log_step "2. Migrate content"

    if is_step_done "CONTENT" && [[ "$force" == false ]]; then
        log_info "content already migrated (skipping)"
        return 0
    fi

    local openspec_dir="${project_root}/openspec"

    if [[ ! -d "$openspec_dir" ]]; then
        log_warn "openspec/ directory not found; skipping content migration"
        save_checkpoint "CONTENT"
        return 0
    fi

    # Migrate specs/
    if [[ -d "${openspec_dir}/specs" ]]; then
        log_info "migrating specs/ ..."
        if [[ "$dry_run" == true ]]; then
            log_info "[DRY-RUN] cp -r ${openspec_dir}/specs/* ${project_root}/dev-playbooks/specs/"
        else
            cp -r "${openspec_dir}/specs/"* "${project_root}/dev-playbooks/specs/" 2>/dev/null || true
        fi
    fi

    # Migrate changes/
    if [[ -d "${openspec_dir}/changes" ]]; then
        log_info "migrating changes/ ..."
        if [[ "$dry_run" == true ]]; then
            log_info "[DRY-RUN] cp -r ${openspec_dir}/changes/* ${project_root}/dev-playbooks/changes/"
        else
            cp -r "${openspec_dir}/changes/"* "${project_root}/dev-playbooks/changes/" 2>/dev/null || true
        fi
    fi

    # Migrate project.md
    if [[ -f "${openspec_dir}/project.md" ]]; then
        log_info "migrating project.md ..."
        if [[ "$dry_run" == true ]]; then
            log_info "[DRY-RUN] cp ${openspec_dir}/project.md ${project_root}/dev-playbooks/project.md"
        else
            cp "${openspec_dir}/project.md" "${project_root}/dev-playbooks/project.md" 2>/dev/null || true
        fi
    fi

    save_checkpoint "CONTENT"
    log_pass "content migration complete"
}

# Step 3: Create/update config
step_config() {
    log_step "3. Create/update config"

    if is_step_done "CONFIG" && [[ "$force" == false ]]; then
        log_info "config already updated (skipping)"
        return 0
    fi

    local config_dir="${project_root}/.devbooks"
    local config_file="${config_dir}/config.yaml"

    if [[ "$dry_run" == true ]]; then
        log_info "[DRY-RUN] would create/update ${config_file}"
    else
        mkdir -p "$config_dir"

        # Write when missing or not configured for dev-playbooks/
        if [[ ! -f "$config_file" ]] || ! grep -q "root: dev-playbooks/" "$config_file" 2>/dev/null; then
            cat > "$config_file" << 'YAML'
# DevBooks 2.0 config
# Generated by migrate-from-openspec.sh

root: dev-playbooks/
constitution: constitution.md
project: project.md

paths:
  specs: specs/
  changes: changes/
  staged: specs/_staged/
  archive: changes/archive/

constraints:
  require_constitution: true
  allow_legacy_protocol: false

fitness:
  mode: warn
  rules_file: specs/architecture/fitness-rules.md

tracing:
  coverage_threshold: 80
  evidence_dir: evidence/
YAML
        fi
    fi

    save_checkpoint "CONFIG"
    log_pass "config update complete"
}

# Step 4: Update references
step_refs() {
    log_step "4. Update path references"

    if is_step_done "REFS" && [[ "$force" == false ]]; then
        log_info "references already updated (skipping)"
        return 0
    fi

    local files_updated=0

    # Find files to update
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue
        [[ ! -f "$file" ]] && continue

        # Skip binary files and .git
        [[ "$file" == *".git"* ]] && continue
        [[ "$file" == *".png" ]] && continue
        [[ "$file" == *".jpg" ]] && continue
        [[ "$file" == *".ico" ]] && continue

        # Replace openspec/ -> dev-playbooks/
        if grep -q "openspec/" "$file" 2>/dev/null; then
            if [[ "$dry_run" == true ]]; then
                log_info "[DRY-RUN] would update references: $file"
            else
                # macOS-compatible sed
                if [[ "$(uname)" == "Darwin" ]]; then
                    sed -i '' 's|openspec/|dev-playbooks/|g' "$file"
                else
                    sed -i 's|openspec/|dev-playbooks/|g' "$file"
                fi
            fi
            files_updated=$((files_updated + 1))
        fi
    done < <(find "${project_root}" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" -o -name "*.sh" -o -name "*.ts" -o -name "*.js" -o -name "*.json" \) 2>/dev/null)

    save_checkpoint "REFS"
    log_pass "updated references in ${files_updated} file(s)"
}

# Step 5: Cleanup
step_cleanup() {
    log_step "5. Cleanup"

    if is_step_done "CLEANUP" && [[ "$force" == false ]]; then
        log_info "cleanup already completed (skipping)"
        return 0
    fi

    local openspec_dir="${project_root}/openspec"

    if [[ "$keep_old" == true ]]; then
        log_info "keeping openspec/ directory (--keep-old)"
    elif [[ -d "$openspec_dir" ]]; then
        if [[ "$dry_run" == true ]]; then
            log_info "[DRY-RUN] rm -rf $openspec_dir"
        else
            # Create backup
            local backup_dir="${project_root}/.devbooks/backup/openspec-$(date +%Y%m%d%H%M%S)"
            mkdir -p "$(dirname "$backup_dir")"
            mv "$openspec_dir" "$backup_dir"
            log_info "backed up openspec/ to ${backup_dir}"
        fi
    fi

    save_checkpoint "CLEANUP"
    log_pass "cleanup complete"
}

# Verify migration results
verify_migration() {
    log_step "Verify migration results"

    local errors=0

    # Check directory structure
    local required_dirs=(
        "dev-playbooks"
        "dev-playbooks/specs"
        "dev-playbooks/changes"
    )

    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "${project_root}/${dir}" ]]; then
            log_error "missing directory: $dir"
            errors=$((errors + 1))
        fi
    done

    # Check config file
    if [[ ! -f "${project_root}/.devbooks/config.yaml" ]]; then
        log_error "missing config file: .devbooks/config.yaml"
        errors=$((errors + 1))
    fi

    # Check remaining openspec references (warning only)
    local remaining_refs
    remaining_refs=$(grep -r "openspec/" "${project_root}" --include="*.md" --include="*.yaml" --include="*.sh" 2>/dev/null | grep -v ".devbooks/backup" | wc -l || echo "0")
    if [[ "$remaining_refs" -gt 0 ]]; then
        log_warn "still found ${remaining_refs} reference(s) to openspec/"
    fi

    if [[ "$errors" -eq 0 ]]; then
        log_pass "migration verification passed"
        return 0
    else
        log_error "migration verification failed: ${errors} error(s)"
        return 1
    fi
}

main() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h) show_help; exit 0 ;;
            --version|-v) echo "migrate-from-openspec.sh v${VERSION}"; exit 0 ;;
            --project-root) project_root="${2:-.}"; shift 2 ;;
            --dry-run) dry_run=true; shift ;;
            --keep-old) keep_old=true; shift ;;
            --force) force=true; shift ;;
            -*) log_error "unknown option: $1"; exit 2 ;;
            *) log_error "unknown argument: $1"; exit 2 ;;
        esac
    done

    log_info "OpenSpec → DevBooks 2.0 migration"
    log_info "project root: ${project_root}"
    [[ "$dry_run" == true ]] && log_info "mode: DRY-RUN"
    [[ "$force" == true ]] && log_info "mode: FORCE"

    init_checkpoint

    # Execute steps
    step_structure
    step_content
    step_config
    step_refs
    step_cleanup

    # Verify
    if [[ "$dry_run" == false ]]; then
        verify_migration
    fi

    log_pass "migration complete!"
    exit 0
}

main "$@"
