#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Test essentials only - KISS!
check "node" node --version
check "npm" npm --version
check "git" git --version
check "claude-cli" bash -c "command -v claude || command -v claude-code"

# Test firewall is active (default: enableFirewall=true)
check "firewall-script-exists" bash -c "[ -f /usr/local/bin/init-firewall.sh ]"

# Test firewall blocks unauthorized domains
check "google-blocked" bash -c "! curl -s --max-time 2 https://google.com >/dev/null 2>&1"

# Test firewall allows authorized domains
check "github-allowed" bash -c "curl -s --max-time 2 https://api.github.com >/dev/null 2>&1"

# Report results
reportResults