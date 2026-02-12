# Test Evaluation Framework - Checklist

## Purpose
Strict evaluation framework to assess test meaningfulness, real-world applicability, and maintainability.

---

## 1. REAL-WORLD RELEVANCE (Weight: 35%)

### 1.1 Business Scenario Coverage
- [ ] **A1**: Tests reflect actual user workflows/journeys
- [ ] **A2**: Tests cover edge cases that occur in production (not just theoretical)
- [ ] **A3**: Tests validate business rules, not just technical implementation
- [ ] **A4**: Test data resembles production data patterns
- [ ] **A5**: Tests cover failure scenarios users actually encounter

**RED FLAGS:**
- Tests validate internal state without business meaning
- Tests check technical constraints that have no user impact
- Test scenarios never happen in real usage
- Tests focus on "what could go wrong" vs "what does go wrong"

### 1.2 User Value Verification
- [ ] **B1**: Tests verify outcomes users care about (not internal mechanics)
- [ ] **B2**: Tests would catch bugs users would report
- [ ] **B3**: Tests validate user-facing error messages/codes
- [ ] **B4**: Tests ensure data consistency from user perspective

**RED FLAGS:**
- Tests pass but feature is broken for users
- Tests verify state changes invisible to users
- Tests check implementation details, not behavior

---

## 2. MOCKING STRATEGY (Weight: 30%)

### 2.1 Mock Usage Assessment
- [ ] **C1**: Mocks are limited to infrastructure/external dependencies only
- [ ] **C2**: Core business logic is NOT mocked
- [ ] **C3**: Mocking depth is ≤ 2 levels (not mocking mocks)
- [ ] **C4**: Tests use real objects for domain models/value objects
- [ ] **C5**: Mock behaviors reflect actual implementation contracts

**RED FLAGS:**
- Mocking domain services/business logic
- Tests become "mock verification" instead of behavior tests
- Tests pass with incorrect mock behavior
- Over-mocking makes tests test nothing real
- Mock setup longer than actual test logic

### 2.2 Mock Realism
- [ ] **D1**: Mock return values are realistic (not just nulls/empty lists)
- [ ] **D2**: Mock failures simulate actual error conditions
- [ ] **D3**: Mock state changes mirror real implementation
- [ ] **D4**: Timing/sequence constraints are realistic

**RED FLAGS:**
- Mocks always succeed (no failure scenarios)
- Mock data is simplified to point of unrealism
- Mocks bypass validations that real code enforces

### 2.3 Sociable vs Solitary Balance
- [ ] **E1**: Integration tests exist for critical paths (not just unit tests)
- [ ] **E2**: Unit tests don't duplicate integration test coverage
- [ ] **E3**: Clear distinction between unit/integration/e2e tests

---

## 3. TEST MAINTAINABILITY (Weight: 20%)

### 3.1 Fragility Assessment
- [ ] **F1**: Tests don't break when refactoring implementation (stable interface)
- [ ] **F2**: Tests avoid checking call counts/order unless critical
- [ ] **F3**: Tests don't depend on exact internal method calls
- [ ] **F4**: Tests don't verify private method behavior
- [ ] **F5**: Tests are independent (no shared state/order dependency)

**RED FLAGS:**
- Tests break on non-breaking code changes
- Tests verify "how" instead of "what"
- Tests coupled to implementation details
- Mock verification checks internal mechanics

### 3.2 Readability & Clarity
- [ ] **G1**: Test name clearly states scenario + expected outcome
- [ ] **G2**: Arrange-Act-Assert pattern is clear
- [ ] **G3**: Test fits on one screen (< 50 lines)
- [ ] **G4**: No complex logic in test code (loops/conditions)
- [ ] **G5**: Setup is minimal and focused

**RED FLAGS:**
- Test name is generic ("testMethod1", "shouldWork")
- Test has nested conditionals/loops
- Excessive setup (>20 lines)
- Hard to determine what is being tested

### 3.3 Duplication & Organization
- [ ] **H1**: No redundant tests (same scenario tested multiple times)
- [ ] **H2**: Test utilities/helpers reduce duplication
- [ ] **H3**: Tests grouped by feature/scenario, not by type
- [ ] **H4**: Each test has single responsibility

