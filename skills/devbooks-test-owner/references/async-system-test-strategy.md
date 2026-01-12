# Async System Testing Strategy

> Use this checklist when testing systems involving message queues, event-driven workflows, eventual consistency, or distributed transactions.
>
> This document is **optional reference**. Use it only when your project is async/event-driven.

---

## 1) Testing challenges in async systems

### 1.1 Key challenges

| Challenge | Description | Testing strategy |
|----------|-------------|------------------|
| Non-deterministic timing | Message arrival order and timing vary | Use explicit waits + timeouts; avoid `sleep` |
| Eventual consistency | State converges over time | Poll assertions + explicit convergence conditions |
| Idempotency | Duplicate messages must not cause duplicate side effects | Send the same message multiple times; assert stable outcomes |
| Fault injection difficulty | Partitions / drops are hard to simulate | Use controllable test doubles |
| State spread | State lives across services/stores | Define a clear “system snapshot” method |

### 1.2 Adjusting the test pyramid

Async systems typically shift the pyramid:

```
        /\
       /  \  E2E (minimize; validate only critical journeys)
      /----\
     /      \  Contract Tests (focus: message contracts)
    /--------\
   /          \  Integration Tests (focus: handlers, retries, idempotency)
  /------------\
 /              \  Unit Tests (pure logic, no IO)
/----------------\
```

**Key differences:**
- Contract tests matter more: message formats, envelopes, schema compatibility
- Integration tests must cover: timeouts, retries, idempotency, out-of-order handling
- Be cautious with E2E: async E2E is prone to flaky tests

---

## 2) Eventual consistency tests

### 2.1 Pattern: poll with timeout

```python
# Recommended: explicit polling + timeout
def wait_for_eventual_consistency(
    condition_fn,        # returns True when converged
    timeout_ms=5000,     # max wait
    poll_interval_ms=100 # polling interval
):
    start = time.now()
    while time.now() - start < timeout_ms:
        if condition_fn():
            return True
        sleep(poll_interval_ms)
    return False

# Example: wait until order state syncs into the query service
assert wait_for_eventual_consistency(
    lambda: query_service.get_order(order_id).status == "PAID",
    timeout_ms=3000
)
```

### 2.2 Checklist

- [ ] Define a clear convergence condition (not “wait N seconds”)
- [ ] Use sensible timeouts (not too short/flaky; not too long/slow)
- [ ] Cover the “convergence failure” case (what happens on timeout?)
- [ ] Validate whether intermediate states are acceptable (what can users see while converging?)

### 2.3 What design.md should declare

```markdown
### Eventual consistency constraints
- Consistency window: < 5 seconds (99% of cases)
- User-visible intermediate behavior: show "processing"
- On convergence failure: trigger compensation / alerting
```

---

## 3) Idempotency tests

### 3.1 Pattern: consume the same message N times

```python
# Test: consuming the same message N times produces side effects only once
def test_idempotent_message_processing():
    message_id = "msg-001"
    order_id = "order-001"

    # Send the same message 3 times
    for _ in range(3):
        send_message(CreateOrderEvent(
            message_id=message_id,
            order_id=order_id,
            amount=100
        ))

    # Wait for processing
    wait_for_eventual_consistency(...)

    # Assert: exactly one order was created
    assert order_count(order_id) == 1
    # Assert: amount is correct (not 300)
    assert get_order(order_id).amount == 100
```

### 3.2 Checklist

- [ ] Each message has a unique `message_id` / `idempotency_key`
- [ ] Cover “exact same message re-consumed”
- [ ] Cover “retry after partial processing” (simulate failure mid-way)
- [ ] Validate idempotency-key storage (Redis/DB) TTL/retention strategy
- [ ] Validate concurrent duplicates (two identical messages arrive at once)

### 3.3 Implementation checks

| Check | Pass condition |
|------|----------------|
| Key generation | Client-generated; not server-derived |
| Key storage | Persisted with a reasonable TTL |
| When to check | Check **before** business processing |
| Duplicate response | Return the same result as the first (not an error) |

---

## 4) Ordering and out-of-order handling tests

### 4.1 Out-of-order scenarios

| Scenario | Example | Strategy |
|---------|---------|----------|
| Out-of-order events | “Order shipped” arrives before “Order created” | Buffer + reorder / reject + retry |
| Version conflicts | Old update overwrites a newer state | Version checks (LWW or reject) |
| Causal inversion | Child event arrives before parent | Dependency tracking + delayed processing |

### 4.2 Pattern

```python
# Test: out-of-order events are handled correctly
def test_out_of_order_events():
    order_id = "order-001"

    # Intentionally send in the wrong order
    send_message(OrderShippedEvent(order_id=order_id, version=2))
    send_message(OrderCreatedEvent(order_id=order_id, version=1))

    wait_for_eventual_consistency(...)

    # Assert: final state is correct
    order = get_order(order_id)
    assert order.status == "SHIPPED"
    assert order.version == 2
```

