---
skill: devbooks-spec-gardener
backward-compat: true
---

# /devbooks:archive

**Backward Compatible Command**: Executes the archive stage.

## Purpose

This command is a backward compatible command, maintaining consistency with the original `/devbooks:archive` invocation style.

Internally invokes the `devbooks-spec-gardener` Skill.

## New Version Alternative

Recommended to use the direct command:

```
/devbooks:gardener
```

## Functionality

Pre-archive pruning and maintenance of <truth-root> (deduplication/merging, removing outdated content, directory organization, consistency fixes) to prevent specs from accumulating out of control.

## Migration Notes

```
Old Command            New Command
/devbooks:archive  →  /devbooks:gardener
```
