#!/bin/bash
# DevBooks COD incremental update script
# Purpose: persist and incrementally update code-map artifacts (module graph, hotspots, key concepts)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colored output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo_info() { echo -e "${GREEN}[COD]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[COD]${NC} $1"; }
echo_error() { echo -e "${RED}[COD]${NC} $1"; }

# Argument parsing
PROJECT_ROOT="."
TRUTH_ROOT=""
FORCE=false
QUIET=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --project-root) PROJECT_ROOT="$2"; shift 2 ;;
        --truth-root) TRUTH_ROOT="$2"; shift 2 ;;
        --force) FORCE=true; shift ;;
        --quiet) QUIET=true; shift ;;
        -h|--help)
            echo "Usage: cod-update.sh [options]"
            echo ""
            echo "Options:"
            echo "  --project-root <dir>  Project root (default: .)"
            echo "  --truth-root <dir>    Truth root (auto-detected)"
            echo "  --force               Force full refresh"
            echo "  --quiet               Quiet mode"
            exit 0
            ;;
        *) echo_error "Unknown argument: $1"; exit 1 ;;
    esac
done

cd "$PROJECT_ROOT"

# Auto-detect truth root
if [ -z "$TRUTH_ROOT" ]; then
    if [ -f "dev-playbooks/project.md" ]; then
        TRUTH_ROOT="dev-playbooks/specs"
    elif [ -f ".devbooks/config.yaml" ]; then
        TRUTH_ROOT=$(grep 'truth_root:' .devbooks/config.yaml | awk '{print $2}' | tr -d '"' || echo "specs")
    else
        TRUTH_ROOT="specs"
    fi
fi

# Ensure directories exist
mkdir -p "$TRUTH_ROOT/architecture"
mkdir -p "$TRUTH_ROOT/_meta"
mkdir -p ".devbooks/cache/cod"

# Cache file paths
CACHE_DIR=".devbooks/cache/cod"
HASH_FILE="$CACHE_DIR/source-hash.txt"
ARCHITECTURE_CACHE="$CACHE_DIR/architecture.json"
HOTSPOTS_CACHE="$CACHE_DIR/hotspots.json"
CONCEPTS_CACHE="$CACHE_DIR/concepts.json"

