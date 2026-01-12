#!/bin/bash
# verify-openspec-free.sh - Verify OpenSpec references are removed
#
# Verifies AC-001 ~ AC-004

set -uo pipefail  # omit -e; handle errors manually

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

PASSED=0
FAILED=0

check() {
    local name="$1"
    local result="$2"
    if [[ "$result" == "0" ]]; then
        echo -e "${GREEN}✅ $name${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌ $name${NC}"
        FAILED=$((FAILED + 1))
    fi
}

echo "=== OpenSpec removal verification ==="
echo ""

# AC-001: No OpenSpec references (exclude legitimate references)
echo "AC-001: Checking OpenSpec references..."
# Exclude legitimate references:
# - backup, changes, .git: history / work dirs
# - migrate-from-openspec.sh: migration script
# - verify-*.sh: verification scripts
# - c4.md: architecture doc (records historical changes)
# - specs/config-protocol/spec.md: rules definition doc
# - specs/slash-commands/spec.md: historical record doc
ref_count=$(grep -rn "openspec\|OpenSpec" . --include="*.md" --include="*.sh" --include="*.yaml" --include="*.yml" --include="*.js" 2>/dev/null | grep -v backup | grep -v changes | grep -v "\.git" | grep -v "DEVBOOKS-EVOLUTION-PROPOSAL.md" | grep -v "migrate-from-openspec.sh" | grep -v "tests/" | grep -v "verify-openspec-free.sh" | grep -v "verify-all.sh" | grep -v "c4.md" | grep -v "specs/config-protocol/spec.md" | grep -v "specs/slash-commands/spec.md" | wc -l | tr -d ' ') || ref_count=0
if [[ "$ref_count" == "0" ]]; then
    check "AC-001: OpenSpec references = 0" "0"
else
    check "AC-001: OpenSpec references = 0 (remaining: $ref_count)" "1"
fi

# AC-002: setup/openspec removed
echo "AC-002: Checking setup/openspec directory..."
if [[ ! -d "setup/openspec" ]]; then
    check "AC-002: setup/openspec removed" "0"
else
    check "AC-002: setup/openspec removed" "1"
fi

# AC-003: .claude/commands/openspec removed
echo "AC-003: Checking .claude/commands/openspec directory..."
if [[ ! -d ".claude/commands/openspec" ]]; then
    check "AC-003: .claude/commands/openspec removed" "0"
else
    check "AC-003: .claude/commands/openspec removed" "1"
fi

# AC-004: dev-playbooks/specs/openspec-integration removed
echo "AC-004: Checking dev-playbooks/specs/openspec-integration directory..."
if [[ ! -d "dev-playbooks/specs/openspec-integration" ]]; then
    check "AC-004: dev-playbooks/specs/openspec-integration removed" "0"
else
    check "AC-004: dev-playbooks/specs/openspec-integration removed" "1"
fi

echo ""
echo "=== Summary ==="
echo "passed: $PASSED"
echo "failed: $FAILED"

if [[ $FAILED -eq 0 ]]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Some checks failed${NC}"
    exit 1
fi
