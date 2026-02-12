# Zest Skill

AdaBoost-inspired code quality analysis skills for LLM agents (Claude Code, Cursor, VS Code).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Installation

### Quick Install (Clone)

```bash
# Clone vào project của bạn
git clone https://github.com/nmnhut-it/zest-skill.git .claude/zest-skill

# Hoặc dùng submodule
git submodule add https://github.com/nmnhut-it/zest-skill.git .claude/zest-skill
```

### Setup Claude Code

Thêm reference vào `CLAUDE.md` của project:

```markdown
## Skills

When user asks for code review, read and follow:
- `.claude/zest-skill/skills/code-quality-booster.md` (boost, deep check)
- `.claude/zest-skill/skills/auto-install.md` (setup tools)
```

### Install Analysis Tools

```bash
# 1. Semgrep (required)
pip install semgrep

# 2. PMD standalone (recommended - no Maven needed)
curl -L -o pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
unzip pmd.zip -d ./tools/

# 3. Verify
semgrep --version          # Should show 1.151.0+
./tools/pmd-bin-7.0.0/bin/pmd --version  # PMD 7.0.0
```

<details>
<summary><strong>Windows PATH Issue (click to expand)</strong></summary>

After `pip install semgrep`, the executable may not be in PATH. Auto-fix:

```bash
# Bash/Git Bash (Windows) - auto-detect Scripts path and add to PATH
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
```

```powershell
# PowerShell - auto-detect and add to PATH
$env:PATH += ";$(python -c "import subprocess; r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True); loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0]; print(loc.replace('site-packages','Scripts'))")"
```

Or use helper scripts: `scripts/find-semgrep.bat run --version`

</details>

> **Note**: LLM sẽ tự cài tools nếu cần theo `auto-install.md`

---

## Tech Stack

- **Runtime**: TypeScript / Node.js
- **Dependency Auto-Install**: Maven, Gradle, cURL (tự động cài các tools cần thiết)
- **IDE Support**: IntelliJ IDEA 2025.2+, VS Code, Cursor, Claude Code

## Features

- **Code Quality Booster** - AdaBoost-inspired iterative analysis với multi-pass detection
- Code Review skill với IntelliJ Inspections + Static Analysis
- Test Generation skill với JaCoCo coverage boosting
- Security Audit skill với Semgrep + FindSecBugs
- AI Code Smell detection

## Quick Start

```bash
# Install dependencies
npm install

# Build
npm run build

# Run
npm start
```

## Supported Tools

| Tool | Purpose | Install | Needs Compile |
|------|---------|---------|---------------|
| **Semgrep** | Security + patterns | `pip install semgrep` | No |
| **PMD** | Code style + best practices | Download zip | No |
| **CPD** (included in PMD) | Duplicate code detection | Included | No |
| SpotBugs | Bug patterns | Download zip | Yes (.class) |
| FindSecBugs | Security (SpotBugs plugin) | Download jar | Yes |

### CPD - Copy-Paste Detector (AI Code Smell!)

PMD bao gồm CPD - detect duplicate code, đặc biệt hữu ích cho AI-generated code:

```bash
# Detect duplicate code (minimum 100 tokens)
./tools/pmd-bin-7.0.0/bin/pmd cpd --minimum-tokens 100 -d ./src --language java

# Output to file
./tools/pmd-bin-7.0.0/bin/pmd cpd --minimum-tokens 50 -d ./src --language java --format csv > cpd-report.csv
```

**Supported languages:** Java, JavaScript, TypeScript, Python, Go, C/C++, C#, Kotlin, Swift, Ruby, PHP, Scala, và 20+ ngôn ngữ khác.

## IntelliJ MCP Server Setup

<details>
<summary><strong>Hướng dẫn cài đặt IntelliJ MCP Server</strong></summary>

### Yêu cầu
- IntelliJ IDEA 2025.2 trở lên
- AI Assistant plugin enabled

### Bước 1: Enable MCP Server trong IntelliJ

1. Mở **Settings** (`Ctrl+Alt+S`)
2. Đi đến **Tools > AI Assistant > MCP Server**
3. Check **Enable MCP Server**
4. Ghi nhớ port (mặc định: `63342`)

