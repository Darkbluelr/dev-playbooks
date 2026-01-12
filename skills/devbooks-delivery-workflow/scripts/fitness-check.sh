#!/bin/bash
# skills/devbooks-delivery-workflow/scripts/fitness-check.sh
# Architecture fitness check script
#
# Runs architecture fitness functions to verify code conforms to architecture rules.
#
# Usage:
#   ./fitness-check.sh [options]
#   ./fitness-check.sh --help
#
# Options:
#   --mode MODE         Mode: warn | error
#   --rules FILE        Rules file path (reserved for future use)
#   --project-root DIR  Project root
#   --file FILE         Check a single file (for testing)
#
# Exit codes:
#   0 - pass (or warnings in warn mode)
#   1 - fail (violations in error mode)
#   2 - usage error

set -euo pipefail

# Version
VERSION="1.0.0"

# Defaults
mode="warn"
rules_file=""
project_root="."
single_file=""

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
errors=0
warnings=0

show_help() {
  cat <<'EOF'
Architecture fitness check (fitness-check.sh)

usage:
  ./fitness-check.sh [options]

options:
  --mode MODE         Mode: warn (warnings only) | error (block)
  --rules FILE        Rules file path (default: specs/architecture/fitness-rules.md)
  --project-root DIR  Project root (default: current directory)
  --file FILE         Check a single file (for testing)
  --help, -h          Show this help
  --version, -v       Show version

supported rules:
  FR-001: Layered architecture check (Controller → Service → Repository)
  FR-002: Circular dependency check (basic)
  FR-003: Sensitive file guard

exit codes:
  0 - pass (or warnings in warn mode)
  1 - fail (violations in error mode)
  2 - usage error

examples:
  ./fitness-check.sh                          # default checks
  ./fitness-check.sh --mode error             # strict mode
  ./fitness-check.sh --rules custom-rules.md  # custom rules file
  ./fitness-check.sh --file src/test.js       # check a single file
EOF
}

show_version() {
  echo "fitness-check.sh v${VERSION}"
}

log_info() { echo -e "${BLUE}[INFO]${NC} $*" >&2; }
log_pass() { echo -e "${GREEN}[PASS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*" >&2; warnings=$((warnings + 1)); }

log_fail() {
  echo -e "${RED}[FAIL]${NC} $*" >&2
  if [[ "$mode" == "error" ]]; then
    errors=$((errors + 1))
  else
    warnings=$((warnings + 1))
  fi
}

# ============================================================================
# FR-001: Layered architecture check
# Controller must not directly call Repository
# ============================================================================
check_layered_architecture() {
  log_info "FR-001: checking layered architecture..."

  local src_dir="${project_root}/src"
  local controllers_dir="${src_dir}/controllers"

  if [[ ! -d "$controllers_dir" ]]; then
    # Try other common paths
    controllers_dir="${src_dir}/controller"
    if [[ ! -d "$controllers_dir" ]]; then
      log_info "  controllers directory not found; skipping"
      return 0
    fi
  fi

  local violations=""

  # Find Controllers that directly call Repository
  # Pattern: Repository.xxx or new XxxRepository
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue

    local matches
    matches=$(grep -nE "Repository\\.(find|save|delete|update|create|get)|new [A-Z][a-zA-Z]*Repository" "$file" 2>/dev/null || true)

    if [[ -n "$matches" ]]; then
      violations="${violations}${file}:\n${matches}\n\n"
    fi
  done < <(find "$controllers_dir" -type f \( -name "*.ts" -o -name "*.js" \) 2>/dev/null)

  if [[ -n "$violations" ]]; then
    log_fail "FR-001: layering violation - Controller directly accesses Repository"
    echo -e "  details:\n$violations" >&2
    return 1
  fi

  log_pass "FR-001: layered architecture check passed"
  return 0
}

# ============================================================================
# FR-002: Circular dependency check (basic)
# Detect obvious circular imports
# ============================================================================
check_circular_dependencies() {
  log_info "FR-002: checking circular dependencies..."

  local src_dir="${project_root}/src"

  if [[ ! -d "$src_dir" ]]; then
    log_info "  src directory not found; skipping"
    return 0
  fi

  # Basic check: mutual imports within the same directory
  # This is simplified; complete detection requires graph analysis
  local circular_count=0

  # Look for potential circular patterns:
  # e.g., a.ts imports './b' and b.ts imports './a'
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue

    local dir
    dir=$(dirname "$file")
    local base
    base=$(basename "$file" | sed 's/\\.(ts|js|tsx|jsx)$//')

    # Extract relative imports for this file
    local imports
    imports=$(grep -oE "from ['\\\"]\\./[a-zA-Z0-9_-]+['\\\"]" "$file" 2>/dev/null | sed "s/from ['\\\"]\\.\\///g; s/['\\\"]//g" || true)

    for imported in $imports; do
      local imported_file="${dir}/${imported}.ts"
      [[ ! -f "$imported_file" ]] && imported_file="${dir}/${imported}.js"
      [[ ! -f "$imported_file" ]] && continue

      # Check if imported file imports back
      if grep -qE "from ['\\\"]\\./${base}['\\\"]" "$imported_file" 2>/dev/null; then
        log_warn "FR-002: potential circular dependency: ${file} <-> ${imported_file}"
        circular_count=$((circular_count + 1))
      fi
    done
  done < <(find "$src_dir" -type f \( -name "*.ts" -o -name "*.js" \) 2>/dev/null | head -100)

  if [[ $circular_count -gt 0 ]]; then
    log_warn "FR-002: detected ${circular_count} potential circular dependency(ies)"
    return 0 # warn only
  fi

  log_pass "FR-002: circular dependency check passed"
  return 0
}

