#!/bin/bash
set -e

# Duplicate test - verifies the feature can be installed twice without issues
echo "Testing duplicate installation of Claude Code feature..."

# The feature should already be installed from the first test
# Just verify it's still working

# Check Claude Code is still available
if command -v claude &> /dev/null; then
    echo "✅ Claude Code still available after duplicate installation"
else
    echo "❌ Claude Code not found after duplicate installation"
    exit 1
fi

# Check Node.js is still available
if command -v node &> /dev/null; then
    echo "✅ Node.js still available"
else
    echo "❌ Node.js not found"
    exit 1
fi

echo "Duplicate installation test passed! ✨"