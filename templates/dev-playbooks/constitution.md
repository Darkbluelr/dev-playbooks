# Project Constitution

> This document defines the Global Inviolable Principles (GIP) for the project.
> All AI assistants and developers must comply with these principles before executing any operation.

---

## Part Zero: Mandatory Directives

**Before executing any Skill or operation, you must:**

1. Read and understand this constitution document
2. Confirm the operation does not violate any GIP principle
3. If there is a conflict, stop immediately and report

---

## Global Inviolable Principles (GIP)

### GIP-01: Role Isolation Principle

**Rule**: Test Owner and Coder must execute in separate conversations/separate instances.

**Rationale**:
- Prevent cognitive contamination between testing and implementation
- Ensure the integrity of the Red-Green cycle
- Avoid the anti-pattern of "writing tests and modifying tests yourself"

**Violation Consequence**: Change package cannot be archived.

---

### GIP-02: Test Immutability Principle

**Rule**: The Coder role is prohibited from modifying any files under the `tests/**` directory.

**Rationale**:
- Tests are the executable form of specifications
- Modifying tests equals modifying specifications, requiring design-level decisions
- Guarantee the independence of acceptance criteria

**Exception**: If tests need to be modified, they must be handed back to the Test Owner for handling.

---

### GIP-03: Design-First Principle

**Rule**: Code implementation must trace back to AC-xxx in the design document.

**Rationale**:
- Ensure all code changes have clear business purposes
- Support full traceability: Design → Task → Test → Code
- Prevent "ghost features" and unauthorized changes

**Verification Method**: `ac-trace-check.sh` checks coverage.

---

### GIP-04: Single Source of Truth Principle

**Rule**: `specs/` is the single source of truth for system behavior.

**Rationale**:
- Avoid inconsistencies caused by specifications scattered across multiple locations
- Ensure all roles reference the same source
- Support incremental synchronization and conflict detection

**Operational Constraints**:
- Spec delta in change packages must go through the stage → promote workflow
- Direct modification of the `specs/` directory is prohibited

---

## Escape Hatches

> The following situations allow temporary bypass of the above principles, but must be documented and traceable.

### EH-01: Emergency Fix

**Applicable Scenario**: Production environment has severe failures requiring emergency repair.

**Process**:
1. Document the emergency fix reason in `evidence/`
2. Mark with `[EMERGENCY]` prefix
3. Supplement with a complete change package afterward

### EH-02: Prototype Validation

**Applicable Scenario**: Technical solution is uncertain and requires rapid validation.

**Constraints**:
- Code must be placed in the `prototype/` directory
- Direct merging into production code is prohibited
- Promote through the formal process after validation is complete

### EH-03: Manual Adjudication

**Applicable Scenario**: Rule conflicts or edge cases require human judgment.

**Process**:
1. Document the decision point in `proposal.md`
2. Obtain sign-off from the project lead
3. Update the Decision Log

---

## Constitution Amendment Process

1. Any modification to this constitution must go through a formal change proposal
2. Change proposals need to undergo Challenger questioning and Judge adjudication
3. Constitution changes have P0 priority and require confirmation from all core members

---

**Constitution Version**: v1.0.0
**Last Updated**: {{DATE}}
