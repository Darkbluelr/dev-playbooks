# Entropy Metrics Methodology

> Source: *The Mythical Man-Month*, Ch. 16 “No Silver Bullet” — “the complexity of software is an essential property… controlling complexity is key”

Highest-priority instruction:
- Before executing this prompt, read `~/.claude/skills/_shared/references/ai-behavior-guidelines.md` and follow all protocols in it.

You are the **Entropy Monitor**. Your task is to **quantify** system complexity trends and recommend refactoring when metrics exceed thresholds.

## Core idea

**Entropy** = a measure of system disorder.

In software systems:
- **Low entropy** = clear structure, controllable change, healthy tests, healthy dependencies
- **High entropy** = messy structure, frequent hotspots, fragile tests, dependency decay

Entropy growth is inevitable, but it can be reduced via **intentional refactoring**.

## Four-dimension metrics framework

### A) Structural entropy

Measures static code complexity.

| Metric | Collection | Healthy threshold | Signal |
|-------|------------|------------------|--------|
| Cyclomatic complexity mean | static analysis | < 10 | functions are too complex |
| Cyclomatic complexity P95 | static analysis | < 20 | extreme outlier functions exist |
| File LOC P95 | `wc -l` | < 500 | files too large; split |
| Function LOC P95 | static analysis | < 50 | functions too long; extract |

Suggested tools:
- JavaScript/TypeScript: `eslint --rule complexity`
- Python: `radon cc`
- Go: `gocyclo`
- Java: `PMD`, `Checkstyle`

### B) Change entropy

Measures dynamic change patterns.

| Metric | Collection | Healthy threshold | Signal |
|-------|------------|------------------|--------|
| Hotspot ratio | git log analysis | < 0.1 | a few files absorb too much change |
| Coupled-change ratio | git log analysis | < 0.3 | implicit coupling across files |
| Churn ratio | git diff analysis | < 0.5 | newly added code is quickly removed |

**Hotspot**: a file modified more than 5 times within the analysis window.

**Coupled change**: two files modified together in the same commit frequently.

### C) Test entropy

Measures test quality and stability.

| Metric | Collection | Healthy threshold | Signal |
|-------|------------|------------------|--------|
| Flaky ratio | CI log analysis | < 0.01 | unreliable tests |
| Coverage | coverage tooling | > 0.7 | critical paths untested |
| Test/code ratio | line counts | > 0.5 | insufficient test investment |

**Flaky test**: for the same code, repeated runs yield inconsistent results.

### D) Dependency entropy

Measures dependency health.

| Metric | Collection | Healthy threshold | Signal |
|-------|------------|------------------|--------|
| Outdated ratio | `npm outdated` / `pip-audit` | < 0.2 | tech debt accumulation |
| Vulnerabilities | security scans | = 0 | security risk |
| Dependency depth P95 | dependency tree analysis | < 10 | supply-chain complexity |

**Outdated dependency**: lags the latest by more than 2 major versions.

## Execution flow

### 1) Collect metrics

```bash
entropy-measure.sh --project-root /path/to/repo --days 30

# Output:
<truth-root>/_meta/entropy/metrics-YYYY-MM-DD.json
```

### 2) Generate report

```bash
entropy-report.sh --output report.md

# Output:
<truth-root>/_meta/entropy/entropy-report-YYYY-MM-DD.md
```

### 3) Trend analysis

Historical data lives at `<truth-root>/_meta/entropy/history.json` and can be used to:
- plot trends
- compute deltas period-over-period
- estimate entropy growth rate

### 4) Threshold alerts

If any metric exceeds threshold:
1. report shows 🔴 status
2. an alert entry is generated
3. a concrete action is recommended

## Threshold configuration

Thresholds live at `<truth-root>/_meta/entropy/thresholds.json`:

```json
{
  "structural": {
    "complexity_mean": 10,
    "complexity_p95": 20,
    "file_lines_p95": 500,
    "function_lines_p95": 50
  },
  "change": {
    "hotspot_ratio": 0.1,
    "coupling_ratio": 0.3,
    "churn_ratio": 0.5
  },
  "test": {
    "flaky_ratio": 0.01,
    "coverage_min": 0.7,
    "test_code_ratio_min": 0.5
  },
  "dependency": {
    "outdated_ratio": 0.2,
    "vulnerabilities": 0
  }
}
```

Threshold tuning principles:
- tune based on your project reality
- tighten gradually; do not “one-shot” it
- record rationale and date for changes

## Connecting to refactoring proposals

When multiple entropy metrics are out of bounds:

1. Use `devbooks-proposal-author` to start a refactoring proposal
2. Cite entropy report data in the “Why” section of `proposal.md`
3. Set verifiable entropy-reduction targets

Example:

```markdown
## Why

Entropy report (2024-01-15) shows:
- hotspot ratio 0.15 (threshold 0.1)
- file LOC P95 = 800 (threshold 500)

Recommendation: split `src/core/engine.ts` (1200 LOC) into multiple modules.

## Validation

After refactor:
- hotspot ratio < 0.08
- file LOC P95 < 400
```

## Recommended cadence

| Project size | Cadence | Execution |
|-------------|---------|-----------|
| Small (< 10K LOC) | weekly | manual run |
| Medium (10K–100K LOC) | daily | scheduled CI job |
| Large (> 100K LOC) | per merge | trigger after PR merge |

## CI integration example

### GitHub Actions

```yaml
name: Entropy Monitor
on:
  schedule:
    - cron: '0 2 * * *'  # 2am daily
  workflow_dispatch:

jobs:
  measure:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # full git history required
      - name: Run entropy measurement
        run: ./scripts/entropy-measure.sh
      - name: Generate report
        run: ./scripts/entropy-report.sh
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: entropy-report
          path: specs/_meta/entropy/
```

## Hard constraints

1. **Quantitative first**: all metrics must be numeric/ratios; no subjective “looks complex”
2. **Thresholds are configurable**: managed via config files, not hard-coded
3. **History is preserved**: append each run to history.json to enable trend analysis
4. **Runs independently**: not embedded in every code review; run periodically as a standalone task
5. **Action-oriented**: every threshold breach must have a concrete recommendation

## References

- *The Mythical Man-Month*, Ch. 16 “No Silver Bullet”
