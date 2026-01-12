#!/bin/bash
# verify-all.sh - Run all verification scripts
#
# Aggregates verification results for AC-001 ~ AC-022

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     DevBooks Independence Verification Suite   ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Run verification scripts
echo -e "${YELLOW}>>> OpenSpec removal verification (AC-001 ~ AC-004)${NC}"
echo ""
openspec_result=0
if "$SCRIPT_DIR/verify-openspec-free.sh"; then
    openspec_result=1
fi
echo ""

echo -e "${YELLOW}>>> Slash command verification (AC-005 ~ AC-010)${NC}"
echo ""
slash_result=0
if "$SCRIPT_DIR/verify-slash-commands.sh"; then
    slash_result=1
fi
echo ""

echo -e "${YELLOW}>>> npm package verification (AC-011 ~ AC-016)${NC}"
echo ""
npm_result=0
if "$SCRIPT_DIR/verify-npm-package.sh"; then
    npm_result=1
fi
echo ""

echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                   Summary                      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
echo ""

if [[ $openspec_result -eq 1 ]]; then
    echo -e "${GREEN}✅ OpenSpec removal verification${NC}"
else
    echo -e "${RED}❌ OpenSpec removal verification${NC}"
fi

if [[ $slash_result -eq 1 ]]; then
    echo -e "${GREEN}✅ Slash command verification${NC}"
else
    echo -e "${RED}❌ Slash command verification${NC}"
fi

if [[ $npm_result -eq 1 ]]; then
    echo -e "${GREEN}✅ npm package verification${NC}"
else
    echo -e "${RED}❌ npm package verification${NC}"
fi

echo ""

total=$((openspec_result + slash_result + npm_result))
if [[ $total -eq 3 ]]; then
    echo -e "${GREEN}🎉 All checks passed! DevBooks independence verified.${NC}"
    exit 0
else
    echo -e "${RED}⚠️  Some checks failed. Review the output above.${NC}"
    exit 1
fi
