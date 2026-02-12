# Zest Skill

Bộ kỹ năng phân tích chất lượng code cho LLM (Claude Code, Cursor, VS Code).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Cài đặt cho Claude Code

```bash
curl -sL https://raw.githubusercontent.com/nmnhut-it/zest-skill/deploy/scripts/install-zest-skill.sh | bash
```

Sau đó thêm vào `CLAUDE.md` của project:
```markdown
Read and follow: .claude/zest-skill/CLAUDE.md
```

---

## Cách dùng

Nói với LLM:
```
review code src/MyService.java
```
hoặc
```
review test src/test/MyServiceTest.java
```
hoặc
```
generate test cho src/MyService.java
```

**Dùng prompt trực tiếp** (copy/paste):
- `prompts/review-code.md` - Review code
- `prompts/review-test.md` - Review test
- `prompts/generate-test.md` - Sinh test

---

## Nguyên lý hoạt động

### Vấn đề

AI review code rất mạnh, nhưng có đặc tính:
- **Bắt giỏi**: Logic errors, business rule violations, design issues
- **Hay bỏ sót**: Code style, naming conventions, security patterns cơ bản

### Giải pháp

**1. Static tools bù đắp điểm mù của AI**

| Tool | Phát hiện |
|------|-----------|
| **PMD** | Code style, naming, best practices |
| **CPD** | Code copy-paste (đặc biệt code AI sinh ra) |
| **Semgrep** | SQL injection, XSS, OWASP Top 10 |

**2. AI chạy nhiều vòng, mỗi vòng tập trung 1 loại lỗi**

```
Vòng 1: Static tools (PMD, Semgrep) → bắt lỗi cơ bản
Vòng 2: AI tập trung vùng chưa bị flag → logic, business rules
Vòng 3: AI đào sâu → security, performance, edge cases
```

Thay vì yêu cầu AI "review tất cả", chia nhỏ thành các vòng chuyên biệt giúp AI tập trung hơn và bắt được nhiều lỗi hơn.

**3. Độ tin cậy tăng khi nhiều nguồn cùng phát hiện**
- 1 nguồn phát hiện → kiểm tra lại
- 2+ nguồn phát hiện → xác nhận chắc chắn

---

## Các skill có sẵn

| Trigger | Skill | Mô tả |
|---------|-------|-------|
| "review code" | `code-review.md` | Review code với PMD, Semgrep + AI |
| "review test" | `test-review.md` | Đánh giá chất lượng test |
| "generate test" | `test-generation.md` | Sinh test JUnit 5 |

---

## License

MIT
