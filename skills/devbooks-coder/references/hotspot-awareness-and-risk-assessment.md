# Hotspot Awareness and Risk Assessment

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `~/.claude/skills/_shared/mcp-enhancement-template.md`

## Dependent MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getHotspots` | Detect hotspot files, output warnings | 2s |
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

## Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available → Call `mcp__ckb__getHotspots` to get hotspot files
3. If timeout or failure → Degrade to basic mode (no hotspot warnings)

## Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Hotspot file warnings | CKB real-time analysis | Not available |
| Risk file identification | Auto-highlight high-hotspot changes | Manual identification |
| Code navigation | Symbol-level jumping | File-level search |

## Degradation Prompt

When MCP unavailable, output this prompt:

```
⚠️ CKB unavailable, skipping hotspot detection.
To enable hotspot warnings, manually generate SCIP index.
```
