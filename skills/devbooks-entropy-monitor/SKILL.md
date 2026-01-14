---
name: devbooks-entropy-monitor
description: devbooks-entropy-monitor: Periodically collect system entropy metrics (structural entropy/change entropy/test entropy/dependency entropy), generate quantitative reports, and recommend refactoring when thresholds are exceeded. Use when user mentions "entropy measurement/complexity trends/refactoring warnings/code health/technical debt measurement".
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash
---

# DevBooks: System Entropy Measurement and Alerts (Entropy Monitor)

> Source: "The Mythical Man-Month" Chapter 16 "No Silver Bullet" — "The complexity of software entities is an essential property... controlling complexity is the key to software development"

## Prerequisites: Configuration Discovery (Protocol-Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Core Philosophy

**System Entropy** = Growth trend of code complexity over time

Goals of entropy measurement:
1. **Quantification**: All metrics are numerical values/ratios, enabling comparison
2. **Trend Visibility**: Historical data supports trend analysis
3. **Threshold Alerts**: Proactively recommend refactoring when thresholds are exceeded
4. **Periodic Execution**: Run as an independent task, not embedded in every code review

## Execution Method

1) First read and follow: `_shared/references/universal-gating-protocol.md` (verifiability + structural quality gating).
2) Strictly output according to the complete prompt: `references/entropy-measurement-methodology.md`.

## Scripts

| Script | Purpose | Example |
|--------|---------|---------|
| `entropy-measure.sh` | Collect entropy metrics | `entropy-measure.sh --project-root /path/to/repo` |
| `entropy-report.sh` | Generate report | `entropy-report.sh --output report.md` |

## Metrics System (Four Dimensions)

### A) Structural Entropy

| Metric | Collection Method | Healthy Threshold | Description |
|--------|------------------|-------------------|-------------|
| Average Cyclomatic Complexity | Static analysis | < 10 | Function-level average |
| Cyclomatic Complexity P95 | Static analysis | < 20 | 95th percentile |
| File Lines P95 | Line count | < 500 | Oversized file warning |
| Function Lines P95 | Static analysis | < 50 | Overly long function warning |

### B) Change Entropy

| Metric | Collection Method | Healthy Threshold | Description |
|--------|------------------|-------------------|-------------|
| Hotspot File Ratio | git log | < 0.1 | Ratio of frequently modified files |
| Coupled Change Rate | git log | < 0.3 | Ratio of file pairs frequently modified together |
| Code Churn Rate | git diff | < 0.5 | Ratio of new code deleted within 30 days |

### C) Test Entropy

| Metric | Collection Method | Healthy Threshold | Description |
|--------|------------------|-------------------|-------------|
| Flaky Test Ratio | CI logs | < 0.01 | Ratio of unstable tests |
| Test Coverage | Coverage tools | > 0.7 | Code coverage rate |
| Test/Code Ratio | Line count | > 0.5 | Ratio of test code to production code |

### D) Dependency Entropy

| Metric | Collection Method | Healthy Threshold | Description |
|--------|------------------|-------------------|-------------|
| Outdated Dependency Ratio | npm/pip audit | < 0.2 | Dependencies more than 2 major versions behind |
| Security Vulnerability Count | Security scan | = 0 | Number of high-risk vulnerabilities |
| Dependency Depth P95 | Dependency tree analysis | < 10 | Levels of transitive dependencies |

## Output Locations

| Output | Path | Description |
|--------|------|-------------|
| Entropy Report | `<truth-root>/_meta/entropy/entropy-report-YYYY-MM-DD.md` | Current collection report |
| Historical Data | `<truth-root>/_meta/entropy/history.json` | All historical metrics |
| Threshold Configuration | `<truth-root>/_meta/entropy/thresholds.json` | Configurable thresholds |

## Recommended Execution Frequency

| Project Size | Recommended Frequency | Trigger Method |
|--------------|----------------------|----------------|
| Small (< 10K LOC) | Weekly | Manual / CI scheduled |
| Medium (10K-100K LOC) | Daily | CI scheduled |
| Large (> 100K LOC) | Every merge | PR merge trigger |

## Relationship with Other Skills

| Skill | Relationship |
|-------|--------------|
| devbooks-code-review | Entropy measurement is **not** embedded in every review, runs as independent task |
| devbooks-proposal-author | Entropy reports can serve as data support for refactoring proposals |
| devbooks-impact-analysis | Changes in high-entropy areas require more careful impact analysis |

## Hard Constraints

1. **Quantification First**: All metrics must be numerical values/ratios, no subjective evaluations
2. **Configurable Thresholds**: All thresholds managed through `thresholds.json`, not hardcoded
3. **Historical Traceability**: Each collection result appended to `history.json`
4. **Independent Execution**: Not embedded in other workflows, runs as periodic independent task

---

## Context Awareness

This Skill automatically detects context before execution to select appropriate collection scope.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect if historical data file exists
2. Detect last collection time
3. Detect if any metrics exceed thresholds

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Initial Collection** | Historical data does not exist | Execute full collection and establish baseline |
| **Incremental Collection** | Interval since last collection exceeded | Collect new data and compare trends |
| **Alert Mode** | Metrics exceeding thresholds detected | Generate alert report and recommend refactoring |

### Detection Output Example

```
Detection Results:
- Historical data: Exists (15 records)
- Last collection: 2026-01-10
- Metrics exceeding thresholds: 2 (Cyclomatic Complexity P95, Hotspot File Ratio)
- Execution mode: Incremental Collection + Alert Mode
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Required MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getHotspots` | Get hotspot file analysis | 2s |
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available → Use `getHotspots` for precise hotspot analysis
3. If timeout or failure → Fall back to Git history statistics

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Hotspot Analysis | CKB real-time analysis (includes complexity) | Git log change frequency statistics |
| Coupling Detection | Call graph analysis | File co-change analysis |
| Trend Prediction | Based on complexity change rate | Based on change frequency |

### Fallback Notice

When MCP is unavailable, output the following notice:

```
Warning: CKB unavailable, using Git history for entropy measurement.
Hotspot analysis based on change frequency, does not include code complexity data.
```

