#!/bin/bash
# Deploy zest-skill to deploy branch
# Usage: ./scripts/deploy.sh

set -e

echo "=== Deploying Zest-Skill ==="
echo

# Ensure we're on master
git checkout master

# Get current commit message for reference
LAST_MSG=$(git log -1 --format="%s")
echo "Last commit: $LAST_MSG"

# Switch to deploy branch
echo
echo "Switching to deploy branch..."
git checkout deploy

# Checkout files from master (only deploy-able files)
echo
echo "Updating files from master..."
git checkout master -- CLAUDE.md
git checkout master -- skills/
git checkout master -- scripts/install-zest-skill.sh
git checkout master -- scripts/install-zest-skill.bat

# Check if there are changes
if ! git diff --staged --quiet; then
    echo
    echo "Changes detected, committing..."
    git commit -m "Deploy: $LAST_MSG"

    echo
    echo "Pushing to origin..."
    git push origin deploy
else
    echo
    echo "No changes to deploy."
fi

# Switch back to master
echo
echo "Switching back to master..."
git checkout master

echo
echo "=== Done ==="
echo
echo "Deploy branch updated: https://github.com/nmnhut-it/zest-skill/tree/deploy"
