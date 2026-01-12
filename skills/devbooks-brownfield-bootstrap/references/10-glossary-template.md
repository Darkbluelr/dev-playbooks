# glossary.md Template (Truth Root Metadata)

> Recommended path: `<truth-root>/_meta/glossary.md`
>
> Goal: unify business language and prevent spec/code drift caused by synonyms with different names.

---
owner: `<role/agent>`
last_verified: `YYYY-MM-DD`
status: `Active | Deprecated | Draft`
freshness_check: `3 Months`
---

## Glossary (Ubiquitous Language)

| Term (Local) | Term (English) | Code Name/Entity | Definition (Business Meaning) | Allowed Synonyms | Banned Terms | Notes/Examples |
|---|---|---|---|---|---|---|
| Order | Order | Order | Transaction record created after a user completes payment | Order slip | Deal/Trade | Example: order number, order status |
| Customer | Customer | Customer | Individual or business that transacts with the platform | User | Account | Example: customer tier, customer profile |

## Domain Modeling Terms

> These terms are used in the domain model section of `design.md` to distinguish object types.

| Term | Definition | Identification Criteria | Examples |
|------|------------|-------------------------|----------|
| **Entity** | Object with a unique identifier, mutable state, and a lifecycle to track | 1) Has a business ID 2) State changes 3) Requires persistence | Order, Customer, Product |
| **Value Object** | Object without a unique identifier, immutable and descriptive | 1) No ID 2) Immutable 3) Freely copied/shared | Address, Money, DateRange, Email |
| **Invariant** | Business constraint that must always hold; any violation is a data error | 1) Cross-attribute constraint 2) Violation means data error | `order_total = SUM(line_item_amounts)`, `inventory >= 0` |
| **Business Rule** | Configurable or variable business policy with defined handling when violated | 1) May change with business 2) Has handling path when violated | `member_discount_rate`, `auto_cancel_after_timeout` |
| **ACL (Anti-Corruption Layer)** | Adapter layer that isolates external models from internal models | 1) External API entry point 2) Model translation logic | Payment gateway adapter, third-party logistics integration |
| **Bounded Context** | Autonomous business boundary with consistent terminology inside | 1) Independently deployable/evolvable 2) Clear term boundaries | Order context, catalog context, user context |

## Usage Rules

- Design/specs/tests/code must use terms from this table; do not invent new terms.
- If you need to add a term, update this file before writing design/spec/tests.
- **Entity vs Value Object**:
  - Ask "Does this object need a unique identifier?" -> Yes: Entity; No: Value Object.
  - Ask "Does this object's state change?" -> Yes: Entity; No: Value Object.
  - Ask "Are two objects equal when all properties match?" -> Yes: Value Object; No: Entity.
- **Invariant labeling**: Prefix `[Invariant]` in `design.md`; code should include a corresponding assertion.
