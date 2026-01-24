---
name: devbooks-docs-consistency
description: devbooks-docs-consistency: Check and maintain consistency between project documentation and code, supporting incremental scanning, custom rules, and completeness checks. Can run on-demand within change packages or globally. Old name devbooks-docs-sync is retained as an alias with deprecation notice.
recommended_experts: ["Technical Writer", "System Architect"]
allowed-tools:
  - Glob
  - Grep
  - Read
  - Edit
  - Write
  - Bash
---

# DevBooks: Documentation Consistency (Docs Consistency)

## Progressive Disclosure

### Base (Required)
Goal: Check documentation consistency and completeness and produce reports.
Inputs: user docs, changed files (change-scoped) or full repo docs (global).
Outputs: evidence reports under `<change-root>/<change-id>/evidence/` (or specified output paths).
Boundaries: check-only by default; do not modify code or `tests/**`.
Evidence: reference generated report paths.

### Advanced (Optional)
Use when you need: rules customization, doc classification tuning, completeness dimensions.

### Extended (Optional)
Use when you need: faster search/impact via optional MCP capabilities.

## Recommended MCP Capability Types
- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use mappings within
2. `dev-playbooks/project.md` (if exists) -> Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) -> template protocol, use default mappings
4. If still undetermined -> **Stop and ask user**

---

## Compatibility and Deprecation

- Old name: `devbooks-docs-sync`
- Current name: `devbooks-docs-consistency`
- Behavior: Old name continues to work as an alias with deprecation notice.
- Runtime notice: Alias points to new directory via symlink, can execute `scripts/alias.sh` to output notice.

Deprecation notice example:

```
devbooks-docs-sync is deprecated, please use devbooks-docs-consistency.
```

---

## Role Definition

**docs-consistency** is the documentation consistency check role in the DevBooks Apply phase, responsible for identifying discrepancies between documentation and code and generating reports, without directly modifying code.

### Document Classification

| Document Type | Target Audience | Checked by This Skill | Examples |
|---------------|-----------------|:---------------------:|----------|
| **Living Documents** | End Users | Yes | README.md, docs/*.md, API.md |
| **Historical Documents** | End Users | Limited (minimal checks only) | CHANGELOG.md |
| **Conceptual Documents** | Design/Architecture | Yes (structural checks) | architecture/*.md |

Classification rules are configurable, default rules in `references/doc-classification.yaml`.

---

## Execution Modes

### Mode 1: Incremental Scan (Change-Scoped)

**Trigger condition**: Running within change package context.

**Behavior**:
1. Read change scope
2. Scan only changed files
3. Record token consumption and scan time
4. Output check report

### Mode 2: Full Scan (Global Check)

**Trigger condition**: User explicitly requests global check (e.g., `devbooks-docs-consistency --global`).

**Behavior**:
1. Scan all user documentation
2. Generate diff report
3. Output improvement suggestions

### Mode 3: Check Mode (Check Only)

**Trigger condition**: User uses `--check` parameter.

**Behavior**: Check only, no modifications, output report.

---

## Command Examples

```
# Rules engine: persistent rules
bash scripts/rules-engine.sh --rules references/docs-rules-schema.yaml --input README.md

# Rules engine: one-time task
bash scripts/rules-engine.sh --once "remove:@augment" --input README.md

# Document classification
bash scripts/doc-classifier.sh README.md

# Completeness check
bash scripts/completeness-checker.sh --input README.md --config references/completeness-dimensions.yaml --output evidence/completeness-report.md
```

---

## Completeness Checks

Execute completeness checks on living documents, covering by default: environment dependencies, security permissions, troubleshooting, configuration instructions, API documentation.

- Dimension configuration: `references/completeness-dimensions.yaml`
- Report output: `<change-root>/<change-id>/evidence/completeness-report.md`
- Methodology reference: [Completeness Thinking Framework](../_shared/references/completeness-thinking-framework.md)

---

## Style Preferences

Style preference reading priority: command-line arguments > config file > defaults.

- Documentation maintenance metadata: `dev-playbooks/specs/_meta/docs-maintenance.md`

---

## Output and Reports

Default output reports (change package context):

- `evidence/completeness-report.md`
- `evidence/token-usage.log`
- `evidence/scan-performance.log`

---

## Workflow Integration

Triggered by `devbooks-archiver` during archiving phase, generates documentation maintenance metadata during brownfield initialization by `devbooks-brownfield-bootstrap`.

---


## Metadata

| Field | Value |
|-------|-------|
| Skill Name | devbooks-docs-consistency |
| Phase | Apply (post-implementation, pre-archiving) |
| Artifacts | Documentation consistency check reports |
| Constraints | Check only, do not modify code |

---

*This Skill documentation follows devbooks-* conventions.*
