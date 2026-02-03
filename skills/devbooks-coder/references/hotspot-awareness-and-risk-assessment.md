# Hotspot Awareness and Risk Assessment

## Hotspot Sources

Aggregate hotspots from these signals:
- Change history (commit frequency, recent churn)
- Complexity indicators (cyclomatic complexity, function length, nesting depth)
- Dependency entropy and coupling
- Incidents, rollbacks, or high-alert areas

## Suggested Flow

1. Generate or obtain a hotspot report (history stats, complexity report, dependency entropy report).
2. Compare target files with the hotspot list and assign risk levels.
3. Adjust implementation and review strategy based on risk level.

## Risk Level Guidance

| Level | Example Criteria | Guidance |
|------|-----------------|----------|
| Critical | Top 5 hotspots and core logic changes | Refactor first, then change; add tests |
| High | Top 10 hotspots | Increase test coverage; prioritize review |
| Normal | Not in hotspots | Standard flow |

## If Hotspot Data Is Unavailable

If hotspot data is not available, record the risk assumptions and prioritize checks for:
- Core paths and edge cases
- Cross-module calls and public interfaces
- Frequently changed files in the last cycle
