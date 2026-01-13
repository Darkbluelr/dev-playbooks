# DevBooks

**Agentic AI Development Workflow for Claude Code / Codex CLI**

> Transform large changes into controllable, traceable, and verifiable closed loops: Skills + Quality Gates + Role Isolation.

[![npm](https://img.shields.io/npm/v/dev-playbooks)](https://www.npmjs.com/package/dev-playbooks)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Why DevBooks?

AI coding assistants are powerful, but often **unpredictable**:

| Pain Point | Consequence |
|------------|-------------|
| **AI self-declares "done"** | Tests actually fail, edge cases missed |
| **Same conversation writes tests and code** | Tests become "pass-through tests", not spec verification |
| **No verification gates** | False completions silently enter production |
| **Only supports 0→1 projects** | No way to onboard legacy codebases |
| **Too few commands** | Complex changes need more than "spec/apply/archive" |

**DevBooks Solutions**:
- **Evidence-based completion**: Completion defined by tests/builds/evidence, not AI self-assessment
- **Mandatory role isolation**: Test Owner and Coder must work in separate conversations
- **Multiple quality gates**: Green evidence checks, task completion rate, role boundary checks
- **21 Skills**: Covering proposals, design, debate, review, entropy metrics, federation analysis, and more

---

## DevBooks Comparison

| Dimension | DevBooks | OpenSpec | spec-kit | No Spec |
|-----------|----------|----------|----------|---------|
| **Spec-driven** | Yes | Yes | Yes | No |
| **Legacy project support** | Auto-generate baseline | Manual | Limited | - |
| **Completion definition** | Test+build evidence | AI self-assessment | AI self-assessment | AI self-assessment |
| **Code quality assurance** | Entropy metrics+gates | None | None | None |
| **Test/implementation separation** | Mandatory isolation | None | None | None |
| **Change traceability** | Change package archive | Feature folders | Spec files | None |
| **Workflow complexity** | High (21 Skills) | Low (3 commands) | Medium (~5 commands) | None |
| **Learning curve** | Steep | Gentle | Medium | None |
| **Best for** | Large/critical changes | Lightweight changes | 0→1 projects | Simple tasks |

---

## How It Works

```
                           DevBooks Workflow

    PROPOSAL Phase              APPLY Phase                    ARCHIVE Phase
    (No coding)                 (Role isolation enforced)      (Quality gates)

    ┌─────────────────┐         ┌─────────────────┐            ┌─────────────────┐
    │  /devbooks:     │         │   Session A     │            │  /devbooks:     │
    │   proposal      │         │  ┌───────────┐  │            │   gardener      │
    │   impact        │─────────│  │Test Owner │  │────────────│   delivery      │
    │   design        │         │  │(Run Red   │  │            │                 │
    │   spec          │         │  │ first)    │  │            │  Quality Gates: │
    │   plan          │         │  └───────────┘  │            │  ✓ Green evidence│
    └─────────────────┘         │                 │            │  ✓ Task complete │
           │                    │   Session B     │            │  ✓ Role boundary │
           ▼                    │  ┌───────────┐  │            │  ✓ No failures   │
    ┌─────────────────┐         │  │  Coder    │  │            └─────────────────┘
    │ Triangle Debate │         │  │(Cannot    │  │
    │ Author/Challenger│         │  │edit tests)│  │
    │ /Judge          │         │  └───────────┘  │
    └─────────────────┘         └─────────────────┘
```

**Core Constraint**: Test Owner and Coder **must work in separate conversations**. This is a hard constraint, not a suggestion. Coder cannot modify `tests/**`; completion is verified by tests/builds, not AI self-assessment.

---

## Quick Start

### Supported AI Tools

| Tool | Slash Commands | Natural Language |
|------|----------------|------------------|
| **Claude Code** | `/devbooks:*` | Supported |
| **Codex CLI** | `/devbooks:*` | Supported |
| Other AI assistants | - | "Run DevBooks proposal skill..." |

### Installation

**npm install (recommended):**

```bash
# Global install
npm install -g dev-playbooks

# Initialize in your project
dev-playbooks init
```

**One-off usage:**

```bash
npx dev-playbooks@latest init
```

**Install from source (contributors):**

```bash
./scripts/install-skills.sh
```

### Installation Locations

After initialization:
- Claude Code: `~/.claude/skills/devbooks-*`
- Codex CLI: `$CODEX_HOME/skills/devbooks-*` (default `~/.codex/skills/devbooks-*`)

### Quick Integration

DevBooks uses two directory roots:

| Directory | Purpose | Default |
|-----------|---------|---------|
| `<truth-root>` | Current specs (read-only truth) | `dev-playbooks/specs/` |
| `<change-root>` | Change packages (workspace) | `dev-playbooks/changes/` |

See `docs/devbooks-integration-template.md` or use `docs/installation-prompt.md` to let AI auto-configure.

---

## Daily Change Workflow

### Using Router (Recommended)

```
/devbooks:router <your requirement>
```

Router analyzes requirements and outputs an execution plan, telling you which command to use next.

### Direct Commands

Once familiar with the flow, call Skills directly:

**1. Proposal Phase (No coding)**

```
/devbooks:proposal Add OAuth2 user authentication
```

Artifacts: `proposal.md` (required), `design.md`, `tasks.md`

**2. Apply Phase (Mandatory role isolation)**

Must open **2 separate conversations**:

```
# Session A - Test Owner
/devbooks:test add-oauth2

# Session B - Coder
/devbooks:code add-oauth2
```

- Test Owner: Write `verification.md` + tests, run **Red** first
- Coder: Implement per `tasks.md`, make gates **Green** (cannot modify tests)

**3. Review Phase**

```
/devbooks:review add-oauth2
```

**4. Archive Phase**

```
/devbooks:gardener add-oauth2
```

---

## Command Reference

### Proposal Phase

| Command | Skill | Description |
|---------|-------|-------------|
| `/devbooks:router` | devbooks-router | Smart routing to appropriate Skill |
| `/devbooks:proposal` | devbooks-proposal-author | Create change proposal |
| `/devbooks:impact` | devbooks-impact-analysis | Cross-module impact analysis |
| `/devbooks:challenger` | devbooks-proposal-challenger | Challenge and critique proposal |
| `/devbooks:judge` | devbooks-proposal-judge | Judge proposal |
| `/devbooks:debate` | devbooks-proposal-debate-workflow | Triangle debate (Author/Challenger/Judge) |
| `/devbooks:design` | devbooks-design-doc | Create design document |
| `/devbooks:spec` | devbooks-spec-contract | Define specs and contracts |
| `/devbooks:c4` | devbooks-c4-map | Generate C4 architecture map |
| `/devbooks:plan` | devbooks-implementation-plan | Create implementation plan |

### Apply Phase

| Command | Skill | Description |
|---------|-------|-------------|
| `/devbooks:test` | devbooks-test-owner | Test Owner role (separate conversation required) |
| `/devbooks:code` | devbooks-coder | Coder role (separate conversation required) |
| `/devbooks:backport` | devbooks-design-backport | Backport findings to design document |

### Review Phase

| Command | Skill | Description |
|---------|-------|-------------|
| `/devbooks:review` | devbooks-code-review | Code review (readability/consistency) |
| `/devbooks:test-review` | devbooks-test-reviewer | Test quality and coverage review |

### Archive Phase

| Command | Skill | Description |
|---------|-------|-------------|
| `/devbooks:gardener` | devbooks-spec-gardener | Spec maintenance and deduplication |
| `/devbooks:delivery` | devbooks-delivery-workflow | Complete delivery closed loop |

### Standalone Skills

| Command | Skill | Description |
|---------|-------|-------------|
| `/devbooks:entropy` | devbooks-entropy-monitor | System entropy metrics |
| `/devbooks:federation` | devbooks-federation | Cross-repo federation analysis |
| `/devbooks:bootstrap` | devbooks-brownfield-bootstrap | Legacy project initialization |
| `/devbooks:index` | devbooks-index-bootstrap | Generate SCIP index |

---

## Advanced Features

<details>
<summary><strong>Detailed Comparison with Other Tools</strong></summary>

### vs. OpenSpec

[OpenSpec](https://github.com/Fission-AI/OpenSpec) is a lightweight spec-driven framework using three core commands (proposal/apply/archive) to align humans and AI, organizing changes by feature folders.

**DevBooks adds:**
- **Role isolation**: Hard boundary between Test Owner and Coder (separate conversations required)
- **Quality gates**: 5+ verification gates to catch false completions
- **21 Skills**: Covering proposals, debate, review, entropy metrics, federation analysis
- **Evidence-based completion**: Tests/builds define "done", not AI self-assessment

**Choose OpenSpec**: Simple spec-driven changes, need lightweight workflow.

**Choose DevBooks**: Large changes, need role separation and quality verification.

### vs. spec-kit

[GitHub spec-kit](https://github.com/github/spec-kit) provides a spec-driven development toolkit with constitution files, multi-step refinement, and structured planning.

**DevBooks adds:**
- **Legacy-first**: Auto-generate baseline specs for existing codebases
- **Role isolation**: Mandatory separation of test writing and implementation
- **Quality gates**: Runtime verification, not just workflow guidance
- **Prototype mode**: Safe experimentation without polluting main src/

**Choose spec-kit**: 0→1 greenfield projects, using supported AI tools.

**Choose DevBooks**: Legacy projects or need mandatory quality gates.

### vs. Kiro.dev

[Kiro](https://kiro.dev/) is AWS's agentic IDE using a three-phase workflow (EARS format requirements, design, tasks), but stores specs and implementation artifacts separately.

**DevBooks differences:**
- **Change packages**: Each change contains proposal/design/spec/plan/verification/evidence, entire lifecycle traceable in one location
- **Role isolation**: Mandatory separation of Test Owner and Coder
- **Quality gates**: Verification through gates, not just task completion

**Choose Kiro**: Want integrated IDE experience and AWS ecosystem.

**Choose DevBooks**: Want change packages bundling all artifacts with mandatory role boundaries.

### vs. No Spec

Without specs, AI generates code from vague prompts, leading to unpredictable outputs, scope creep, and "hallucinated completions".

**DevBooks provides:**
- Agreed specs before implementation
- Quality gates to verify real completion
- Role isolation to prevent self-validation
- Evidence chain for every change

</details>

<details>
<summary><strong>Quality Gates</strong></summary>

DevBooks provides quality gates to catch "false completions":

| Gate | Trigger Mode | Check Content |
|------|--------------|---------------|
| Green Evidence Check | archive, strict | `evidence/green-final/` exists and non-empty |
| Task Completion Check | strict | All tasks in tasks.md complete or SKIP-APPROVED |
| Test Failure Interception | archive, strict | No failure patterns in Green evidence |
| P0 Skip Approval | strict | P0 task skips must have approval record |
| Role Boundary Check | apply --role | Coder cannot modify tests/, Test Owner cannot modify src/ |

**Core Scripts:**
- `change-check.sh --mode proposal|apply|archive|strict`
- `handoff-check.sh` - Role handoff verification
- `audit-scope.sh` - Full audit scan
- `progress-dashboard.sh` - Progress visualization

</details>

<details>
<summary><strong>Prototype Mode</strong></summary>

When technical approach is uncertain:

1. Create prototype: `change-scaffold.sh <change-id> --prototype`
2. Test Owner uses `--prototype`: Characterization tests (no Red baseline needed)
3. Coder uses `--prototype`: Output to `prototype/src/` (isolated from main src)
4. Promote or discard: `prototype-promote.sh <change-id>`

Prototype mode prevents experimental code from polluting main source tree.

</details>

<details>
<summary><strong>Entropy Metrics Monitoring</strong></summary>

DevBooks tracks four-dimensional system entropy:

| Metric | What It Measures |
|--------|------------------|
| Structural Entropy | Module complexity and coupling |
| Change Entropy | Churn and volatility patterns |
| Test Entropy | Test coverage and quality decay |
| Dependency Entropy | External dependency health |

Use `/devbooks:entropy` to generate reports and identify refactoring opportunities.

Tools: `tools/devbooks-complexity.sh`, `tools/devbooks-entropy-viz.sh`

</details>

<details>
<summary><strong>Legacy Project Initialization</strong></summary>

When `<truth-root>` is empty:

```
/devbooks:bootstrap
```

Generates:
- Project profile and glossary
- Baseline specs from existing code
- Minimal verification anchors
- Module dependency graph
- Tech debt hotspots

</details>

<details>
<summary><strong>Cross-Repository Federation</strong></summary>

Multi-repository analysis:

```
/devbooks:federation
```

Analyzes contracts and dependencies across repository boundaries, supporting coordinated changes.

</details>

<details>
<summary><strong>MCP Code Intelligence Enhancement</strong></summary>

DevBooks connects to CKB (Code Knowledge Base) service via MCP (Model Context Protocol), providing AI with **semantic-level code understanding**, not just text search.

**CKB Capabilities:**

| Capability | Description | Typical Scenario |
|------------|-------------|------------------|
| **Impact Analysis** | Analyze propagation range and risk of symbol changes | Assess downstream impact before modifying interfaces |
| **Call Graph** | Trace function call chains and dependencies | Understand code execution paths |
| **Hotspot Discovery** | Identify high-churn, high-coupling code areas | Prioritize refactoring |
| **Symbol References** | Precisely find all usage locations of symbols | Confirm impact scope before renaming |

**Graceful Degradation:**

| Environment | Behavior |
|-------------|----------|
| CKB Available | Semantic analysis mode: Use graph-based tools for precise analysis |
| CKB Unavailable | Text search mode: Fall back to Grep + Glob (full functionality, reduced precision) |

Auto-detection with 2-second timeout. No manual configuration needed. Recommend configuring CKB for best code understanding.

</details>

<details>
<summary><strong>Proposal Debate Workflow</strong></summary>

Rigorous proposal review using triangle debate:

```
/devbooks:debate
```

Three roles:
1. **Author**: Create and defend proposal
2. **Challenger**: Question assumptions, find gaps, identify risks
3. **Judge**: Make final decision, record rationale

Decision outcomes: `Approved`, `Revise`, `Rejected`

</details>

---

## Repository Structure

```
skills/          # 21 devbooks-* Skills source code
templates/       # Project initialization templates
scripts/         # Installation and helper scripts
tools/           # Complexity and entropy metrics tools
docs/            # Supporting documentation
bin/             # CLI entry point
```

---

## Documentation

- [Slash Commands Guide](docs/slash-commands-guide.md)
- [Skills Usage Guide](skills/Skills-Usage-Guide.md)
- [MCP Configuration](docs/Recommended-MCP.md)
- [Integration Template](docs/devbooks-integration-template.md)
- [Installation Prompt](docs/installation-prompt.md)

---

## Design Principles

| Principle | Description |
|-----------|-------------|
| **Protocol First** | Truth/changes/archives written to project, not just in chat |
| **Anchor First** | Completion defined by tests, static analysis, builds, and evidence |
| **Role Isolation** | Test Owner and Coder must work in separate conversations |
| **Truth Source Separation** | `<truth-root>` is read-only truth; `<change-root>` is temporary workspace |
| **Structure Gating** | Prioritize complexity/coupling/test quality over proxy metrics |

---

## License

MIT
