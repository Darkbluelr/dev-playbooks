# SSOT - Single Source of Truth

> This document is the project's **requirements-level source of truth**, defining "what the system must do".
>
> - For technical design ("how to implement"), see the `specs/` directory
> - For machine-readable index, see `requirements.index.yaml`

## System Boundary

<!-- Describe the boundary between the system and the external world -->

### User Roles

| Role | Description |
|------|-------------|
| <!-- role name --> | <!-- role description --> |

### External Systems

| System | Interaction | Description |
|--------|-------------|-------------|
| <!-- system name --> | <!-- API/message/file --> | <!-- description --> |

## Core Requirements

<!--
Each requirement format:
- id: R-XXX (stable ID, immutable)
- severity: must | should | may
- statement: single-line description (must be machine-readable)
-->

### R-001: <!-- Requirement Title -->

- **severity**: must
- **statement**: <!-- single-line requirement description -->

<!-- Additional notes (optional) -->

## Constraints and Compliance

<!-- Non-functional constraints: performance, security, compliance, etc. -->

### Performance Constraints

| Metric | Requirement | Description |
|--------|-------------|-------------|
| <!-- metric name --> | <!-- threshold --> | <!-- description --> |

### Security Constraints

<!-- Security-related mandatory requirements -->

### Compliance Requirements

<!-- Regulatory/standard compliance requirements -->

## Open Questions

<!-- Undecided issues that need future clarification -->

| ID | Question | Status | Decision |
|----|----------|--------|----------|
| Q-001 | <!-- question description --> | open | - |

---

> **Maintenance Notes**:
> - After modifying this document, update `requirements.index.yaml` accordingly
> - Use `ssot-maintainer` skill or `ssot-index-sync.sh` script
