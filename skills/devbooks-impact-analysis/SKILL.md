---
name: devbooks-impact-analysis
description: devbooks-impact-analysis: Performs impact analysis before cross-module/cross-file/external contract changes, producing the Impact section (Scope/Impacts/Risks/Minimal Diff/Open Questions) that can be directly written to proposal.md. Use when the user mentions "impact analysis/change scope control/reference lookup/affected modules/compatibility risks" etc.
tools:
  - Glob
  - Grep
  - Read
  - Bash
---

# DevBooks: Impact Analysis

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) -> DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) -> template protocol, use default mappings
5. If still unable to determine -> **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before performing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Output Location

- Recommended: Write to the Impact section of `<change-root>/<change-id>/proposal.md` (or create a separate analysis document and backfill later)

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (Verifiability + Structural Quality Gate).
2) Use `Grep` to search for symbol references, `Glob` to find related files.
3) Strictly follow the complete prompt to output Impact Analysis Markdown: `references/impact-analysis-prompt.md`.

## Output Format

```markdown
## Impact Analysis

### Scope
- Direct impact: X files
- Indirect impact: Y files

### Impacts
| File | Impact Type | Risk Level |
|------|-------------|------------|
| ... | Direct call | High |

### Risks
- ...

### Minimal Diff
- ...

### Open Questions
- ...
```

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate analysis scope.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect whether a change package exists
2. Detect whether the `proposal.md` already has an Impact section
3. Detect whether CKB index is available (enhances analysis capability)

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **New Analysis** | Impact section does not exist | Perform complete impact analysis |
| **Incremental Analysis** | Impact exists, new changes present | Update affected files list |
| **Enhanced Analysis** | CKB index available | Use call graph for precise analysis |
| **Basic Analysis** | CKB index unavailable | Use Grep text search for analysis |

### Detection Output Example

```
Detection Results:
- proposal.md: Exists, Impact section missing
- CKB Index: Available
- Run Mode: New Analysis + Enhanced Mode
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Required MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__analyzeImpact` | Symbol-level impact analysis | 2s |
| `mcp__ckb__findReferences` | Precise reference lookup | 2s |
| `mcp__ckb__getCallGraph` | Call graph analysis | 2s |
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available -> Use `analyzeImpact` and `findReferences` for precise analysis
3. If timeout or failure -> Fallback to basic mode (Grep text search)

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Reference Lookup | Symbol-level precise matching | Text Grep search |
| Impact Scope | Call graph transitive analysis | Direct reference counting |
| Risk Assessment | Quantified based on call depth | Estimated based on file count |
| Cross-module Analysis | Automatic module boundary recognition | Requires manual scope specification |

### Fallback Notice

When MCP is unavailable, output the following notice:

```
Warning: CKB unavailable, using Grep text search for impact analysis.
Analysis results may not be precise. Recommend manually generating SCIP index and re-analyzing.
```

