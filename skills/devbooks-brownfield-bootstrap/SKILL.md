---
name: devbooks-brownfield-bootstrap
description: "devbooks-brownfield-bootstrap: Legacy Project Initialization - Generates project profile, glossary, baseline specs, and minimal verification anchors when the truth directory is empty, preventing 'patching specs while changing behavior'. Use when the user mentions 'brownfield init/baseline specs/project profile/create glossary/onboard legacy project to context protocol'."
tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
  - mcp__ckb__getStatus
  - mcp__ckb__getArchitecture
  - mcp__ckb__getHotspots
  - mcp__ckb__listKeyConcepts
  - mcp__ckb__getModuleOverview
---

# DevBooks: Brownfield Bootstrap (Legacy Project Initialization)

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root
- `<change-root>`: Change package directory root

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) -> Parse and use the mappings within
2. `dev-playbooks/project.md` (if exists) -> DevBooks 2.0 protocol, use default mappings
4. `project.md` (if exists) -> Template protocol, use default mappings
5. If still unable to determine -> **Stop and ask user**

**Key Constraints**:
- If configuration specifies `agents_doc` (rules document), **must read that document first** before executing any operations
- No guessing directory roots
- No skipping rules document reading

## COD Model Generation (Code Overview & Dependencies)

Automatically generates the project's "code map" during initialization (requires CKB MCP Server availability, otherwise skip):

### Auto-Generated Artifacts

| Artifact | Path | Data Source |
|----------|------|-------------|
| Module Dependency Graph | `<truth-root>/architecture/module-graph.md` | `mcp__ckb__getArchitecture` |
| Technical Debt Hotspots | `<truth-root>/architecture/hotspots.md` | `mcp__ckb__getHotspots` |
| Domain Concepts | `<truth-root>/_meta/key-concepts.md` | `mcp__ckb__listKeyConcepts` |
| Project Profile | `<truth-root>/_meta/project-profile.md` | Comprehensive Analysis |

### Hotspot Calculation Formula

```
Hotspot Score = Change Frequency × Cyclomatic Complexity
```

- **High Hotspot** (score > threshold): Frequent changes + high complexity = Bug-dense area
- **Dormant Debt** (high complexity + low frequency): Temporarily safe but needs attention
- **Active Healthy** (high frequency + low complexity): Normal maintenance area

### Boundary Identification

Automatic distinction between:
- **User Code**: `src/`, `lib/`, `app/`, etc. (modifiable)
- **Library Code**: `node_modules/`, `vendor/`, `.venv/`, etc. (immutable interfaces)
- **Generated Code**: `dist/`, `build/`, `*.generated.*`, etc. (manual modification prohibited)

### Execution Flow

1) **Check Graph Index**: Call `mcp__ckb__getStatus`
   - If SCIP available -> Use graph-based analysis
   - If unavailable -> Prompt to generate index or use Git history analysis

2) **Generate COD Artifacts**:
   ```bash
   # Get module architecture
   mcp__ckb__getArchitecture(depth=2, includeExternalDeps=false)

   # Get hotspots (last 30 days)
   mcp__ckb__getHotspots(limit=20)

   # Get domain concepts
   mcp__ckb__listKeyConcepts(limit=12)
   ```

3) **Generate Project Profile**: Integrate above data + traditional analysis

## Reference Skeleton and Templates

- Workflow: `references/brownfield-bootstrap.md`
- Code Navigation Strategy: `references/code-navigation-strategy.md`
- **Project Profile Template (Three-Layer Architecture)**: `templates/project-profile-template.md`
- One-time Prompt: `references/brownfield-bootstrap-prompt.md`
- Template (as needed): `references/10-glossary-template.md`

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate initialization scope.

Detection rules reference: `skills/_shared/context-detection-template.md`

### Detection Flow

1. Detect if `<truth-root>/` is empty or essentially empty
2. Detect if CKB index is available
3. Detect project scale and language stack

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Full Initialization** | truth-root is empty | Generate all base artifacts |
| **Incremental Initialization** | truth-root partially exists | Only supplement missing artifacts |
| **Enhanced Mode** | CKB index available | Use graph analysis for more precise profiling |
| **Basic Mode** | CKB index unavailable | Use traditional analysis methods |

### Detection Output Example

```
Detection Results:
- truth-root: Empty
- CKB Index: Available
- Project Scale: Medium (~50K LOC)
- Running Mode: Full Initialization + Enhanced Mode
```

---

## MCP Enhancement

This Skill supports MCP runtime enhancement, automatically detecting and enabling advanced features.

MCP enhancement rules reference: `skills/_shared/mcp-enhancement-template.md`

### Dependent MCP Services

| Service | Purpose | Timeout |
|---------|---------|---------|
| `mcp__ckb__getStatus` | Detect CKB index availability | 2s |
| `mcp__ckb__getArchitecture` | Get module dependency graph | 2s |
| `mcp__ckb__getHotspots` | Get technical debt hotspots | 2s |
| `mcp__ckb__listKeyConcepts` | Get domain concepts | 2s |
| `mcp__ckb__getModuleOverview` | Get module overview | 2s |

### Detection Flow

1. Call `mcp__ckb__getStatus` (2s timeout)
2. If CKB available -> Use graph-based analysis to generate COD artifacts
3. If timeout or failure -> Degrade to traditional analysis (Git history + file statistics)

### Enhanced Mode vs Basic Mode

| Feature | Enhanced Mode | Basic Mode |
|---------|---------------|------------|
| Module Dependency Graph | CKB getArchitecture | Directory structure inference |
| Technical Debt Hotspots | CKB getHotspots | Git log statistics |
| Domain Concepts | CKB listKeyConcepts | Naming analysis |
| Boundary Identification | Precise module boundaries | Directory conventions |

### Degradation Notice

When MCP is unavailable, output the following notice:

```
Warning: CKB unavailable, using traditional analysis methods to generate project profile.
For more precise architecture analysis, please run /devbooks:index to generate the index.
```

