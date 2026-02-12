# Code Quality Booster Skill

## Trigger
- User yêu cầu review code toàn diện
- User muốn "boost", "thorough review", "deep check"
- User cần comprehensive analysis với high confidence

## Concept: AdaBoost-Inspired Iterative Analysis

```
Pass 1 (Static)  →  Pass 2 (AI Semantic)  →  Pass 3 (Deep Specialized)
      ↓                    ↓                        ↓
  SpotBugs              Focus on               Security deep-dive
  PMD                   UNCOVERED              Performance profiling
  IntelliJ              regions                AI-smell detection
  Semgrep               (weighted)             Logging analysis
```

**Key Insight**: Mỗi pass focus vào những gì pass trước MISSED (như AdaBoost weak learners).

---

## Phase 1: Initialize

### Step 1.1: Read Target Files
```
1. Đọc file(s) cần analyze
2. Tính cyclomatic complexity mỗi method
3. Đánh dấu method boundaries
```

### Step 1.2: Initialize Weight Map
```
Mỗi line bắt đầu với weight = 1.0

Complexity adjustment:
- Line trong method có CC > 10: weight *= (1 + CC/10)
- Method boundary lines: weight *= 1.2
```

### Step 1.3: Set Convergence Criteria
```
maxPasses: 3
qualityThreshold: 85
minNewFindingsRatio: 0.05 (5%)
diminishingReturns: 0.02 (2%)
timeoutSeconds: 300
```

---

## Phase 2: Boosting Loop

### Pass 1: Broad Static Analysis

**Tools:**
```bash
# SpotBugs (bytecode analysis)
mvn spotbugs:check -Dspotbugs.xmlOutput=true -Dspotbugs.effort=Max

# PMD (source analysis)
mvn pmd:check -Dformat=xml

# Semgrep (security patterns)
semgrep --config "p/java" --json <file>
```

**IntelliJ MCP (nếu có):**
```
Tool: get_file_problems(<file_path>)
→ 600+ inspections: null analysis, resource leak, unused code
```

**After Pass 1:**
```
For each line:
  If line has finding:
    weight *= 0.5  (đã caught, giảm focus)
  Else:
    weight *= 1.5  (missed, tăng focus cho Pass 2)
```

### Pass 2: AI Semantic Review

**Focus regions:** Lines với weight > 1.2 (không có findings từ Pass 1)

**Checklist cho high-weight regions:**

#### 2.1 Business Logic
- [ ] Logic đúng theo requirements?
- [ ] Edge cases được handle?
- [ ] Race conditions potential?

#### 2.2 Design Quality
- [ ] Single Responsibility adherence?
- [ ] Dependency injection proper?
- [ ] Interface segregation?

#### 2.3 Error Handling
- [ ] Exceptions specific (không catch Exception)?
- [ ] Error recovery logic?
- [ ] Không có empty catch blocks?

#### 2.4 Context-Dependent Issues
- [ ] Thread safety của shared state?
- [ ] Resource cleanup đúng cách?
- [ ] Null safety boundaries?

**After Pass 2:**
```
Update weights:
  Finding found: weight *= 0.5
  No finding: weight *= 1.5

Record focus regions for Pass 3
```

### Pass 3: Deep Specialized Checks

**Activate specializations based on Pass 1+2 findings:**

#### 3.1 Security Deep-Dive
Nếu Pass 1/2 có security-related findings:
```
- OWASP Top 10 manual checklist
- FindSecBugs deep scan
- Semgrep security rules expanded
```

| Check | Pattern |
|-------|---------|
| SQL Injection | String concat in query |
| XSS | User input to response |
| Path Traversal | User input in file path |
| Command Injection | Runtime.exec with input |
| Deserialization | ObjectInputStream.readObject |

#### 3.2 Performance Profiling
Nếu có loops, DB calls, hoặc heavy computation:

| Issue | Detection |
|-------|-----------|
| N+1 Query | Loop containing repository call |
| Blocking I/O | Sync call in async context |
| String Concat | `+=` in loop |
| Memory Leak | Static collections growing |
| Inefficient Loop | O(n^2) patterns |

#### 3.3 Logging Analysis
Check all log statements:

| Issue | Pattern |
|-------|---------|
| Sensitive Data | `log.*password\|token\|secret` |
| Missing Stacktrace | `log.error` without exception param |
| Wrong Level | ERROR for expected conditions |
| String Concat | `log.info("User " + userId)` |

#### 3.4 AI-Generated Code Smell
Nếu nghi ngờ AI-generated:

| Smell | Detection | Ratio vs Human |
|-------|-----------|----------------|
| Excessive Duplication | PMD CPD > 10% | 8x higher |
| Hallucinated APIs | Unresolved references | Common |
| Over-Engineering | Abstract với 1 impl | 3x higher |
| Shallow Error Handling | `catch (Exception) + RuntimeException` | 5x higher |
| Missing Edge Cases | No null/boundary tests | Common |

---

## Phase 3: Aggregation

### Step 3.1: Deduplicate Findings
```
Group findings by (file, line, category)
Keep highest severity if duplicates
```

### Step 3.2: Apply Boost Multipliers
```
For each finding:
  passCount = count(detectedInPasses)

  boostMultiplier =
    passCount == 1 ? 1.0 :
    passCount == 2 ? 1.5 :
    passCount == 3 ? 2.0

  finalScore = baseSeverityScore * boostMultiplier

  confidence =
    passCount == 1 ? 70% :
    passCount == 2 ? 90% :
    passCount == 3 ? 98%
```

