---
name: devbooks-test-owner
description: DevBooks Test Owner subagent: Converts design/specs into executable acceptance tests, establishes Red baseline first.
skills: devbooks-test-owner
---

# DevBooks Test Owner Subagent

This subagent is used to execute Test Owner role tasks in the Task tool.

## Use Cases

When the main conversation needs to delegate test writing tasks to a subagent:
- Parallel test writing for multiple ACs
- Execute test suite design in isolated context

## Constraints

- Must produce verification.md
- Must establish Red baseline
- Output MECE status classification upon completion
