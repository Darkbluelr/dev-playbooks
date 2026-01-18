# MCP Enhancement Template

> This template is referenced by SKILL.md files and defines a standard section format for MCP runtime detection and graceful degradation.

---

## Core Principles

1. **2s timeout**: All MCP calls must return within 2s, otherwise treated as unavailable
2. **Graceful degradation**: When MCP is unavailable, the Skill continues with basic functionality
3. **Silent detection**: Detection is transparent to the user; only show a notice when degraded

---

## Standard Section Format

Each SKILL.md "MCP Enhancement" section should include:

```markdown
## MCP Enhancement

This Skill supports MCP runtime enhancement and automatically detects and enables advanced features.

### Dependent MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |
| `mcp__ckb__getHotspots` | Get hotspot files | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If success -> enable enhanced mode
3. If timeout or failure -> degrade to basic mode

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Hotspot detection | CKB real-time analysis | Git history stats |
| Impact analysis | Symbol-level references | File-level grep |
| Call graph | Precise call chain | Not available |

### Degradation Notice

When MCP is unavailable, output:

```
⚠️ CKB unavailable (timeout or not configured), running in basic mode.
To enable enhanced features, manually generate SCIP index.
```
```

---

## Skill Classification

### Skills Without MCP Dependencies

The following Skills do not depend on MCP and do not need an MCP Enhancement section:

- devbooks-design-doc (document-only)
- devbooks-implementation-plan (plan-only)
- devbooks-proposal-author (document-only)
- devbooks-proposal-challenger (review-only)
- devbooks-proposal-judge (verdict-only)
- devbooks-design-backport (document backport)
- devbooks-archiver (file pruning)
- devbooks-test-reviewer (test review)

For these Skills, the MCP Enhancement section should be:

```markdown
## MCP Enhancement

This Skill does not depend on MCP services; no runtime detection needed.
```

### Skills With MCP Dependencies

The following Skills depend on MCP and require the full MCP Enhancement section:

| Skill | MCP Dependencies | Enhanced Features |
|-------|------------------|-------------------|
| devbooks-coder | mcp__ckb__getHotspots | Hotspot warnings |
| devbooks-code-review | mcp__ckb__getHotspots | Hotspot highlighting |
| devbooks-impact-analysis | mcp__ckb__analyzeImpact, findReferences | Precise impact analysis |
| devbooks-brownfield-bootstrap | mcp__ckb__* | COD model generation |
| devbooks-router | mcp__ckb__getStatus | Index availability detection |
| devbooks-spec-contract | mcp__ckb__findReferences | Reference detection |
| devbooks-entropy-monitor | mcp__ckb__getHotspots | Hotspot trend analysis |
| devbooks-delivery-workflow | mcp__ckb__getStatus | Index detection |
| devbooks-test-owner | mcp__ckb__analyzeImpact | Test coverage analysis |

---

## Detection Code Example

### Bash Detection Script

```bash
#!/bin/bash
# mcp-detect.sh - MCP availability detection

TIMEOUT=2

# Check CKB
check_ckb() {
  # Simulate MCP call (executed by Claude Code)
  # If no response within 2s, return degraded state
  echo "⚠️ CKB detection must be executed in Claude Code runtime"
}

# Output detection results
detect_mcp() {
  local ckb_status="unknown"

  # Check index.scip file existence (file-level detection)
  if [ -f "index.scip" ]; then
    ckb_status="available (file-based)"
  else
    ckb_status="unavailable"
  fi

  echo "MCP detection results:"
  echo "- CKB index: $ckb_status"
}

detect_mcp
```

---

## Notes

1. **Do not add non-existent MCP tools to SKILL.md frontmatter**
2. **Timeout detection should run once at Skill start, not multiple times**
3. **After degrading, do not repeat the notice; output once on first detection**
4. **Enhanced features are optional; basic functionality must remain complete**