### Bước 2: Cấu hình MCP Client

**Claude Code** - thêm vào `~/.claude/settings.json`:
```json
{
  "mcpServers": {
    "intellij": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-client", "http://localhost:63342/api/mcp"]
    }
  }
}
```

**Cursor** - thêm vào `.cursor/mcp.json`:
```json
{
  "servers": {
    "intellij": {
      "url": "http://localhost:63342/api/mcp"
    }
  }
}
```

**VS Code + Continue** - thêm vào `.continuerc.json`:
```json
{
  "mcpServers": [
    {
      "name": "intellij",
      "url": "http://localhost:63342/api/mcp"
    }
  ]
}
```

### Bước 3: Verify Connection

Test connection bằng cách gọi tool:
```
get_file_text_by_path("pom.xml")
```

### Available Tools (30+)

| Category | Tools |
|----------|-------|
| File Ops | `get_file_text_by_path`, `create_new_file`, `replace_text_in_file`, `reformat_file` |
| Code Intel | `get_file_problems`, `get_symbol_info`, `rename_refactoring` |
| Search | `search_in_files_by_text`, `search_in_files_by_regex`, `find_files_by_glob` |
| Execution | `execute_terminal_command`, `execute_run_configuration` |
| Project | `get_project_dependencies`, `get_project_modules`, `list_directory_tree` |

</details>

## Skills Documentation

### Code Quality Booster (Flagship)

```bash
# Trigger
"boost analysis cho UserService"
"thorough review"
"deep check this code"
```

**AdaBoost-inspired iterative analysis:**

```
Pass 1 (Static)  →  Pass 2 (AI Semantic)  →  Pass 3 (Deep Specialized)
      ↓                    ↓                        ↓
  SpotBugs              Focus on               Security deep-dive
  PMD                   UNCOVERED              Performance profiling
  IntelliJ              regions                AI-smell detection
  Semgrep               (weighted)             Logging analysis
```

**Key Features:**
- Mỗi pass focus vào những gì pass trước MISSED (weighted focusing)
- Multi-pass confirmation: findings detected bởi 2-3 passes = higher confidence
- Auto-convergence: stop khi quality đạt hoặc diminishing returns
- Self-healing suggestions với code fixes

**Output includes:**
- Boosting progression table
- Weight distribution visualization
- Multi-pass confirmations with confidence scores
- Tool summary across all passes

### Code Review Skill

```bash
# Trigger
"review UserService.java"
"code này có vấn đề gì không?"
```

Flow: Read source → IntelliJ Inspections → SpotBugs/PMD → AI Semantic Review → Output

### Test Generation Skill

```bash
# Trigger
"generate tests cho OrderService"
"tăng coverage lên 80%"
```

Flow: Analyze class → Generate JUnit 5 tests → Compile check → Run + JaCoCo → Boosting loop

### Security Audit Skill

```bash
# Trigger
"security review file này"
"scan OWASP vulnerabilities"
```

Flow: Semgrep scan → FindSecBugs → OWASP Top 10 checklist → Report

### Test Evaluation Skill

```bash
# Trigger
"evaluate test này có tốt không"
"test quality check"
```

Flow: Read test → Checklist evaluation → Score (Real-world 35%, Mocking 30%, Maintainability 20%, Bug Detection 15%) → Verdict

## Project Structure

```
zest-skill/
├── src/
│   ├── types/
│   │   ├── skill.ts      # Core type definitions
│   │   ├── booster.ts    # Boosting-specific types (AdaBoost)
│   │   └── index.ts
│   └── index.ts
├── skills/               # Markdown skill files for LLM agents
│   ├── code-quality-booster.md  # Flagship: AdaBoost iterative analysis
│   ├── code-review.md           # Static analysis + AI semantic review
│   ├── test-evaluation.md       # Test quality assessment
│   ├── test-generation.md       # JUnit 5 + coverage boosting
│   └── security-audit.md        # OWASP Top 10 + Semgrep
├── package.json
├── tsconfig.json
└── readme.md
```

## License

MIT
