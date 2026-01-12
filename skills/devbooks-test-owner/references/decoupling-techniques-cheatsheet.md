# Decoupling Techniques Cheat Sheet (8 High-Frequency Techniques)

> Source: *Working Effectively with Legacy Code* (selected techniques)
> Recommended roles: Test Owner / Coder

---

## Quick index

| # | Technique | One-line summary | Frequency | Best for |
|---|----------|------------------|-----------|----------|
| 1 | Extract Interface | Introduce an interface to isolate external dependencies | High | external services / DB / third-party APIs |
| 2 | Parameterize Constructor | Inject dependencies via constructor parameters | High | hard-coded deps, `new` in constructors |
| 3 | Subclass and Override | Override behavior in a test-only subclass | High | partial behavior replacement without editing original class |
| 4 | Introduce Static Setter | Add a setter for static/global dependencies | Medium | singletons / globals / static factories |
| 5 | Extract and Override Getter | Override a getter that returns a dependency | Medium | field dependencies / lazy initialization |
| 6 | Break Out Method Object | Extract a long method into a small object | Medium | long methods / complex algorithms |
| 7 | Adapt Parameter | Wrap/adapter for hard-to-mock parameter types | Low | hard-to-construct values, legacy types |
| 8 | Encapsulate Global References | Wrap global/environment access behind an adapter | Low | global state / env vars / time |

---

## 1) Extract Interface

### Problem
```python
class OrderService:
    def __init__(self):
        self._payment = PaymentGateway()   # hard-coded real gateway
        self._inventory = InventoryDB()    # hard-coded real DB

    def process(self, order):
        self._payment.charge(order.total)  # not testable: performs real charge
        self._inventory.deduct(order.items)
```

### Solution
```python
from typing import Protocol

# 1) Extract interfaces
class PaymentGatewayInterface(Protocol):
    def charge(self, amount) -> bool: ...

class InventoryInterface(Protocol):
    def deduct(self, items) -> None: ...

# 2) Inject via constructor
class OrderService:
    def __init__(self, payment: PaymentGatewayInterface, inventory: InventoryInterface):
        self._payment = payment
        self._inventory = inventory

# 3) In tests, inject mocks/fakes
def test_order_service_process():
    mock_payment = Mock(spec=PaymentGatewayInterface)
    mock_inventory = Mock(spec=InventoryInterface)
    service = OrderService(mock_payment, mock_inventory)
    service.process(order)
    mock_payment.charge.assert_called_once_with(order.total)
```

Key points:
- Interfaces define contracts; implementations become replaceable.
- Prefer injecting interfaces at boundaries (DB/network/filesystem/time).

---

## 2) Parameterize Constructor

### Problem
```python
class ReportGenerator:
    def __init__(self):
        self._db = DatabaseConnection()              # new dependency in constructor
        self._logger = FileLogger("/var/log/app.log")
```

### Solution
```python
class ReportGenerator:
    def __init__(self, db=None, logger=None):
        self._db = db or DatabaseConnection()        # defaults preserve compatibility
        self._logger = logger or FileLogger("/var/log/app.log")

def test_report_generator():
    generator = ReportGenerator(db=Mock(), logger=Mock())
```

Key points:
- Keep defaults to avoid breaking callers.
- Make “seams” explicit while keeping production behavior unchanged.

---

## 3) Subclass and Override

### Problem
```python
class PaymentProcessor:
    def process(self, payment):
        gateway = self._get_gateway()
        return gateway.charge(payment)

    def _get_gateway(self):
        return RealPaymentGateway()  # not replaceable in tests
```

### Solution
```python
class TestablePaymentProcessor(PaymentProcessor):
    def __init__(self, mock_gateway):
        self._mock_gateway = mock_gateway

    def _get_gateway(self):
        return self._mock_gateway

def test_process_uses_gateway():
    p = TestablePaymentProcessor(mock_gateway=Mock())
    p.process(payment)
```

Key points:
- Works when you can’t change the original class easily.
- Prefer this as a temporary seam; refactor toward DI when possible.

---

## 4) Introduce Static Setter

### Problem
```python
class Clock:
    now = datetime.utcnow  # static/global dependency
```

### Solution
```python
class Clock:
    _now = datetime.utcnow

    @staticmethod
    def now():
        return Clock._now()

    @staticmethod
    def set_now(fn):
        Clock._now = fn

def test_time_dependent_logic():
    Clock.set_now(lambda: fixed_time)
```

Key points:
- Use carefully; avoid leaking global state between tests.
- Always reset after tests.

---

## 5) Extract and Override Getter

### Problem
```python
class UserService:
    def __init__(self):
        self._repo = UserRepository()

    def get_user(self, user_id):
        return self._repo.get(user_id)
```

### Solution
```python
class UserService:
    def _get_repo(self):
        return self._repo

class TestableUserService(UserService):
    def __init__(self, repo):
        self._repo = repo

    def _get_repo(self):
        return self._repo
```

Key points:
- Use when direct constructor injection is blocked by legacy patterns.

---

## 6) Break Out Method Object

### Problem
```python
def calculate_invoice_total(invoice):
    # 200 lines of intertwined logic…
    ...
```

### Solution
```python
class InvoiceTotalCalculator:
    def __init__(self, invoice):
        self.invoice = invoice

    def compute(self):
        ...

def calculate_invoice_total(invoice):
    return InvoiceTotalCalculator(invoice).compute()
```

Key points:
- Easier unit testing and targeted seams.
- Enables incremental refactoring of long methods.

---

## 7) Adapt Parameter

### Problem
```python
def handle_request(req):
    # req is a complex framework type that is hard to construct
    ...
```

### Solution
```python
class RequestAdapter:
    def __init__(self, req):
        self._req = req

    def user_id(self):
        return self._req.headers.get("X-User-Id")

def handle_request(req):
    r = RequestAdapter(req)
    ...
```

Key points:
- Convert “hard-to-construct” objects into simple, test-friendly adapters.

---

## 8) Encapsulate Global References

### Problem
```python
import os

def load_config():
    return os.environ["APP_MODE"]
```

### Solution
```python
class Env:
    def get(self, key, default=None):
        return os.environ.get(key, default)

def load_config(env: Env):
    return env.get("APP_MODE", "dev")
```

Key points:
- Wrap time/random/env/FS/network behind injectable adapters.
- This is the foundation for deterministic testing.
