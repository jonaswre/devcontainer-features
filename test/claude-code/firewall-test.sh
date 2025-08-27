#!/bin/bash
set -e

echo "Testing Claude Code firewall functionality..."

# This test verifies that the firewall properly blocks unauthorized domains
# when enableFirewall is true

# First check if firewall is supposed to be enabled
if [ "${ENABLEFIREWALL:-true}" != "true" ]; then
    echo "⚠️ Firewall is disabled, skipping firewall tests"
    exit 0
fi

# Check if the firewall initialization script exists
if [ ! -f /usr/local/bin/init-firewall.sh ]; then
    echo "❌ Firewall script not found at /usr/local/bin/init-firewall.sh"
    exit 1
fi
echo "✅ Firewall script exists"

# Check if we have sudo permissions for firewall
if ! sudo -n true 2>/dev/null; then
    echo "❌ Cannot initialize firewall - sudo not configured"
    exit 1
fi

# Initialize the firewall
if ! sudo /usr/local/bin/init-firewall.sh; then
    echo "❌ Failed to initialize firewall"
    echo "Container must be run with --cap-add=NET_ADMIN --cap-add=NET_RAW"
    exit 1
fi

echo "Firewall initialized, testing network restrictions..."

# Test allowed domains (should succeed)
echo "Testing allowed domains..."
if curl -s --max-time 5 https://api.github.com/zen > /dev/null 2>&1; then
    echo "✅ GitHub API accessible (allowed)"
else
    echo "❌ GitHub API blocked (should be allowed)"
    exit 1
fi

if curl -s --max-time 5 https://registry.npmjs.org > /dev/null 2>&1; then
    echo "✅ NPM registry accessible (allowed)"
else
    echo "❌ NPM registry blocked (should be allowed)"
    exit 1
fi

# Test blocked domains (should fail)
echo "Testing blocked domains..."
if curl -s --max-time 5 https://google.com > /dev/null 2>&1; then
    echo "❌ google.com accessible (should be blocked)"
    exit 1
else
    echo "✅ google.com blocked (expected)"
fi

if curl -s --max-time 5 https://facebook.com > /dev/null 2>&1; then
    echo "❌ facebook.com accessible (should be blocked)"
    exit 1
else
    echo "✅ facebook.com blocked (expected)"
fi

if curl -s --max-time 5 https://twitter.com > /dev/null 2>&1; then
    echo "❌ twitter.com accessible (should be blocked)"
    exit 1
else
    echo "✅ twitter.com blocked (expected)"
fi

echo ""
echo "Firewall test passed! ✨"
echo "✅ Allowed domains are accessible"
echo "✅ Unauthorized domains are blocked"