**RED FLAGS:**
- 5+ tests doing essentially the same thing
- Copy-paste test code with minor variations
- Tests organized by "Boundary/Constraint" instead of feature

---

## 4. BUG DETECTION EFFECTIVENESS (Weight: 15%)

### 4.1 Mutation Testing Mindset
- [ ] **I1**: If I introduce a bug, will this test catch it?
- [ ] **I2**: If I remove a line of code, will test fail?
- [ ] **I3**: Tests verify correct behavior, not just "no exceptions"
- [ ] **I4**: Assertions are specific (not just "result != null")

**RED FLAGS:**
- Tests pass even with obvious bugs
- Tests only check happy path
- Weak assertions (only checking nullity/type)
- Tests don't verify complete state changes

### 4.2 Regression Prevention
- [ ] **J1**: Tests would catch common regression patterns
- [ ] **J2**: Tests cover historically buggy areas
- [ ] **J3**: Tests verify fixes stay fixed

---

## 5. TESTING ANTI-PATTERNS (Automatic Fail)

- [ ] **ANTI-1**: Test only verifies mocks were called (London School extreme)
- [ ] **ANTI-2**: Test has no assertions (or only verify() calls)
- [ ] **ANTI-3**: Test always passes regardless of implementation
- [ ] **ANTI-4**: Test is actually just code coverage filler
- [ ] **ANTI-5**: Test duplicates what another test already covers
- [ ] **ANTI-6**: Test requires production code changes to pass
- [ ] **ANTI-7**: Test setup is more complex than code under test
- [ ] **ANTI-8**: "Liar test" - passes even when feature is broken

---

## SCORING SYSTEM

### Individual Test Score
- **Excellent (90-100%)**: Meaningful, maintainable, tests real behavior
- **Good (75-89%)**: Solid test with minor issues
- **Acceptable (60-74%)**: Provides value but has problems
- **Poor (40-59%)**: Limited value, consider refactoring
- **Worthless (0-39%)**: Delete or completely rewrite

### Category Scores
Weight scores by percentages above:
- Real-World Relevance: 35%
- Mocking Strategy: 30%
- Maintainability: 20%
- Bug Detection: 15%

---

## EVALUATION PROCESS

For each test file:
1. Read the test file completely
2. Identify the feature/use case being tested
3. Evaluate against checklist criteria
4. Document RED FLAGS found
5. Assign score per category
6. Calculate weighted total
7. Provide verdict: Keep As-Is / Refactor / Delete
8. Document specific improvements needed

---

## OUTPUT FORMAT

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

## KEY QUESTIONS TO ASK

1. **"So What?" Test**: If this test fails, what actual problem does it indicate?
2. **"Realism Test"**: Could this scenario happen in production?
3. **"Refactor Test"**: If I rename variables/methods, does test break?
4. **"Mock Test"**: Am I testing my code or testing my mocks?
5. **"Value Test"**: Does this test justify its maintenance cost?

---

## COMMON TEST SMELLS TO DETECT

### Meaningless Tests
- Testing getters/setters only
- Testing framework behavior
- Testing private methods
- Testing trivial logic
- Redundant coverage

### Over-Mocking
- Mocking value objects
- Mocking everything in collaboration chain
- Mock returning mock returning mock
- Verifying internal method calls

### Fragile Tests
- Asserting on exact exception messages
- Verifying call order unnecessarily
- Checking internal state
- Depending on test execution order

### Maintenance Nightmares
- Tests with 100+ lines of setup
- Tests requiring test data files
- Tests with complex loops/conditionals
- Tests that are harder to understand than code

---

## PASS/FAIL CRITERIA

### Must Have (Non-negotiable)
- At least one meaningful assertion
- Tests actual code behavior (not just mocks)
- Independent from other tests
- Name describes what it tests

### Should Have
- Reflects real user scenario
- Would catch actual bugs
- Maintainable (<50 lines)
- Clear arrange-act-assert

### Nice to Have
- Tests edge cases that matter
- Fast execution (<100ms)
- Self-documenting
- Easy to debug when failing
