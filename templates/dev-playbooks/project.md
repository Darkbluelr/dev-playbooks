# Project Context

> This document describes the project's technology stack, conventions, and domain context.
> For constitutional rules, please refer to `constitution.md`.

---

## Purpose

<!-- Describe your project purpose here -->

## Technology Stack

- **Primary Language**: <!-- e.g., TypeScript, Python, Go -->
- **Framework**: <!-- e.g., React, Django, Gin -->
- **Database**: <!-- e.g., PostgreSQL, MongoDB -->
- **Configuration Format**: YAML / JSON
- **Documentation Format**: Markdown
- **Version Control**: Git

## Project Conventions

### Code Style

<!-- Describe your code style requirements -->

### Architecture Patterns

- **Configuration Discovery**: All Skills discover configuration through `config-discovery.sh`
- **Constitution First**: Load `constitution.md` before executing any operation
- **Three-Layer Sync**: Draft -> Staged -> Truth

### Testing Strategy

- **Unit Tests**: <!-- e.g., Jest, pytest, go test -->
- **Coverage Target**: 80%
- **Red-Green Cycle**: Test Owner produces Red baseline first, Coder makes it Green

### Git Workflow

- **Main Branch**: `main` / `master`
- **Change Branch**: `change/<change-id>`
- **Commit Format**: `<type>: <subject>`
  - type: feat, fix, refactor, docs, test, chore

## Domain Context

### Core Concepts

| Term | Definition |
|------|------------|
| Truth Root | Truth source root directory, storing final versions of specs and designs |
| Change Root | Change package root directory, storing all artifacts for each change |
| Spec Delta | Specification increment, describing spec modifications from changes |
| AC-ID | Acceptance Criteria Identifier, format `AC-XXX` |
| GIP | Global Inviolable Principle |

### Role Definitions

| Role | Responsibility | Constraints |
|------|----------------|-------------|
| Design Owner | Produce What/Constraints + AC-xxx | Must not write implementation steps |
| Spec Owner | Produce spec delta | - |
| Planner | Derive tasks from design | Must not reference tests/ |
| Test Owner | Derive tests from design/specs | Must not reference tasks/ |
| Coder | Implement according to tasks | Must not modify tests/ |
| Reviewer | Code review | Must not modify tests or design |

## Important Constraints

1. **Role Isolation**: Test Owner and Coder must have independent conversations
2. **Tests Are Immutable**: Coder must not modify tests/
3. **Design First**: Code must be traceable to AC-xxx
4. **Single Source of Truth**: specs/ is the only authority

## External Dependencies

<!-- List your project's external dependencies -->

---

## Directory Root Mapping

| Path | Purpose |
|------|---------|
| `dev-playbooks/` | DevBooks management directory (centralized) |
| `dev-playbooks/constitution.md` | Project constitution |
| `dev-playbooks/project.md` | This file |
| `dev-playbooks/specs/` | Truth source |
| `dev-playbooks/changes/` | Change packages |
| `dev-playbooks/scripts/` | Project-level scripts (optional override) |

---

**Document Version**: v1.0.0
**Last Updated**: {{DATE}}
