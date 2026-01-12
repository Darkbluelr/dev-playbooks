# Microservice Design Checklist

> Use this checklist when the design involves microservices or distributed architecture.
>
> This document is **optional guidance**; use it only when the project truly involves microservices/distributed systems.

---

## 1) RPC Location Transparency Trap (must check)

**Core principle**: a remote call is not a local function call—do not hide the complexity.

### 1.1 The design doc must declare

- [ ] **Timeout policy**: timeout per RPC call (recommended 1–5 seconds)
- [ ] **Retry policy**: max retries, backoff interval, exponential backoff
- [ ] **Degradation strategy**: behavior when a dependency is unavailable (defaults/cache/error codes)
- [ ] **Circuit breaker threshold**: failure rate that triggers breaking (recommended 50%)

### 1.2 Anti-pattern checks

| Anti-pattern | Problem | Correct approach |
|--------|------|----------|
| RPC without timeouts | One slow service drags down the whole chain | set explicit timeouts (1–5s) |
| Infinite retries | retry storms overwhelm downstream | max 3 retries with exponential backoff |
| Synchronous call chaining | A→B→C→D accumulates latency | async or parallelize |
| Hidden remote calls | caller doesn’t know it’s network IO | make fallibility explicit in API names/types |

### 1.3 Test Owner checklist

- [ ] Tests cover dependency timeouts (mock timeouts)
- [ ] Tests cover dependency error responses
- [ ] Tests cover degraded behavior after circuit breaking
- [ ] Tests cover retry logic (verify max retries)

---

## 2) Distributed Failure Impact Assessment

### 2.1 Failure mode list

| Failure type | Blast radius | Detection | Recovery strategy |
|----------|----------|----------|----------|
| Network partition | service A can’t reach service B | health-check timeouts | circuit breaker + degrade |
| Node crash | single-node outage | heartbeat failures | load-balancer failover |
| Slow responses | end-to-end latency increases | p99 latency alerts | rate-limit + queue |
| Data inconsistency | replicas out of sync | reconciliation jobs | retry + compensation |

### 2.2 The design doc must declare

- [ ] Which inter-service dependencies are involved?
- [ ] What is the blast radius for each dependency failure?
- [ ] What user-visible behavior occurs under failure?
- [ ] Do we need chaos testing / failure drills?

---

## 3) Distributed Tracing

### 3.1 Design requirements

- [ ] All RPC calls propagate `trace_id`
- [ ] Logs include `trace_id`
- [ ] Events/messages include `trace_id`

### 3.2 Implementation checks

```
Headers: `X-Trace-Id` / `X-Request-Id`
Log format: `{"trace_id": "xxx", "message": "...", "timestamp": "..." }`
Message fields: `{"trace_id": "xxx", "event_type": "...", "payload": {...} }`
```

### 3.3 Test Owner checklist

- [ ] Tests verify trace_id is propagated across services
- [ ] Tests verify logs include trace_id
- [ ] Tests verify error logs can be traced back to the originating request via trace_id

---

## 4) Inter-service Contract Management

### 4.1 Contract definition requirements

- [ ] Use OpenAPI/Proto/AsyncAPI to define contracts
- [ ] Contract files are version-controlled
- [ ] Contract changes go through compatibility checks

### 4.2 Contract testing requirements

- [ ] Provider-side contract tests (implementation matches contract)
- [ ] Consumer-side contract tests (consumer assumptions are correct)
- [ ] Both sides run tests on contract changes

### 4.3 Breaking change handling

- [ ] Do not delete published APIs directly
- [ ] Run old and new versions in parallel for at least 2 release cycles
- [ ] Provide a migration guide and deprecation timeline

---

## 5) Exactly-once and Idempotency

### 5.1 Choosing delivery semantics

| Semantics | Use case | Implementation complexity |
|------|----------|------------|
| at-most-once | logs/telemetry (loss allowed) | Low |
| at-least-once | notifications/analytics (duplicates allowed) | Medium |
| exactly-once | payments/orders (no loss or duplicates) | High |

### 5.2 Exactly-once implementation checklist

- [ ] Messages include a unique `message_id`
- [ ] Consumers persist processed `message_id` (DB/Redis)
- [ ] Duplicate messages return success (idempotent handling)
- [ ] Tests cover: consume the same message 3 times, execute side effects only once

### 5.3 Test Owner checklist

- [ ] Tests verify duplicates do not cause duplicate side effects
- [ ] Tests verify retry succeeds after message loss
- [ ] Tests verify partial failure compensation works correctly

---

## 6) Design Doc Template Additions

In the “Target Architecture” section of `design.md`, add:

```markdown
### Microservice Design Constraints (if applicable)

#### Service dependency sketch
- This service → Dependency Service A (timeout 3s, retries 2, degrade to empty list)
- This service → Dependency Service B (timeout 5s, retries 0, degrade to cached value)

#### Failure modes and degradation
| Failure scenario | User-visible behavior | Recovery strategy |
|----------|--------------|----------|
| Service A unavailable | show “no data” | circuit-break 60s then retry |
| Service B slow | use cached data | rate-limit when p99 > 1s |

#### Tracing requirements
- All APIs propagate `X-Trace-Id`
- Logs are JSON and include `trace_id`
```
