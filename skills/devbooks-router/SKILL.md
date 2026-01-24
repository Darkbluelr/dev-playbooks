---
name: devbooks-router
description: devbooks-router: DevBooks workflow entry guidance. Helps users determine which skill to start with, detects project current status, and provides shortest closed-loop path. Use when the user says "what's next/where to start/run DevBooks closed-loop/project status" etc. Note: Routing after skill completion is handled by each skill itself, no need to call router.
allowed-tools:
  - Glob
  - Grep
  - Read
  - Bash
---

# DevBooks: Workflow Entry Guide (Router)

## Progressive Disclosure

### Base (must read)
Goal: determine the current phase and output the shortest closed-loop routing (skills + artifact paths + rationale).
Input: user request, config mapping (truth-root/change-root), existing artifacts, change package status.
Output: 2 minimum key questions + 3-6 routing results + next-step suggestion.
Boundaries: do not directly produce change package artifacts; do not replace other Skills; must read `agents_doc` first.
Evidence: reference artifact paths and the detection conclusion.

### Advanced (optional)
Use when you need: impact profile parsing, degradation notes, detailed routing rules.

### Extended (optional)
Use when you need: prototype track, pre-archive checks, context-detection details.

## Core Notes

- Run config discovery (prefer `.devbooks/config.yaml`) and read `agents_doc` before routing.
- Output 2 minimum key questions + 3-6 routing results (paths + rationale).
- If the user asks to "start producing files", switch to the target Skill's output mode.

## References

- `skills/devbooks-router/references/routing-rules-and-templates.md`: positioning, config discovery, impact profile parsing, routing rules, prototype track, context detection.

## Recommended MCP Capability Types

- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)
