---
name: devbooks-impact-analysis
description: devbooks-impact-analysis: Performs impact analysis before cross-module/cross-file/external contract changes, producing the Impact section (Scope/Impacts/Risks/Minimal Diff/Open Questions) that can be directly written to proposal.md. Use when the user mentions "impact analysis/change scope control/reference lookup/affected modules/compatibility risks" etc.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash
---

# DevBooks: Impact Analysis

## Progressive Disclosure

### Base (Required)
Goal: Write an Impact Analysis section into `<change-root>/<change-id>/proposal.md`.
Inputs: change intent, target symbols/files, existing proposal/design context.
Outputs: updated `proposal.md` Impact section (Scope/Impacts/Risks/Minimal Diff/Open Questions).
Boundaries: write results to the artifact file, not to the conversation; do not modify `tests/**`.
Evidence: reference the updated file path and summary counts (files/risks).

### Advanced (Optional)
Use when you need: transitive impact, risk heatmap, open questions.

### Extended (Optional)
Use when you need: faster search/graph impact via code intelligence or reference tools.

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) -> Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) -> template protocol, use default mappings
5. If still unable to determine -> **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before performing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Output Location

- **Must** write to: The Impact section of `<change-root>/<change-id>/proposal.md`
- Alternative: Separate `impact-analysis.md` file (to be backfilled to proposal.md later)

## Output Behavior (Critical Constraint)

> **Golden Rule**: **Write directly to document, do NOT output to conversation window**

### Must Follow

1. **Direct Write**: Use `Edit` or `Write` tool to write analysis results directly to target document
2. **No Echo**: Do NOT display the complete analysis content in the conversation
3. **Brief Notification**: After completion, only inform the user "Impact analysis written to `<file-path>`"

### Correct vs Incorrect Behavior

| Scenario | ❌ Incorrect Behavior | ✅ Correct Behavior |
|----------|----------------------|---------------------|
| Analysis complete | Output full Impact table in conversation | Use Edit tool to write to proposal.md |
| Notify user | Repeat analysis content | "Impact analysis written to `changes/xxx/proposal.md`" |
| Large results | Paginate output to conversation | Write all to file, inform file location |

### Example Conversation

```
User: Analyze the impact of modifying UserService

AI: [Uses code search/reference tracking for analysis]
    [Uses Edit tool to write to proposal.md]

    Impact analysis written to the Impact section of `changes/refactor-user/proposal.md`.
    - Direct impact: 8 files
    - Indirect impact: 12 files
    - Risk level: Medium

    Open the file to view details.
```

## Execution Method

1) First read and follow: `~/.claude/skills/_shared/references/ai-behavior-guidelines.md` (Verifiability + Structural Quality Gate).
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

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

### Detection Flow

1. Detect whether a change package exists
2. Detect whether the `proposal.md` already has an Impact section
3. Detect whether structured reference tracking capability is available (for more precise analysis)

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **New Analysis** | Impact section does not exist | Perform complete impact analysis |
| **Incremental Analysis** | Impact exists, new changes present | Update affected files list |
| **Structured Analysis** | Structured reference tracking available | Use call relationships for precise analysis |
| **Text Analysis** | Only text search available | Use Grep text search for analysis |

### Detection Output Example

```
Detection Results:
- proposal.md: Exists, Impact section missing
- Reference tracking capability: Available
- Run Mode: New Analysis + Structured Analysis
```

---
