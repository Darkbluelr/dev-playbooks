# MCP Capability Guidance Template

> This template is referenced by SKILL.md files and defines the standard sections for MCP capability guidance and progressive disclosure.

---

## Core Principles

1. Capability-based naming, not server-based naming
2. MCP is optional; skills must remain complete without it
3. Progressive disclosure: Base, Advanced, Extended

---

## Standard Section Format

```markdown
## Recommended MCP Capability Types

- `code-search`: locate relevant code and symbols
- `reference-tracking`: find usages, call relationships, and ownership
- `impact-analysis`: assess change scope and blast radius
- `doc-retrieval`: fetch up-to-date library docs and examples (optional)

## Progressive Disclosure

### Base
Goal: ...
Inputs: ...
Outputs: ...
Boundaries: ...
Evidence: ...

### Advanced
- Validate adjacent artifacts for consistency and highlight gaps.
- Provide edge cases, open questions, and suggested next steps.

### Extended
- If MCP is available, use: `code-search`, `reference-tracking`, `impact-analysis` (and `doc-retrieval` if needed).
- If MCP is unavailable, state the limitation and continue with Base/Advanced.
```

---

## Capability Naming Conventions

- Use lowercase kebab-case for capability names.
- Describe what the capability does, not which server provides it.
- List only what is needed; mark optional capabilities in prose.

---

## Notes

1. Do not add MCP runtime detection steps to SKILL.md.
2. Keep capability lists short and relevant.
3. Base level must be executable without MCP.
