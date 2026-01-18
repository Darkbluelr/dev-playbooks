# Resource Management Review Checklist

This document defines resource management review guidelines.

---

## 1) Common resource leak patterns

### Subscription / listener leaks

```typescript
// Bad: subscription is never removed
class MyComponent {
  private handler = (e: Event) => { /* ... */ };

  initialize() {
    document.addEventListener('click', this.handler);
    // Missing removeEventListener
  }
}

// Good: use AbortController
class MyComponent {
  private abortController = new AbortController();

  initialize() {
    document.addEventListener('click', this.handler, {
      signal: this.abortController.signal
    });
  }

  dispose() {
    this.abortController.abort();
  }
}
```

### Timer leaks

```typescript
// Bad: timer is never cleared
class Poller {
  start() {
    setInterval(() => this.poll(), 1000);
    // Missing cleanup
  }
}

// Good: keep the handle and clear it in dispose
class Poller {
  private intervalId?: NodeJS.Timeout;

  start() {
    this.intervalId = setInterval(() => this.poll(), 1000);
  }

  dispose() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = undefined;
    }
  }
}
```

### Stream / connection leaks

```typescript
// Bad: stream is not closed on error
async function readFile(path: string) {
  const stream = fs.createReadStream(path);
  const data = await streamToString(stream);
  // If streamToString throws, the stream will remain open
  return data;
}

// Good: use try/finally
async function readFile(path: string) {
  const stream = fs.createReadStream(path);
  try {
    return await streamToString(stream);
  } finally {
    stream.destroy();
  }
}

// Better: use using (TypeScript 5.2+)
async function readFile(path: string) {
  using stream = fs.createReadStream(path);
  return await streamToString(stream);
}
```

---

## 2) DisposableStore pattern

### Basic usage

```typescript
import { Disposable, DisposableStore } from 'vs/base/common/lifecycle';

class MyService extends Disposable {
  // Must be readonly
  private readonly _disposables = new DisposableStore();

  constructor() {
    super();

    // Register subscription in the store
    this._disposables.add(
      eventEmitter.on('change', () => this.handleChange())
    );

    // Register timers/resources in the store
    this._disposables.add(
      new IntervalTimer(() => this.poll(), 1000)
    );
  }

  override dispose() {
    this._disposables.dispose();
    super.dispose(); // Must call
  }
}
```

### Rules to check

| Rule | Detection pattern | Severity |
|------|-------------------|----------|
| `DisposableStore` must be `readonly` | `private\\s+(?!readonly)\\s*_?\\w*[Dd]isposable` | Error |
| `dispose()` must call `super.dispose()` | `override\\s+dispose\\(\\).*\\{(?![\\s\\S]*super\\.dispose)` | Error |
| Subscriptions must be registered | `.on\\(.*\\)` without `.add(` | Warning |
| Tests should check for leaks | missing `ensureNoDisposablesAreLeakedInTestSuite` | Warning |

---

## 3) Detecting leaks in tests

### Using `ensureNoDisposablesAreLeakedInTestSuite`

```typescript
import { ensureNoDisposablesAreLeakedInTestSuite } from 'vs/base/test/common/utils';

suite('MyService', () => {
  // Enable leak detection at suite start
  ensureNoDisposablesAreLeakedInTestSuite();

  let service: MyService;

  setup(() => {
    service = new MyService();
  });

  teardown(() => {
    service.dispose(); // Must clean up
  });

  test('should do something', () => {
    // test code
  });
});
```

### Common test leak patterns

```typescript
// Bad: disposable created in a test is never disposed
test('creates disposable', () => {
  const disposable = new MyDisposable();
  // test ends, disposable not disposed -> leak
});

// Good: dispose in teardown
let disposable: MyDisposable;

setup(() => {
  disposable = new MyDisposable();
});

teardown(() => {
  disposable.dispose();
});
```

---

## 4) Review checklist

### Must check in code review

- [ ] **`DisposableStore` declarations**
  - Is it `readonly`?
  - Is it `private`?

- [ ] **`dispose()` method**
  - Does it call `super.dispose()`?
  - Does it clean up all known resources?
  - Is cleanup defined in a base class when appropriate?

- [ ] **Subscriptions / listeners**
  - Are they registered in a `DisposableStore`?
  - Is there a corresponding cancellation/removal path?
  - Is `AbortController` used where applicable?

- [ ] **Timers**
  - Does `setInterval` have a corresponding `clearInterval`?
  - Are `setTimeout` callbacks canceled on teardown/dispose?

- [ ] **Streams / connections**
  - Are they closed in a `finally` block?
  - Is `using` used when available?

- [ ] **Tests**
  - Is `ensureNoDisposablesAreLeakedInTestSuite()` present?
  - Does teardown dispose everything created by tests?

---

## 5) Automated detection

### ESLint rule config

```javascript
// eslint.config.js
module.exports = {
  rules: {
    // Custom rule: DisposableStore must be readonly
    'local/code-no-potentially-unsafe-disposables': 'error',

    // Custom rule: dispose must call super
    'local/code-must-use-super-dispose': 'error',
  }
};
```

### Grep / ripgrep commands

```bash
# Detect non-readonly DisposableStore fields
rg 'private\\s+(?!readonly)\\s*_?\\w*[Dd]isposable' --type ts

# Detect dispose() methods missing super.dispose()
rg -U 'override\\s+dispose\\(\\).*?\\{[^}]*\\}' --type ts | grep -v 'super.dispose'

# Detect setInterval without clearInterval
rg 'setInterval\\(' --type ts -l | xargs -I {} sh -c 'rg -c "clearInterval" {} || echo "Missing clearInterval: {}"'
```

---

## 6) Fix guide

### Add a `DisposableStore`

```typescript
// Before
class MyClass {
  private subscription: Subscription;

  constructor() {
    this.subscription = eventEmitter.on('change', () => {});
  }
}

// After
class MyClass extends Disposable {
  private readonly _disposables = new DisposableStore();

  constructor() {
    super();
    this._disposables.add(
      eventEmitter.on('change', () => {})
    );
  }

  override dispose() {
    this._disposables.dispose();
    super.dispose();
  }
}
```

### Add test leak detection

```typescript
// Before
suite('MyTest', () => {
  test('does something', () => {
    const obj = new MyDisposable();
    // Not disposed
  });
});

// After
suite('MyTest', () => {
  ensureNoDisposablesAreLeakedInTestSuite();

  const disposables = new DisposableStore();

  teardown(() => {
    disposables.clear();
  });

  test('does something', () => {
    const obj = disposables.add(new MyDisposable());
    // Automatically disposed in teardown
  });
});
```
