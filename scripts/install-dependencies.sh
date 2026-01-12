#!/bin/bash
# DevBooks dependency installer
# Supports macOS (Homebrew) and Linux (apt/yum/dnf)
#
# Usage: ./scripts/install-dependencies.sh [--all | --minimal | --dev]
#   --minimal  Install required dependencies only (jq, ripgrep)
#   --all      Install all recommended dependencies (default)
#   --dev      Also install developer dependencies (shellcheck)

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Darwin*) echo "macos" ;;
    Linux*)  echo "linux" ;;
    *)       echo "unknown" ;;
  esac
}

# Detect package manager
detect_package_manager() {
  if command -v brew &>/dev/null; then
    echo "brew"
  elif command -v apt-get &>/dev/null; then
    echo "apt"
  elif command -v yum &>/dev/null; then
    echo "yum"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  else
    echo "unknown"
  fi
}

# Check whether a command exists
check_command() {
  command -v "$1" &>/dev/null
}

# Install a single tool
install_tool() {
  local tool="$1"
  local pkg_manager="$2"

  if check_command "$tool"; then
    log_info "$tool is already installed ($(which $tool))"
    return 0
  fi

  log_info "Installing $tool..."
  case "$pkg_manager" in
    brew)
      case "$tool" in
        radon) pip3 install radon ;;
        gocyclo)
          if check_command go; then
            go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
          else
            log_warn "Skipping gocyclo (requires Go)"
            return 0
          fi
          ;;
        *) brew install "$tool" ;;
      esac
      ;;
    apt)
      case "$tool" in
        ripgrep) sudo apt-get install -y ripgrep ;;
        radon) pip3 install radon ;;
        scc)
          log_warn "scc requires manual installation: https://github.com/boyter/scc#installation"
          return 0
          ;;
        gocyclo)
          if check_command go; then
            go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
          else
            log_warn "Skipping gocyclo (requires Go)"
            return 0
          fi
          ;;
        *) sudo apt-get install -y "$tool" ;;
      esac
      ;;
    yum|dnf)
      case "$tool" in
        radon) pip3 install radon ;;
        scc)
          log_warn "scc requires manual installation: https://github.com/boyter/scc#installation"
          return 0
          ;;
        gocyclo)
          if check_command go; then
            go install github.com/fzipp/gocyclo/cmd/gocyclo@latest
          else
            log_warn "Skipping gocyclo (requires Go)"
            return 0
          fi
          ;;
        *) sudo "$pkg_manager" install -y "$tool" ;;
      esac
      ;;
    *)
      log_error "Unknown package manager. Please install $tool manually."
      return 1
      ;;
  esac
}

# Main
main() {
  local mode="${1:---all}"
  local os=$(detect_os)
  local pkg_manager=$(detect_package_manager)

  log_info "Detected OS: $os"
  log_info "Detected package manager: $pkg_manager"
  echo ""

  # Required dependencies
  local required_tools=(jq ripgrep)

  # Recommended dependencies (complexity tooling)
  local recommended_tools=(scc radon gocyclo)

  # Developer dependencies
  local dev_tools=(shellcheck)

  # Select install scope by mode
  local tools_to_install=()
  case "$mode" in
    --minimal)
      tools_to_install=("${required_tools[@]}")
      log_info "Install mode: minimal"
      ;;
    --dev)
      tools_to_install=("${required_tools[@]}" "${recommended_tools[@]}" "${dev_tools[@]}")
      log_info "Install mode: all + dev"
      ;;
    --all|*)
      tools_to_install=("${required_tools[@]}" "${recommended_tools[@]}")
      log_info "Install mode: all recommended"
      ;;
  esac
  echo ""

  # Install tools
  local failed=()
  for tool in "${tools_to_install[@]}"; do
    if ! install_tool "$tool" "$pkg_manager"; then
      failed+=("$tool")
    fi
  done
  echo ""

  # Verify install
  log_info "=== Install verification ==="
  echo ""
  echo "Required tools:"
  for tool in "${required_tools[@]}"; do
    if check_command "$tool"; then
      echo "  ✅ $tool: $(which $tool)"
    else
      echo "  ❌ $tool: not installed"
    fi
  done
  echo ""
  echo "Complexity tools:"
  for tool in "${recommended_tools[@]}"; do
    if check_command "$tool"; then
      echo "  ✅ $tool: $(which $tool)"
    else
      echo "  ⚠️ $tool: not installed (optional)"
    fi
  done
  echo ""

  if [[ "$mode" == "--dev" ]]; then
    echo "Developer tools:"
    for tool in "${dev_tools[@]}"; do
      if check_command "$tool"; then
        echo "  ✅ $tool: $(which $tool)"
      else
        echo "  ⚠️ $tool: not installed (optional)"
      fi
    done
    echo ""
  fi

  # Summary
  if [ ${#failed[@]} -eq 0 ]; then
    log_info "✅ All dependencies installed!"
  else
    log_warn "The following tools failed to install; install manually: ${failed[*]}"
  fi
}

# Help
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  cat << 'EOF'
DevBooks dependency installer

Usage:
  ./scripts/install-dependencies.sh [options]

Options:
  --minimal   Install required deps only (jq, ripgrep)
  --all       Install all recommended deps (default)
  --dev       Also install dev deps (shellcheck)
  --help      Show this help

Dependencies:
  Required:
    - jq        JSON processing (formatting hook outputs)
    - ripgrep   Code search (symbol definition lookup)

  Recommended:
    - scc       Language-agnostic complexity metrics (JS/TS/Go/Java, etc.)
    - radon     Python cyclomatic complexity
    - gocyclo   Go cyclomatic complexity

  Dev:
    - shellcheck  Shell script static analysis

Examples:
  ./scripts/install-dependencies.sh           # install all recommended deps
  ./scripts/install-dependencies.sh --minimal # required deps only
  ./scripts/install-dependencies.sh --dev     # all + dev deps
EOF
  exit 0
fi

main "$@"
