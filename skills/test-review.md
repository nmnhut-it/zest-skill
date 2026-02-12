# Test Review Skill

Review chất lượng test cho Java project.

## Trigger

- "review test", "check test"
- "test này có tốt không"

## Prerequisites (Windows)

```bash
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
```

---

## Steps

### 1. Đọc Test File

```
Read test file và source file được test (SUT - System Under Test)
```

### 2. Static Analysis với PMD

```bash
./tools/pmd-bin-7.0.0/bin/pmd check -d <test-file> -R rulesets/java/quickstart.xml -f json
```

### 3. Checklist Evaluation

| Category | Weight | Criteria |
|----------|--------|----------|
| **Real-World** | 35% | Test phản ánh user workflow thật? |
| **Mocking** | 30% | Chỉ mock external deps? Không over-mock? |
| **Maintainability** | 20% | Test không vỡ khi refactor? |
| **Bug Detection** | 15% | Test có bắt được bug thật? |

---

## Anti-Patterns (tự động fail)

| Code | Anti-Pattern |
|------|--------------|
| ANTI-1 | Test chỉ verify mock, không assert gì |
| ANTI-2 | Test không có assertion |
| ANTI-3 | Test luôn pass dù code sai |
| ANTI-4 | Test chỉ để tăng coverage |
| ANTI-5 | Test trùng lặp test khác |

---

## Common Issues

### Missing Assertions
```java
// BAD - chỉ verify mock
@Test
void testProcess() {
    service.process(input);
    verify(repo).save(any());  // Không assert result!
}

// GOOD
@Test
void testProcess_shouldReturnSuccess() {
    Result result = service.process(input);
    assertThat(result.getStatus()).isEqualTo(SUCCESS);
}
```

### Over-mocking
```java
// BAD - mock quá nhiều
when(service.validate(any())).thenReturn(true);
when(service.process(any())).thenReturn(result);
// Test chỉ verify flow, không test logic

// GOOD - chỉ mock external deps
when(externalApi.call(any())).thenReturn(apiResponse);
// Test real logic của service
```

### Missing Edge Cases
```java
// BAD - chỉ happy path
@Test
void testDivide() {
    assertEquals(10, calc.divide(100, 10));
}

// GOOD - có edge cases
@Test
void testDivide_byZero_shouldThrow() {
    assertThrows(ArithmeticException.class,
        () -> calc.divide(100, 0));
}
```

---

## Output Format

```markdown
## Test Review: <TestClassName>

### Summary
- **Score**: X/100
- **SUT**: <SourceClassName>
- **Test Count**: N tests

### Scores
| Category | Score | Notes |
|----------|-------|-------|
| Real-World | X/35 | ... |
| Mocking | X/30 | ... |
| Maintainability | X/20 | ... |
| Bug Detection | X/15 | ... |

### Anti-Patterns Found
- [ANTI-X]: Description

### Issues
| # | Issue | Severity | Fix |
|---|-------|----------|-----|
| 1 | ... | Medium | ... |

### Recommendations
1. ...
2. ...
```

## Verdict Scale

| Score | Verdict | Action |
|-------|---------|--------|
| 90-100 | Excellent | Giữ nguyên |
| 75-89 | Good | Cải thiện nhỏ |
| 60-74 | OK | Nên refactor |
| 40-59 | Poor | Cần refactor lớn |
| 0-39 | Worthless | Xóa hoặc viết lại |