### 4.3 Checklist

- [ ] Declare ordering requirements: globally ordered / partition-ordered / unordered
- [ ] If ordered: use a partition key to enforce per-entity ordering
- [ ] If unordered: implement version/timestamp guards
- [ ] Cover “out-of-order arrival”
- [ ] Cover “version conflict”

---

## 5) Timeout and retry tests

### 5.1 Timeout pattern

```python
# Test: downstream timeout handling
def test_downstream_timeout():
    with mock_timeout(payment_service, timeout_ms=100):
        result = order_service.process_order(order_id)

    # Assert: degraded behavior after timeout
    assert result.status == "PENDING_PAYMENT"
    assert result.retry_scheduled == True
```

### 5.2 Retry pattern

```python
# Test: retry behavior is correct
def test_retry_with_exponential_backoff():
    attempt_times = []

    with mock_failure(payment_service, fail_count=2):
        with capture_attempts(payment_service, attempt_times):
            result = order_service.process_order(order_id)

    # Assert: retried 3 times (1 initial + 2 retries)
    assert len(attempt_times) == 3
    # Assert: exponential backoff
    assert attempt_times[1] - attempt_times[0] >= 100  # first retry
    assert attempt_times[2] - attempt_times[1] >= 200  # second retry
```

### 5.3 Checklist

- [ ] Every async operation has an explicit timeout
- [ ] Retries have a max-attempt limit (no infinite retry)
- [ ] Retries use exponential backoff (avoid retry storms)
- [ ] Cover “degrade after timeout”
- [ ] Cover “retry succeeds”
- [ ] Cover “retry exhausted”
- [ ] Validate idempotency under retries (no duplicate side effects)

---

## 6) Compensation transaction tests (Saga pattern)

### 6.1 Pattern

```python
# Test: correct compensation on partial failure
def test_saga_compensation():
    order_id = "order-001"

    # Simulate: inventory reserve succeeds, payment fails
    with mock_success(inventory_service):
        with mock_failure(payment_service):
            result = order_service.create_order(order_id)

    wait_for_eventual_consistency(...)

    # Assert: order failed
    assert get_order(order_id).status == "FAILED"
    # Assert: inventory rollback happened
    assert get_inventory_reserved(order_id) == 0
    # Assert: compensation log exists
    assert compensation_log_exists(order_id, "INVENTORY_ROLLBACK")
```

### 6.2 Checklist

- [ ] Every compensatable action has a corresponding compensation action
- [ ] Compensation actions themselves are idempotent
- [ ] Cover every “mid-chain failure” point
- [ ] Cover “compensation fails”
- [ ] Validate compensation order (reverse order)
- [ ] Validate compensation logs/audit trails

---

## 7) Test doubles for async systems

### 7.1 Queue test doubles

| Double type | Use case | Implementation notes |
|------------|----------|----------------------|
| In-memory queue | Unit/integration | In-memory queue, synchronous delivery |
| Controllable queue | Fault injection | Control delay, drop, duplicate |
| Record & replay | Regression | Record production messages and replay offline |

### 7.2 Checklist

- [ ] Double shares the same interface as the real system
- [ ] Can control delivery delay
- [ ] Can simulate message drops
- [ ] Can simulate duplicates
- [ ] Can simulate out-of-order delivery
- [ ] Can inject handler failures

---

## 8) verification.md supplement template

If your `verification.md` includes async-system tests, add the following section:

```markdown
### Async system test checks (if applicable)

#### Eventual consistency
- [ ] Define consistency window: < X seconds
- [ ] Cover "converges successfully"
- [ ] Cover "converges timeout"

#### Idempotency
- [ ] Messages include `idempotency_key`
- [ ] Cover "duplicate messages are processed once"
- [ ] Cover "concurrent duplicate messages"

#### Ordering
- [ ] Declare ordering requirement: global / partition / none
- [ ] Cover "out-of-order messages"

#### Timeouts and retries
- [ ] Declare timeout: X ms
- [ ] Declare retry strategy: max N attempts, exponential backoff
- [ ] Cover "degrade on timeout"
- [ ] Cover "retry success / retry exhausted"

#### Compensation (if applicable)
- [ ] Define compensation operations
- [ ] Cover "compensates on partial failure"
- [ ] Validate compensation idempotency
```

---

## 9) Common flaky test patterns and fixes

| Flaky pattern | Root cause | Fix |
|-------------|------------|-----|
| Fixed `sleep` | Too short/long timing assumptions | Use polling + timeout |
| Order-dependent assertions | Parallel consumption causes reorder | Design idempotency or add explicit ordering |
| Shared state across tests | Tests affect each other | Use isolated data per test |
| Time-sensitive assertions | Depend on wall clock | Inject a controllable clock |
| Resource contention | Port/file conflicts | Allocate dynamically or isolate environments |
