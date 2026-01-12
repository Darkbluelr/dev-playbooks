---
name: devbooks-c4-map
description: devbooks-c4-map: Maintain/update the project's C4 architecture map (current truth) and output C4 Delta based on changes. Use when user says "draw architecture diagram/C4/boundaries/dependency direction/module map/architecture map maintenance" etc.
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
---

# DevBooks: C4 Architecture Map

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) → DevBooks 2.0 protocol, use default mappings
4. `project.md` (if exists) → template protocol, use default mappings
5. If still unable to determine → **Stop and ask the user**

**Key Constraints**:
- If `agents_doc` (rules document) is specified in the configuration, **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading the rules document

## Artifact Locations

- Authoritative C4 map: `<truth-root>/architecture/c4.md`
- Layering constraints definition: `<truth-root>/architecture/layering-constraints.md` (optional)

## Layering Dependency Constraints

Drawing from VS Code's layering architecture enforcement mechanism, the C4 map should include a **Layering Constraints** section:

### Layering Constraint Definition Rules

1. **Unidirectional Dependency Principle**: Upper layers may depend on lower layers; lower layers are prohibited from depending on upper layers
   - Example: `base ← platform ← domain ← application ← ui`
   - Arrow direction indicates "dependency direction"

2. **Environment Isolation Principle**: The `common` layer can only be referenced by `browser`/`node` layers, not the reverse
   - `common`: Platform-agnostic code
   - `browser`: Browser-specific code (DOM API)
   - `node`: Node.js-specific code (fs, process)

3. **Contrib Reverse Isolation**: Contribution modules can only depend on core; core is prohibited from depending on contribution modules
   - Example: `workbench/contrib/*` → `workbench/core` (allowed)
   - Example: `workbench/core` → `workbench/contrib/*` (prohibited)

### Layering Constraints Output Format

The `## Architecture Guardrails` section in `c4.md` must include:

```markdown
### Layering Constraints

| Layer | May Depend On | Prohibited Dependencies |
|-------|---------------|------------------------|
| base | (none) | platform, domain, application, ui |
| platform | base | domain, application, ui |
| domain | base, platform | application, ui |
| application | base, platform, domain | ui |
| ui | base, platform, domain, application | (none) |

### Environment Constraints

| Environment | May Reference | Prohibited References |
|-------------|---------------|----------------------|
| common | (platform-agnostic libraries) | browser/*, node/* |
| browser | common/* | node/* |
| node | common/* | browser/* |
```

## Execution Method

1) First read and follow: `_shared/references/通用守门协议.md` (verifiability + structural quality gating).
2) Strictly follow the complete prompt output: `references/C4架构地图提示词.md`.
3) Reference the layering constraints checklist: `references/分层约束检查清单.md`.

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate running mode.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect whether `<truth-root>/architecture/c4.md` exists
2. If change-id is provided, detect whether there are C4-related changes
3. Select running mode based on detection results

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Create Mode** | `c4.md` does not exist | Analyze codebase, generate complete C4 diagrams at all levels (Context/Container/Component) |
| **Update Mode** | `c4.md` exists, changes need to be reflected | Read change content, output C4 Delta, update architecture diagram |

### Detection Output Example

```
Detection Results:
- Artifact existence: c4.md exists
- Change impact: Component-level changes detected (added templates/claude-commands/devbooks/ 15 files)
- Running mode: Update mode
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Required MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getArchitecture` | Get module dependency graph | 2s |
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available → Call `mcp__ckb__getArchitecture` to get precise module dependencies
3. If timeout or failure → Fall back to directory structure-based inference

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Module identification | CKB precise boundaries | Directory structure inference |
| Dependency direction | Symbol-level analysis | Import statement matching |
| Cycle detection | Precise detection | Heuristic detection |

### Fallback Notice

When MCP is unavailable, output the following notice:

```
Warning: CKB unavailable, using directory structure to infer architecture.
Generated C4 diagrams may not be precise. Recommend running /devbooks:index to generate index.
```

