# Zest-Skill

AdaBoost-inspired code quality skills for LLM agents.

## Install

```bash
git clone -b deploy https://github.com/nmnhut-it/zest-skill.git .claude/zest-skill
```

## Skills

| File | Trigger |
|------|---------|
| `code-quality-booster.md` | "boost", "deep check" |
| `auto-install.md` | "setup tools" |
| `code-review.md` | "review code" |
| `test-generation.md` | "generate test" |
| `test-evaluation.md` | "evaluate test" |
| `security-audit.md` | "security scan" |

## Setup

Add to `CLAUDE.md`:

```markdown
## Skills
Read: `.claude/zest-skill/skills/code-quality-booster.md`
```

## Tools

```bash
# PMD (includes CPD for duplicate detection)
curl -L -o pmd.zip https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip
unzip pmd.zip -d ./tools/
```

MIT License
