# DevBooks / Dev Playbooks

DevBooks is an "agentic AI programming workflow" for **Claude Code / Codex CLI**: Through **Skills + Context Protocol Adapters**, it transforms large project changes into controllable, traceable, and archivable closed loops (protocol-based context, executable acceptance anchors, role isolation, impact analysis, etc.).

## Core Principles

- **Protocol First**: Document "current truth / change packages / archives" in the project (not just in chat).
- **Anchor First**: Completion is defined by `tests/`, static analysis, builds, and evidence (not AI self-assessment).
- **Role Isolation**: Test Owner and Coder must work in separate conversations/instances; Coder cannot modify `tests/**`.
- **Structure Gating**: When encountering "proxy metric-driven" requirements, stop and evaluate, prioritizing complexity/coupling/dependency direction/test quality.
- **Truth Source Separation**: `<truth-root>` is the single source of truth (read-only reference), `<change-root>/<change-id>/` is the temporary workspace (free to experiment); Archive = merge derived data back to truth source.

---

## Quick Start

### 1. Install DevBooks CLI (npm) (recommended)

Global install:

```bash
npm install -g devbooks
```

One-off (no global install):

```bash
npx devbooks@latest init
```

### 2. Initialize in Your Project

If you used the one-off npx command above, you can skip this step.

Run in your project root:

```bash
devbooks init
```

If you need to update an existing setup later:

```bash
devbooks update
```

Installation locations (after `devbooks init` or the install script):
- Claude Code: `~/.claude/skills/devbooks-*`
- Codex CLI: `$CODEX_HOME/skills/devbooks-*` (default `~/.codex/skills/devbooks-*`)
- Codex Prompts: `$CODEX_HOME/prompts/devbooks-*.md` (optional)

### 3. Install from Source (Contributors or Local Testing)

Run in this repository's root directory:

```bash
./scripts/install-skills.sh
```

If you primarily use Codex CLI and want to install command entry points (prompts):

```bash
./scripts/install-skills.sh --with-codex-prompts
```

### 4. Integrate with Your Project

DevBooks Skills depend on two directory root definitions:
- `<truth-root>`: Current truth directory root (default `dev-playbooks/specs/`)
- `<change-root>`: Change package directory root (default `dev-playbooks/changes/`)

**Quick Integration**:
- Entry point: `setup/generic/DevBooks-Integration-Template.md`
- Let AI auto-wire: `setup/generic/Installation-Prompt.md`

---

## Daily Change Workflow

### Dual Entry Architecture (v2)

DevBooks provides two command entry points:

1. **Router Entry** (Recommended): Input requirements, get complete execution plan
2. **Direct Commands**: Call corresponding Skill directly when familiar with the flow

### Using Router (Recommended for Beginners)

```
/devbooks:router <your requirement>
```

Router analyzes requirements and outputs an execution plan, telling you which command to use next.

### Direct Commands (21 Commands Mapping 1:1 to 21 Skills)

| Phase | Command | Description |
|-------|---------|-------------|
| **Proposal** | `/devbooks:proposal` | Create change proposal |
| | `/devbooks:impact` | Impact analysis |
| | `/devbooks:challenger` | Challenge proposal |
| | `/devbooks:judge` | Judge proposal |
| | `/devbooks:debate` | Triangle debate workflow |
| | `/devbooks:design` | Design document |
| | `/devbooks:spec` | Specs and contracts |
| | `/devbooks:c4` | C4 architecture map |
| | `/devbooks:plan` | Implementation plan |
| **Apply** | `/devbooks:test` | Test Owner (separate conversation) |
| | `/devbooks:code` | Coder (separate conversation) |
| | `/devbooks:backport` | Design backport |
| **Review** | `/devbooks:review` | Code review |
| | `/devbooks:test-review` | Test review |
| **Archive** | `/devbooks:gardener` | Spec gardener |
| | `/devbooks:delivery` | Delivery workflow |
| **Independent** | `/devbooks:entropy` | Entropy metrics |
| | `/devbooks:federation` | Cross-repo federation analysis |
| | `/devbooks:bootstrap` | Legacy project initialization |
| | `/devbooks:index` | Index bootstrap |

### Typical Workflow Example

**1. Proposal (Proposal Phase, No Code Writing)**

```
/devbooks:proposal <your requirement>
```

Artifacts: `proposal.md` (required), `design.md` (required for non-trivial changes), `tasks.md` (required)

**2. Apply (Implementation Phase, Mandatory Role Isolation)**

Must open 2 separate conversations/instances:
```
/devbooks:test <change-id>   # Test Owner
/devbooks:code <change-id>   # Coder
```

- Test Owner: Write `verification.md` + tests, run to **Red** first
- Coder: Implement per `tasks.md`, make gates **Green** (cannot modify tests)

**3. Review (Review Phase)**

```
/devbooks:review <change-id>
```

**4. Archive (Archive Phase)**

```
/devbooks:gardener <change-id>
```

---

## Skills Index

