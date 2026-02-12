# Code Review Skill

## Trigger
- "review code", "check code"
- "code này có vấn đề gì không"

## Prerequisites

**Windows PATH (run ONCE per session):**
```bash
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
```

---

## Concept: Multi-Pass Review

AI review 1 lần dễ bỏ sót. Chia thành nhiều pass nhỏ, mỗi pass focus 1 loại lỗi:

```
Pass 1: Static Tools    → PMD, Semgrep (catch style, security cơ bản)
Pass 2: AI - Security   → Focus CHỈ security issues
Pass 3: AI - Logic      → Focus CHỈ business logic, null safety
Pass 4: AI - Resources  → Focus CHỈ resource leaks, performance
Pass 5: AI - Structure  → Focus CHỈ architecture, design
```

**Sau mỗi pass:** Đánh dấu lines đã có findings → pass sau focus vào vùng chưa bị flag.

---

## Execution

### Pass 1: Static Analysis

#### 1.1 PMD + CPD
```bash
./tools/pmd-bin-7.0.0/bin/pmd check -d <file> -R rulesets/java/quickstart.xml -f json
./tools/pmd-bin-7.0.0/bin/pmd cpd --minimum-tokens 50 -d ./src --language java
```

#### 1.2 Semgrep
```bash
semgrep --config "p/java" --config "p/owasp-top-ten" --json <file>
```

#### 1.3 IntelliJ MCP (nếu có)
```
get_file_problems(<file_path>)
```

**→ Ghi nhận:** Lines có findings từ static tools.

---

### Pass 2: AI - Security Focus

**CHỈ tập trung security, KHÔNG nghĩ về cái khác:**

- [ ] SQL injection (string concat trong query?)
- [ ] XSS (user input → response?)
- [ ] Path traversal (user input trong file path?)
- [ ] Command injection (Runtime.exec với input?)
- [ ] Hardcoded secrets/credentials
- [ ] Unsafe deserialization
- [ ] Missing input validation
- [ ] Sensitive data trong logs

**→ Ghi nhận:** Lines có security issues.

---

### Pass 3: AI - Logic & Null Safety Focus

**CHỈ tập trung logic, KHÔNG nghĩ về security:**

- [ ] Business logic đúng requirements?
- [ ] Edge cases được handle?
- [ ] Null checks ở boundaries
- [ ] Chain calls có thể NPE: `user.getProfile().getAddress()`
- [ ] Optional usage đúng cách
- [ ] Race conditions trong shared state
- [ ] Error handling: catch specific, không empty

**→ Ghi nhận:** Lines có logic issues.

---

### Pass 4: AI - Resource & Performance Focus

**CHỈ tập trung resources, KHÔNG nghĩ về logic:**

- [ ] try-with-resources cho I/O, streams
- [ ] Connection closing (DB, HTTP)
- [ ] N+1 queries (loop với DB call)
- [ ] Object creation trong loops
- [ ] String concat trong loops (`+=`)
- [ ] Blocking I/O trong async context

**→ Ghi nhận:** Lines có resource/perf issues.

---

### Pass 5: AI - Structure & Design Focus

**CHỈ tập trung architecture:**

#### File/Class Size
| Metric | Warning |
|--------|---------|
| File > 500 lines | Tách nhỏ |
| Method > 30 lines | Extract methods |

#### Layer Separation
```
BAD: Scene → Manager → Controller → Manager (đan xen)
GOOD: Scene → Controller → Services → Model (rõ ràng)
```

#### AI Code Smells
| Pattern | Detection |
|---------|-----------|
| Duplication | CPD > 50 tokens |
| Hallucinated APIs | Unresolved references |
| Over-engineering | Interface với 1 impl |
| Magic Numbers | Hardcoded values |

---

### Pass 6: Logging Quality (optional)

- [ ] Log format chuẩn (parseable)
- [ ] Log cả success VÀ error
- [ ] Error codes rõ ràng
- [ ] Không log sensitive data

```java
// BAD
log.error("Error");

// GOOD
log.error("Payment failed: userId={}, errorCode={}", userId, code, e);
```

---

## Aggregation

### Confidence từ Multi-Pass
| Detected by | Confidence |
|-------------|------------|
| 1 pass | 70% - kiểm tra lại |
| 2 passes | 90% - likely real |
| 3+ passes | 98% - confirmed |

### Priority
```
CRITICAL: Security issues
HIGH: Logic bugs, resource leaks
MEDIUM: Performance, design
LOW: Style, suggestions
```

---

## Output Format

```markdown
## Code Review: [FileName]
**Score**: X/10
**Verdict**: [Pass / Needs Work / Critical Issues]

### Pass Summary
| Pass | Focus | Findings |
|------|-------|----------|
| 1 Static | PMD, Semgrep | X issues |
| 2 Security | AI | Y issues |
| 3 Logic | AI | Z issues |
| 4 Resources | AI | W issues |
| 5 Structure | AI | V issues |

### Multi-Pass Confirmations (High Confidence)
- [LINE XX] Detected by Pass 1 + 3 → 90% confidence

### Critical Issues (phải fix)
- [LINE XX] [SECURITY] SQL injection...

### Warnings (nên fix)
- [LINE XX] [LOGIC] Potential NPE...

### Suggestions
- Consider extracting method at line XX
```

---

## Rules
- Mỗi pass CHỈ focus 1 loại vấn đề
- KHÔNG cố tìm tất cả trong 1 pass
- Issues detected nhiều passes = high confidence
- Priority: Security > Logic > Resources > Structure
