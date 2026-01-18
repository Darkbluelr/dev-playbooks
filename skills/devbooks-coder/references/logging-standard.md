# Logging Standard

This document defines standard conventions for application logs.

---

## 1) Log Levels

### Level Definitions

| Level | Purpose | Examples |
|-------|---------|----------|
| `ERROR` | Requires immediate attention | DB connection failure, external API error |
| `WARN` | Potential issue but main flow continues | Missing config using defaults, retry success |
| `INFO` | Key business milestones | User login, order created, service started |
| `DEBUG` | Development debugging info | Function inputs, intermediate state |
| `TRACE` | Very detailed tracing | Each row processed, loop iteration |

### Level Selection Guide

```typescript
// ERROR: system cannot operate normally
logger.error('Database connection failed', { error, retries: 3 });

// WARN: recoverable issue
logger.warn('Cache miss, falling back to database', { key });

// INFO: business milestone
logger.info('User registered', { userId, email });

// DEBUG: useful during development
logger.debug('Processing request', { params, headers });

// TRACE: very detailed trace
logger.trace('Row processed', { rowIndex, data });
```

---

## 2) Log Format

### Structured Logs

```typescript
// Recommended: structured logging
logger.info('Order created', {
  orderId: '12345',
  userId: 'user-789',
  amount: 99.99,
  currency: 'USD',
  items: 3
});

// JSON output (easy to parse)
{
  "timestamp": "2024-01-15T10:30:00.000Z",
  "level": "INFO",
  "message": "Order created",
  "orderId": "12345",
  "userId": "user-789",
  "amount": 99.99,
  "currency": "USD",
  "items": 3,
  "service": "order-service",
  "traceId": "abc-123-xyz"
}
```

### Required Fields

| Field | Description | Example |
|-------|-------------|---------|
| `timestamp` | ISO 8601 timestamp | `2024-01-15T10:30:00.000Z` |
| `level` | Log level | `INFO`, `ERROR` |
| `message` | Human-readable message | `User logged in` |
| `service` | Service name | `user-service` |
| `traceId` | Trace ID | `abc-123-xyz` |

### Optional Fields

| Field | Description | When to use |
|-------|-------------|-------------|
| `userId` | User identifier | When user context exists |
| `requestId` | Request ID | HTTP request handling |
| `duration` | Duration (ms) | Performance logs |
| `error` | Error details | ERROR logs |

---

## 3) Log Content Guidelines

### Message Style

```typescript
// Recommended: start with a verb, describe what happened
logger.info('User logged in', { userId });
logger.info('Order created', { orderId });
logger.info('Payment processed', { paymentId, amount });

// Avoid: vague messages
logger.info('Done');        // ❌ Done what?
logger.info('Error');       // ❌ What error?
logger.info('Processing');  // ❌ Processing what?
```

### Context Data

```typescript
// Recommended: include enough context
logger.error('Failed to process payment', {
  orderId: '12345',
  paymentMethod: 'credit_card',
  error: {
    code: 'DECLINED',
    message: 'Card declined by issuer'
  },
  retryCount: 2
});

// Avoid: missing context
logger.error('Payment failed');  // ❌ Which order? Why?
```

### Sensitive Data Handling

```typescript
// Forbidden: log sensitive data
logger.info('User login', {
  email: 'user@example.com',
  password: '123456'  // ❌ Never log this!
});

// Good: mask sensitive data
logger.info('User login', {
  email: maskEmail('user@example.com'),  // u***@example.com
  passwordProvided: true
});

// Masking helpers
function maskEmail(email: string): string {
  const [local, domain] = email.split('@');
  return `${local[0]}***@${domain}`;
}

function maskCreditCard(card: string): string {
  return `****-****-****-${card.slice(-4)}`;
}
```

**Never log**:

| Type | Examples |
|------|----------|
| Passwords | password, secret, token |
| Credentials | API key, access token |
| Personal data | government ID, bank card number |
| Sensitive business data | full card numbers, CVV |

---

## 4) Error Logging

### Error Structure

```typescript
logger.error('Operation failed', {
  operation: 'createOrder',
  error: {
    name: error.name,
    message: error.message,
    code: error.code,
    stack: error.stack  // only outside production
  },
  context: {
    userId: '12345',
    input: sanitize(input)  // sanitized input
  },
  recovery: 'Will retry in 5 seconds'
});
```

### Error Classification

```typescript
// Recoverable errors (WARN)
logger.warn('Temporary failure, retrying', {
  operation: 'fetchData',
  attempt: 2,
  maxAttempts: 3
});

// Non-recoverable errors (ERROR)
logger.error('Critical failure', {
  operation: 'saveData',
  error: error.message,
  action: 'Manual intervention required'
});
```

---

## 5) Performance Logs

### Duration Tracking

```typescript
// Track duration
const start = performance.now();
await processOrder(order);
const duration = performance.now() - start;

logger.info('Order processed', {
  orderId: order.id,
  duration: Math.round(duration),  // ms
  durationUnit: 'ms'
});

// Slow warning
if (duration > 1000) {
  logger.warn('Slow operation detected', {
    operation: 'processOrder',
    duration,
    threshold: 1000
  });
}
```

### Batch Operations

```typescript
logger.info('Batch processing completed', {
  operation: 'importUsers',
  total: 1000,
  success: 985,
  failed: 15,
  duration: 5230,
  avgPerItem: 5.23
});
```

---

## 6) Logging Configuration

### Environment Defaults

| Environment | Default Level | Output Format | Stack Trace |
|-------------|---------------|---------------|-------------|
| Development | DEBUG | Human-readable | Full |
| Staging | INFO | JSON | ERROR only |
| Production | INFO | JSON | ERROR only |

### Example Config

```typescript
// logger.config.ts
interface LoggerConfig {
  level: 'error' | 'warn' | 'info' | 'debug' | 'trace';
  format: 'json' | 'pretty';
  includeStack: boolean;
  service: string;
}

const config: LoggerConfig = {
  level: process.env.LOG_LEVEL || 'info',
  format: process.env.NODE_ENV === 'production' ? 'json' : 'pretty',
  includeStack: process.env.NODE_ENV !== 'production',
  service: process.env.SERVICE_NAME || 'app'
};
```

---

## 7) Logging Library Recommendations

### Node.js

```typescript
// Recommended: pino (high performance)
import pino from 'pino';

const logger = pino({
  level: 'info',
  formatters: {
    level: (label) => ({ level: label.toUpperCase() })
  },
  timestamp: () => `,\"timestamp\":\"${new Date().toISOString()}\"`
});

// Or: winston (feature rich)
import winston from 'winston';

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console()
  ]
});
```

### Browser

```typescript
// Simple wrapper
const logger = {
  error: (msg: string, data?: object) =>
    console.error(JSON.stringify({ level: 'ERROR', message: msg, ...data })),
  warn: (msg: string, data?: object) =>
    console.warn(JSON.stringify({ level: 'WARN', message: msg, ...data })),
  info: (msg: string, data?: object) =>
    console.info(JSON.stringify({ level: 'INFO', message: msg, ...data })),
  debug: (msg: string, data?: object) =>
    console.debug(JSON.stringify({ level: 'DEBUG', message: msg, ...data }))
};
```

---

## 8) Checklist

When writing logs, confirm:

- [ ] Is the level correct? (ERROR/WARN/INFO/DEBUG)
- [ ] Is the message clear? (verb-first, event description)
- [ ] Is context sufficient to locate the issue?
- [ ] Is sensitive data masked?
- [ ] Do error logs include stack traces (where appropriate)?
- [ ] Do performance logs include durations?
