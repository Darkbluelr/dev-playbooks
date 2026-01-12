---
skill: multi-skill
backward-compat: true
---

# /devbooks:quick

**Backward Compatible Command**: quick mode (small changes).

## Purpose

This is a backward compatible command, maintaining consistency with the original `/devbooks:quick` invocation style.

For small changes, it may skip parts of the workflow.

## New version alternative

Use Router to get the recommended shortest path:

```
/devbooks:router
```

Router will automatically recommend the shortest safe route based on change size.

## Quick mode constraints

- Only for single-file or small multi-file changes
- No external API changes
- No architecture boundary changes
- No data model changes

## Boundary checks

If the change exceeds quick mode boundaries, it will recommend switching to the full workflow.

## Migration notes

```
Old command           New command
/devbooks:quick  →  /devbooks:router (Router will recommend a quick path if applicable)
```

