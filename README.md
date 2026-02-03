# DevBooks

[![npm](https://img.shields.io/npm/v/dev-playbooks)](https://www.npmjs.com/package/dev-playbooks)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## What's New in v4.0

- **Completion Contract**: Compiles user intent into machine-readable contracts, locking "obligation → check → evidence" chains to prevent AI from silently lowering delivery standards
- **7 Gates (G0-G6)**: Full-chain judgeable checkpoints from input readiness to archive decision — any failure blocks
- **Upstream SSOT Support**: Auto-indexes existing project requirement docs, extracts judgeable constraints; creates minimal SSOT package when no docs exist
- **Knife Slicing Protocol**: Large requirements must be sliced, each slice has complexity budget — over budget means slice again
- **Void Research Protocol**: High-entropy problems get researched before decisions, producing traceable Architecture Decision Records (ADR)
- **Evidence Freshness Check**: Evidence files must be newer than covered deliverables — no cheating with stale evidence
- **Weak-Link Obligations**: Docs, configs, release notes and other "non-code contracts" are also compiled into judgeable obligations

---

## Do you run into these problems when using AI to write code?

**"Says it's fixed, but it's not"**
AI says "Fixed." You ask if it's sure. It says "Yes." You deploy. It breaks. Turns out the test it wrote happens to pass its own bug.

**"Forgets what you said earlier"**
At the start you said "Don't touch module X." Thirty messages later, it touched module X. You remind it. It apologizes. Next turn, it does it again.

**"Falls apart on bigger tasks"**
Small features are fine. Anything complex and it starts hallucinating. Fixes A, breaks B. Fixes B, breaks C.

**"You can't tell if it's actually done"**
It says "Done." You don't trust it. You ask it to double-check. It says "Checked, all good." You still don't trust it.

**"Have to re-teach it every time"**
Conventions from the last conversation? Gone. Project terminology, boundaries, constraints? Explain them again.

**"Don't know what it actually changed"**
It modified a bunch of files. You ask what changed. It gives you a summary. Is the summary accurate? You have no idea.

---

## These aren't AI being dumb. They're structural problems.

Better prompts won't fix this. It's how LLMs work:

| Problem | Root Cause |
|---------|------------|
| Says fixed but isn't | Writes tests that validate its own code — of course they pass |
| Forgets earlier context | Context window is limited; early info gets pushed out |
| Falls apart on big tasks | Complexity exceeds what a single conversation can handle |
| Can't tell if it's done | No objective evidence, just verbal claims |
| Re-teach every time | Conversations are temporary; knowledge isn't persisted |
| Don't know what changed | No auditable change record |

---

## DevBooks: Engineering constraints that solve these problems

```bash
npm install -g dev-playbooks
dev-playbooks init
dev-playbooks delivery
```

| Problem | How DevBooks Solves It |
|---------|------------------------|
| Self-validation | **Role isolation**: Test-writing agent and code-writing agent must be separate — can't see each other's reasoning |
| Context amnesia | **Truth to disk**: Terms, boundaries, constraints written in files, not dependent on conversation memory |
| Too complex | **Slicing budget**: Large requirements must be sliced into small pieces, each with complexity cap — over budget means slice again |
| Verbal completion | **Evidence defines done**: Test logs, build outputs must actually exist on disk |
| Re-teach every time | **SSOT (Single Source of Truth)**: Project knowledge persisted in specs/, stable across conversations and changes |
| Don't know what changed | **Change packages**: Every change has complete record — proposal, design, tasks, evidence |

---

## How it works

You only need to remember one command:

```bash
dev-playbooks delivery
```

The system asks a few questions, then generates a `RUNBOOK.md` — your operation manual for this task. Just follow it.

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

## Core Mechanisms

**Single Source of Truth (SSOT)**

```
Your requirement docs (if any)
    ↓ Extract constraints
specs/ (terms, boundaries, decisions) ← "Project memory" stable across changes
    ↓
changes/<id>/ (this change's proposal, design, tasks, evidence)
    ↓ Archive
specs/ (update truth)
```

If you don't have requirement docs, DevBooks will help you create a minimal one. This is actually good — it forces you to clarify vague ideas.

**Completion Contract**

Compiles "what I want" into a machine-checkable list:
- 5 obligations
- Each has a corresponding check
- Each has a corresponding evidence file

Not "roughly done," but "all 5 have evidence."

**7 Gates (G0-G6)**

| Gate | What It Checks |
|------|----------------|
| G0 | Is input ready? Are requirements clear? |
| G1 | Are all required files present? |
| G2 | Are all tasks complete? |
| G3 | Is slicing correct? (large requests) |
| G4 | Are docs in sync? |
| G5 | Is risk covered? (high-risk changes) |
| G6 | Is evidence complete? Ready to archive? |

Any failure blocks the flow. Not a warning. A block.

---

## Directory Structure

```
project/
├── .devbooks/config.yaml     # Config
└── dev-playbooks/
    ├── constitution.md       # Hard constraints (non-bypassable rules)
    ├── specs/                # Truth source (stable across changes)
    └── changes/              # Change packages (one directory per change)
        └── <change-id>/
            ├── proposal.md   # Why and what
            ├── design.md     # How, acceptance criteria
            ├── tasks.md      # Executable steps
            ├── verification.md # How to prove it's correct
            └── evidence/     # Test logs, build outputs
```

---

## Next Steps

- [Quick Start](docs/Usage-Guide.md)
- [AI-Native Workflow](docs/ai-native-workflow.md)
- [Skill Reference](docs/Skill-Details.md)

---

## License

MIT
