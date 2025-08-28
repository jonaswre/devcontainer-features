#!/bin/bash
set -e

echo "Testing Claude Code with firewall enabled (strict security test)..."

# This test specifically validates firewall functionality
# It should only run when we have proper capabilities

# Check if firewall script exists
if [ ! -f /usr/local/bin/init-firewall.sh ]; then
    echo "❌ Firewall script not installed"
    exit 1
fi

# Check if firewall is already initialized
echo "Checking firewall status..."
if iptables -L OUTPUT -n 2>/dev/null | grep -q "allowed-domains"; then
    echo "✅ Firewall already initialized and active"
else
    # Try to initialize if not already running
    echo "Firewall not active, attempting to initialize..."
    
    # Check sudo permissions
    if ! sudo -n true 2>/dev/null; then
        echo "❌ Sudo not configured for firewall"
        exit 1
    fi
    
    if ! sudo /usr/local/bin/init-firewall.sh; then
        echo "❌ CRITICAL: Failed to initialize firewall"
        echo "This test requires --cap-add=NET_ADMIN --cap-add=NET_RAW"
        exit 1
    fi
    
    echo "✅ Firewall initialized"
fi

# Wait for rules to settle
sleep 2

# Test blocking of unauthorized domains - MUST be blocked
echo "Verifying unauthorized domains are blocked..."

test_blocked_domain() {
    local domain=$1
    if curl -s --connect-timeout 3 --max-time 5 "https://${domain}" > /dev/null 2>&1; then
        echo "❌ SECURITY FAILURE: ${domain} is accessible (should be blocked)"
        return 1
    else
        echo "✅ ${domain} blocked"
        return 0
    fi
}

test_allowed_domain() {
    local domain=$1
    if curl -s --connect-timeout 3 --max-time 5 "https://${domain}/zen" > /dev/null 2>&1; then
        echo "✅ ${domain} accessible (allowed)"
        return 0
    else
        echo "❌ ${domain} blocked (should be allowed)"
        return 1
    fi
}

# Test blocked domains
failed=0
for domain in google.com facebook.com twitter.com amazon.com; do
    test_blocked_domain "$domain" || failed=1
done

# Test allowed domains
test_allowed_domain "api.github.com" || failed=1

if [ $failed -eq 1 ]; then
    echo "❌ Firewall test failed - security not properly configured"
    exit 1
fi

echo ""
echo "✅ Firewall security test passed! All unauthorized domains blocked."