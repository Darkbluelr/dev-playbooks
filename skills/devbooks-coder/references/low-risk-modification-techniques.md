# Low-Risk Modification Techniques Cheat Sheet

> Source: *Working Effectively with Legacy Code* - Michael Feathers  
> Role: Coder (implementation owner)

---

## Applicable Scenarios

When the Coder needs to add features or fix bugs in legacy code with constraints:
- High time pressure, no large refactor possible
- Insufficient test coverage, high change risk
- Must preserve existing behavior

---

## Core Principles

| Principle | Description |
|----------|-------------|
| **Behavior preservation** | Changes must keep existing behavior intact |
| **Minimal intrusion** | Modify original code as little as possible; add around it |
| **Testability first** | New code must be testable even if old code is not |
| **Leverage the compiler** | Change signatures and let compile errors reveal call sites |

---

## 1. Sprout Method

### Definition
When adding new functionality, do not modify the original method. **Create a new method** and call it from the original method.

### When to Use
- You need to add logic in the middle of a method
- The original method is long or hard to test
- The new logic is relatively independent

### Steps
1. Identify where new code should be inserted
2. Extract new logic into a separate method
3. Write tests for the new method
4. Call the new method from the original location

### Example

```python
# Original code (hard to test)
class OrderProcessor:
    def process(self, order):
        # 100 lines of legacy code...
        total = self._calculate_total(order)
        # need to add discount logic here
        self._save_order(order, total)
        # 50 more lines...

# After Sprout Method
class OrderProcessor:
    def process(self, order):
        # 100 lines of legacy code... (unchanged)
        total = self._calculate_total(order)
        discounted_total = self._apply_discount(order, total)  # new call
        self._save_order(order, discounted_total)  # param adjusted
        # 50 more lines... (unchanged)

    def _apply_discount(self, order, total):  # new method, independently testable
        if order.customer.is_vip:
            return total * 0.9
        return total
```

### Benefits
- New code is 100% testable
- Minimal changes to old code (one call line)
- Risk isolated: new logic bugs do not affect original logic

---

## 2. Sprout Class

### Definition
When new functionality needs multiple methods or state, **create a new class** to encapsulate it, then instantiate/use it in the original code.

### When to Use
- New functionality is complex and requires multiple methods
- New functionality needs state
- Original class is already large (>500 lines)

### Steps
1. Create a new class that implements the new functionality
2. Write full tests for the new class
3. Instantiate the new class in the original code
4. Call the new class methods

### Example

```python
# New standalone class (fully testable)
class DiscountCalculator:
    def __init__(self, discount_rules: list[DiscountRule]):
        self._rules = discount_rules

    def calculate(self, order, original_total):
        discount = 0
        for rule in self._rules:
            discount += rule.apply(order, original_total)
        return original_total - discount

# Use it in original code
class OrderProcessor:
    def __init__(self):
        self._discount_calc = DiscountCalculator(self._load_rules())

    def process(self, order):
        # legacy code...
        total = self._calculate_total(order)
        discounted = self._discount_calc.calculate(order, total)  # new class
        self._save_order(order, discounted)
```

### Benefits
- New class is fully independent and testable
- Clear responsibility, avoids bloating the original class
- Extensible for future rules

---

## 3. Wrap Method

### Definition
Do not change the original method implementation. **Create a new wrapper method** that calls the original and adds pre/post logic.

### When to Use
- Add logic before/after method execution (logging, validation, caching)
- Preserve original signature and caller transparency
- Follow open/closed principle

### Steps
1. Rename the original method (e.g., `pay` -> `_pay_impl`)
2. Create a new method with the original name
3. In the new method, call the original and add pre/post logic

### Example

```python
# Original code
class PaymentService:
    def pay(self, order, amount):
        # payment logic...
        return result

# After Wrap Method
class PaymentService:
    def pay(self, order, amount):  # external call unchanged
        self._log_payment_start(order, amount)  # pre-logic
        result = self._pay_impl(order, amount)  # original logic
        self._log_payment_end(order, result)    # post-logic
        return result

    def _pay_impl(self, order, amount):  # renamed original
        # original payment logic (unchanged)
        return result
```

### Benefits
- Original logic untouched
- Callers unchanged
- Pre/post logic testable independently

---

## 4. Wrap Class (Decorator)

### Definition
Create a new class that **wraps the original class**, adding logic around method calls (decorator pattern).

### When to Use
- Original class cannot be modified (third-party)
- Add cross-cutting concerns (logging, caching, auth)
- Keep original class unchanged

### Steps
1. Create wrapper class holding the original instance
2. Implement the same interface
3. Add logic then delegate to the original

### Example

```python
# Original class (third-party, cannot modify)
class LegacyPaymentGateway:
    def process(self, payment):
        # complex legacy logic...
        return result

# Wrap Class
class AuditedPaymentGateway:
    def __init__(self, gateway: LegacyPaymentGateway, audit_log: AuditLog):
        self._gateway = gateway
        self._audit = audit_log

    def process(self, payment):  # same interface
        self._audit.log_start(payment)
        try:
            result = self._gateway.process(payment)  # delegate
            self._audit.log_success(payment, result)
            return result
        except Exception as e:
            self._audit.log_failure(payment, e)
            raise
```

### Benefits
- Original class unchanged
- Multiple wrappers can be composed (cache + log + retry)
- Open/closed principle compliant

---

## 5. Decision Flow

```
Need to add/modify functionality
      |
      v
┌─────────────────────────┐
| Is the new feature separable? |
└───────────┬─────────────┘
       ┌────┴────┐
       v         v
      Yes        No
       |         |
       v         v
 ┌──────────┐  ┌────────────────────┐
 | Needs state? |  | Add before/after? |
 └────┬─────┘  └────────┬──────────┘
   ┌──┴──┐          ┌───┴───┐
   v     v          v       v
  Yes    No         Yes     No
   |     |           |       |
   v     v           v       v
Sprout  Sprout     Wrap    Add in middle
Class   Method     Method  of method
                  or         |
                 Wrap        v
                 Class     Sprout
                          Method
```

---

## 6. Working with Test Owner

| Coder Action | Test Owner Needed |
|-------------|-------------------|
| Use Sprout Method/Class | Test Owner writes tests for new method/class |
| Use Wrap Method/Class | Test Owner validates behavior unchanged |
| Need decoupling for tests | Refer to "Decoupling Techniques Cheat Sheet" |
| Changes affect multiple callers | Refer to Impact Analysis Pinch Points |

---

## 7. Prohibited Behaviors

- **Forbidden**: directly modify core legacy logic (unless fully covered by tests)
- **Forbidden**: "incidental refactors" unrelated to the change
- **Forbidden**: delete seemingly unused code (may have hidden dependencies)
- **Forbidden**: modify `tests/**` (must hand back to Test Owner)

---

## References

- *Working Effectively with Legacy Code* chapters 6–8
- "Decoupling Techniques Cheat Sheet"
- dev-playbooks `devbooks-coder/SKILL.md`
