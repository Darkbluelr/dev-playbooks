---
name: devbooks-brownfield-bootstrap
description: "devbooks-brownfield-bootstrap: Brownfield project initialization. When the truth directory is empty, generate project profile, glossary, SSOT, baseline specs, and minimum verification anchors to avoid 'patching specs while changing behavior'. Use when user says 'brownfield init/baseline specs/project profile/establish glossary/initialize SSOT/onboard legacy project to context protocol' etc."
allowed-tools:
  - Glob
  - Grep
  - Read
  - Write
  - Edit
  - Bash
---

# DevBooks: Brownfield Bootstrap

## Responsibility Boundary with ssot-maintainer

| Skill | Responsibility | Analogy |
|-------|----------------|---------|
| **brownfield-bootstrap** | **Create** SSOT/Spec skeleton (from scratch) | `git init` |
| **ssot-maintainer** | **Maintain** SSOT (add/update/remove existing entries) | `git commit` |

**Key Distinction**:
- This Skill is responsible for **initialization**: when `ssot/` directory doesn't exist or is empty, generate skeleton
- `ssot-maintainer` is responsible for **maintenance**: after SSOT exists, handle delta, sync index, refresh ledger
- After initialization is complete, subsequent SSOT changes should use `ssot-maintainer`

## SSOT vs Spec Differences

| Dimension | SSOT | Spec |
|-----------|------|------|
| **Abstraction Level** | Requirements Layer (What) | Design Layer (How) |
| **Granularity** | Project-level | Module-level |
| **Location** | `<devbooks-root>/ssot/` | `<truth-root>/` |
| **Content** | What the system must do | How modules work |

See `docs/SSOT-vs-Spec-Boundary.md` for details.

## Prerequisites: Configuration Discovery (Protocol Agnostic)

- `<truth-root>`: Current truth directory root (usually `dev-playbooks/specs/`)
- `<change-root>`: Change package directory root (usually `dev-playbooks/changes/`)
- `<devbooks-root>`: DevBooks management directory (usually `dev-playbooks/`)

Before execution, **must** search for configuration in the following order (stop when found):
1. `.devbooks/config.yaml` (if exists) → Parse and use its mappings
2. `dev-playbooks/project.md` (if exists) → Dev-Playbooks protocol, use default mappings
3. `project.md` (if exists) → Template protocol, use default mappings
5. If still unable to determine → **Create DevBooks directory structure and initialize basic configuration**

**Key Constraints**:
- If configuration specifies `agents_doc` (rules document), **must read that document first** before executing any operations
- Do not guess directory roots
- Do not skip reading rules document

---

## Core Responsibilities

Brownfield project initialization includes the following responsibilities:

### 1. Basic Configuration File Initialization

Check and create in `<devbooks-root>/` (usually `dev-playbooks/`):

| File | Purpose | Creation Condition |
|------|---------|-------------------|
| `constitution.md` | Project constitution (GIP principles) | When file doesn't exist |
| `project.md` | Project context (tech stack/conventions) | When file doesn't exist |

**Creation Method**:
- **Not simple template copying**, but customized content based on code analysis results
- `constitution.md`: Based on default GIP principles, can be adjusted according to project characteristics
- `project.md`: Filled based on code analysis results:
  - Tech stack (language/framework/database)
  - Development conventions (code style/testing strategy/Git workflow)
  - Domain context (core concepts/role definitions)
  - Directory root mappings

### 2. Project Profile and Metadata

Generate in `<truth-root>/_meta/`:

| Artifact | Path | Description |
|----------|------|-------------|
| Project profile | `_meta/project-profile.md` | Detailed technical profile with three-layer architecture |
| Glossary | `_meta/glossary.md` | Unified language table (optional but recommended) |
| Documentation maintenance metadata | `_meta/docs-maintenance.md` | Documentation style and maintenance configuration |
| Domain concepts | `_meta/key-concepts.md` | Concept extraction based on code semantics (optional) |

### 3. Project SSOT Initialization (Core Responsibility)

Generate SSOT skeleton in `<devbooks-root>/ssot/`:

| Artifact | Path | Description |
|----------|------|-------------|
| SSOT Document | `ssot/SSOT.md` | Human-readable requirements/constraints document |
| Requirements Index | `ssot/requirements.index.yaml` | Machine-readable index (stable ID → anchor → statement) |

**Generation Strategy: Skeleton First + Progressive Completion**

1. **Core Contract Extraction** (AI-led)
   - Scan API definitions (OpenAPI/GraphQL/RPC)
   - Scan data models (Schema/Entity)
   - Scan configuration constraints (env vars/feature flags)
   - Scan key business rules (inferred from code comments/test cases)

2. **Confidence Marking**
   - Each requirement marked with `confidence: low|medium|high`
   - AI-generated defaults to `medium`
   - Upgraded to `high` after human confirmation

3. **Minimum Viable SSOT**
   - Initial target: 5-15 core requirements
   - Don't pursue completeness, pursue addressability
   - Progressive completion via `ssot-maintainer` later

**Upstream SSOT Handling**:
- If project already has upstream SSOT (e.g., separate `SSOT docs/`)
- This Skill does not copy original text, but writes pointers/links in `ssot/SSOT.md`
- And establishes stable ID and anchor index in `requirements.index.yaml`

### 4. Architecture Analysis Artifacts

Generate in `<truth-root>/architecture/`:

| Artifact | Path | Data Source |
|----------|------|-------------|
| **C4 Architecture Map** | `architecture/c4.md` | Comprehensive analysis (optionally with structured capability) |
| Module dependency graph | `architecture/module-graph.md` | Structured dependency analysis (optional) |
| Technical debt hotspots | `architecture/hotspots.md` | Change history + complexity analysis (optional) |
| Layering constraints | `architecture/layering-constraints.md` | Code analysis (optional) |

