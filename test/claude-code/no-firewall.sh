#!/bin/bash
set -e

source dev-container-features-test-lib

# Test basics work without firewall
check "node" node --version
check "claude-cli" bash -c "command -v claude || command -v claude-code"
check "no-firewall-script" bash -c "[ ! -f /usr/local/bin/init-firewall.sh ]"

# Test network is unrestricted (google should be accessible)
check "network-unrestricted" bash -c "curl -s --max-time 2 https://google.com >/dev/null 2>&1"

reportResults