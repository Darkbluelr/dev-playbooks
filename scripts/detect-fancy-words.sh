#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# Pattern matches marketing fluff words that should be avoided in technical documentation
PATTERN="(super brain|revolutionary|disruptive|perfect|elegant|game changer|cutting edge|best in class|seamless|robust)"

grep -rE "$PATTERN" "$ROOT_DIR/skills"/*/{SKILL,skill}.md 2>/dev/null || true
