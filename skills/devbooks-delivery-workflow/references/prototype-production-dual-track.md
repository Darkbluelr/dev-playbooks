# Prototype–Production Dual Track

> Source: *The Mythical Man-Month*, Ch. 11 “Plan to Throw One Away” — “the first system you build is never right… plan to throw one away”

## Core idea

The **prototype track** is for fast technical feasibility validation and produces a “throwaway first version”.

The **production track** is for shipping high-quality code, with tests/gates as the Definition of Done.

The two tracks are **physically isolated**, connected via an explicit “promote” workflow.

---

## When to use the prototype track

| Scenario | Signal | Recommendation |
|---------|--------|----------------|
| Technical uncertainty | “not sure this library works” / “uncertain feasibility” | ✅ prototype |
| First time doing it | “first time building this” / “expect rewrite” | ✅ prototype |
| Behavior exploration | “need to observe real API responses” | ✅ prototype |
| Requirements clear | design is decided, ACs defined | ❌ go straight to production track |
| Small changes | bug fix, config tweak | ❌ go straight to production track |

---

## Dual-track workflow diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Proposal phase                           │
│  proposal.md (shared)                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────┴───────────────┐
              │                               │
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │  Prototype track │             │ Production track │
    │   (Prototype)    │             │   (Production)   │
    ├─────────────────┤             ├─────────────────┤
    │ prototype/src/   │             │ design.md        │
    │ prototype/       │             │ tasks.md         │
    │   characterization/│           │ verification.md  │
    │ PROTOTYPE.md     │             │ tests/**         │
    ├─────────────────┤             ├─────────────────┤
    │ Characterization │             │ Acceptance tests │
    │ (record behavior)│             │ (verify intent)  │
    │ No Red baseline  │             │ Red baseline req │
    └────────┬────────┘             └────────┬────────┘
             │                                │
             │                                │
             ▼                                │
    ┌─────────────────┐                       │
    │ Learn & decide   │                       │
    │ promote or drop? │                       │
    └────────┬────────┘                       │
             │                                │
     ┌───────┴───────┐                        │
     ▼               ▼                        │
 [promote]         [drop]                     │
     │               │                        │
     ▼               ▼                        │
prototype-promote.sh  delete prototype/        │
     │               └─────────────────────►──┤
     │                                        │
     └────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │  Archive phase   │
                    │   (Archive)      │
                    └─────────────────┘
```

---

## Characterization tests vs acceptance tests

| Dimension | Acceptance tests | Characterization tests |
|----------|------------------|------------------------|
| **Purpose** | assert “what it should be” | assert “what it actually is” |
| **Source** | design doc / AC-xxx | observation/runtime behavior |
| **Baseline** | must start Red | starts Green |
| **Track** | production | prototype |
| **Use** | validate intent | capture behavior snapshots |
| **CI** | in main pipeline | skipped/isolated |

### Characterization test naming conventions

```
# Python
test_characterize_<behavior>.py
@pytest.mark.characterization

# TypeScript/JavaScript
*.characterization.test.ts
describe.skip('characterization: <behavior>')
```

---

## Role isolation (unchanged)

In prototype mode, role isolation is **the same** as the production track:

| Role | Responsibility | Must not |
|------|----------------|----------|
| Test Owner | produce characterization tests | share context with Coder |
| Coder | produce prototype code | modify characterization/ |

---

## Prototype promotion checklist

Before running `prototype-promote.sh <change-id>`, you must complete:

- [ ] Create production-grade `design.md` (distill What/Constraints/AC-xxx from prototype learnings)
- [ ] Test Owner produces acceptance verification in `verification.md` (replacing characterization tests)
- [ ] Complete the promotion checklist in `prototype/PROTOTYPE.md`
- [ ] Record technical findings in `prototype/PROTOTYPE.md` under “learning log”

---

## Prototype drop checklist

If you decide to drop the prototype:

- [ ] Record key learnings into the Decision Log in `proposal.md`
- [ ] Delete the `prototype/` directory
- [ ] Optional: retain learnings under `<truth-root>/_meta/lessons-learned/`

---

## Script references

| Script | Purpose | Example |
|--------|---------|---------|
| `change-scaffold.sh --prototype` | create prototype scaffold | `change-scaffold.sh feat-001 --prototype` |
| `prototype-promote.sh` | promote prototype to production track | `prototype-promote.sh feat-001` |

---

## FAQ

### Q: Can prototype code be used directly for production?

No. Prototype code is physically isolated under `prototype/src/` and must not be copied directly into repo production code. Promotion must be explicit via `prototype-promote.sh`.

### Q: Do characterization tests run in CI?

No. Characterization tests are marked `@characterization` and skipped by default. During promotion they should be archived to `tests/archived-characterization/`.

### Q: Do we need to write design.md during the prototype phase?

No. If you decide to promote, then distill prototype learnings into a production-grade `design.md`.

### Q: Can we skip prototype and go straight to production?

Yes. If requirements and technical approach are clear, go directly to the production track.

---

## References

- *The Mythical Man-Month*, Ch. 11 “Plan to Throw One Away”
- Michael Feathers, *Working Effectively with Legacy Code* — Characterization Tests
- Martin Fowler, “Is High Quality Software Worth the Cost?”
