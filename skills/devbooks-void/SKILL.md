---
name: devbooks-void
description: devbooks-void: Void protocol executor. For high-entropy / uncertain / multi-option disputes. Produces only research_report + ADR + Freeze/Thaw artifacts (no production code). Use when users say "enter void / stuck / uncertain / need research / freeze / thaw".
recommended_experts: ["Research Lead", "System Architect"]
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Void (High-entropy problem protocol)

## Progressive disclosure

### Basic layer (must read)

Goal: turn "insufficient input / uncertainty / multi-option dispute" into auditable knowledge + decision artifacts, and use Freeze/Thaw to control downstream execution.

Inputs: user request, change package metadata (proposal front matter), existing evidence and Gate Reports (if any).

Outputs (MUST):
- `void/research_report.md`: conclusions, constraints, evidence sources, impacts, risks, and next-step suggestions
- `void/ADR.md`: Context / Options / Decision / Consequences
- `void/void.yaml`: Freeze/Thaw state, blocking questions, resolved questions, and references

Boundaries (MUST):
- Void must not produce production code changes; must not modify `tests/` or `src/`.
- Void artifacts must be machine-checkable (see `void-protocol-check.sh`).

Evidence: Void artifacts exist and are non-empty; Freeze/Thaw state aligns with change package state/next_action.

### Advanced layer (optional)

Use when you need to backport conclusions into Truth (Decision/Constraints), or generate an input index for subsequent Knife/Bootstrap.

## Key points

- Run config discovery (`.devbooks/config.yaml`) and read the rules doc first, then produce Void artifacts.
- Conclusions must be actionable: include an explicit `next_action` (Bootstrap/Knife/DevBooks) and unblock conditions.
- Freeze must block downstream execution; Thaw must link ADR + evidence and record the absorption path.

## References

- `dev-playbooks/specs/void/spec.md`

