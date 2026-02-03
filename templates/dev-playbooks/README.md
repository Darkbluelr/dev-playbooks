# DevBooks

**An agentic AI development workflow for Claude Code / Codex CLI**

> Turn large changes into a controlled, traceable, verifiable loop: Skills + quality gates + role isolation.

[![npm](https://img.shields.io/npm/v/dev-playbooks)](https://www.npmjs.com/package/dev-playbooks)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

![DevBooks Workflow](docs/workflow-diagram.svg)

---

## Why DevBooks?

AI coding assistants are powerful, but often **unpredictable**:

| Pain point | Outcome |
|------|------|
| **AI self-declares "done"** | Tests fail, edge cases are missed |
| **Writing tests and code in the same chat** | Tests turn into “pass tests” instead of spec verification |
| **No verification gates** | False completion silently ships |
| **Only works for greenfield (0→1)** | Brownfield repos have no on-ramp |
| **Too few commands** | Complex changes need more phases, roles, and verification anchors |

**DevBooks provides**:
- **Evidence-based done**: completion is defined by tests/build/evidence, not AI self-evaluation
- **Enforced role isolation**: Test Owner and Coder must work in separate conversations
- **Multiple quality gates**: green evidence checks, task completion, role boundary checks
- **21 Skills**: proposal, design, debate, review, entropy metrics, and full workflow coverage

---

## DevBooks comparison overview

| Dimension | DevBooks | Lightweight 3-command spec workflow | Toolkit-style spec process | no spec |
|------|----------|----------|----------|--------|
| Spec-driven workflow | Yes | Yes | Yes | No |
| Traceability of change artifacts | Change package archived in one place (proposal/design/spec/tasks/verification/evidence) | Organized mostly by folders/files | Document + planning oriented | None |
| Role & responsibility boundaries | **Enforced isolation** (Test Owner / Coder) | Convention-based (not enforced) | Convention-based (not enforced) | None |
| Definition of done (DoD) | **Evidence-driven + gates** (tests/build/audit) | Manual definition/manual checks | Manual definition/manual checks | Often subjective |
| Code quality assurance | Gates + metrics (entropy/hotspots) + Reviewer role | External tooling + manual review | External tooling + manual review | Unstable |
| Impact analysis | CKB graph capabilities (graceful fallback to grep) | Text search/manual reasoning | Text search/manual reasoning | Easy to miss changes |
| Brownfield on-ramp | Auto baseline specs/glossary/min verification anchors | Manual | Limited | - |
| Automation coverage | 21 Skills (proposal → implement → archive) | 3 core commands | Toolkit (more 0→1) | - |

## How It Works

**Hard constraint**: Test Owner and Coder **must work in separate conversations**. This is not a suggestion. Coder cannot modify `tests/**`. "Done" is defined by tests/build verification, not AI self-evaluation.

---

## Quick Start

### Supported AI tools

| Tool | Support Level | Config File |
|------|---------------|-------------|
| **Claude Code** | Full Skills | `CLAUDE.md` |
| **Codex CLI** | Full Skills | `AGENTS.md` |
| **Qoder** | Full Skills | `AGENTS.md` |
| **OpenCode (oh-my-opencode)** | Full Skills | `AGENTS.md` |
| **Cursor** | Rules | `.cursor/rules/` |
| **Windsurf** | Rules | `.windsurf/rules/` |
| **Gemini CLI** | Rules | `GEMINI.md` |
| **Continue** | Rules | `.continue/rules/` |
| **GitHub Copilot** | Instructions | `.github/copilot-instructions.md` |

> **Tip**: Use natural language to invoke skills, e.g., "Run devbooks-proposal-author skill to create a proposal for adding OAuth2 authentication"

### Install & init

**Install via npm (recommended):**

```bash
# global install
npm install -g dev-playbooks

# init inside your project
dev-playbooks init
```

**One-off usage:**

```bash
npx dev-playbooks@latest init
```

**From source (contributors):**

```bash
# From repo root:
./scripts/install-skills.sh

# Or from inside dev-playbooks/:
../scripts/install-skills.sh
```

### Install targets

After initialization:
- Claude Code: `~/.claude/skills/devbooks-*`
- Codex CLI: `~/.codex/skills/devbooks-*`
- Qoder: `~/.qoder/` (manual setup required)
- OpenCode: `~/.config/opencode/skill/devbooks-*`

### Quick integration

DevBooks uses two directory roots:

| Directory | Purpose | Default |
|------|------|--------|
| `<truth-root>` | Current specs (read-only truth) | `dev-playbooks/specs/` |
| `<change-root>` | Change packages (workspace) | `dev-playbooks/changes/` |

---

## Day-to-Day Change Workflow

### Use Delivery (single entry)

```
Run devbooks-delivery-workflow skill: <your request>
```

Delivery classifies your request (by `request_kind`) and runs the minimal sufficient closed loop. It will ask targeted questions when inputs are missing, and may escalate gates/roles based on `risk_level` and evidence requirements.

### Direct skill invocation

Once you know the flow, call the Skills directly:

**1) Proposal stage (no coding)**

```
Run devbooks-proposal-author skill to create a proposal: Add OAuth2 user authentication
```

Artifacts: `proposal.md` (required), `design.md`, `tasks.md`

**2) Apply stage (role isolation enforced)**