### Role-Based
- `devbooks-router`: Route to appropriate Skill
- `devbooks-proposal-author` / `devbooks-proposal-challenger` / `devbooks-proposal-judge`
- `devbooks-impact-analysis` / `devbooks-design-doc` / `devbooks-spec-contract` / `devbooks-implementation-plan`
- `devbooks-test-owner` / `devbooks-coder` / `devbooks-code-review` / `devbooks-test-reviewer` / `devbooks-spec-gardener`
- `devbooks-c4-map` / `devbooks-design-backport`

### Workflow-Based
- `devbooks-proposal-debate-workflow` / `devbooks-delivery-workflow`
- `devbooks-brownfield-bootstrap`: Legacy project initialization
- `devbooks-index-bootstrap`: Generate SCIP index (requires CKB MCP)
- `devbooks-federation`: Cross-repo federation analysis

### Metrics-Based
- `devbooks-entropy-monitor`: System entropy metrics collection and reporting

---

## Repository Structure

```
skills/          # devbooks-* Skills source code
setup/           # Context protocol adapters and integration templates
└── generic/     # Protocol-agnostic templates
scripts/         # Installation and helper scripts
docs/            # Supporting documentation
tools/           # Helper scripts (complexity calculation, entropy metrics, etc.)
```

---

## Documentation Index

### MCP Auto-Detection and Fallback

DevBooks Skills support MCP (Model Context Protocol) auto-detection and fallback:

| MCP Status | Behavior |
|------------|----------|
| CKB Available | Enhanced mode: Use graph-based tools like `analyzeImpact`, `getCallGraph`, `getHotspots` |
| CKB Unavailable or Timeout (2s) | Basic mode: Use Grep + Glob text search (full functionality, only loses some enhanced capabilities) |

**Detection Mechanism**:
- Each Skill automatically calls `mcp__ckb__getStatus()` on execution
- After 2-second timeout: `[MCP detection timeout, degraded to basic mode]`
- No need to manually choose "basic prompt" or "enhanced prompt"

**Updating Slash Commands**:

After updating MCP configuration (e.g., adding/removing CKB Server), MCP detection happens automatically at runtime, no manual slash command updates needed.

If you need to reinstall Skills (e.g., updating DevBooks version):

```bash
./scripts/install-skills.sh
```

### Supporting Documentation

- Slash Commands Guide: `docs/slash-commands-guide.md`
- Skills Quick Reference: `skills/Skills-Usage-Guide.md`
- MCP Configuration: `docs/Recommended-MCP.md`

---

## Optional: Scripted Common Steps

DevBooks deterministic scripts are located in the installed Skill's `scripts/` directory:

```bash
# Codex
DEVBOOKS_SCRIPTS="${CODEX_HOME:-$HOME/.codex}/skills/devbooks-delivery-workflow/scripts"

# Claude
DEVBOOKS_SCRIPTS="$HOME/.claude/skills/devbooks-delivery-workflow/scripts"
```

Common commands:
- Generate change package scaffold: `"$DEVBOOKS_SCRIPTS/change-scaffold.sh" <change-id> ...`
- One-click validation: `"$DEVBOOKS_SCRIPTS/change-check.sh" <change-id> --mode strict ...`
- Evidence capture: `"$DEVBOOKS_SCRIPTS/change-evidence.sh" <change-id> ...`

---

## Quality Gates (v2)

DevBooks provides quality gate mechanisms to catch "false completions" and ensure real quality of change packages:

| Gate | Trigger Mode | Check Content |
|------|--------------|---------------|
| Green Evidence Check | archive, strict | `evidence/green-final/` exists and is non-empty |
| Task Completion Check | strict | All tasks in tasks.md complete or have SKIP-APPROVED |
| Test Failure Interception | archive, strict | No failure patterns in Green evidence |
| P0 Skip Approval | strict | P0 task skips must have approval record |
| Role Boundary Check | apply --role | Coder cannot modify tests/, Test Owner cannot modify src/ |

**Core Scripts**:
- `change-check.sh`: One-click validation (supports `--mode proposal|apply|archive|strict`)
- `handoff-check.sh`: Role handoff handshake check
- `env-match-check.sh`: Test environment declaration check
- `audit-scope.sh`: Full audit scan
- `progress-dashboard.sh`: Progress dashboard

See details: `docs/quality-gates-guide.md`

---

## Optional: Prototype Mode

When technical approach is uncertain and quick validation is needed:

1. Create prototype: `change-scaffold.sh <change-id> --prototype ...`
2. Test Owner uses `--prototype`: Produce characterization tests (no Red baseline needed)
3. Coder uses `--prototype`: Output to `prototype/src/` (cannot land in repo src/)
4. Promote or discard: `prototype-promote.sh <change-id> ...`

---

## Legacy Project Initialization

When `<truth-root>` is empty, use `devbooks-brownfield-bootstrap`:
- One-time output of project profile, glossary (optional), baseline specs and minimal verification anchors
- Auto-generate module dependency graph, tech debt hotspots, domain concepts, and other "code map" artifacts

---

## Tool Scripts

| Tool | Purpose |
|------|---------|
| `tools/devbooks-complexity.sh` | Cyclomatic complexity calculation |
| `tools/devbooks-entropy-viz.sh` | Entropy metrics visualization |

Configuration: `.devbooks/config.yaml`
