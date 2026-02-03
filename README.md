# DevBooks

[![npm](https://img.shields.io/npm/v/dev-playbooks)](https://www.npmjs.com/package/dev-playbooks)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Transform AI coding from "says it's done" to "proves it's done."**

DevBooks is an engineering protocol for AI that uses upstream Single Source of Truth (SSOT), executable gates, and evidence loops to upgrade AI programming from "conversational guessing" to "auditable engineering delivery."

---

## Core Philosophy

The essence of software engineering is **building reliable systems on unreliable components**. Traditional engineering uses RAID against unreliable disks, TCP retransmission against unreliable networks, and Code Review against unreliable human programmers. AI engineering likewise needs **gates and evidence loops** to constrain unreliable LLM outputs.

DevBooks is not prompt optimization. It's engineering constraints.

---

## Upstream SSOT: Single Authority Across the Development Lifecycle

At the core of DevBooks is the **Single Source of Truth (SSOT)**—all critical knowledge persisted and versioned, stable across conversations and changes.

```
Your requirement docs (if any)
    ↓ Extract constraints, build index
specs/ (terms, boundaries, decisions, scenarios) ← "Project memory" stable across changes
    ↓ Derive change packages
changes/<id>/ (proposal, design, tasks, evidence)
    ↓ Archive writeback
specs/ (update truth)
```

**Problems SSOT Solves:**

| Problem | Root Cause | How SSOT Solves It |
|---------|------------|-------------------|
| Re-teach every time | Conversations are temporary, knowledge isn't persisted | Terms, boundaries, constraints written in files, not dependent on conversation memory |
| Forgets what you said earlier | Context window is limited, early info gets pushed out | Truth artifacts persisted, critical constraints force-injected |
| Don't know what changed | No auditable change record | Every change has complete record—proposal, design, tasks, evidence |

---

## Ledger & Index: Continuous Completion Tracking

DevBooks continuously tracks delivery status through **Completion Contracts** and **Requirements Index**.

### Completion Contract: Compile "what I want" into machine-checkable lists

```yaml
obligations:
  - id: O-001
    describes: "User can login via email"
    severity: must
checks:
  - id: C-001
    type: test
    covers: [O-001]
    artifacts: ["evidence/gates/login-test.log"]
```

Not "roughly done," but "all 5 obligations have evidence."

### Requirements Index: Turn upstream docs into traceable obligation lists

```yaml
set_id: ARCH-P3
source_ref: "truth://specs/architecture/design.md"
requirements:
  - id: R-001
    severity: must
    statement: "All APIs must support versioning"
  - id: R-002
    severity: should
    statement: "Response time < 200ms"
```

When a change package claims "upstream task completed," the system can judge that claim—not verbal confirmation, but machine verification.

---

## Knife Slicing Protocol: Turn Large Requirements into Executable Queues

What happens when you hand large requirements directly to AI? Fixes A, breaks B. Fixes B, breaks C.

The Knife protocol uses **complexity budgets** and **topological sorting** to slice Epics into independently verifiable atomic change package queues.

### Slicing Algorithm

```
Score = w₁·Files + w₂·Modules + w₃·RiskFlags + w₄·HotspotWeight
```

| Signal | Weight | Description |
|--------|--------|-------------|
| files_touched | 1.0 | 1 point per file |
| modules_touched | 5.0 | Cross-module risk is high |
| risk_flags | 10.0 | 10 points per risk flag |
| hotspot_weight | 2.0 | High churn areas weighted |

**Over budget means slice again**—no "forcing through."

### Slicing Invariants

1. **MECE Coverage**: Union of all slice acceptance criteria equals Epic's complete set, no overlap
2. **Independently Green**: Each slice has at least one deterministic verification anchor, no "intermediate state won't compile"
3. **Topologically Sortable**: Dependency graph must be acyclic, execution order must be topological
4. **Budget Circuit Breaker**: Over budget must recursively re-slice, or flow back for more info

---

## 7 Gates: Full-Chain Judgeable Checkpoints

| Gate | What It Checks | Failure Consequence |
|------|----------------|---------------------|
| G0 | Is input ready? Are baseline artifacts complete? | Flow back to Bootstrap |
| G1 | Are all required files present? Is structure correct? | Block |
| G2 | Are all tasks complete? Does green evidence exist? | Block |
| G3 | Is slicing correct? Are anchors complete? (large requests) | Flow back to Knife |
| G4 | Are docs in sync? Are extension packs complete? | Block |
| G5 | Is risk covered? Is rollback strategy present? (high-risk) | Block |
| G6 | Is evidence complete? Is contract satisfied? Ready to archive? | Block |

Any failure blocks the flow. Not a warning. A block.

---

## Role Isolation: Prevent AI from Validating Itself

| Role | Responsibility | Hard Constraint |
|------|---------------|-----------------|
| Test Owner | Derive acceptance tests from design | Cannot see implementation code |
| Coder | Implement features per tasks | Cannot modify tests/ |
| Reviewer | Review readability and consistency | Cannot change tests or design |

Test Owner and Coder must execute in **different contexts**—not "different people," but "different conversations/instances." They can only exchange information through **persisted artifacts**.

---

## Quick Start

```bash
npm install -g dev-playbooks
dev-playbooks init
dev-playbooks delivery
```

You only need to remember one command: `delivery`. The system asks a few questions, then generates a `RUNBOOK.md`—your operation manual for this task. Just follow it.

```
Your request
    ↓
Delivery (determine type, generate RUNBOOK)
    ↓
┌─────────────────────────────────┐
│ Small change → Execute directly │
│ Large request → Slice first     │
│ Uncertain → Research first      │
└─────────────────────────────────┘
    ↓
Gate checks (7 checkpoints, any failure blocks)
    ↓
Evidence archive (test logs, build outputs, approvals)
```

---

## Directory Structure

```
project/
├── .devbooks/config.yaml        # Config entry point
└── dev-playbooks/
    ├── constitution.md          # Hard constraints (non-bypassable rules)
    ├── specs/                   # Truth source (SSOT)
    │   ├── _meta/
    │   │   ├── glossary.md      # Unified language
    │   │   ├── boundaries.md    # Module boundaries
    │   │   ├── capabilities.yaml # Capability registry
    │   │   └── epics/           # Knife slice plans
    │   └── ...
    └── changes/                 # Change packages
        └── <change-id>/
            ├── proposal.md      # Why and what
            ├── design.md        # How, acceptance criteria
            ├── tasks.md         # Executable steps
            ├── completion.contract.yaml  # Completion contract
            ├── verification.md  # How to prove it's correct
            └── evidence/        # Test logs, build outputs
```

---

## Use Cases

- **Brownfield Onboarding**: Auto-index existing docs, extract judgeable constraints, establish minimal SSOT package
- **Greenfield Projects**: Guide completion of terms, boundaries, scenarios, decisions to establish baseline
- **Daily Changes**: Minimal sufficient loop with reproducible verification anchors + evidence archive
- **Large Refactors**: Knife slicing + migration patterns (Expand-Contract / Strangler Fig / Branch by Abstraction)

---

## Next Steps

- [Quick Start](docs/Usage-Guide.md)
- [AI-Native Workflow](docs/ai-native-workflow.md)
- [Skill Reference](docs/Skill-Details.md)

---

## License

MIT
