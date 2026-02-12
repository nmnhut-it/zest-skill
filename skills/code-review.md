# Code Review Skill

## Trigger
- User yêu cầu review code, review file, review PR/MR
- User hỏi "code này có vấn đề gì không"
- User yêu cầu check quality

## Prerequisites
Kiểm tra tools có sẵn:
- IntelliJ MCP: `get_file_problems`, `get_symbol_info`
- Terminal: `mvn`, `gradle`, `semgrep`, `git`

---

## Execution Steps

### Step 1: Thu thập Context
```
1. Đọc file cần review
2. Xem project dependencies (Maven/Gradle)
3. Nếu review PR: chạy `git diff main..HEAD -- <file_path>`
4. Tìm related files (imports, usages)
```

### Step 2: Static Analysis

#### 2.1 IntelliJ Inspections (nếu có MCP)
```
Tool: get_file_problems(<file_path>)
→ 600+ inspections: null analysis, resource leak, unused code, type mismatch
```

#### 2.2 SpotBugs (bytecode analysis)
```bash
mvn spotbugs:check -Dspotbugs.xmlOutput=true -Dspotbugs.effort=Max
# Parse: target/spotbugsXml.xml
```

#### 2.3 PMD (source analysis)
```bash
mvn pmd:check -Dformat=xml
# Parse: target/pmd.xml
```

#### 2.4 Semgrep (security + patterns)
```bash
semgrep --config "p/java" --config "p/owasp-top-ten" --json <file>
```

### Step 3: AI Semantic Review

#### 3.1 Security Checklist
- [ ] SQL injection, XSS, path traversal
- [ ] Hardcoded secrets/credentials
- [ ] Unsafe deserialization
- [ ] SSRF vulnerabilities

#### 3.2 Null Safety
- [ ] Optional usage đúng cách
- [ ] Null checks ở boundaries
- [ ] @NonNull/@Nullable annotations

#### 3.3 Resource Management
- [ ] try-with-resources cho I/O
- [ ] Connection closing (DB, HTTP)
- [ ] Stream closing

#### 3.4 Concurrency
- [ ] Race conditions
- [ ] Thread safety của shared state
- [ ] Deadlock potential

#### 3.5 Error Handling
- [ ] Catch blocks không empty
- [ ] Exception specificity (không catch Exception)
- [ ] Error recovery logic

#### 3.6 Performance
- [ ] N+1 queries
- [ ] Unnecessary object creation trong loops
- [ ] Blocking I/O trong async context

#### 3.7 Design
- [ ] Single Responsibility adherence
- [ ] Dependency injection usage
- [ ] Interface segregation

### Step 4: AI-Generated Code Smells
Nếu code là AI-generated, check thêm:

| Pattern | Detection |
|---------|-----------|
| Excessive Duplication | PMD CPD, 8x higher than human code |
| Hallucinated APIs | `get_file_problems` shows unresolved references |
| Over-engineering | Abstract class với 1 impl, unnecessary generics |
| Shallow Error Handling | `catch (Exception e) { log; throw RuntimeException }` |
| Missing Edge Cases | No null/empty/boundary tests |
| Verbose but Shallow | Long code with little substance |

### Step 5: Code Structure Review
Từ victory_wheel notes:
- [ ] File size reasonable (< 500 lines)
- [ ] Clear separation: Model / View / Controller
- [ ] No flow đan xen giữa layers
- [ ] Magic numbers có comments
- [ ] TypeScript/strong typing thay vì @typedef

---

## Output Format

```
## Code Review: [FileName]
**Score**: X/10
**Verdict**: [Pass / Needs Work / Critical Issues]

### Critical Issues (phải fix)
- [LINE XX] [CATEGORY] Mô tả + code suggestion

### Warnings (nên fix)
- [LINE XX] [CATEGORY] Mô tả + code suggestion

### Suggestions (nice to have)
- Mô tả improvement

### Positive Notes
- Điểm tốt của code

### Static Analysis Summary
- IntelliJ: X errors, Y warnings
- SpotBugs: X findings
- PMD: X findings
- Semgrep: X findings
```

---

## Rules
- KHÔNG list tất cả findings - chỉ những cái QUAN TRỌNG
- LUÔN giải thích TẠI SAO đó là vấn đề
- LUÔN đưa code suggestion cụ thể
- Priority: Security > Bugs > Performance > Design > Style
- Nếu IntelliJ đã báo → không lặp lại
