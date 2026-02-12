# Test Review Skill

Review test code quality cho Java project.

## Trigger

- "review test", "check test quality"
- "test này có tốt không"

## Input

- Test file path hoặc test class name

## Steps

### 1. Read Test File

```
Read test file và source file được test (SUT - System Under Test)
```

### 2. Static Analysis với PMD

```bash
# Windows
tools\pmd-bin-7.0.0\bin\pmd.bat check -d <test-file> -R rulesets/java/quickstart.xml -f json

# Check test-specific rules
tools\pmd-bin-7.0.0\bin\pmd.bat check -d <test-file> -R category/java/bestpractices.xml/JUnitTestsShouldIncludeAssert,category/java/bestpractices.xml/JUnitTestContainsTooManyAsserts -f text
```

### 3. Checklist Evaluation

| Category | Weight | Criteria |
|----------|--------|----------|
| **Assertions** | 25% | Có assert đủ? Không chỉ verify mock? |
| **Edge Cases** | 25% | Null, empty, boundary values? |
| **Mocking** | 20% | Mock đúng dependencies? Không over-mock? |
| **Naming** | 15% | Test name mô tả behavior? |
| **Independence** | 15% | Tests độc lập? Không share state? |

### 4. Common Issues to Check

#### 4.1 Missing Assertions
```java
// BAD - chỉ verify mock, không assert result
@Test
void testProcess() {
    service.process(input);
    verify(repo).save(any());  // Không assert gì về result!
}

// GOOD
@Test
void testProcess_shouldReturnProcessedData() {
    Result result = service.process(input);
    assertThat(result.getStatus()).isEqualTo(Status.SUCCESS);
    verify(repo).save(any());
}
```

#### 4.2 Over-mocking
```java
// BAD - mock quá nhiều, test không có ý nghĩa
when(service.validate(any())).thenReturn(true);
when(service.process(any())).thenReturn(result);
when(service.save(any())).thenReturn(saved);
// Test chỉ verify flow, không test logic thật

// GOOD - chỉ mock external dependencies
when(externalApi.call(any())).thenReturn(apiResponse);
// Test real logic của service
```

#### 4.3 Missing Edge Cases
```java
// BAD - chỉ test happy path
@Test
void testCalculate() {
    assertEquals(10, calculator.divide(100, 10));
}

// GOOD - test edge cases
@Test
void testDivide_byZero_shouldThrow() {
    assertThrows(ArithmeticException.class,
        () -> calculator.divide(100, 0));
}

@Test
void testDivide_negativeNumbers() {
    assertEquals(-10, calculator.divide(-100, 10));
}
```

### 5. Output Format

```markdown
## Test Review: <TestClassName>

### Summary
- **Score**: X/100
- **SUT**: <SourceClassName>
- **Test Count**: N tests

### Findings

| # | Issue | Severity | Line | Fix |
|---|-------|----------|------|-----|
| 1 | Missing null check test | Medium | - | Add test for null input |

### Score Breakdown

| Category | Score | Notes |
|----------|-------|-------|
| Assertions | X/25 | ... |
| Edge Cases | X/25 | ... |
| Mocking | X/20 | ... |
| Naming | X/15 | ... |
| Independence | X/15 | ... |

### Recommendations

1. ...
2. ...
```

## Notes

- Focus vào test có assert thật sự, không chỉ verify mock
- Check edge cases: null, empty, negative, boundary
- Nếu project có experience.md, đọc trước để biết các lỗi hay gặp
