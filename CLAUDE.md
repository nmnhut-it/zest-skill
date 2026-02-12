# Zest Skill - Code Quality Booster

## Available Skills

| Trigger | Skill File | Description |
|---------|-----------|-------------|
| "review code" | `skills/code-review.md` | Review code với PMD, Semgrep + AI |
| "review test" | `skills/test-review.md` | Đánh giá chất lượng test |
| "generate test" | `skills/test-generation.md` | Sinh test JUnit 5 |

## How to Use

1. **Windows only**: Run PATH setup (in skill file)
2. Đọc skill file tương ứng với user request
3. Follow step-by-step instructions
4. Output theo format định nghĩa

## Experience (Project-specific)

Nếu project có file `experience.md`, đọc trước khi review để biết các lỗi hay gặp.

## Tools Required

| Tool | Install | Purpose |
|------|---------|---------|
| **PMD** | Download zip, extract to `./tools/` | Code quality, CPD |
| **Semgrep** | `pip install semgrep` | Security scanning |

**Quick install:**
```bash
# PMD
curl -L -o pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
unzip pmd.zip -d ./tools/

# Semgrep
pip install semgrep
```

## IntelliJ MCP (Optional)

If IntelliJ 2025.2+ available:
```
get_file_problems(<file>) → 600+ inspections
get_symbol_info(<file>, <line>, <col>) → Symbol info
```
