#!/bin/bash
# DevBooks graph cache manager
# Purpose: cache common CKB MCP query results to reduce repeated queries

set -e

CACHE_DIR=".devbooks/cache/graph"
CACHE_TTL=3600  # default TTL: 1 hour (seconds)

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_info() { echo -e "${GREEN}[Cache]${NC} $1"; }
echo_warn() { echo -e "${YELLOW}[Cache]${NC} $1"; }

# Argument parsing
ACTION=""
KEY=""
VALUE=""
TTL=$CACHE_TTL

while [[ $# -gt 0 ]]; do
    case $1 in
        get|set|clear|status|warm) ACTION="$1"; shift ;;
        --key) KEY="$2"; shift 2 ;;
        --value) VALUE="$2"; shift 2 ;;
        --ttl) TTL="$2"; shift 2 ;;
        --project-root) cd "$2"; shift 2 ;;
        -h|--help)
            echo "usage: graph-cache.sh <action> [options]"
            echo ""
            echo "Actions:"
            echo "  get     Get cache"
            echo "  set     Set cache"
            echo "  clear   Clear cache"
            echo "  status  Show cache status"
            echo "  warm    Warm cache"
            echo ""
            echo "Options:"
            echo "  --key <name>      Cache key"
            echo "  --value <data>    Cache value"
            echo "  --ttl <seconds>   Cache TTL (default: 3600)"
            echo "  --project-root    Project root"
            exit 0
            ;;
        *) shift ;;
    esac
done

# Ensure cache directory exists
mkdir -p "$CACHE_DIR"

# Compute cache file path
get_cache_file() {
    local key="$1"
    local hash=$(echo "$key" | md5sum | cut -d' ' -f1)
    echo "$CACHE_DIR/${hash}.json"
}

# Check whether cache is valid
is_cache_valid() {
    local cache_file="$1"
    local ttl="${2:-$CACHE_TTL}"

    if [ ! -f "$cache_file" ]; then
        return 1
    fi

    local file_age=$(( $(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null) ))

    if [ $file_age -gt $ttl ]; then
        return 1
    fi

    return 0
}

# Get cache
cache_get() {
    local cache_file=$(get_cache_file "$KEY")

    if is_cache_valid "$cache_file" "$TTL"; then
        cat "$cache_file"
        return 0
    else
        return 1
    fi
}

# Set cache
cache_set() {
    local cache_file=$(get_cache_file "$KEY")

    # Write cache metadata
    cat > "$cache_file" << EOF
{
  "key": "$KEY",
  "timestamp": $(date +%s),
  "ttl": $TTL,
  "data": $VALUE
}
EOF

    echo_info "cached: $KEY"
}

# Clear cache
cache_clear() {
    if [ -n "$KEY" ]; then
        local cache_file=$(get_cache_file "$KEY")
        rm -f "$cache_file"
        echo_info "cleared: $KEY"
    else
        rm -rf "$CACHE_DIR"/*
        echo_info "cleared all cache entries"
    fi
}

# Show cache status
cache_status() {
    echo "=== DevBooks graph cache status ==="
    echo ""

    if [ ! -d "$CACHE_DIR" ] || [ -z "$(ls -A "$CACHE_DIR" 2>/dev/null)" ]; then
        echo "cache is empty"
        return
    fi

    local total=0
    local valid=0
    local expired=0

    echo "| Key | Size | Age | Status |"
    echo "|-----|------|------|------|"

    for cache_file in "$CACHE_DIR"/*.json; do
        if [ -f "$cache_file" ]; then
            total=$((total + 1))

            local size=$(du -h "$cache_file" | cut -f1)
            local age=$(( ($(date +%s) - $(stat -f%m "$cache_file" 2>/dev/null || stat -c%Y "$cache_file" 2>/dev/null)) ))
            local age_min=$((age / 60))

            local key=$(jq -r '.key // "unknown"' "$cache_file" 2>/dev/null || echo "unknown")
            local ttl=$(jq -r '.ttl // 3600' "$cache_file" 2>/dev/null || echo 3600)

            local status="✅ valid"
            if [ $age -gt $ttl ]; then
                status="❌ expired"
                expired=$((expired + 1))
            else
                valid=$((valid + 1))
            fi

            # Truncate long keys
            if [ ${#key} -gt 30 ]; then
                key="${key:0:27}..."
            fi

            echo "| $key | $size | ${age_min}m | $status |"
        fi
    done

    echo ""
    echo "total: $total entries; $valid valid; $expired expired"
}

# Warm cache (common queries)
cache_warm() {
    echo_info "warming cache..."

    # Check whether a SCIP index exists
    if [ ! -f "index.scip" ]; then
        echo_warn "SCIP index not found; cannot warm graph cache"
        return 1
    fi

    # Cache common query results
    # Note: actual MCP calls must be executed in Claude Code.
    # Here we only clean expired cache and keep placeholders.

    # Clean expired cache
    for cache_file in "$CACHE_DIR"/*.json; do
        if [ -f "$cache_file" ]; then
            if ! is_cache_valid "$cache_file"; then
                rm -f "$cache_file"
                echo_info "removed expired: $(basename "$cache_file")"
            fi
        fi
    done

    echo_info "cache warm-up complete"
    echo ""
    echo "Tip: in Claude Code, run these commands to warm common queries:"
    echo "  - mcp__ckb__getArchitecture(depth=2)"
    echo "  - mcp__ckb__getHotspots(limit=20)"
    echo "  - mcp__ckb__listKeyConcepts(limit=12)"
}

# Main
case "$ACTION" in
    get) cache_get ;;
    set) cache_set ;;
    clear) cache_clear ;;
    status) cache_status ;;
    warm) cache_warm ;;
    *)
        echo "error: specify an action: get, set, clear, status, warm"
        echo "hint: use -h for help"
        exit 1
        ;;
esac
