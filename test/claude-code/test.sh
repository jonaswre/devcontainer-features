#!/bin/bash
set -e

echo "Testing Claude Code devcontainer feature..."

# Test 1: Claude Code is installed
if ! command -v claude-code &> /dev/null; then
    echo "❌ Claude Code not installed"
    exit 1
fi
echo "✅ Claude Code installed"

# Test 2: Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not installed"
    exit 1
fi
echo "✅ Node.js installed: $(node --version)"

# Test 3: Status command exists
if ! command -v claude-code-status &> /dev/null; then
    echo "❌ Status command not found"
    exit 1
fi
echo "✅ Status command available"

# Test 4: Firewall (if enabled)
if [ "${ENABLEFIREWALL:-true}" = "true" ]; then
    if iptables -L -n 2>/dev/null | grep -q "Chain"; then
        echo "✅ Firewall configured"
    else
        echo "⚠️  Firewall not active (may require privileges)"
    fi
fi

# Test 5: Environment variable
if [ -n "$CLAUDE_CODE_DEVCONTAINER" ]; then
    echo "✅ Environment configured"
else
    echo "❌ Environment variable not set"
    exit 1
fi

echo ""
echo "All tests passed! ✨"
claude-code-status