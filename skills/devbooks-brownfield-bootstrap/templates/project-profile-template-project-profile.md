# Project Profile Template

---

## A) Syntax Layer

**Goal**: establish structural understanding of the codebase — tech stack, directory layout, and build commands.

### A.1 Stack Overview

| Dimension | Value |
|------|-----|
| Primary language | `<language>` |
| Framework | `<framework>` |
| Runtime | `<runtime>` |
| Package manager | `<package-manager>` |
| Build tool | `<build-tool>` |

### A.2 Directory Structure

```
<project-root>/
├── src/                    # Source code
│   ├── base/               # Base layer (platform-agnostic)
│   ├── platform/           # Platform layer (platform services)
│   ├── domain/             # Domain layer (business logic)
│   ├── application/        # Application layer (use-case orchestration)
│   └── ui/                 # UI layer (user interaction)
├── tests/                  # Tests
├── docs/                   # Docs
└── scripts/                # Scripts
```

### A.3 Key Commands

| Command | Purpose |
|------|------|
| `<install-cmd>` | Install dependencies |
| `<build-cmd>` | Build |
| `<test-cmd>` | Run tests |
| `<lint-cmd>` | Lint / static checks |
| `<start-cmd>` | Start service |

---

## B) Semantics Layer

**Goal**: understand logical relationships — module dependencies, API boundaries, and data flow.

### B.1 Module Dependency Graph

> Can be generated from structure analysis or maintained manually.

```
[base] ← [platform] ← [domain] ← [application] ← [ui]
           ↑
       [external-libs]
```

**Layering constraints**:

| Layer | Allowed dependencies | Forbidden dependencies |
|------|--------|----------|
| base | (none) | all upper layers |
| platform | base | domain, application, ui |
| domain | base, platform | application, ui |
| application | base, platform, domain | ui |
| ui | all layers | (none) |

### B.2 Capabilities

| Capability | Entry point | Owning module | Dependencies |
|------|------|----------|------|
| `<capability-1>` | `<entry-point>` | `<module>` | `<deps>` |
| `<capability-2>` | `<entry-point>` | `<module>` | `<deps>` |

### B.3 External Contracts

| Type | Location | Format |
|------|------|------|
| REST API | `src/api/` | OpenAPI 3.0 |
| Events | `src/events/` | CloudEvents |
| Data schemas | `src/schemas/` | JSON Schema |
| Configuration | `config/` | YAML |

### B.4 Boundary Identification

| Area | Path patterns | Properties |
|------|----------|------|
| **User code** | `src/**`, `lib/**` | Modifiable |
| **Library code** | `node_modules/**`, `vendor/**` | Immutable interfaces |
| **Generated code** | `dist/**`, `*.generated.*` | Do not edit manually |
| **Config files** | `*.config.*`, `.*rc` | Changes must be declared |

---

## C) Context Layer

**Goal**: capture tacit knowledge — historical decisions, team conventions, and technical debt.

### C.1 Technical Debt Hotspots

> Can be generated from change history and complexity metrics, or maintained manually.

| File | Change frequency | Complexity | Hotspot score | Risk level |
|------|----------|--------|----------|----------|
| `<file-1>` | high | high | `<score>` | 🔴 Critical |
| `<file-2>` | medium | high | `<score>` | 🟡 High |
| `<file-3>` | high | low | `<score>` | 🟢 Normal |

### C.2 Glossary

> Can be extracted from code and docs, or maintained manually.

| Term | Definition | Code location |
|------|------|----------|
| `<term-1>` | `<definition>` | `<location>` |
| `<term-2>` | `<definition>` | `<location>` |

### C.3 Architecture Decision Records (ADRs)

| ID | Title | Status | Date |
|------|------|------|------|
| ADR-001 | `<title>` | Accepted | `<date>` |
| ADR-002 | `<title>` | Superseded | `<date>` |

### C.4 Known Constraints and Limitations

| Constraint | Reason | Impact scope |
|------|------|----------|
| `<constraint-1>` | `<reason>` | `<scope>` |
| `<constraint-2>` | `<reason>` | `<scope>` |

### C.5 Team Conventions

| Category | Convention | Enforcement |
|------|------|----------|
| Naming | `<convention>` | MUST |
| Commits | `<convention>` | MUST |
| Branch strategy | `<convention>` | MUST |
| Code style | `<convention>` | Enforced by lint |

---

## D) Quality Gates

### D.1 Pre-merge Checks

- [ ] Build passes: `<build-cmd>`
- [ ] Lint passes: `<lint-cmd>`
- [ ] Tests pass: `<test-cmd>`
- [ ] Layering constraints pass: `guardrail-check.sh --check-layers`
- [ ] No cyclic dependencies: `guardrail-check.sh --check-cycles`

### D.2 Additional Checks for Hotspot Changes

When changes touch hotspot files:

- [ ] Test coverage ≥ 80%
- [ ] Stricter code review focus
- [ ] Cyclomatic complexity does not increase

---

## E) Metadata

| Field | Value |
|------|-----|
| Created at | `<date>` |
| Last updated | `<date>` |
| Maintainer | `<maintainer>` |
| Version | `<version>` |
