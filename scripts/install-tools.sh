#!/bin/bash
# Install analysis tools for code review
# Usage: ./scripts/install-tools.sh

set -e

TOOLS_DIR="./tools"
REPORTS_DIR="$TOOLS_DIR/reports"

echo "=== Installing Code Analysis Tools ==="

# Create directories
mkdir -p "$TOOLS_DIR" "$REPORTS_DIR"

# 1. Install Semgrep via pip
echo ""
echo "[1/2] Installing Semgrep..."
if command -v semgrep &> /dev/null; then
    echo "  Semgrep already installed: $(semgrep --version)"
else
    if command -v pip3 &> /dev/null; then
        pip3 install semgrep
    elif command -v pip &> /dev/null; then
        pip install semgrep
    else
        echo "  ERROR: pip not found. Install Python first."
        exit 1
    fi
    echo "  Semgrep installed: $(semgrep --version)"
fi

# 2. Install PMD standalone
echo ""
echo "[2/2] Installing PMD..."
PMD_VERSION="7.0.0"
PMD_DIR="$TOOLS_DIR/pmd-bin-$PMD_VERSION"

if [ -d "$PMD_DIR" ]; then
    echo "  PMD already installed at $PMD_DIR"
else
    PMD_URL="https://github.com/pmd/pmd/releases/download/pmd_releases%2F$PMD_VERSION/pmd-dist-$PMD_VERSION-bin.zip"
    echo "  Downloading PMD $PMD_VERSION..."
    curl -L -o "$TOOLS_DIR/pmd.zip" "$PMD_URL"
    echo "  Extracting..."
    unzip -q -o "$TOOLS_DIR/pmd.zip" -d "$TOOLS_DIR"
    rm "$TOOLS_DIR/pmd.zip"
    echo "  PMD installed at $PMD_DIR"
fi

# Verify
echo ""
echo "=== Installation Complete ==="
echo ""
echo "Tools Status:"
echo "  Semgrep: $(semgrep --version 2>/dev/null || echo 'Not in PATH')"
echo "  PMD: $PMD_DIR/bin/pmd --version"
echo ""
echo "Usage:"
echo "  # Semgrep"
echo "  semgrep --config 'p/java' ./src"
echo ""
echo "  # PMD"
echo "  $PMD_DIR/bin/pmd check -d ./src -R rulesets/java/quickstart.xml -f json"
