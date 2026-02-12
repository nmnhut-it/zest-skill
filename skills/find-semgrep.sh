#!/bin/bash
# Find semgrep executable path without requiring PATH update
# Usage: source scripts/find-semgrep.sh && $SEMGREP --version
# Or:    scripts/find-semgrep.sh run --version

set -e

# Find semgrep Scripts directory from pip installation
find_semgrep_path() {
    local location
    location=$(pip show -f semgrep 2>/dev/null | grep "Location:" | cut -d' ' -f2)

    if [ -z "$location" ]; then
        echo ""
        return 1
    fi

    # Scripts folder is sibling to site-packages
    local scripts_dir="${location/site-packages/Scripts}"

    # Check if semgrep exists there
    if [ -f "$scripts_dir/semgrep" ]; then
        echo "$scripts_dir/semgrep"
    elif [ -f "$scripts_dir/semgrep.exe" ]; then
        echo "$scripts_dir/semgrep.exe"
    else
        # Fallback: check if semgrep is in PATH
        if command -v semgrep &>/dev/null; then
            command -v semgrep
        else
            echo ""
            return 1
        fi
    fi
}

# Export path for sourcing
SEMGREP_PATH=$(find_semgrep_path)
export SEMGREP_PATH
export SEMGREP="$SEMGREP_PATH"

# If called with "run" argument, execute semgrep with remaining args
if [ "$1" = "run" ]; then
    shift
    if [ -n "$SEMGREP_PATH" ]; then
        "$SEMGREP_PATH" "$@"
    else
        echo "ERROR: semgrep not found. Install with: pip install semgrep" >&2
        exit 1
    fi
elif [ "$1" = "path" ]; then
    # Just print the path
    if [ -n "$SEMGREP_PATH" ]; then
        echo "$SEMGREP_PATH"
    else
        echo "ERROR: semgrep not found" >&2
        exit 1
    fi
fi
