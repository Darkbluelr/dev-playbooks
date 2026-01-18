# Spec Structure Template

> This template defines the standard structure for Spec truth files, ensuring Specs are verifiable, traceable, and can drive test generation.

## File Location

```
<truth-root>/specs/<capability>/spec.md
```

## Standard Structure

```markdown
---
# Metadata (required)
capability: <capability-name>
owner: @<owner>
last_verified: YYYY-MM-DD
last_referenced_by: <last-referencing-change-id>
health: active | stale | deprecated
freshness_check: monthly | quarterly | on-change
---

# <Capability Name> Specification

## Glossary

> Capability-specific terms, consistent with `<truth-root>/_meta/glossary.md`.

| Term | Definition | Constraints |
|------|------------|-------------|
| Order | Order entity | Must have at least one OrderItem |
| OrderItem | Order line item | qty > 0, price >= 0 |

## Invariants

> Constraints that must always hold; violations are system bugs.

| ID | Description | Verification |
|----|-------------|--------------|
| INV-001 | Order total = SUM(item.price * item.qty) | A (automated test) |
| INV-002 | Inventory quantity >= 0 | A (automated test) |
| INV-003 | Shipped orders cannot be cancelled | A (state machine test) |

## Contracts

### Preconditions

| ID | Operation | Condition | Violation Behavior |
|----|-----------|-----------|-------------------|
| PRE-001 | Create order | user.isAuthenticated | Return 401 |
| PRE-002 | Pay order | order.status == 'pending' | Return 400 |

### Postconditions

| ID | Operation | Guarantee |
|----|-----------|-----------|
| POST-001 | Create order success | Generate unique order.id |
| POST-002 | Payment success | inventory.decreased(qty) |

## State Machine

> If this capability involves state transitions, a state machine must be defined.

### State Set

```
States: {Created, Paid, Shipped, Done, Cancelled}
```

### Transition Rules

| Current State | Action | Target State | Condition |
|---------------|--------|--------------|-----------|
| Created | pay | Paid | payment.success |
| Created | cancel | Cancelled | - |
| Paid | ship | Shipped | inventory.reserved |
| Paid | refund | Cancelled | - |
| Shipped | deliver | Done | - |

### Forbidden Transitions

| Current State | Action | Reason |
|---------------|--------|--------|
| Shipped | cancel | Violates INV-003 |
| Done | * | Terminal state, cannot exit |
| Cancelled | * | Terminal state, cannot exit |

## Requirements

### REQ-001: <Requirement Title>

**Description**: <one-sentence description>

**SHALL/SHOULD/MAY**:
- The system **SHALL** ...
- The system **SHOULD** ...

**Trace**: AC-001 (from design.md)

#### Scenario: <scenario-name>

- **GIVEN** user is logged in and cart is non-empty
- **WHEN** user clicks "Submit Order"
- **THEN** system creates order and returns order ID

**Data Instances** (boundary conditions):

| Input | Expected Output | Notes |
|-------|-----------------|-------|
| qty=1, price=100 | total=100 | Normal value |
| qty=0 | Reject | Boundary - zero |
| qty=-1 | Reject | Boundary - negative |

---

## Change History

| Date | Change Package | Changes |
|------|----------------|---------|
| 2024-01-16 | 20240116-1030-add-cancel | Add cancel order scenario |
```

## Usage Guide

### 1. Who Writes Specs?

- **spec-contract skill**: Creates/updates spec deltas
- **archiver skill**: Merges spec deltas into truth-root

### 2. Who Reads Specs?

| Skill | Reading Purpose |
|-------|-----------------|
| design-doc | Check if design conflicts with existing Specs, reference REQ-xxx |
| test-owner | Generate tests from contracts/state machines |
| impact-analysis | Identify affected Specs |
| code-review | Check terminology consistency |
| archiver | Update metadata, build reference chain |

### 3. Test Generation Mapping

| Spec Element | Generated Test Type |
|--------------|---------------------|
| INV-xxx | Invariant tests |
| PRE-xxx | Precondition tests (satisfied + violated) |
| POST-xxx | Postcondition tests |
| State Transition | State transition tests |
| Forbidden Transition | Forbidden transition tests |
| Data Instance Table | Parameterized test cases |

### 4. Health Detection

The `health` field in Spec files is automatically detected by entropy-monitor:

| Condition | health Status |
|-----------|---------------|
| last_verified < 90 days | `active` |
| last_verified > 90 days | `stale` (needs review) |
| Explicitly marked deprecated | `deprecated` |
| last_referenced_by empty for >6 months | Recommend deletion |
