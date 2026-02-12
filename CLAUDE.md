# Zest Skill - Code Quality Booster

## Available Skills

| Trigger | Skill File | Description |
|---------|-----------|-------------|
| "review code" | `skills/code-review.md` | Review code với PMD, Semgrep + AI |
| "review test" | `skills/test-review.md` | Đánh giá chất lượng test |
| "generate test" | `skills/test-generation.md` | Sinh test JUnit 5 |

## Experience (Project-specific)

Nếu project có file `experience.md`, đọc trước khi review để biết các lỗi hay gặp.

## How to Use Skills

1. **FIRST (Windows only)**: Run PATH setup below
2. Check if tools are installed, if not → run `skills/auto-install.md`
3. Đọc skill file tương ứng với user request
4. Follow step-by-step instructions
5. Output theo format định nghĩa

## Windows PATH Setup (REQUIRED - run ONCE per session)

**Run this BEFORE any semgrep command:**
```bash
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
```

## Tools Installation (No Maven Required!)

### Semgrep (required)
```bash
pip install semgrep
```

### PMD (works on source code, no compile)

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