# Compute a source hash (for change detection)
calculate_source_hash() {
    # Hash source files only; ignore node_modules and build outputs.
    find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \
        -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \) \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" ! -path "*/build/*" \
        -exec md5sum {} \; 2>/dev/null | sort | md5sum | cut -d' ' -f1
}

# Check whether an update is needed
needs_update() {
    if [ "$FORCE" = true ]; then
        return 0
    fi

    if [ ! -f "$HASH_FILE" ]; then
        return 0
    fi

    local old_hash=$(cat "$HASH_FILE")
    local new_hash=$(calculate_source_hash)

    if [ "$old_hash" != "$new_hash" ]; then
        return 0
    fi

    # Ensure artifacts exist
    if [ ! -f "$TRUTH_ROOT/architecture/module-graph.md" ]; then
        return 0
    fi

    return 1
}

# Try to use CKB MCP for architecture (if available)
fetch_architecture_via_mcp() {
    # Check whether CKB is usable (via index.scip presence)
    if [ ! -f "index.scip" ]; then
        echo_warn "SCIP index not found; skipping graph-based architecture analysis"
        return 1
    fi

    # We cannot call MCP directly here; fall back to cache checks.
    if [ -f "$ARCHITECTURE_CACHE" ]; then
        local cache_age=$(( ($(date +%s) - $(stat -f%m "$ARCHITECTURE_CACHE" 2>/dev/null || stat -c%Y "$ARCHITECTURE_CACHE" 2>/dev/null)) ))
        if [ $cache_age -lt 3600 ]; then  # cache valid for 1 hour
            echo_info "Using cached architecture data"
            return 0
        fi
    fi

    return 1
}

# Generate module dependency graph from filesystem (fallback)
generate_module_graph_fallback() {
    local output="$TRUTH_ROOT/architecture/module-graph.md"
    local temp_file=$(mktemp)

    echo_info "Generating module dependency graph (filesystem analysis)..."

    cat > "$temp_file" << 'EOF'
# Module Dependency Graph

> Auto-generated on $(date +%Y-%m-%d) via filesystem analysis

## Directory structure

```
EOF

    # Directory tree
    if command -v tree &> /dev/null; then
        tree -d -L 3 -I 'node_modules|.git|dist|build|__pycache__|.venv|vendor' >> "$temp_file" 2>/dev/null || true
    else
        find . -type d -maxdepth 3 \
            ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
            ! -path "*/build/*" ! -path "*/__pycache__/*" ! -path "*/.venv/*" \
            2>/dev/null | head -50 >> "$temp_file"
    fi

    echo '```' >> "$temp_file"
    echo "" >> "$temp_file"

    # Import/dependency analysis
    echo "## Primary dependencies" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "| Module | Imports | Exports/References |" >> "$temp_file"
    echo "|------|--------|----------|" >> "$temp_file"

    # TypeScript/JavaScript projects
    if [ -f "package.json" ]; then
        for dir in src lib app; do
            if [ -d "$dir" ]; then
                local import_count=$(grep -r "^import\|^from" "$dir" 2>/dev/null | wc -l || echo 0)
                local export_count=$(grep -r "^export" "$dir" 2>/dev/null | wc -l || echo 0)
                echo "| \`$dir/\` | $import_count | $export_count |" >> "$temp_file"
            fi
        done
    fi

    # Python projects
    if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        for dir in src lib app; do
            if [ -d "$dir" ]; then
                local import_count=$(grep -r "^import\|^from" "$dir" --include="*.py" 2>/dev/null | wc -l || echo 0)
                echo "| \`$dir/\` | $import_count | - |" >> "$temp_file"
            fi
        done
    fi

    echo "" >> "$temp_file"
    echo "---" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "> Tip: run \`devbooks-index-bootstrap\` to generate a SCIP index for more accurate dependency analysis" >> "$temp_file"

    # Update only when content changes
    if [ -f "$output" ]; then
        if ! diff -q "$temp_file" "$output" > /dev/null 2>&1; then
            mv "$temp_file" "$output"
            echo_info "Module dependency graph updated: $output"
        else
            rm "$temp_file"
            [ "$QUIET" = false ] && echo_info "Module dependency graph unchanged"
        fi
    else
        mv "$temp_file" "$output"
        echo_info "Module dependency graph created: $output"
    fi
}

# Generate hotspot report
generate_hotspots() {
    local output="$TRUTH_ROOT/architecture/hotspots.md"
    local temp_file=$(mktemp)

    echo_info "Generating tech-debt hotspots..."

    cat > "$temp_file" << EOF
# Tech-Debt Hotspots

> Auto-generated on $(date +%Y-%m-%d)
> Hotspot score = change frequency × complexity proxy

## Frequently changed files (last 30 days)

| File | Changes | LOC | Risk |
|------|--------:|----:|------|
EOF

    # Git history analysis
    if [ -d ".git" ]; then
        git log --since="30 days ago" --name-only --pretty=format: 2>/dev/null | \
            grep -v '^$' | \
            grep -v 'node_modules\|dist\|build\|\.lock\|package-lock' | \
            sort | uniq -c | sort -rn | head -15 | \
            while read count file; do
                if [ -f "$file" ]; then
                    local lines=$(wc -l < "$file" 2>/dev/null || echo 0)
                    local risk="🟢 Normal"
                    if [ $count -gt 10 ] && [ $lines -gt 300 ]; then
                        risk="🔴 Critical"
                    elif [ $count -gt 5 ] && [ $lines -gt 200 ]; then
                        risk="🟡 High"
                    fi
                    echo "| \`$file\` | $count | $lines | $risk |"
                fi
            done >> "$temp_file"
    else
        echo "| (no Git history) | - | - | - |" >> "$temp_file"
    fi

    echo "" >> "$temp_file"
    echo "## Large files (complexity proxy)" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "| File | LOC |" >> "$temp_file"
    echo "|------|------|" >> "$temp_file"

    find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.py" -o -name "*.go" \) \
        ! -path "*/node_modules/*" ! -path "*/.git/*" ! -path "*/dist/*" \
        -exec wc -l {} \; 2>/dev/null | \
        sort -rn | head -10 | \
        while read lines file; do
            echo "| \`$file\` | $lines |"
        done >> "$temp_file"

    # Update only when content changes
    if [ -f "$output" ]; then
        # Ignore date header lines for diff
        if ! diff <(tail -n +4 "$temp_file") <(tail -n +4 "$output") > /dev/null 2>&1; then
            mv "$temp_file" "$output"
            echo_info "Hotspot report updated: $output"
        else
            rm "$temp_file"
            [ "$QUIET" = false ] && echo_info "Hotspot report unchanged"
        fi
    else
        mv "$temp_file" "$output"
        echo_info "Hotspot report created: $output"
    fi
}

# Generate key concepts (naming-based heuristic)
generate_key_concepts() {
    local output="$TRUTH_ROOT/_meta/key-concepts.md"
    local temp_file=$(mktemp)

    echo_info "Generating key concepts..."

    cat > "$temp_file" << EOF
# Key Concepts

> Auto-generated on $(date +%Y-%m-%d)
> Derived from code naming patterns

## Core classes/interfaces

| Concept | Occurrences | Example location |
|---------|------------:|------------------|
EOF

    # Extract PascalCase names (class-like)
    grep -rho '\b[A-Z][a-z]*[A-Z][a-zA-Z]*\b' \
        --include="*.ts" --include="*.tsx" --include="*.js" --include="*.py" --include="*.go" \
        . 2>/dev/null | \
        grep -v 'node_modules\|dist\|build' | \
        sort | uniq -c | sort -rn | head -15 | \
        while read count name; do
            local location=$(grep -rl "\b$name\b" --include="*.ts" --include="*.py" . 2>/dev/null | head -1 || echo "-")
            echo "| \`$name\` | $count | \`$location\` |"
        done >> "$temp_file"

    echo "" >> "$temp_file"
    echo "## Common verbs (operations)" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "| Verb | Occurrences |" >> "$temp_file"
    echo "|------|------------:|" >> "$temp_file"

    # Extract verbs from function-like names
    grep -rho '\b\(get\|set\|create\|update\|delete\|fetch\|save\|load\|process\|handle\|validate\)[A-Za-z]*\b' \
        --include="*.ts" --include="*.js" --include="*.py" \
        . 2>/dev/null | \
        grep -v 'node_modules' | \
        sed 's/[A-Z]/ /g' | awk '{print tolower($1)}' | \
        sort | uniq -c | sort -rn | head -10 | \
        while read count verb; do
            echo "| \`$verb\` | $count |"
        done >> "$temp_file"

    # Update only when content changes
    if [ -f "$output" ]; then
        if ! diff <(tail -n +4 "$temp_file") <(tail -n +4 "$output") > /dev/null 2>&1; then
            mv "$temp_file" "$output"
            echo_info "Key concepts updated: $output"
        else
            rm "$temp_file"
            [ "$QUIET" = false ] && echo_info "Key concepts unchanged"
        fi
    else
        mv "$temp_file" "$output"
        echo_info "Key concepts created: $output"
    fi
}

# Main flow
main() {
    if needs_update; then
        echo_info "Code changes detected; updating COD artifacts..."

        # Try MCP/cache first; fall back to filesystem analysis
        if ! fetch_architecture_via_mcp; then
            generate_module_graph_fallback
        fi

        generate_hotspots
        generate_key_concepts

        # Save new hash
        calculate_source_hash > "$HASH_FILE"

        echo_info "COD artifact update complete"
    else
        [ "$QUIET" = false ] && echo_info "No code changes detected; skipping update"
    fi
}

main
