#!/bin/bash
set -e

echo "Testing Claude Code devcontainer feature..."

# This script runs inside the devcontainer after feature installation

# Test 1: Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not installed"
    exit 1
fi
echo "✅ Node.js installed: $(node --version)"

# Test 2: NPM is available
if ! command -v npm &> /dev/null; then
    echo "❌ NPM not installed"
    exit 1
fi
echo "✅ NPM installed: $(npm --version)"

# Test 3: Git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git not installed"
    exit 1
fi
echo "✅ Git installed"

# Test 4: Environment variable
if [ -n "$CLAUDE_CODE_DEVCONTAINER" ]; then
    echo "✅ Environment configured"
else
    echo "❌ Environment variable not set"
    exit 1
fi

# Test 5: Check for Claude Code (binary is named 'claude')
if command -v claude &> /dev/null; then
    echo "✅ Claude Code installed"
    claude --version || true
elif command -v claude-code &> /dev/null; then
    echo "✅ Claude Code installed (alternate name)"
    claude-code --version || true
else
    echo "❌ Claude Code not found"
    echo "Expected 'claude' command to be available after npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# Test 6: Check for status command
if command -v claude-code-status &> /dev/null; then
    echo "✅ Status command available"
else
    echo "⚠️  Status command not found (may be created during install)"
fi

# Test 7: Check for development tools
if command -v rg &> /dev/null; then
    echo "✅ Ripgrep installed"
fi

if command -v fzf &> /dev/null; then
    echo "✅ FZF installed"
fi

# Test 8: Check firewall functionality if enabled (SECURITY CRITICAL)
if [ "${ENABLEFIREWALL:-true}" = "true" ] && [ -f /usr/local/bin/init-firewall.sh ]; then
    echo "Testing firewall security..."
    
    # Check if sudoers is configured
    if ! sudo -n true 2>/dev/null; then
        echo "❌ Firewall sudo permissions not configured properly"
        exit 1
    fi
    
    # Initialize firewall
    if ! sudo /usr/local/bin/init-firewall.sh; then
        echo "❌ Failed to initialize firewall - security risk!"
        echo "Container must be run with --cap-add=NET_ADMIN --cap-add=NET_RAW"
        exit 1
    fi
    
    echo "Firewall initialized, testing blocking..."
    
    # Test that unauthorized domains are blocked (MUST FAIL if accessible)
    if curl -s --max-time 3 https://google.com > /dev/null 2>&1; then
        echo "❌ SECURITY FAILURE: google.com is accessible (should be blocked)"
        exit 1
    else
        echo "✅ google.com blocked"
    fi
    
    # Test that allowed domains still work
    if ! curl -s --max-time 3 https://api.github.com/zen > /dev/null 2>&1; then
        echo "❌ GitHub API blocked (should be allowed)"
        exit 1
    else
        echo "✅ GitHub API accessible"
    fi
    
    echo "✅ Firewall security verified - unauthorized domains blocked"
fi

echo ""
echo "Core tests passed! ✨"