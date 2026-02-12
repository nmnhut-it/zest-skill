#!/bin/bash
# Install Zest-Skill for Claude Code
# Usage: curl -sL https://raw.githubusercontent.com/nmnhut-it/zest-skill/deploy/scripts/install-zest-skill.sh | bash

set -e

echo "=== Installing Zest-Skill ==="

# Create .claude directory
mkdir -p .claude

# Clone or update zest-skill
if [ -d ".claude/zest-skill" ]; then
    echo "Updating existing zest-skill..."
    cd .claude/zest-skill
    git pull
    cd ../..
else
    echo "Cloning zest-skill from GitHub..."
    git clone -b deploy https://github.com/nmnhut-it/zest-skill.git .claude/zest-skill
fi

# Install Semgrep
echo
echo "=== Installing Semgrep ==="
pip install semgrep

# Setup PATH for semgrep (Windows/Git Bash)
echo
echo "=== Setting up PATH ==="
export PATH="$PATH:$(python -c "import subprocess;r=subprocess.run(['pip','show','semgrep'],capture_output=True,text=True);loc=[l.split(': ',1)[1] for l in r.stdout.split('\n') if l.startswith('Location:')][0];p=loc.replace('site-packages','Scripts').replace(chr(92),'/');print('/'+p[0].lower()+p[2:] if len(p)>1 and p[1]==':' else p)")"

# Install PMD
echo
echo "=== Installing PMD ==="

mkdir -p tools/reports

if [ -d "tools/pmd-bin-7.0.0" ]; then
    echo "PMD already installed"
else
    echo "Downloading PMD 7.0.0..."
    curl -L -o tools/pmd.zip "https://github.com/pmd/pmd/releases/download/pmd_releases%2F7.0.0/pmd-dist-7.0.0-bin.zip"
    echo "Extracting..."
    unzip -o tools/pmd.zip -d tools/
    rm tools/pmd.zip
    echo "PMD installed"
fi

# Verify
echo
echo "=== Verifying ==="
semgrep --version && echo "Semgrep OK"
./tools/pmd-bin-7.0.0/bin/pmd --version && echo "PMD OK"

echo
echo "=== Done ==="
echo
echo "Skills: .claude/zest-skill/skills/"
echo "PMD:    tools/pmd-bin-7.0.0/bin/pmd"
echo
echo "Add this to your CLAUDE.md:"
echo '  Read and follow: .claude/zest-skill/CLAUDE.md'
