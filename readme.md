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
# Minimum requirement (recommended)
pip install semgrep

# Test
semgrep --version
```

> **Note**: LLM sẽ tự cài tools khác nếu cần theo `auto-install.md`

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

## Auto-Install Dependencies

Skill tự động cài đặt các dependencies cần thiết:

| Tool | Install Method |
|------|---------------|
| SpotBugs | Maven/Gradle plugin |
| PMD | Maven/Gradle plugin |
| Semgrep | cURL + pip |
| JaCoCo | Maven/Gradle plugin |
| FindSecBugs | Maven plugin |

```bash
# Maven - thêm vào pom.xml tự động
mvn spotbugs:check

# Gradle - thêm vào build.gradle tự động
gradle spotbugsMain

# Semgrep - cài qua curl
curl -sSL https://semgrep.dev/install.sh | sh
```

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
