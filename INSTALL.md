# Installation Guide

## Quick Install (Recommended)

### Option 1: Clone vào project của bạn

```bash
# Clone vào thư mục .claude/skills
git clone https://github.com/nmnhut-it/zest-skill.git .claude/zest-skill

# Hoặc dùng git submodule (recommended cho team)
git submodule add https://github.com/nmnhut-it/zest-skill.git .claude/zest-skill
```

### Option 2: Copy CLAUDE.md reference

Thêm vào `CLAUDE.md` của project bạn:

```markdown
## External Skills

Đọc skills từ: `.claude/zest-skill/skills/`

| Trigger | Skill |
|---------|-------|
| "boost", "deep check" | `.claude/zest-skill/skills/code-quality-booster.md` |
| "review code" | `.claude/zest-skill/skills/code-review.md` |
| "setup tools" | `.claude/zest-skill/skills/auto-install.md` |
```

### Option 3: NPM Install (nếu publish lên npm)

```bash
npm install zest-skill --save-dev
```

Sau đó reference trong CLAUDE.md:
```markdown
Skills location: `node_modules/zest-skill/skills/`
```

---

## Setup cho Claude Code

### Step 1: Tạo CLAUDE.md trong project root

```markdown
# My Project

## Skills

Include skills từ zest-skill:

When user asks for code review or quality check:
1. Read `.claude/zest-skill/skills/auto-install.md` - check/install tools
2. Read `.claude/zest-skill/skills/code-quality-booster.md` - run analysis
3. Follow instructions in skill file
```

### Step 2: Install analysis tools

```bash
# Minimum requirement - Semgrep
pip install semgrep

# Optional - PMD standalone
# (LLM sẽ tự download nếu cần theo auto-install.md)
```

### Step 3: Test

Trong Claude Code, nói:
```
"boost analysis cho src/main/java/MyService.java"
```

---

## Setup cho Cursor

Thêm vào `.cursorrules`:

```markdown
## Code Quality Skills

When reviewing code or checking quality, follow instructions in:
- `.claude/zest-skill/skills/code-quality-booster.md`

Triggers:
- "boost", "deep check" → code-quality-booster.md
- "review" → code-review.md
- "security" → security-audit.md
```

---

## Setup cho VS Code + Continue

Thêm vào `.continuerules`:

```markdown
## External Skills

Skills location: .claude/zest-skill/skills/

Available skills:
- code-quality-booster.md: AdaBoost iterative analysis
- code-review.md: Static + AI review
- auto-install.md: Tool installation
```

---

## Directory Structure After Install

```
your-project/
├── .claude/
│   └── zest-skill/           # Cloned repo
│       ├── skills/
│       │   ├── code-quality-booster.md
│       │   ├── code-review.md
│       │   ├── auto-install.md
│       │   └── ...
│       ├── CLAUDE.md
│       └── package.json
├── CLAUDE.md                  # Your project's CLAUDE.md
├── src/
└── ...
```

---

## Verify Installation

### Check skills available
```bash
ls .claude/zest-skill/skills/
```

Expected output:
```
auto-install.md
code-quality-booster.md
code-review.md
security-audit.md
test-evaluation.md
test-generation.md
```

### Check tools
```bash
semgrep --version
```

---

## Update Skills

```bash
# If using git clone
cd .claude/zest-skill && git pull

# If using submodule
git submodule update --remote .claude/zest-skill
```

---

## Troubleshooting

### "Skill file not found"
- Check path: `.claude/zest-skill/skills/code-quality-booster.md`
- Ensure repo was cloned correctly

### "semgrep: command not found"
- Run: `pip install semgrep`
- Or ask Claude: "setup tools"

### "Permission denied"
- Windows: Run PowerShell as Administrator
- Unix: Use `sudo pip install semgrep`
