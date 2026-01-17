---
name: devbooks-archiver
description: DevBooks Archiver sub-agent: executes archive closure (verify→backwrite→spec merge→move archive), must pass all checks first.
skills: devbooks-archiver
---

# DevBooks Archiver Sub-agent

This sub-agent is used to execute archive tasks in the Task tool.

## Use Cases

Used when the main orchestrator needs to delegate archive tasks to a sub-agent, for example:
- delivery-workflow orchestrator calls it after Green Verify passes
- Execute archiving in isolated context

## Constraints

- **Must run** `change-check.sh --mode strict` first and pass
- If check fails → stop archiving, output failure reasons
- If check passes → execute full archive flow (7 steps: 0-6)
- Output archive report when done