### Step 3.3: Calculate Quality Score
```
totalIssueScore = sum(finding.finalScore for all findings)
maxPossibleScore = lineCount * 10

qualityScore = 100 - (totalIssueScore / maxPossibleScore * 100)
qualityScore = clamp(qualityScore, 0, 100)
```

---

## Phase 4: Self-Healing (Optional)

### Step 4.1: Generate Fix Suggestions
Cho mỗi finding với severity >= HIGH:
```
1. Analyze context around the line
2. Generate suggested fix code
3. Estimate confidence of fix
```

### Step 4.2: Apply with Verification
```
If user approves:
  1. Apply fix
  2. Re-run affected Pass
  3. Verify finding resolved
  4. If not resolved: rollback + try alternative
```

---

## Convergence Rules

Stop boosting khi:
```
1. passNumber >= maxPasses (3)
2. qualityScore >= qualityThreshold (85)
3. newFindings / totalFindings < minNewFindingsRatio (5%)
4. Two consecutive passes với delta < diminishingReturns (2%)
5. elapsed >= timeoutSeconds (300)
```

---

## Output Format

```markdown
## Code Quality Booster Report: [FileName]

### Summary
**Final Score**: 82/100
**Verdict**: Good - Minor improvements recommended
**Convergence**: Stopped at Pass 3 (diminishing returns < 2%)
**Total Findings**: 18 (12 static + 5 AI + 1 deep)

### Boosting Progression
| Pass | New Findings | Cumulative | Delta | Focus |
|------|--------------|------------|-------|-------|
| 1 (Static)     | 12 | 12 | -    | Full file scan |
| 2 (AI Semantic)| 5  | 17 | +42% | Lines 45-89, 120-150 (high weight) |
| 3 (Deep)       | 1  | 18 | +6%  | Security deep-dive triggered |

### Multi-Pass Confirmations (High Confidence)
Issues detected by multiple passes - very likely real problems:

| Line | Category | Original | Boosted | Passes | Confidence |
|------|----------|----------|---------|--------|------------|
| 23   | Security | HIGH     | CRITICAL (x1.5) | 1, 3 | 95% |
| 45   | Resource | MEDIUM   | HIGH (x1.5)     | 1, 2 | 90% |

### Weight Distribution
```
Lines 1-50:    ████████░░ (80% reviewed, avg weight 1.2)
Lines 51-100:  ██████████ (100% reviewed, avg weight 0.8)
Lines 101-150: ████░░░░░░ (40% reviewed, avg weight 1.8) ← needs attention
```

### Findings by Pass

#### Pass 1: Static Analysis
| Line | Severity | Category | Issue | Tool |
|------|----------|----------|-------|------|
| 23   | HIGH     | NullPointer | Potential NPE on `user.getName()` | SpotBugs |
| 45   | MEDIUM   | Resource | Stream not closed | IntelliJ |

#### Pass 2: AI Semantic Review
**Focus regions**: Lines 67-89, 130-145 (weight > 1.2)

| Line | Severity | Category | Issue |
|------|----------|----------|-------|
| 72   | HIGH     | Logic | Race condition in cache update |
| 89   | MEDIUM   | Design | SRP violation - method does 3 things |

#### Pass 3: Deep Specialized
**Specializations activated**: Security, Performance

| Line | Severity | Category | Issue | Multi-Pass? |
|------|----------|----------|-------|-------------|
| 23   | CRITICAL | Security | SQL injection (NPE was hiding it) | Pass 1 + 3 |

### Tool Summary
| Tool | Critical | High | Medium | Low |
|------|----------|------|--------|-----|
| SpotBugs | 0 | 2 | 5 | 3 |
| PMD | 0 | 1 | 4 | 8 |
| IntelliJ | 1 | 3 | 2 | 12 |
| Semgrep | 1 | 2 | 1 | 0 |
| **AI Review** | 0 | 2 | 3 | 1 |
| **Deep Checks** | 1 | 0 | 0 | 0 |

### Self-Healing Suggestions
[ ] **Fix #1** (Line 23): Use PreparedStatement for SQL query
    ```java
    // Before
    String query = "SELECT * FROM users WHERE id = " + userId;

    // After
    PreparedStatement ps = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
    ps.setString(1, userId);
    ```
    Confidence: 95%

[ ] **Fix #2** (Line 45): Add try-with-resources
    ```java
    // Before
    InputStream is = new FileInputStream(file);

    // After
    try (InputStream is = new FileInputStream(file)) {
        // ...
    }
    ```
    Confidence: 98%

### Recommendations
1. **[CRITICAL]** Fix SQL injection at line 23 - highest priority
2. **[HIGH]** Address race condition at line 72 before production
3. **[MEDIUM]** Refactor line 89 to follow SRP
4. **[LOW]** Clean up resource warnings
```

---

## Rules

- **Iterative focus**: Mỗi pass tập trung vào những gì pass trước missed
- **Weight-driven**: Lines không có findings → tăng weight → focus nhiều hơn
- **Multi-pass confirmation**: Findings detected bởi nhiều passes = high confidence
- **Convergence-aware**: Tự động stop khi diminishing returns
- **Self-healing optional**: Chỉ apply fix với user confirmation

---

## Comparison: Single Pass vs Boosting

| Metric | Single Pass Review | Code Quality Booster |
|--------|-------------------|---------------------|
| Coverage | 60-70% | 90-95% |
| False Negatives | High | Low (multi-pass) |
| Confidence | Single tool | Multi-tool confirmation |
| Focus | Fixed | Adaptive (weights) |
| Iteration | Manual | Automatic |
