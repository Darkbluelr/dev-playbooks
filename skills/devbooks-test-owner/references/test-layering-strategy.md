# Test Layering Strategy

This document defines best practices for test layering.

---

## 1) Test pyramid principle

### Ideal ratio

| Layer | Ratio | Characteristics | Frequency |
|------|-------|-----------------|-----------|
| Unit tests | 70% | Fast, isolated, focused | Every commit |
| Integration tests | 20% | Module boundaries, real dependencies | Every PR |
| E2E tests | 10% | End-to-end, user perspective | On merge |

### Responsibilities per layer

**Unit tests:**
- Test a single function/class behavior
- Fully isolated, no external dependencies
- Execution speed < 5s/file
- Cover all boundary cases

**Integration tests:**
- Test interactions across modules
- May use test DB/cache
- Execution speed < 30s/file
- Cover API contracts

**E2E tests:**
- Test complete user flows
- Use a real environment
- Execution speed < 60s/scenario
- Cover only critical paths

---

## 2) Naming conventions

### File naming

```
src/
├── user/
│   ├── user.service.ts
│   └── test/
│       └── user.service.test.ts    # unit test (next to source)

tests/
├── unit/                           # alternative: centralized unit tests
│   └── user.service.test.ts
├── integration/
│   └── user.api.integrationTest.ts # integration test
├── e2e/
│   └── user-flow.e2e.ts            # E2E test
├── contract/
│   └── user.api.contract.ts        # contract test
└── smoke/
    └── health.smoke.ts             # smoke test
```

### Test case naming

```typescript
// Good: describes behavior and expected outcome
describe('UserService', () => {
  describe('createUser', () => {
    it('should create a new user with valid data', () => {});
    it('should throw ValidationError when email is invalid', () => {});
    it('should return existing user when email already exists', () => {});
  });
});

// Bad: vague naming
describe('UserService', () => {
  it('test1', () => {});
  it('works', () => {});
});
```

---

## 3) Isolation strategies

### Unit test isolation

```typescript
// Use mocks to isolate external dependencies
import { mock, MockProxy } from 'jest-mock-extended';

describe('UserService', () => {
  let userRepo: MockProxy<UserRepository>;
  let service: UserService;

  beforeEach(() => {
    userRepo = mock<UserRepository>();
    service = new UserService(userRepo);
  });

  it('should call repository save', async () => {
    userRepo.save.mockResolvedValue({ id: '1', name: 'test' });
    await service.createUser({ name: 'test' });
    expect(userRepo.save).toHaveBeenCalledWith({ name: 'test' });
  });
});
```

### Integration test isolation

```typescript
// Use beforeEach/afterEach cleanup
describe('User API Integration', () => {
  let testDb: TestDatabase;

  beforeAll(async () => {
    testDb = await TestDatabase.create();
  });

  beforeEach(async () => {
    await testDb.clean(); // clean before each test
  });

  afterAll(async () => {
    await testDb.destroy();
  });

  it('should create user via API', async () => {
    const response = await request(app)
      .post('/users')
      .send({ name: 'test' });
    expect(response.status).toBe(201);
  });
});
```

### E2E test isolation

```typescript
// Use an isolated test environment
describe('User Registration Flow', () => {
  let browser: Browser;
  let page: Page;

  beforeAll(async () => {
    browser = await chromium.launch();
  });

  beforeEach(async () => {
    page = await browser.newPage();
    await seedTestData(); // prepare data
  });

  afterEach(async () => {
    await page.close();
    await cleanupTestData(); // cleanup data
  });

  afterAll(async () => {
    await browser.close();
  });
});
```

---

## 4) Stability and guardrails

### Forbidden patterns to commit

```bash
# pre-commit hook check
check_test_only() {
  if rg -l '\\.(only|skip)\\(' tests/ src/**/test/; then
    echo "error: found .only() or .skip() in tests" >&2
    exit 1
  fi
}
```

### Handling flaky tests

```typescript
// Temporary skip for flaky tests (must include an issue link)
describe.skip('Flaky test - see #123', () => {
  // TODO: Fix flaky test by 2024-01-15
});

// Or retries (not recommended; fix root cause)
it('sometimes fails', async () => {
  // jest-retries or mocha-retry
}, { retries: 2 });
```

### Timeout settings

```typescript
// Reasonable timeout settings
jest.setTimeout(5000); // unit tests default 5s

describe('Integration Tests', () => {
  beforeAll(() => {
    jest.setTimeout(30000); // integration tests 30s
  });
});
```

---

## 5) Coverage strategy

### Coverage targets

| Metric | Minimum | Recommended |
|-------|---------|-------------|
| Line coverage | 70% | 80%+ |
| Branch coverage | 60% | 70%+ |
| Function coverage | 80% | 90%+ |

### Coverage exceptions

```typescript
// Mark code that does not need coverage
/* istanbul ignore next */
function debugOnly() {
  // debug-only, no tests needed
}

/* istanbul ignore if */
if (process.env.NODE_ENV === 'development') {
  // development-only behavior
}
```

---

## 6) Anti-fragile testing

### Avoid brittle selectors

```typescript
// Bad: relies on CSS class names (breaks on style refactors)
await page.click('.btn-primary');

// Bad: relies on visible text (breaks on i18n)
await page.click('text=Submit');

// Good: use data-testid
await page.click('[data-testid="submit-button"]');

// Good: use role selectors
await page.click('role=button[name="Submit"]');
```

### Avoid brittle assertions

```typescript
// Bad: exact match (breaks on formatting changes)
expect(result.createdAt).toBe('2024-01-01T00:00:00.000Z');

// Good: type assertion
expect(result.createdAt).toBeInstanceOf(Date);

// Good: partial match
expect(result.message).toContain('success');
```

---

## 7) Test review checklist

In code review, check:

- [ ] Do tests follow naming conventions?
- [ ] Are unit tests fully isolated?
- [ ] Do integration tests have cleanup logic?
- [ ] Are there any leftover `.only()` / `.skip()`?
- [ ] Are timeouts reasonable?
- [ ] Are selectors non-brittle?
- [ ] Does new code come with tests?
- [ ] Are boundary cases covered?
