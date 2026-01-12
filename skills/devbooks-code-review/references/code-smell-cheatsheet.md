# Core Code Smells Cheat Sheet (Top 8 + Module Cycles)

> Source: *Refactoring: Improving the Design of Existing Code (2nd Edition)* (debate-revised summary)
> This reduces the original 22 smells down to 8 high-frequency, high-impact smells for day-to-day reviews.

---

## Quick Index

| # | Smell | One-line description | Severity |
|---|-------|----------------------|----------|
| 1 | Duplicated Code | The same logic appears in multiple places | Blocker |
| 2 | Long Method | A function is too long to understand easily | Blocker |
| 3 | Large Class | A class takes on too many responsibilities | Warning |
| 4 | Long Parameter List | Too many parameters make calls fragile | Blocker |
| 5 | Divergent Change | One class changes for multiple reasons | Warning |
| 6 | Shotgun Surgery | One change requires touching many places | Blocker |
| 7 | Feature Envy | A method depends too much on another class | Warning |
| 8 | Primitive Obsession | Domain concepts are modeled as primitives | Warning |
| 9 | **Module Cycle** | A→B→A blocks independent build/test | **Blocker** |

---

## 1. Duplicated Code

**Signals:**
- Similarity > 80% appears in 2+ places
- Copy/paste with only variable names changed
- Duplicate logic across sibling subclasses

**Why it matters:**
- Easy to miss one site when changing behavior
- Increases code size and reduces readability
- Violates DRY

**Refactorings:**
1. **Duplicates within one class** → Extract Method
2. **Duplicates across sibling subclasses** → Extract Method → Pull Up Method
3. **Duplicates across unrelated classes** → Extract Class (shared component)

**Example:**
```python
# Smell: duplicated validation logic
def create_user(email):
    if not email or '@' not in email:
        raise ValueError("Invalid email")
    # ...

def update_email(email):
    if not email or '@' not in email:  # duplicated!
        raise ValueError("Invalid email")
    # ...

# Refactor: extract a helper
def validate_email(email):
    if not email or '@' not in email:
        raise ValueError("Invalid email")

def create_user(email):
    validate_email(email)
    # ...
```

---

## 2. Long Method

**Signals:**
- **P95 < 50 lines** (use as a discussion trigger, not a hard rule)
- You need to scroll to read the full function
- The function contains large comment blocks explaining “what this part does”
- Cyclomatic complexity > 10

**Why it matters:**
- Hard to understand the overall intent
- Hard to test (too many branches)
- Hard to reuse partial logic

**Refactorings:**
1. **Comments are a signal** → Extract Method (use the comment as the method name)
2. **Too many temporaries** → Replace Temp with Query
3. **Complex conditionals** → Decompose Conditional

**Example:**
```python
# Smell: long method
def process_order(order):
    # validate order
    if not order.items:
        raise ValueError("Empty order")
    if order.total < 0:
        raise ValueError("Invalid total")

    # calculate discount
    discount = 0
    if order.customer.is_vip:
        discount = order.total * 0.1
    elif order.total > 1000:
        discount = order.total * 0.05

    # update inventory
    for item in order.items:
        stock = get_stock(item.product_id)
        stock.quantity -= item.quantity
        save_stock(stock)

    # ... 50 more lines

# Refactor: extract helpers
def process_order(order):
    validate_order(order)
    discount = calculate_discount(order)
    update_inventory(order)
    # ...
```

---

## 3. Large Class

**Signals:**
- **P95 < 500 lines**
- > 10 instance fields
- > 20 methods
- Multiple groups of fields with shared prefixes (e.g., `billing_*`, `shipping_*`)

**Why it matters:**
- Violates SRP (Single Responsibility Principle)
- Hard to test (too many dependencies)
- Change impact becomes unpredictable

**Refactorings:**
1. **Responsibilities can be separated** → Extract Class
2. **There are true subtypes** → Extract Subclass
3. **Consumers only need a subset** → Extract Interface

---

## 4. Long Parameter List

**Signals:**
- More than 5 parameters
- Call sites often mix up parameter order
- Multiple functions share the same parameter “bundle”

**Why it matters:**
- Easy to pass the wrong argument
- Hard to remember the signature
- The bundle is often a hidden domain concept

**Refactorings:**
1. **Arguments can be obtained from an object** → Preserve Whole Object
2. **Arguments always travel together** → Introduce Parameter Object

**Example:**
```python
# Smell: too many parameters
def create_address(street, city, state, zip_code, country, apt_number):
    pass

# Refactor: introduce a parameter object
@dataclass
class Address:
    street: str
    city: str
    state: str
    zip_code: str
    country: str
    apt_number: str = None

def create_address(address: Address):
    pass
```

---

