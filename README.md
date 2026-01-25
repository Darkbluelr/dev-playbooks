# DevBooks

**Quality gates for AI coding: turn assistants from "unpredictable" into "verifiable"**

[![npm](https://img.shields.io/npm/v/dev-playbooks)](https://www.npmjs.com/package/dev-playbooks)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

![DevBooks Workflow](docs/workflow-diagram.svg)

---

## Best Practice: Run the Full Loop in One Command

Not sure how to start? Just run:

```bash
/devbooks-delivery-workflow
```

This skill orchestrates the full development loop: Proposal -> Design -> Spec -> Plan -> Test -> Implement -> Review -> Archive

**Best for**: new feature work, major refactors, teams new to DevBooks

If you're not sure which entrypoint to use, start with:

```bash
/devbooks:start
```

Start is the default entrypoint. It routes you to the shortest closed-loop next step.

---

## Positioning and Writing Conventions

DevBooks is not an MCP tool. It provides optional MCP integration points plus a small set of self-check scripts.
DevBooks is a collaboration system built around protocols, workflows, and writing conventions, emphasizing traceability and verifiability.

Constraints: the core flow must remain traceable and auditable.
Trade-offs: prioritize consistency checks, accept some automation overhead.
Impact: better document scanability and lower collaboration cost.

---

## Core Problems We Solve

### Problem 1: Logic hallucinations and fabricated facts

**Pain**: When unsure, AI tends to invent APIs or code instead of admitting uncertainty.

**DevBooks approach**:
- Spec-driven development: all code must trace to AC-xxx (acceptance criteria)
- Contract tests: validate external contracts and prevent API hallucinations

### Problem 2: Non-convergent debugging

**Pain**: Fixing one bug introduces two more, creating a whack-a-mole loop.

**DevBooks approach**:
- Role isolation: Test Owner produces a Red baseline first; Coder cannot modify tests
- Convergence audit: `devbooks-convergence-audit` evaluates whether a change package is truly progressing

### Problem 3: Local optima and short-sighted solutions

**Pain**: AI tends to generate local, runnable code blocks without considering overall architecture.

**DevBooks approach**:
- Design first: design docs define What/Constraints, not How
- Architecture constraints: fitness rules validate architecture rules
- Impact analysis: assess cross-module impact before changes

### Problem 4: Verification fatigue

**Pain**: AI generates fast, human review attention decays over time.

**DevBooks approach**:
- Automated quality gates: green evidence checks, task completion, role boundary checks
- Enforced review: Reviewer focuses on maintainability; business correctness is proven by tests

---

## Quick Start

### Install

```bash
# install globally
npm install -g dev-playbooks

# initialize in a project
dev-playbooks init
```

### Update

```bash
dev-playbooks update
```

### Supported AI tools

| Tool | Support level |
|------|---------------|
| Claude Code | Full Skills (`.claude/skills/`) |
| Codex CLI | Full Skills (`.codex/skills/`) |
| Qoder | Full Skills |
| OpenCode | Full Skills |
| Every Code | Full Skills |
| Factory | Native Skills (`.factory/skills/`) |
| Cursor | Native Skills (`.cursor/skills/`) |
| Windsurf | Rules system |
| Gemini CLI | Rules system |

---

## Docs

- [DevBooks setup guide](docs/devbooks-setup-guide.md) - setup instructions
- [AI-native workflow](docs/ai-native-workflow.md) - workflow, roles, evidence
- [Recommended MCP](docs/Recommended-MCP.md) - MCP server recommendations

---

## Core Principles

### 1. Role Isolation

Test Owner and Coder **must work in separate conversations**. This is not optional.

**Isolation baseline**:
- Do not write tests and implementation in the same chat
- Tests are used to verify specs

### 2. Spec-Driven

All code must trace to AC-xxx (acceptance criteria).

```
Requirement -> Proposal -> Design (AC-001, AC-002) -> Spec -> Tasks -> Tests -> Code
```

### 3. Evidence-First

Completion is defined by evidence, not AI declarations.

Required evidence:
- Tests pass (green evidence)
- Build succeeds
- Static checks pass
- Task completion rate 100%

---

## Workflow

```
1. Proposal - analyze requirements, assess impact
2. Design - define What/Constraints + AC-xxx
3. Spec - define external behavior contracts
4. Plan - create implementation plan and task breakdown
5. Test - write acceptance tests (separate conversation)
6. Implement - implement features (separate conversation)
7. Review - code review
8. Archive - archive the change package
```

---

## 18 Skills

| Skill | Phase | Purpose |
|-------|------|---------|
| devbooks-router | Entry | Workflow guidance |
| devbooks-proposal-author | Proposal | Write proposals |
| devbooks-proposal-challenger | Proposal | Challenge proposals |
| devbooks-proposal-judge | Proposal | Judge proposals |
| devbooks-design-doc | Design | Write design docs |
| devbooks-spec-contract | Spec | Define specs and contracts |
| devbooks-implementation-plan | Plan | Create implementation plans |
| devbooks-test-owner | Test | Write acceptance tests |
| devbooks-test-reviewer | Review | Test review |
| devbooks-coder | Implement | Implement tasks |
| devbooks-reviewer | Review | Code review |
| devbooks-archiver | Archive | Archive change packages |
| devbooks-docs-consistency | Quality | Docs consistency checks |
| devbooks-impact-analysis | Quality | Impact analysis |
| devbooks-convergence-audit | Quality | Convergence audit |
| devbooks-entropy-monitor | Quality | Entropy monitoring |
| devbooks-brownfield-bootstrap | Init | Brownfield bootstrap |
| devbooks-delivery-workflow | Full | Full loop orchestration |

See [DevBooks setup guide](docs/devbooks-setup-guide.md) for configuration details.

---

## Traditional AI Coding Comparison

### Comparison with traditional AI coding

| Traditional AI coding | DevBooks |
|----------------------|----------|
| AI self-declares "done" | Tests pass + build succeeds |
| Tests and code in same chat | Role isolation, separate conversations |
| No verification gates | Multiple quality gates |
| Fix one bug, create two | Stable convergence |
| Only supports greenfield | Supports brownfield |

### Use cases

- New feature development
- Major refactors
- Bug fixes
- Brownfield onboarding
- Projects that demand high quality

---

## License

MIT License - see [LICENSE](LICENSE)
