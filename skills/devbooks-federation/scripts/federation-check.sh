#!/bin/bash
# DevBooks federation check script
# Purpose: detect whether changes touch federation contracts and generate an impact report

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() { echo -e "${GREEN}[Federation]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[Federation]${NC} $1"; }
echo_error() { echo -e "${RED}[Federation]${NC} $1"; }

# Argument parsing
PROJECT_ROOT="."
CHANGE_FILES=""
OUTPUT=""
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --project-root) PROJECT_ROOT="$2"; shift 2 ;;
        --change-files) CHANGE_FILES="$2"; shift 2 ;;
        --output) OUTPUT="$2"; shift 2 ;;
        --quiet) QUIET=true; shift ;;
        -h|--help)
            echo "usage: federation-check.sh [options]"
            echo ""
            echo "Options:"
            echo "  --project-root <dir>   Project root (default: .)"
            echo "  --change-files <list>  Changed files (comma-separated)"
            echo "  --output <file>        Output report path"
            echo "  --quiet                Quiet mode"
            exit 0
            ;;
        *) echo_error "Unknown argument: $1"; exit 1 ;;
    esac
done

cd "$PROJECT_ROOT"

# Find federation config
FEDERATION_CONFIG=""
if [ -f ".devbooks/federation.yaml" ]; then
    FEDERATION_CONFIG=".devbooks/federation.yaml"
elif [ -f "dev-playbooks/federation.yaml" ]; then
    FEDERATION_CONFIG="dev-playbooks/federation.yaml"
fi

if [ -z "$FEDERATION_CONFIG" ]; then
    [ "$QUIET" = false ] && echo_info "No federation config found; skipping"
    exit 0
fi

[ "$QUIET" = false ] && echo_info "Using federation config: $FEDERATION_CONFIG"

# If no changed files were provided, try to read them from git
if [ -z "$CHANGE_FILES" ]; then
    if [ -d ".git" ]; then
        CHANGE_FILES=$(git diff --cached --name-only 2>/dev/null | tr '\n' ',' | sed 's/,$//')
        if [ -z "$CHANGE_FILES" ]; then
            CHANGE_FILES=$(git diff --name-only HEAD~1 2>/dev/null | tr '\n' ',' | sed 's/,$//')
        fi
    fi
fi

if [ -z "$CHANGE_FILES" ]; then
    [ "$QUIET" = false ] && echo_info "No changed files; skipping"
    exit 0
fi

[ "$QUIET" = false ] && echo_info "Checking changed files: $CHANGE_FILES"

# Extract contract patterns (simple implementation: parse contracts lines from YAML)
CONTRACT_PATTERNS=$(grep -E "^\s+-\s+\"" "$FEDERATION_CONFIG" 2>/dev/null | sed 's/.*"\([^"]*\)".*/\1/' | tr '\n' '|' | sed 's/|$//')

if [ -z "$CONTRACT_PATTERNS" ]; then
    [ "$QUIET" = false ] && echo_info "No contract patterns defined; skipping"
    exit 0
fi

# Detect whether changes touch contracts
CONTRACT_CHANGES=""
IFS=',' read -ra FILES <<< "$CHANGE_FILES"
for file in "${FILES[@]}"; do
    if echo "$file" | grep -qE "$CONTRACT_PATTERNS"; then
        CONTRACT_CHANGES="$CONTRACT_CHANGES$file,"
    fi
done
CONTRACT_CHANGES=${CONTRACT_CHANGES%,}

if [ -z "$CONTRACT_CHANGES" ]; then
    [ "$QUIET" = false ] && echo_info "No contract files changed"
    exit 0
fi

# Contract changes found
echo_warn "Contract changes detected: $CONTRACT_CHANGES"

# Generate report
REPORT=$(cat << EOF
# Cross-repository impact analysis report

> Auto-generated on $(date +%Y-%m-%d)
> Federation config: $FEDERATION_CONFIG

## Contract changes

The following files match federation contracts:

$(echo "$CONTRACT_CHANGES" | tr ',' '\n' | while read f; do echo "- \`$f\`"; done)

## Recommended actions

1. [ ] Confirm change type (Breaking / Deprecation / Enhancement / Patch)
2. [ ] Run \`devbooks-federation\` for full cross-repo impact analysis
3. [ ] If breaking, notify downstream consumers
4. [ ] Update CHANGELOG

## Downstream consumers

$(grep -A20 "downstreams:" "$FEDERATION_CONFIG" 2>/dev/null | grep -E "^\s+-\s+name:" | sed 's/.*name:\s*"\([^"]*\)".*/- \1/' || echo "(see federation.yaml)")

---

> Tip: use the \`devbooks-federation\` skill for full analysis
EOF
)

# Output report
if [ -n "$OUTPUT" ]; then
    echo "$REPORT" > "$OUTPUT"
    echo_info "Report generated: $OUTPUT"
else
    echo ""
    echo "$REPORT"
fi

# Return non-zero to indicate contract changes
exit 1