> **Design Decision**: C4 architecture map is now generated by brownfield-bootstrap during initialization. Subsequent architecture changes are recorded in design.md's Architecture Impact section and merged by archiver during archiving.

### 5. Baseline Change Package (Optional)

Generate in `<change-root>/<baseline-id>/`:

| Artifact | Description |
|----------|-------------|
| `proposal.md` | Baseline scope, In/Out, risks |
| `design.md` | Current state inventory (capability inventory) |
| `specs/<cap>/spec.md` | Baseline spec deltas (mainly ADDED) |
| `verification.md` | Minimum verification anchor plan |

---

## COD Model Generation (Code Overview & Dependencies)

Optionally generate the project's "code map" during initialization, based on available structured code analysis capability:

### Auto-generated Artifacts

| Artifact | Path | Data Source |
|----------|------|-------------|
| **C4 Architecture Map** | `<truth-root>/architecture/c4.md` | Comprehensive analysis |
| Module dependency graph | `<truth-root>/architecture/module-graph.md` | Structured dependency analysis (optional) |
| Technical debt hotspots | `<truth-root>/architecture/hotspots.md` | Change history + complexity analysis (optional) |
| Domain concepts | `<truth-root>/_meta/key-concepts.md` | Code semantic concept extraction (optional) |
| Project profile | `<truth-root>/_meta/project-profile.md` | Comprehensive analysis |

### C4 Architecture Map Generation Rules

C4 map generated during initialization should include:

1. **Context Level**: System's relationship with external actors (users, external systems)
2. **Container Level**: Containers within the system (applications, databases, services)
3. **Component Level**: Components within main containers (modules, classes)

**Output Format**:

```markdown
# C4 Architecture Map

## System Context

[Describe system boundaries and external interactions]

## Container Diagram

| Container | Tech Stack | Responsibility |
|-----------|------------|----------------|
| <name> | <tech> | <responsibility> |

## Component Diagram

### <Container Name>

| Component | Responsibility | Dependencies |
|-----------|----------------|--------------|
| <name> | <responsibility> | <dependencies> |

## Architecture Guardrails

### Layering Constraints

| Layer | Can Depend On | Cannot Depend On |
|-------|---------------|------------------|
| <layer> | <allowed> | <forbidden> |
```

### Hotspot Calculation Formula

```
Hotspot Score = Change Frequency × Cyclomatic Complexity
```

- **High Hotspot** (score > threshold): Frequent changes + high complexity = Bug-dense area
- **Dormant Debt** (high complexity + low frequency): Temporarily safe but needs attention
- **Active Healthy** (high frequency + low complexity): Normal maintenance area

### Boundary Identification

Automatically distinguish:
- **User Code**: `src/`, `lib/`, `app/` etc. (modifiable)
- **Library Code**: `node_modules/`, `vendor/`, `.venv/` etc. (immutable interface)
- **Generated Code**: `dist/`, `build/`, `*.generated.*` etc. (manual modification prohibited)

### Execution Flow

1) **Check available capability**: confirm structured code analysis capability (such as dependency or reference tracking).
2) **Generate COD artifacts**: use available code search, reference tracking, and change history analysis to produce dependency graphs, hotspots, and concepts.
3) **Generate project profile**: integrate the above data with traditional analysis.

## Reference Scaffolds and Templates

- Workflow: `references/brownfield-bootstrap.md`
- Code navigation strategy: `references/code-navigation-strategy.md`
- **Project profile template (three-layer architecture)**: `templates/project-profile-template-project-profile.md`
- One-time prompt: `references/brownfield-bootstrap-prompt.md`
- Template (as needed): `references/glossary-template.md`

---

## Context Awareness

This Skill automatically detects context before execution and selects the appropriate initialization scope.

Detection rules reference: `skills/_shared/context-detection-template-context-detection.md`

### Detection Flow

1. Detect if `<devbooks-root>/constitution.md` exists
2. Detect if `<devbooks-root>/project.md` exists
3. Detect if `<truth-root>/` is empty or basically empty
4. Detect whether structured analysis capability is available
5. Detect project scale and language stack

### Modes Supported by This Skill

| Mode | Trigger Condition | Behavior |
|------|-------------------|----------|
| **Full New Init** | devbooks-root doesn't exist or is empty | Create complete directory structure + constitution + project + profile |
| **Supplement Config** | constitution/project missing | Only supplement missing configuration files |
| **Complete Init** | truth-root is empty | Generate all basic artifacts (profile/baseline/verification) |
| **Incremental Init** | truth-root partially exists | Only supplement missing artifacts |
| **Structured Analysis** | Structured capability available | Use dependency/reference tracking to refine the profile |
| **Text Analysis** | Only text search available | Use traditional analysis methods |

### Detection Output Example

```
Detection Results:
- devbooks-root: Exists
- constitution.md: Doesn't exist → Will create
- project.md: Doesn't exist → Will create
- truth-root: Empty
- Structured capability: Available
- Project scale: Medium (~50K LOC)
- Running mode: Supplement Config + Complete Init + Structured Analysis
```

---


## Progressive Disclosure
### Base (Required)
Goal: Clarify this Skill's core outputs and usage scope.
Inputs: User goals, existing documents, change package context, or project path.
Outputs: Executable artifacts, next-step guidance, or recorded paths.
Boundaries: Does not replace other roles; does not touch `tests/`.
Evidence: Reference output paths or execution records.

### Advanced (Optional)
Use when you need to refine strategy, boundaries, or risk notes.

### Extended (Optional)
Use when you need to coordinate with external systems or optional tools.
