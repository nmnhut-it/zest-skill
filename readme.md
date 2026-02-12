# Zest Skill

AdaBoost-inspired code quality analysis skills for LLM agents (Claude Code, Cursor, VS Code).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Installation

### One-Line Install (Git Bash)

```bash
curl -sL https://raw.githubusercontent.com/nmnhut-it/zest-skill/deploy/scripts/install-zest-skill.sh | bash
```

This will:
- Clone zest-skill to `.claude/zest-skill/`
- Install Semgrep and PMD
- Setup PATH automatically

### Manual Install

```bash
# 1. Clone to your project
git clone -b deploy https://github.com/nmnhut-it/zest-skill.git .claude/zest-skill

# 2. Install tools
pip install semgrep
curl -L -o pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
unzip pmd.zip -d ./tools/

# 3. Windows only - run ONCE per session before using semgrep
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"
```

### Setup Claude Code

Add to your project's `CLAUDE.md`:

```markdown
## Skills
Read and follow: .claude/zest-skill/CLAUDE.md
```

---

## How It Works

### The Problem

Traditional code review tools run once and report findings. But:
- Each tool has blind spots (PMD misses what SpotBugs catches)
- No prioritization of high-risk areas
- Static tools can't detect AI-generated code smells

### The Solution: AdaBoost-Inspired Analysis

Inspired by AdaBoost machine learning algorithm, we use **iterative multi-pass analysis** where each pass focuses on what previous passes MISSED.

```
Pass 1 (Static Tools)  →  Pass 2 (AI Focus)  →  Pass 3 (Deep Specialized)
        ↓                       ↓                        ↓
    PMD, CPD               High-weight              Security
    Semgrep                uncovered                Performance
    SpotBugs               regions                  AI-smell
```

### Key Concepts

**1. Weight-Based Focusing**
- Each line starts with weight = 1.0
- Lines NOT flagged by Pass 1 get higher weight (× 1.5)
- Pass 2 focuses on high-weight regions
- Result: Problems in "clean-looking" code get caught

**2. Multi-Pass Confidence**
- Issue found by 1 tool: normal confidence
- Issue found by 2 tools: high confidence (× 1.5)
- Issue found by 3 tools: confirmed (× 2.0)

**3. Convergence**
- Stop when quality score stabilizes
- Or when diminishing returns detected
- Prevents infinite analysis loops

---

## Methodology

### Phase 1: Initialize
```
1. Read target files
2. Calculate cyclomatic complexity per method
3. Initialize weight map (all lines = 1.0)
4. Adjust weights for complex methods (CC > 10)
```

### Phase 2: Static Analysis (Pass 1)
```
1. Run PMD → code style, best practices
2. Run CPD → duplicate detection (AI smell!)
3. Run Semgrep → security patterns
4. (Optional) Run SpotBugs → bug patterns
5. Collect findings, mark covered lines
6. Update weights: covered lines × 0.5, uncovered × 1.5
```

### Phase 3: AI Semantic Review (Pass 2)
```
1. Focus on HIGH-WEIGHT regions (uncovered by Pass 1)
2. AI reviews for:
   - Logic errors
   - Business rule violations
   - Naming inconsistencies
   - Missing error handling
3. Update weights based on findings
```

### Phase 4: Deep Specialized (Pass 3)
```
1. Security deep-dive (OWASP Top 10)
2. Performance analysis
3. AI code smell detection:
   - Over-abstraction
   - Copy-paste with minor changes
   - Inconsistent patterns
4. Logging/monitoring gaps
```

### Phase 5: Report
```
1. Aggregate findings across all passes
2. Apply multi-pass confidence boost
3. Generate prioritized report:
   - Critical (multi-pass confirmed)
   - High (security/performance)
   - Medium (code quality)
   - Low (style)
```

---

## Available Skills

| Trigger | Skill | Description |
|---------|-------|-------------|
| "boost", "deep check" | `code-quality-booster.md` | AdaBoost multi-pass analysis |
| "review code" | `code-review.md` | Static + AI review |
| "security scan" | `security-audit.md` | OWASP + Semgrep |
| "generate test" | `test-generation.md` | JUnit 5 with coverage boost |
| "review test" | `test-review.md` | Test quality evaluation |
| "setup tools" | `auto-install.md` | Install PMD, Semgrep |

---

## Supported Tools

| Tool | Purpose | Needs Compile |
|------|---------|---------------|
| **Semgrep** | Security patterns | No |
| **PMD** | Code style, best practices | No |
| **CPD** | Duplicate detection | No |
| SpotBugs | Bug patterns | Yes (.class) |

### Why These Tools?

- **Semgrep**: Pattern-based, great for security rules, works on source
- **PMD + CPD**: Fast, extensive Java rules, includes duplicate detector
- **SpotBugs**: Bytecode analysis catches what source analysis misses

---

## Example Output

```
## Boosting Analysis Report

### Pass Summary
| Pass | Tool | Findings | Weight Impact |
|------|------|----------|---------------|
| 1 | PMD | 5 | -2.5 (covered) |
| 1 | CPD | 2 duplicates | -1.0 |
| 2 | AI Review | 3 | +4.5 (uncovered) |
| 3 | Security | 1 critical | +2.0 |

### Multi-Pass Confirmations
- [CRITICAL] SQL Injection at line 45 (PMD + Semgrep + AI = 3x confirmed)
- [HIGH] Null pointer risk at line 78 (PMD + AI = 2x confirmed)

### Findings by Priority
1. **Critical**: SQL injection in UserRepository.java:45
2. **High**: Missing null check in OrderService.java:78
3. **Medium**: Duplicate code blocks (3 instances)
...
```

---

## Project Structure

```
zest-skill/
├── skills/                    # LLM skill files
│   ├── code-quality-booster.md
│   ├── code-review.md
│   ├── security-audit.md
│   ├── test-generation.md
│   └── auto-install.md
├── scripts/
│   ├── install-zest-skill.sh  # One-line installer
│   └── deploy.sh
└── CLAUDE.md                  # Entry point for LLMs
```

---

## License

MIT
