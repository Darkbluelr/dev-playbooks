# SSOT vs Spec Boundary Guide

This document clarifies the responsibilities and boundaries between SSOT (Single Source of Truth) and Spec (Specification) in DevBooks.

## Core Differences

| Dimension | SSOT | Spec |
|-----------|------|------|
| **Abstraction Level** | Requirements Layer (What) | Design Layer (How) |
| **Granularity** | Project-level | Module-level |
| **Content** | What the system must do | How modules work |
| **Source** | Business/Product/Compliance/Architecture constraints | Technical design decisions |
| **Change Frequency** | Low (milestone-level) | Medium (feature-level) |

## Content Examples

### SSOT Example

```markdown
# R-001: API Error Format Standardization
- severity: must
- All external APIs must return a standard error format
- Error responses must include code, message, and details fields
```

### Spec Example

```markdown
# ErrorResponse Spec

## Schema
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| code | string | Y | Error code, format `E-{MODULE}-{NUMBER}` |
| message | string | Y | Human-readable error message |
| details | object | N | Additional context |

## Behavior
- 4xx errors: code starts with `E-CLIENT-`
- 5xx errors: code starts with `E-SERVER-`
```

## Directory Structure

```
dev-playbooks/
├── ssot/                        # [Requirements Layer] Project-level source of truth
│   ├── SSOT.md                  # Human-readable requirements/constraints document
│   ├── requirements.index.yaml  # Machine-readable index (stable ID → anchor)
│   └── requirements.ledger.yaml # Derived progress (can be discarded and rebuilt)
│
├── specs/                       # [Design Layer] Module-level behavior specifications
│   ├── _meta/                   # Metadata (profile/glossary)
│   ├── architecture/            # Architecture constraints
│   └── <capability>/spec.md     # Module specifications
│
└── changes/                     # Change history
    └── <change-id>/
        ├── proposal.md          # upstream_claims references SSOT
        └── specs/               # spec delta (merged to specs/ after archiving)
```

## Traceability Chain

```
SSOT.md (R-001: API Error Format Standardization)
    ↓ index
requirements.index.yaml (R-001 → anchor → statement)
    ↓ reference
changes/<id>/proposal.md (upstream_claims: [R-001])
    ↓ design
changes/<id>/specs/error-handling/spec.md (ErrorResponse design)
    ↓ archive
specs/error-handling/spec.md (truth)
```

## Skill Responsibilities

### SSOT Related

| Skill | Responsibility | Trigger |
|-------|----------------|---------|
| `brownfield-bootstrap` | **Create** SSOT skeleton | Brownfield project initialization |
| `ssot-maintainer` | **Maintain** SSOT (add/update/remove) | SSOT content changes |

### Spec Related

| Skill | Responsibility | Trigger |
|-------|----------------|---------|
| `brownfield-bootstrap` | **Create** baseline Spec | Brownfield project initialization |
| `spec-contract` | **Define** module behavior specifications | Change package design phase |
| `design-doc` | **Design** architecture and constraints | Change package design phase |

## FAQ

### Q: When to write SSOT vs Spec?

- **Write SSOT**: When defining "constraints the system must satisfy"
  - Example: Compliance requirements, SLA commitments, API compatibility guarantees
- **Write Spec**: When designing "how specific modules implement"
  - Example: Interface signatures, data models, state machines

### Q: Can we keep only one of SSOT or Spec?

No. They are at different abstraction levels:
- SSOT is "input" (requirements source)
- Spec is "output" (design decisions)

One requirement (SSOT) may affect multiple module Specs.

### Q: What does upstream_claims in change packages reference?

It references requirement IDs in SSOT (e.g., `R-001`), not Specs.

Specs are "outputs" of change packages, not "inputs".