## 5. Divergent Change

**Signals:**
- Database changes require editing this class
- UI changes also require editing this class
- Business rule changes require editing this class too
- “Every requirement change touches this file”

**Why it matters:**
- One class carries multiple change axes
- Unrelated edits interfere with each other
- Hard to test one dimension in isolation

**Refactorings:**
- Extract Class (split by reason-to-change)

**Compared to Shotgun Surgery:**
- Divergent Change: one class responds to many changes
- Shotgun Surgery: one change requires touching many classes
- They are dual problems with opposite fixes

---

## 6. Shotgun Surgery

**Signals:**
- One requirement forces edits in 3+ classes/files
- “Fixing one place means changing lots of other places”
- Easy to miss one spot and ship a bug

**Why it matters:**
- Changes are easy to overlook
- Logic is scattered and hard to reason about
- Test coverage becomes expensive

**Refactorings:**
1. **Logic should be centralized** → Move Method / Move Field
2. **Over-fragmented code** → Inline Class (merge first, then re-split intentionally)

---

## 7. Feature Envy

**Signals:**
- A method calls other classes more than it uses its own class
- A method reads many fields from another class
- “This method feels like it belongs elsewhere”

**Why it matters:**
- Violates “data and behavior belong together”
- Increases coupling
- Blurs responsibility boundaries

**Refactorings:**
- Move Method (move closer to the data it uses)

**Common exceptions (not Feature Envy):**
- Strategy pattern (strategy accessing context)
- Visitor pattern (visitor accessing elements)
- If this is intentional, document it as a pattern choice

---

## 8. Primitive Obsession

**Signals:**
- `string` used for phone numbers, emails, money
- `int` used for status codes or type codes
- Business rules are duplicated across the codebase (e.g., email validation)

**Why it matters:**
- Poor type safety (a `string` can be anything)
- Business rules can’t be centralized
- Domain language drifts away from the project glossary

**Refactorings:**
- Replace Data Value with Object
- Replace Type Code with Class/Subclass

**Scope guidance (debate-revised):**
- **Must encapsulate:** domain concepts (Money, Email, UserId, PhoneNumber)
- **Optional encapsulation:** technical types (coordinates, colors, simple configs)

**Example:**
```python
# Smell: primitives used for domain concepts
def transfer(from_account: str, to_account: str, amount: float):
    pass  # amount can be negative? which currency?

# Refactor: encapsulate into a value object
@dataclass(frozen=True)
class Money:
    amount: Decimal
    currency: str

    def __post_init__(self):
        if self.amount < 0:
            raise ValueError("Amount cannot be negative")

def transfer(from_account: AccountId, to_account: AccountId, amount: Money):
    pass
```

---

## Smells Removed (after debate)

The following concepts were removed after an Advocate/Skeptic/Judge debate:

| Original smell | Why it was removed |
|---------------|--------------------|
| Parallel Inheritance Hierarchies | Deep inheritance is rare in modern codebases |
| Lazy Class | Conflicts with SRP; small classes can be good design |
| Speculative Generality | Too subjective to enforce consistently |
| Temporary Field | Low frequency in typical codebases |
| Message Chains | Fluent functional chains are common now |
| Middle Man | Can be a valid anti-corruption layer in layered designs |
| Alternative Classes with Different Interfaces | Typically covered by terminology/interface consistency checks |
| Incomplete Library Class | Third-party code can’t be refactored |
| Data Class | DTO layers often intentionally allow anemic structures |
| Refused Bequest | Inheritance usage has declined significantly |
| Comments | “Why” comments can be valuable |

---

## Quick Decision Flow

```
Spot suspicious code
    |
    +-- Duplicate? ------------------> Extract Method
    |
    +-- Function > 50 lines? --------> Extract Method + Decompose Conditional
    |
    +-- Class > 500 lines? ----------> Extract Class
    |
    +-- Parameters > 5? -------------> Introduce Parameter Object
    |
    +-- One change touches many? ----> Move Method/Field (centralize logic)
    |
    +-- One class changes for many reasons?
    |                               -> Extract Class (split change axes)
    |
    +-- Method uses other class a lot?
    |                               -> Move Method
    |
    +-- Domain concepts are strings?
                                    -> Replace Data Value with Object
```

---

## 9. Module Cycle

> Source: *Clean Architecture* (debate-revised) — a consensus “keep” rule

**Signals:**
- Module A depends on B, and B depends on A (direct cycle)
- Indirect cycles like A→B→C→A
- You can’t build/test a module independently
- “Changing one module forces changing another”

**Why it matters:**
- Blocks independent testing (you must mock multiple sides)
- Blocks independent deployment/release
- Strong signal of architecture erosion
- Refactor cost grows nonlinearly