You must use **two separate conversations**:

```
# Chat A - Test Owner
Run devbooks-test-owner skill for change add-oauth2

# Chat B - Coder
Run devbooks-coder skill for change add-oauth2
```

- Test Owner: writes `verification.md` + tests, runs **Red** first
- Coder: implements per `tasks.md`, makes gates **Green** (cannot modify tests)

**3) Review stage**

```
Run devbooks-reviewer skill for change add-oauth2
```

**4) Archive stage**

```
Run devbooks-archiver skill for change add-oauth2
```

---

## Skills Reference

### Proposal stage

| Skill | Description |
|-------|-------------|
| devbooks-proposal-author | Create a change proposal |
| devbooks-impact-analysis | Cross-module impact analysis |
| devbooks-proposal-challenger | Challenge a proposal |
| devbooks-proposal-judge | Adjudicate a proposal |
| devbooks-design-doc | Create a design doc |
| devbooks-spec-contract | Define specs & contracts |
| devbooks-implementation-plan | Create an implementation plan |

### Apply stage

| Skill | Description |
|-------|-------------|
| devbooks-test-owner | Test Owner role (separate chat required) |
| devbooks-coder | Coder role (separate chat required) |
| devbooks-design-doc | Backport discoveries to design |

### Review stage

| Skill | Description |
|-------|-------------|
| devbooks-reviewer | Code review (readability/consistency) |
| devbooks-test-reviewer | Test quality and coverage review |

### Archive stage

| Skill | Description |
|-------|-------------|
| devbooks-archiver | Maintain/dedupe specs |
| devbooks-delivery-workflow | End-to-end delivery workflow |

### Standalone Skills

| Skill | Description |
|-------|-------------|
| devbooks-entropy-monitor | System entropy metrics |
| devbooks-brownfield-bootstrap | Brownfield project bootstrap |

---

## DevBooks Comparisons

### vs. Lightweight 3-command spec workflow

A lightweight 3-command spec workflow typically aligns humans and AI with a small fixed set of phases (e.g., propose/apply/archive), which works well for small, low-risk changes.

**DevBooks adds:**
- **Role isolation**: hard boundary between Test Owner and Coder (separate conversations)
- **Quality gates**: 5+ verification gates block false completion
- **21 Skills**: proposal, debate, review, entropy metrics, and full workflow coverage
- **Evidence-based done**: tests/build define “done”, not AI self-evaluation

**Choose a lightweight workflow**: simple spec-driven changes, want minimal ceremony.

**Choose DevBooks**: large changes, need enforced role boundaries and verifiable quality gates.

### vs. Toolkit-style spec process

A toolkit-style spec process typically provides more templates and structured documents (e.g., constitution, requirements, design, tasks), and is often used for greenfield (0→1) standardization.