# ============================================================================
# FR-003: Sensitive file guard
# Prevent sensitive files from being accidentally tracked/committed
# ============================================================================
check_sensitive_files() {
  log_info "FR-003: checking sensitive files..."

  local sensitive_patterns=(
    ".env"
    ".env.local"
    ".env.production"
    "credentials.json"
    "secrets.yaml"
    "*.pem"
    "*.key"
    "id_rsa"
    "id_ed25519"
  )

  local violations=0

  for pattern in "${sensitive_patterns[@]}"; do
    # Check whether sensitive files are tracked by git
    if command -v git >/dev/null 2>&1 && git -C "$project_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      local tracked
      tracked=$(git -C "$project_root" ls-files "$pattern" 2>/dev/null || true)
      if [[ -n "$tracked" ]]; then
        log_fail "FR-003: sensitive file is tracked by git: ${tracked}"
        violations=$((violations + 1))
      fi
    fi
  done

  # Check .gitignore includes sensitive patterns
  local gitignore="${project_root}/.gitignore"
  if [[ -f "$gitignore" ]]; then
    local missing_patterns=()
    for pattern in ".env" "*.key" "*.pem"; do
      if ! grep -qE "^${pattern}$|^\\*${pattern}$" "$gitignore" 2>/dev/null; then
        missing_patterns+=("$pattern")
      fi
    done

    if [[ ${#missing_patterns[@]} -gt 0 ]]; then
      log_warn "FR-003: consider adding sensitive patterns to .gitignore: ${missing_patterns[*]}"
    fi
  fi

  if [[ $violations -eq 0 ]]; then
    log_pass "FR-003: sensitive file check passed"
    return 0
  fi

  return 1
}

# ============================================================================
# Check a single file (for testing)
# ============================================================================
check_single_file() {
  local file="$1"

  log_info "checking file: $file"

  if [[ ! -f "$file" ]]; then
    log_fail "file not found: $file"
    return 1
  fi

  # FR-001: Layered architecture check
  if [[ "$file" =~ controller ]]; then
    local matches
    matches=$(grep -nE "Repository\\.(find|save|delete|update|create|get)" "$file" 2>/dev/null || true)
    if [[ -n "$matches" ]]; then
      log_fail "FR-001: Controller directly accesses Repository"
      echo "  $matches" >&2
      return 1
    fi
  fi

  log_pass "file check passed: $file"
  return 0
}

# ============================================================================
# Main
# ============================================================================
main() {
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
      --mode)
        mode="${2:-warn}"
        shift 2
        ;;
      --rules)
        rules_file="${2:-}"
        shift 2
        ;;
      --project-root)
        project_root="${2:-.}"
        shift 2
        ;;
      --file)
        single_file="${2:-}"
        shift 2
        ;;
      -*)
        echo "error: unknown option: $1" >&2
        echo "hint: use --help" >&2
        exit 2
        ;;
      *)
        shift
        ;;
    esac
  done

  case "$mode" in
    warn|error) ;;
    *)
      echo "error: invalid --mode: $mode (must be warn or error)" >&2
      exit 2
      ;;
  esac

  echo "=========================================="
  echo "Architecture fitness check (fitness-check.sh)"
  echo "mode: $mode"
  echo "project: $project_root"
  echo "=========================================="
  echo ""

  if [[ -n "$single_file" ]]; then
    check_single_file "$single_file"
    exit $?
  fi

  check_layered_architecture || true
  check_circular_dependencies || true
  check_sensitive_files || true

  echo ""
  echo "=========================================="
  echo "Done"
  echo "  errors: $errors"
  echo "  warnings: $warnings"
  echo "=========================================="

  if [[ $errors -gt 0 ]]; then
    echo ""
    log_fail "failed: ${errors} error(s)"
    exit 1
  fi

  if [[ $warnings -gt 0 ]]; then
    echo ""
    log_warn "passed with warnings: ${warnings}"
    exit 0
  fi

  echo ""
  log_pass "passed: no violations"
  exit 0
}

main "$@"
