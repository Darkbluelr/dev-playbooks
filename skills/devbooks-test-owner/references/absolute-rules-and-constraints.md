# Test Owner Absolute Rules and Constraints

> **These rules have no exceptions. Violation means failure.**

## 🚨 Rule 1: No Stub Tests

```
❌ FORBIDDEN: Test function body is empty (pass / return)
❌ FORBIDDEN: Test contains skip / pytest.skip / @skip
❌ FORBIDDEN: Test contains TODO / FIXME / not_implemented
❌ FORBIDDEN: Test only has assert True or assert 1 == 1
❌ FORBIDDEN: Test raises NotImplementedError

✅ REQUIRED: Every test has real assertions
✅ REQUIRED: Every test can run independently
✅ REQUIRED: Test failures give meaningful error messages
```

### Stub Test Examples (All FORBIDDEN)

```python
# ❌ Empty function body
def test_login():
    pass

# ❌ Skip marker
def test_login():
    pytest.skip("not implemented yet")

# ❌ TODO placeholder
def test_login():
    # TODO: implement this test
    assert True

# ❌ Meaningless assertion
def test_login():
    assert 1 == 1

# ❌ Raises not implemented exception
def test_login():
    raise NotImplementedError("pending")
```

### Proper Test Example

```python
# ✅ Real test with assertions
def test_login_returns_jwt():
    # Arrange
    user = create_test_user(email="test@example.com", password="secret")

    # Act
    result = login_service.login(email="test@example.com", password="secret")

    # Assert
    assert result.token is not None
    assert result.token.startswith("eyJ")
    assert result.user_id == user.id
```

## 🚨 Rule 2: No Demo Mode (NO DEMO MODE)

```
❌ FORBIDDEN: Treating test writing as "demonstration" or "showcase"
❌ FORBIDDEN: Claiming "tests written" when files are empty or don't exist
❌ FORBIDDEN: Outputting test plan without actually creating test files
❌ FORBIDDEN: Using "simulate", "assume" instead of actually writing tests

✅ REQUIRED: Every claimed test must be a real file
✅ REQUIRED: Files must contain executable test code
✅ REQUIRED: Red baseline evidence must come from actually running tests
```

## 🚨 Rule 3: Tests Must Not Be Decoupled from AC

```
❌ FORBIDDEN: Tests not associated with any AC
❌ FORBIDDEN: AC without corresponding tests
❌ FORBIDDEN: Tests pass but AC not actually verified

✅ REQUIRED: Every AC has at least one test
✅ REQUIRED: Every test is linked to a specific AC-xxx
✅ REQUIRED: verification.md AC Coverage Matrix has 100% test mapping
```

## Test Isolation Requirements

- [ ] Each test must run independently, not dependent on execution order of other tests
- [ ] Integration tests must have `beforeEach`/`afterEach` cleanup
- [ ] Shared mutable state is prohibited
- [ ] Tests must clean up created files/data after completion

## Test Stability Requirements

- [ ] Committing `test.only` / `it.only` / `describe.only` is prohibited
- [ ] Flaky tests must be marked and fixed within a deadline (no more than 1 week)
- [ ] Test timeouts must be reasonably set (unit tests < 5s, integration tests < 30s)
- [ ] External network dependencies are prohibited (mock all external calls)

## AC Coverage Matrix Checkbox Permissions

| Checkbox Location | Who Can Check | When to Check |
|-------------------|---------------|---------------|
| `[ ]` in AC Coverage Matrix | **Test Owner** | Phase 2 after evidence audit confirmed |
| Status field `Verified` | **Test Owner** | After Phase 2 completion |
| Status field `Done` | Reviewer | After Code Review passes |

**Prohibited**: Coder cannot check AC Coverage Matrix, cannot modify verification.md.
