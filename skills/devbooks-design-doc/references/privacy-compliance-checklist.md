# Telemetry Privacy & Compliance Checklist

This document defines privacy/compliance requirements for telemetry data.

---

## 1) GDPR classification requirements

When `design.md` or a spec delta includes telemetry, you **must** fill in the following fields:

```markdown
## Telemetry Design

### GDPR Classification

| Field | Value | Notes |
|------|-----|------|
| **owner** | @username | data owner (must be a team member) |
| **isMeasurement** | true/false | whether it’s measurement data (non-PII) |
| **purpose** | PerformanceAndHealth / BusinessInsight / FeatureInsight | collection purpose |
| **classification** | SystemMetaData / CallstackOrException / EndUserPseudonymizedInformation | data category |
| **retention** | 90d / 1y / permanent | retention period |
| **gdprRequired** | true/false | whether user consent is required |

### Telemetry event definitions

| Event name | Trigger | Data fields | Classification |
|--------|----------|----------|------|
| feature.used | when the user uses feature X | `{ featureId, duration }` | SystemMetaData |
| error.occurred | when an error occurs | `{ errorCode, stack }` | CallstackOrException |
```

---

## 2) Data classification guidance

### SystemMetaData

**Definition**: system information that does not identify the user.

**Allowed**:
- OS version
- App version
- Feature flag states
- Performance metrics (latency, memory)
- Anonymous usage frequency

**Example**:
```typescript
// Compliant: system metadata
telemetry.log('app.startup', {
  version: '1.0.0',
  os: 'darwin',
  memoryUsage: process.memoryUsage().heapUsed,
});
```

### CallstackOrException

**Definition**: error information and callstacks.

**Allowed**:
- Error codes
- Error messages (must be sanitized)
- Callstacks (must sanitize file paths)

**Sanitization requirements**:
- Remove usernames: `/Users/john/` → `/Users/<username>/`
- Remove project paths: `/project/secret/` → `<project>/`
- Remove sensitive filenames: `credentials.json` → `<sensitive>`

**Example**:
```typescript
// Compliant: sanitized exception
telemetry.logError('app.error', {
  errorCode: 'E001',
  message: sanitizeMessage(error.message),
  stack: sanitizeStack(error.stack),
});
```

### EndUserPseudonymizedInformation

**Definition**: user information that has been pseudonymized.

**Requirements**:
- Must use one-way hashing
- Must not be reversible
- Requires user consent

**Example**:
```typescript
// Compliant: pseudonymized user ID
telemetry.log('user.action', {
  hashedUserId: sha256(userId + salt), // one-way hash
  action: 'click',
});
```

### PublicNonPersonalData

**Definition**: fully public data that does not include personal information.

**Allowed**:
- Public configuration options
- Public API versions
- Public feature lists

---

## 3) Data you must not collect

| Type | Examples | Reason |
|------|------|------|
| Plain PII | name, email, phone | directly identifies users |
| Location info | GPS, IP address | indirectly identifies users |
| File contents | user docs, source code | sensitive data |
| Passwords/tokens | API keys, passwords | security risk |
| Health info | medical data | sensitive data |
| Financial info | credit card numbers | sensitive data |

**Detection rules**:
```bash
# Detect possible PII collection
rg "email|phone|name|address|ip" --type ts -g "*telemetry*"
rg "password|token|secret|key" --type ts -g "*telemetry*"
```

---

## 4) Event naming conventions

### Standard events (publicLog2)

Used for normal feature usage and performance measurement:

```typescript
// Naming format: <domain>.<action>
publicLog2<{ duration: number }>('editor.opened', { duration: 123 });
publicLog2<{ count: number }>('search.performed', { count: 10 });
```

### Exception events (publicLogError2)

Used for errors and exceptional conditions:

```typescript
// Naming format: <domain>.error or <domain>.failed
publicLogError2<{ code: string }>('editor.error', { code: 'E001' });
publicLogError2<{ reason: string }>('save.failed', { reason: 'disk_full' });
```

---

## 5) Code review checklist

When reviewing telemetry-related code:

### Must check

- [ ] **Is GDPR classification complete?**
  - Is `owner` specified?
  - Is `classification` correct?
  - Is `purpose` clear?

- [ ] **Is data sanitized?**
  - Are usernames removed from file paths?
  - Are error messages filtered for sensitive data?
  - Is there any plain PII?

- [ ] **Is naming compliant?**
  - Do event names follow `<domain>.<action>`?
  - Do error events use `publicLogError2`?

- [ ] **Is user consent handled?**
  - For consent-required data, is `telemetryLevel` checked?
  - Are user privacy settings respected?

### Automated checks

```bash
# Check for telemetry without classification
rg "publicLog2|telemetry\.log" --type ts | xargs -I {} grep -L "classification" {}

# Check for sensitive data collection
rg "(email|phone|password|token)" --type ts -g "*telemetry*"
```

---

## 6) design.md template snippet

When `design.md` includes telemetry, add:

```markdown
## Telemetry Impact

### New telemetry events

| Event | owner | classification | purpose | isMeasurement |
|------|-------|----------------|---------|---------------|
| feature.x.used | @alice | SystemMetaData | FeatureInsight | true |
| feature.x.error | @alice | CallstackOrException | PerformanceAndHealth | false |

### Data field definitions

```typescript
interface FeatureXUsedEvent {
  duration: number;        // duration (ms)
  success: boolean;        // success
  // Do not add: userId, filePath, etc.
}
```

### Privacy impact assessment

- [ ] No PII collected
- [ ] Sensitive paths are sanitized
- [ ] telemetryLevel settings checked
- [ ] Privacy Review completed (if required)
```

---

## 7) Compliance approval workflow

| Data category | Approval requirement |
|----------|----------|
| SystemMetaData | no approval required |
| CallstackOrException | no approval required (must sanitize) |
| EndUserPseudonymizedInformation | requires Privacy Review |
| Any new PII | requires Legal Review |

---

## References

- [GDPR data classification guide](https://gdpr.eu/data-protection/)
- [VS Code telemetry documentation](https://code.visualstudio.com/docs/getstarted/telemetry)
- [Microsoft Privacy Statement](https://privacy.microsoft.com/)
