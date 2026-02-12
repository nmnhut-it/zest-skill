# Security Audit Skill

## Trigger
- User yêu cầu security review, security scan
- Trước khi deploy, release
- User hỏi về vulnerabilities

---

## Execution Steps

### Step 1: Dependency Check (OWASP)

Từ Monitoring Code Quality: "Chỉ thực hiện khi gắn thêm thư viện mới"

```bash
# Gradle
./gradlew dependencyCheckAnalyze

# Maven
mvn org.owasp:dependency-check-maven:check
```

Output: `target/dependency-check-report.html`

### Step 2: Semgrep Scan

```bash
semgrep --config "p/java" --config "p/owasp-top-ten" --json <file_or_dir>
```

Parse JSON → list findings by severity.

### Step 3: SpotBugs + FindSecBugs

```bash
mvn spotbugs:check \
  -Dspotbugs.plugins=com.h3xstream.findsecbugs:findsecbugs-plugin:1.13.0
```

Focus categories: SECURITY, MALICIOUS_CODE

### Step 4: IntelliJ Inspections (nếu có MCP)

```
Tool: get_file_problems(<file_path>)
→ Filter security-related warnings
```

### Step 5: OWASP Top 10 Manual Review

| ID | Vulnerability | Check |
|----|---------------|-------|
| A01 | Broken Access Control | Authorization checks on every endpoint? |
| A02 | Cryptographic Failures | Hardcoded keys? Weak algorithms? Plaintext passwords? |
| A03 | Injection | SQL, LDAP, OS command, XSS - parameterized queries? |
| A04 | Insecure Design | Rate limiting? Input validation? Business logic flaws? |
| A05 | Security Misconfiguration | Default credentials? Verbose errors? CORS? |
| A06 | Vulnerable Components | Outdated dependencies? Known CVEs? |
| A07 | Auth Failures | Session management? Password policy? MFA? |
| A08 | Data Integrity | Deserialization? Unsigned updates? |
| A09 | Logging Failures | Sensitive data in logs? Missing audit trail? |
| A10 | SSRF | Unvalidated URLs? Internal network access? |

### Step 6: Java-Specific Security Checks

```java
// RED FLAGS to search for:

// SQL Injection
String query = "SELECT * FROM users WHERE id = " + userId;  // BAD
// Should use PreparedStatement

// Path Traversal
new File(basePath + userInput);  // BAD
// Should validate/sanitize userInput

// Command Injection
Runtime.getRuntime().exec("cmd " + userInput);  // BAD
ProcessBuilder with user input  // BAD

// XSS (in web apps)
response.getWriter().write(userInput);  // BAD
// Should encode output

// Deserialization
ObjectInputStream.readObject()  // on untrusted data = BAD

// Weak Crypto
Cipher.getInstance("DES")  // BAD, use AES
Cipher.getInstance("AES/ECB/...")  // BAD, use CBC/GCM
MessageDigest.getInstance("MD5")  // BAD for passwords
MessageDigest.getInstance("SHA1")  // BAD for passwords

// Hardcoded Secrets
String apiKey = "sk-1234..."  // BAD
String password = "admin123"  // BAD

// Unsafe CORS
@CrossOrigin("*")  // BAD in production

// Missing Input Validation
@RequestParam String id  // without @Valid or validation
@PathVariable used directly in file paths
```

### Step 7: Spring Security Checks (nếu dùng Spring)

- [ ] `@PreAuthorize` / `@Secured` on sensitive endpoints
- [ ] CSRF protection enabled (không disable trừ API-only)
- [ ] Session fixation protection
- [ ] Security headers (X-Frame-Options, CSP, etc.)
- [ ] Password encoder sử dụng BCrypt/Argon2

---

## Output Format

```
## Security Audit: [Project/File]
**Scan Date**: YYYY-MM-DD
**Risk Level**: [Critical / High / Medium / Low]

### Tool Findings Summary
| Tool | Critical | High | Medium | Low |
|------|----------|------|--------|-----|
| OWASP Dependency | X | X | X | X |
| Semgrep | X | X | X | X |
| FindSecBugs | X | X | X | X |

### Critical Issues (fix before deploy)
- [OWASP-XX] [File:Line] Description
  **Impact**: What can attacker do
  **Fix**: How to fix

### High Priority (fix this sprint)
- [Category] Description

### Medium Priority (fix when possible)
- [Category] Description

### Low / Info
- [Category] Description

### OWASP Top 10 Assessment
| ID | Status | Notes |
|----|--------|-------|
| A01 | PASS/FAIL | ... |
| A02 | PASS/FAIL | ... |
| ... | ... | ... |

### Recommendations
1. [Immediate action]
2. [Short-term action]
3. [Long-term improvement]
```

---

## Severity Classification

| Severity | Criteria |
|----------|----------|
| Critical | Exploitable remotely, no auth required, high impact |
| High | Exploitable with low complexity, significant impact |
| Medium | Requires specific conditions, moderate impact |
| Low | Minor impact, defense in depth |
| Info | Best practice, no direct vulnerability |

---

## Common False Positives

Verify before reporting:
- Test code flagged as vulnerable
- Dead/unreachable code
- Already mitigated by framework
- Development-only code paths
