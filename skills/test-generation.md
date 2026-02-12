# Test Generation Skill

## Trigger
- User yêu cầu viết test, generate test
- User muốn tăng coverage
- User nói "code này chưa có test"

---

## Prerequisites Check
Verify project có:
- [ ] JUnit 5 (junit-jupiter)
- [ ] Mockito (mockito-core)
- [ ] AssertJ (assertj-core) - recommended
- [ ] JaCoCo plugin configured

Nếu thiếu → hướng dẫn user thêm vào pom.xml/build.gradle.

---

## Execution Steps

### Step 1: Analyze Target Class

```
1. Đọc source code của class cần test
2. Identify public methods + signatures
3. Tìm dependencies (injected services)
4. Tìm existing tests: *Test.java, *Tests.java
5. Check coverage baseline nếu có JaCoCo
```

**Coverage baseline:**
```bash
mvn test jacoco:report -pl <module>
# Read: target/site/jacoco/jacoco.xml
```

### Step 2: Test Categories (viết theo thứ tự)

| Priority | Category | Description |
|----------|----------|-------------|
| 1 | Happy Path | Normal input, expected output |
| 2 | Null/Empty | Null params, empty strings, empty collections |
| 3 | Boundary | 0, -1, MAX_VALUE, empty vs single item |
| 4 | Error Cases | Exceptions, invalid state |
| 5 | Edge Cases | Concurrent access, large data |

**Từ Monitoring Code Quality insights:**
- Test cơ bản đúng flow (ứng với client)
- Test ngoại lệ (tool sửa gói tin, client gửi sai)
- Test theo kịch bản (VD: user nhận 7 phần quà trong 7 ngày)

### Step 3: Generate Test Code

**Framework:** JUnit 5 + Mockito + AssertJ

**Naming Convention:**
- Class: `XxxTest` trong `src/test/java/` mirror package
- Method: `should_<expected>_when_<condition>()`

**Structure Template:**
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock private UserRepository userRepository;
    @Mock private EmailService emailService;
    @InjectMocks private UserService userService;

    @Nested
    @DisplayName("createUser")
    class CreateUser {

        @Test
        @DisplayName("should create user when valid input")
        void should_create_user_when_valid_input() {
            // Arrange
            var request = new CreateUserRequest("John", "john@example.com");
            var savedUser = new User(1L, "John", "john@example.com");
            when(userRepository.existsByEmail(anyString())).thenReturn(false);
            when(userRepository.save(any(User.class))).thenReturn(savedUser);

            // Act
            var result = userService.createUser(request);

            // Assert
            assertThat(result.getName()).isEqualTo("John");
            assertThat(result.getEmail()).isEqualTo("john@example.com");
            verify(userRepository).save(any(User.class));
        }

        @Test
        @DisplayName("should throw when email already exists")
        void should_throw_when_email_exists() {
            // Arrange
            when(userRepository.existsByEmail("john@example.com")).thenReturn(true);

            // Act & Assert
            assertThatThrownBy(() -> userService.createUser(request))
                .isInstanceOf(EmailExistsException.class)
                .hasMessageContaining("john@example.com");
        }
    }
}
```

**RULES:**
- Mỗi test method test ĐÚNG 1 behavior
- PHẢI có meaningful assertions (KHÔNG chỉ verify no exception)
- Mock ALL external dependencies (DB, HTTP, File I/O)
- KHÔNG mock class đang test
- Dùng `@Nested` group theo method
- Spring Boot: `@WebMvcTest`, `@DataJpaTest` cho integration

### Step 4: Compile Check + Self-Heal

```bash
mvn test-compile -pl <module>
```

**Auto-fix errors:**
| Error Type | Fix |
|------------|-----|
| Import not found | Check actual class names, fix import |
| Method not found | Use `get_symbol_info` verify signature |
| Type mismatch | Check actual return types |
| Mockito setup wrong | Verify mock returns đúng type |
| Cannot access private | Test qua public API |

Retry compile tối đa 3 lần.

### Step 5: Run Tests + Measure Coverage

```bash
mvn test -Dtest=<TestClassName> jacoco:report -pl <module>
```

Record:
- Tests pass: X/Y
- Tests fail: list failures + root cause
- Line coverage: XX%
- Branch coverage: XX%

### Step 6: Boosting Loop (nếu coverage < target)

**Round N:**
1. Parse JaCoCo XML → tìm uncovered lines:
```xml
<line nr="XX" mi="Y"/> <!-- mi > 0 = missed instructions -->
```

2. Map uncovered lines → source code:
   - Method nào chưa test?
   - Branch nào chưa test? (if/else, switch, try/catch)
   - Edge case nào miss?

3. Generate THÊM tests CHỈ cho phần chưa covered

4. Compile + Run lại → đo delta coverage

**Stop boosting khi:**
- Coverage đạt target (70-80%)
- Delta < 3% (diminishing returns)
- Đã 3 rounds (max)
- Uncovered lines là unreachable code

### Step 7: Quality Check

Review tests đã gen:
- [ ] Test chỉ check "no exception thrown"? → xóa hoặc thêm assertion
- [ ] Test duplicate logic? → merge
- [ ] Flaky pattern? (time, random, external state) → fix
- [ ] Test names descriptive? → improve

---

## Output Format

```
## Test Generation Report: [ClassName]

### Generated Tests
- Total: X tests
- File: src/test/java/.../XxxTest.java

### Coverage
| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Line | X% | Y% | +Z% |
| Branch | X% | Y% | +Z% |

### Test Summary
| Method | Tests | Coverage |
|--------|-------|----------|
| methodA | 3 | 100% |
| methodB | 2 | 85% |

### Uncovered (reason)
- Line 45-50: Dead code (unreachable)
- Line 72: Private helper

### Boosting Rounds
- Round 1: +15% (added boundary tests)
- Round 2: +8% (added error cases)
- Round 3: +3% (diminishing returns, stopped)
```

---

## Anti-Patterns to Avoid

| Pattern | Why Bad |
|---------|---------|
| Test only verifies mock calls | Tests mocks, not code |
| No assertions | Coverage filler |
| Testing private methods | Couples to implementation |
| Mocking value objects | Over-mocking |
| Generic test names | Hard to understand failures |
| 100+ lines setup | Maintenance nightmare |
