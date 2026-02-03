# MCP Prompt Template (Recommended MCP Capability Types)

> This template can be referenced by `skills/**/SKILL.md` to indicate which MCP capability types fit a task.
> It is not bound to any specific MCP server/tool name, and it does not describe runtime detection, timeouts, failure handling, or downgrade strategies.

---

## Standard section format (copy into SKILL.md)

```markdown
## Recommended MCP capability types
- Code search (code-search)
- Reference tracking (reference-tracking)
- Impact analysis (impact-analysis)
- Doc retrieval (doc-retrieval)
```

## Rules (SKILL.md only)

- Only list capability types (English label + optional identifier).
- Do not mention specific MCP servers, function names, or commands (e.g., `ckb`, `context7`, `mcp__*`).
- Do not include runtime detection, timeout thresholds, failure handling, or downgrade prompts.

---

## Legacy "## MCP Enhancement" section (deprecated)

`skills/**/SKILL.md` should no longer use "## MCP Enhancement / Required MCP servers / Enhanced vs basic mode" structures.
If you need to describe MCP runtime detection and failure handling, keep it in specs only:

- Spec: `dev-playbooks/specs/mcp/spec.md`