**DevBooks adds:**
- **Brownfield first**: generate baseline specs for existing codebases
- **Role isolation**: enforced separation between tests and implementation
- **Quality gates**: executable verification, not just workflow guidance
- **Prototype mode**: safe experiments without polluting main src

**Choose a toolkit-style process**: greenfield (0→1) projects where you want structured templates and multi-step guidance.

**Choose DevBooks**: brownfield repos or when you need enforced quality gates.

### vs. Kiro.dev

[Kiro](https://kiro.dev/) is an AWS agentic IDE with a three-phase workflow (EARS requirements, design, tasks), but stores specs separately from implementation artifacts.

**DevBooks differences:**
- **Change package**: proposal/design/spec/plan/verification/evidence in one place for lifecycle traceability
- **Role isolation**: Test Owner and Coder are separated
- **Quality gates**: verified through gates, not just task completion

**Choose Kiro**: want an IDE-first experience integrated with AWS ecosystem.

**Choose DevBooks**: want change packages bundling artifacts and enforced role boundaries.

### vs. no spec

Without specs, the assistant generates code from vague prompts, leading to unpredictable output, scope creep, and “hallucinated completion”.

**DevBooks brings:**
- Specs agreed before implementation
- Quality gates that verify real completion
- Role isolation to prevent self-verification
- Evidence chain per change

---

## Core Principles

| Principle | Meaning |
|------|------|
| **Protocol first** | truth/change/archive live in the repo, not only in chat logs |
| **Anchor first** | done is defined by tests/static checks/build/evidence |
| **Role isolation** | Test Owner and Coder must work in separate conversations |
| **Truth root separation** | `<truth-root>` is read-only truth; `<change-root>` is the workspace |
| **Structural gates** | prioritize complexity/coupling/test quality, not proxy metrics |

---

## Advanced Features

<details>
<summary><strong>Quality gates</strong></summary>

DevBooks uses quality gates to block “false done”:

| Gate | Trigger mode | What it checks |
|------|----------|----------|
| Green evidence | archive, strict | `evidence/green-final/` exists and is non-empty |
| Task completion | strict | all tasks are done or SKIP-APPROVED |
| Test failure block | archive, strict | no failures in green evidence |
| P0 skip approval | strict | P0 skips require an approval record |
| Role boundary | apply --role | Coder cannot modify tests/, Test Owner cannot modify src/ |
| Gate report on disk | strict, archive | `evidence/gates/G0-<mode>.report.json` (G0–G6) |
| Protocol coverage report | strict, archive | `evidence/gates/protocol-v1.1-coverage.report.json` and `uncovered=0` |
| Risk evidence block | strict, archive | `evidence/risks/rollback-plan.md` + `evidence/risks/dependency-audit.log` |

Core scripts (bundled with the installed `devbooks-delivery-workflow` skill under `devbooks-delivery-workflow/scripts/`):
- `change-check.sh --mode proposal|apply|archive|strict`
- `handoff-check.sh` - handoff boundary checks
- `audit-scope.sh` - full audit scan
- `progress-dashboard.sh` - progress visualization

</details>

<details>
<summary><strong>Prototype mode</strong></summary>

When the technical approach is uncertain:

1. Create a prototype: `change-scaffold.sh <change-id> --prototype`
2. Test Owner with `--prototype`: characterization tests (no Red baseline required)
3. Coder with `--prototype`: output to `prototype/src/` (isolates main src)
4. Promote or discard: `prototype-promote.sh <change-id>`

Prototype mode prevents experimental code from polluting the main tree.

Scripts are bundled with the installed `devbooks-delivery-workflow` skill under `devbooks-delivery-workflow/scripts/`.

</details>

<details>
<summary><strong>Entropy monitoring</strong></summary>

DevBooks tracks four dimensions of system entropy:

| Metric | What it measures |
|------|----------|
| Structural entropy | module complexity and coupling |
| Change entropy | change patterns and volatility |
| Test entropy | coverage/quality decay over time |
| Dependency entropy | external dependency health |

Use `devbooks-entropy-monitor` skill to generate reports and identify refactor opportunities.

Scripts (bundled with the installed `devbooks-entropy-monitor` skill under `devbooks-entropy-monitor/scripts/`): `entropy-measure.sh`, `entropy-report.sh`

</details>

<details>
<summary><strong>Brownfield project bootstrap</strong></summary>

When `<truth-root>` is empty:

```
Run devbooks-brownfield-bootstrap skill
```

Generates:
- project profile and glossary
- baseline specs from existing code
- minimal verification anchors
- module dependency map
- technical debt hotspots

</details>

<details>
<summary><strong>MCP auto-detection</strong></summary>

DevBooks Skills support graceful MCP (Model Context Protocol) degradation: everything still works without MCP/CKB; once CKB (Code Knowledge Base) is available, graph-based capabilities are enabled automatically to improve scope/reference/call-chain analysis.

### What does it help with?

- **More accurate impact analysis**: from “file-level guesses” to “symbol-level references + call graph”, reducing missed changes
- **More focused reviews**: auto-fetch hotspots and prioritize high-risk areas (tech debt / high-churn)
- **Less pain on large repos**: reduce grep noise and repeated confirmation

### MCP state and behavior

| MCP state | Behavior |
|----------|------|
| CKB available | Enhanced mode: symbol-level impact analysis / reference search / call graph / hotspots |
| CKB unavailable | Basic mode: grep + glob text search (full functionality, lower precision) |

### Auto detection

- Skills that can use MCP probe availability first (2s timeout)
- Timeout/failure → silently fall back to basic mode (do not block execution)
- No need to manually pick “basic/enhanced” mode

</details>

<details>
<summary><strong>Proposal review workflow</strong></summary>

For strict proposal review, use the three-role workflow (each role in a separate conversation):

1. **Author** (`devbooks-proposal-author`): creates the proposal
2. **Challenger** (`devbooks-proposal-challenger`): challenges assumptions, finds gaps, identifies risks
3. **Judge** (`devbooks-proposal-judge`): makes the final decision and records rationale

Decision: `Approved`, `Revise`, `Rejected`

</details>

---

## Migration from other frameworks

DevBooks provides migration scripts to help move from a legacy layout into DevBooks.

Migration sources are identified by a `legacy-id`, which maps to a script at `scripts/legacy/migrate-from-<legacy-id>.sh`.
(To avoid enumerating legacy source names in user-facing output, the CLI does not list available ids; inspect `scripts/legacy/` yourself.)

```bash
# Use CLI (recommended)
dev-playbooks migrate --from <legacy-id>

# Preview changes first
dev-playbooks migrate --from <legacy-id> --dry-run

# Keep the old directory after migration
dev-playbooks migrate --from <legacy-id> --keep-old
```

**Notes:**
- Mapping rules are defined by the selected migration script. Scripts typically map legacy specs/change artifacts into `dev-playbooks/specs/` and `dev-playbooks/changes/`, and update doc references (script is the source of truth).

### Migration features

Migration scripts support:

- **Idempotent runs**: safe to rerun
- **Resume support**: can continue after interruption
- **Dry-run mode**: preview before applying
- **Automatic backups**: backups live under `.devbooks/backup/`
- **Reference updates**: doc path references are updated automatically

### After migration

1. Run `dev-playbooks init` to install DevBooks Skills
2. Review migrated files under `dev-playbooks/`
3. Update AC mapping inside `verification.md` as needed
4. If you need baseline specs, run `devbooks-brownfield-bootstrap`

---

## Directory Structure

```
dev-playbooks/
├── README.md              # This document
├── constitution.md        # Project constitution (GIP principles)
├── project.md             # Project context (tech stack/conventions)
├── specs/                 # Current specs (read-only truth)
│   ├── _meta/             # Metadata (glossary, project profile)
│   └── architecture/      # Architecture specs (fitness-rules)
├── changes/               # Change packages (workspace)
├── scripts/               # Helper scripts
└── docs/                  # Documentation
    └── workflow-diagram.svg      # Workflow visualization
```

---

## Documentation

- [Workflow diagram](docs/workflow-diagram.svg)

---

## License

MIT