**Detection tools:**
```bash
# JavaScript/TypeScript
npx madge --circular src/

# Java
jdeps -R -summary target/classes | grep cycle

# Go
go mod graph | tsort 2>&1 | grep -i cycle

# Python
pydeps --show-cycles src/
```

**Refactorings:**
1. **Dependency inversion** → extract interfaces into a separate module; both sides depend on the interface
2. **Callbacks/events** → A calls B, and B notifies A via callback/event instead of direct dependency
3. **Extract a shared module** → move common dependencies into module C

**Example:**
```python
# Smell: cyclic imports
# order.py
from payment import PaymentService  # Order → Payment

# payment.py
from order import Order  # Payment → Order (cycle!)

# Refactor: dependency inversion
# interfaces.py (independent module)
class OrderInterface(ABC):
    @abstractmethod
    def get_total(self) -> Money: ...

# order.py
class Order(OrderInterface):  # implements the interface
    pass

# payment.py
from interfaces import OrderInterface  # depend on the interface only
class PaymentService:
    def charge(self, order: OrderInterface): ...
```

**CI integration suggestion:**
```yaml
# .github/workflows/ci.yml
- name: Check circular dependencies
  run: |
    npx madge --circular src/ && echo "No cycles found" || exit 1
```

---

## References

- *Refactoring: Improving the Design of Existing Code* (2nd Edition) — Martin Fowler
- *Clean Architecture* — Robert C. Martin (Chapter: Component Coupling)
- Dev Playbooks debate-revised evaluation notes
- `devbooks-code-review` checklists

---

## 10. VS Code-style Code Hygiene Checks

> Inspired by VS Code custom ESLint rules as automated review items.

### Do-not-commit patterns (Blocker)

| Pattern | Detection command | Why it matters |
|---------|-------------------|----------------|
| `test.only` / `describe.only` | `rg '\\.only\\s*\\(' tests/` | Skips other tests |
| `console.log` / `console.debug` | `rg 'console\\.(log\\|debug)' src/` | Debug leftovers |
| `debugger` | `rg 'debugger' src/` | Breakpoints left in code |
| `@ts-ignore` | `rg '@ts-ignore' src/` | Hides type errors |
| `as any` | `rg 'as any' src/` | Bypasses type safety |
| `TODO` without an issue | `rg 'TODO(?!.*#\\d+)' src/` | Untracked work |

### Resource management checks (Warning)

| Pattern | How to detect | Preferred fix |
|---------|---------------|---------------|
| Non-`readonly` `DisposableStore` | `rg 'private\\s+(?!readonly)\\s*_?\\w*[Dd]isposable'` | Use `readonly` |
| `dispose()` missing `super.dispose()` | Review `override dispose` | Must call `super.dispose()` |
| `setInterval` without cleanup | Find `setInterval` without `clearInterval` | Clear in `dispose()` |
| Listener without removal | Find `addEventListener` without `removeEventListener` | Use `AbortController` |

### Layering constraints checks

```bash
# Verify forbidden cross-layer imports
# base must not depend on platform/editor/workbench
rg "from ['\\\"](vs/(platform|editor|workbench))" src/vs/base/

# platform must not depend on editor/workbench
rg "from ['\\\"](vs/(editor|workbench))" src/vs/platform/

# common must not depend on browser/node
rg "from ['\\\"].*(browser|node)" src/**/common/
```

### Type safety checks

```typescript
// Avoid: empty-object assertions
const config = {} as Config;  // bad

// Avoid: non-null assertions
const name = user!.name;  // bad

// Avoid: any
function process(data: any) { }  // bad

// Prefer: unknown or concrete types
function process(data: unknown) { }  // ok
```

### Automation script example

```bash
#!/usr/bin/env bash
# hygiene-check.sh

set -euo pipefail

echo "=== Code hygiene checks ==="

# 1) Debugging statements
if rg -l 'console\\.(log|debug)|debugger' src/ --type ts 2>/dev/null; then
  echo "ERROR: found debugging statements"
  exit 1
fi

# 2) test.only / describe.only
if rg -l '\\.only\\s*\\(' tests/ --type ts 2>/dev/null; then
  echo "ERROR: found test.only / describe.only"
  exit 1
fi

# 3) @ts-ignore occurrences
count=$(rg -c '@ts-ignore' src/ --type ts 2>/dev/null | wc -l)
if [ "${count}" -gt 0 ]; then
  echo "WARN: found ${count} files with @ts-ignore"
fi

# 4) any occurrences
count=$(rg -c ': any[^a-z]' src/ --type ts 2>/dev/null | wc -l)
if [ "${count}" -gt 0 ]; then
  echo "WARN: found ${count} files with ': any'"
fi

echo "OK: hygiene checks passed"
```
