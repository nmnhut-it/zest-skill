# Test Evaluation Skill

## Trigger
- User yêu cầu đánh giá test quality
- User hỏi "test này có tốt không"
- User muốn review test suite

## Purpose
Đánh giá test meaningfulness, real-world applicability, và maintainability.

---

## Scoring Weights
| Category | Weight |
|----------|--------|
| Real-World Relevance | 35% |
| Mocking Strategy | 30% |
| Maintainability | 20% |
| Bug Detection | 15% |

---

## Evaluation Checklist

### 1. Real-World Relevance (35%)

#### 1.1 Business Scenario Coverage
- [ ] Tests reflect actual user workflows
- [ ] Tests cover production edge cases (not theoretical)
- [ ] Tests validate business rules, not implementation
- [ ] Test data resembles production patterns
- [ ] Tests cover real failure scenarios

**RED FLAGS:**
- Tests validate internal state without business meaning
- Test scenarios never happen in real usage
- Tests focus on "what could go wrong" vs "what does go wrong"

#### 1.2 User Value Verification
- [ ] Tests verify outcomes users care about
- [ ] Tests would catch bugs users would report
- [ ] Tests validate user-facing error messages
- [ ] Tests ensure data consistency from user perspective

**RED FLAGS:**
- Tests pass but feature is broken for users
- Tests verify state changes invisible to users

### 2. Mocking Strategy (30%)

#### 2.1 Mock Usage Assessment
- [ ] Mocks limited to infrastructure/external deps only
- [ ] Core business logic is NOT mocked
- [ ] Mocking depth ≤ 2 levels
- [ ] Real objects for domain models/value objects
- [ ] Mock behaviors reflect actual contracts

**RED FLAGS:**
- Mocking domain services/business logic
- Tests become "mock verification" instead of behavior tests
- Mock setup longer than actual test logic

#### 2.2 Mock Realism
- [ ] Mock return values are realistic
- [ ] Mock failures simulate actual error conditions
- [ ] Mock state changes mirror real implementation

**RED FLAGS:**
- Mocks always succeed (no failure scenarios)
- Mocks bypass validations that real code enforces

#### 2.3 Sociable vs Solitary Balance
- [ ] Integration tests exist for critical paths
- [ ] Unit tests don't duplicate integration coverage
- [ ] Clear distinction: unit/integration/e2e

### 3. Maintainability (20%)

#### 3.1 Fragility Assessment
- [ ] Tests don't break when refactoring implementation
- [ ] Tests avoid checking call counts/order unless critical
- [ ] Tests don't depend on exact internal method calls
- [ ] Tests don't verify private method behavior
- [ ] Tests are independent (no shared state)

**RED FLAGS:**
- Tests break on non-breaking code changes
- Tests verify "how" instead of "what"
- Mock verification checks internal mechanics

#### 3.2 Readability & Clarity
- [ ] Test name states scenario + expected outcome
- [ ] Arrange-Act-Assert pattern is clear
- [ ] Test fits on one screen (< 50 lines)
- [ ] No complex logic in test code
- [ ] Setup is minimal and focused

**RED FLAGS:**
- Test name is generic ("testMethod1", "shouldWork")
- Excessive setup (>20 lines)

#### 3.3 Duplication & Organization
- [ ] No redundant tests
- [ ] Test utilities reduce duplication
- [ ] Tests grouped by feature/scenario
- [ ] Each test has single responsibility

### 4. Bug Detection Effectiveness (15%)

#### 4.1 Mutation Testing Mindset
- [ ] If I introduce a bug, will test catch it?
- [ ] If I remove a line of code, will test fail?
- [ ] Tests verify correct behavior, not just "no exceptions"
- [ ] Assertions are specific (not just "result != null")

**RED FLAGS:**
- Tests pass even with obvious bugs
- Tests only check happy path
- Weak assertions (only checking nullity/type)

#### 4.2 Regression Prevention
- [ ] Tests would catch common regression patterns
- [ ] Tests cover historically buggy areas
- [ ] Tests verify fixes stay fixed

---

## Anti-Patterns (Automatic Fail)

| Code | Anti-Pattern |
|------|--------------|
| ANTI-1 | Test only verifies mocks were called |
| ANTI-2 | Test has no assertions |
| ANTI-3 | Test always passes regardless of implementation |
| ANTI-4 | Test is just coverage filler |
| ANTI-5 | Test duplicates another test |
| ANTI-6 | Test requires production code changes to pass |
| ANTI-7 | Test setup more complex than code under test |
| ANTI-8 | "Liar test" - passes when feature is broken |

---

## Key Questions

1. **"So What?" Test**: If this test fails, what actual problem does it indicate?
2. **"Realism Test"**: Could this scenario happen in production?
3. **"Refactor Test"**: If I rename variables/methods, does test break?
4. **"Mock Test"**: Am I testing my code or testing my mocks?
5. **"Value Test"**: Does this test justify its maintenance cost?

---

## Output Format

```
## Test File: [FileName]
**Feature Under Test**: [Description]
**Total Tests**: X | **Lines**: Y

### Scores
- Real-World Relevance: X/35
- Mocking Strategy: X/30
- Maintainability: X/20
- Bug Detection: X/15
**TOTAL: X/100** - [Verdict]

### Critical Issues Found
- [Issue 1]
- [Issue 2]

### Red Flags
- [Flag 1]
- [Flag 2]

### Anti-Patterns Detected
- [ANTI-X]: Description

### Recommendations
1. [Action 1]
2. [Action 2]

### Example of Problem
```java
// Current problematic test
```

### What Good Test Would Look Like
```java
// Improved version
```
```

---

## Verdict Scale
| Score | Verdict | Action |
|-------|---------|--------|
| 90-100 | Excellent | Keep as-is |
| 75-89 | Good | Minor improvements |
| 60-74 | Acceptable | Refactor recommended |
| 40-59 | Poor | Major refactor needed |
| 0-39 | Worthless | Delete or rewrite |
