# Zest Skill

Bộ kỹ năng phân tích chất lượng code cho LLM (Claude Code, Cursor, VS Code), lấy cảm hứng từ thuật toán AdaBoost.

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

Các công cụ review code truyền thống chạy 1 lần rồi báo kết quả. Nhưng:
- Mỗi tool có điểm mù (PMD bỏ sót cái SpotBugs bắt được)
- Không ưu tiên vùng code nguy hiểm
- Tool tĩnh không phát hiện được "mùi code AI"

### Giải pháp: Phân tích đa vòng kiểu AdaBoost

Lấy ý tưởng từ thuật toán AdaBoost: **mỗi vòng tập trung vào những gì vòng trước BỎ SÓT**.

```
Vòng 1 (Static Tools)  →  Vòng 2 (AI Focus)  →  Vòng 3 (Deep)
         ↓                       ↓                    ↓
     PMD, CPD               Vùng chưa bị          Security
     Semgrep                "soi" ở Vòng 1        Performance
                                                  AI-smell
```

### Công cụ sử dụng

| Tool | Là gì | Phát hiện |
|------|-------|-----------|
| **PMD** | Phân tích mã nguồn Java | Code style, best practices, code smell |
| **CPD** | Copy-Paste Detector (trong PMD) | Code bị copy-paste, đặc biệt code AI sinh ra |
| **Semgrep** | Pattern matching cho security | SQL injection, XSS, secrets, OWASP Top 10 |

### Ý tưởng chính

**1. Tập trung vào vùng chưa được "soi"**
- Vòng 1: các tool tĩnh quét toàn bộ code, đánh dấu dòng đã kiểm tra
- Vòng 2: AI tập trung review những dòng mà Vòng 1 KHÔNG phát hiện vấn đề
- Lý do: code "trông sạch" với tool tĩnh có thể chứa lỗi logic, business rule sai

**2. Độ tin cậy tăng khi nhiều tool cùng phát hiện**
- 1 tool phát hiện → bình thường
- 2 tools phát hiện → tin cậy cao
- 3 tools phát hiện → xác nhận chắc chắn

---

## Phương pháp

| Pha | Mô tả |
|-----|-------|
| **1. Khởi tạo** | Đọc file, xác định độ phức tạp từng method |
| **2. Vòng 1 (Static)** | Chạy PMD, CPD, Semgrep → đánh dấu dòng đã kiểm tra |
| **3. Vòng 2 (AI Review)** | AI tập trung review vùng chưa bị flag, kiểm tra logic |
| **4. Vòng 3 (Deep)** | Đào sâu security, performance, phát hiện code AI |
| **5. Báo cáo** | Tổng hợp findings, ưu tiên issue được nhiều tool xác nhận |

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
