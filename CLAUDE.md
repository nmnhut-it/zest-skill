# Zest Skill - Code Quality Booster

## Available Skills

| Trigger | Skill File | Description |
|---------|-----------|-------------|
| "setup tools", "install" | `skills/auto-install.md` | Auto-install PMD (no Maven needed) |
| "boost", "thorough review", "deep check" | `skills/code-quality-booster.md` | AdaBoost iterative analysis |
| "review code", "check quality" | `skills/code-review.md` | Static + AI review |
| "review test", "check test" | `skills/test-review.md` | Test code review |
| "generate test", "write test" | `skills/test-generation.md` | JUnit 5 test gen |
| "security scan", "owasp" | `skills/security-audit.md` | Security audit |
| "evaluate test", "test quality" | `skills/test-evaluation.md` | Test quality check |

## Experience (Project-specific)

Nếu project có file `experience.md`, đọc trước khi review để biết các lỗi hay gặp.

## How to Use Skills

1. **FIRST**: Check if tools are installed, if not → run `skills/auto-install.md`
2. Đọc skill file tương ứng với user request
3. Follow step-by-step instructions
4. Output theo format định nghĩa

## Tools Installation (No Maven Required!)

### Quick Install (LLM tự chạy)

**PMD** (works on source code, no compile):
```bash
# Windows PowerShell
Invoke-WebRequest -Uri "https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip" -OutFile pmd.zip
Expand-Archive pmd.zip -DestinationPath ./tools/

# Unix/Mac
curl -L -o pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
unzip pmd.zip -d ./tools/
```

**Run:**
```bash
# PMD (needs Java runtime only)
./tools/pmd-bin-7.0.0/bin/pmd check -d ./src -R rulesets/java/quickstart.xml -f json

# CPD - Copy-Paste Detector (AI code smell!)
./tools/pmd-bin-7.0.0/bin/pmd cpd --minimum-tokens 50 -d ./src --language java
```

### Fallback Priority

```
1. PMD standalone → Needs Java runtime, no compile
2. SpotBugs standalone → Needs compiled .class files
3. Grep patterns → Last resort, basic detection
```

## Code Quality Booster - Quick Reference

AdaBoost-inspired 3-pass analysis:

```
Pass 1 (Static)  →  Pass 2 (AI Focus)  →  Pass 3 (Deep)
   PMD               High-weight           Security
   CPD               uncovered             Performance
   (SpotBugs)        regions               AI-smell
                                           Logging
```

**Minimum required**: PMD only (can run full analysis)

Weight formula:
- No finding: weight × 1.5 (increase focus next pass)
- Has finding: weight × 0.5 (decrease focus)

Multi-pass boost:
- 1 pass detect: × 1.0
- 2 passes detect: × 1.5 (high confidence)
- 3 passes detect: × 2.0 (confirmed issue)

## IntelliJ MCP (Optional, Enhanced)

If IntelliJ 2025.2+ available:
```
get_file_problems(<file>) → 600+ inspections (best Java analysis)
get_symbol_info(<file>, <line>, <col>) → Symbol documentation
execute_terminal_command(<cmd>) → Run any command
```
