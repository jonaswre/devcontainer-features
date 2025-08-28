#!/bin/bash
set -e

# Import test library
source dev-container-features-test-lib

# Test essentials only - KISS!
check "node" node --version
check "npm" npm --version
check "git" git --version
check "claude-cli" bash -c "command -v claude || command -v claude-code"

# Test firewall script is installed
check "firewall-script" bash -c "[ -x /usr/local/bin/init-firewall.sh ]"

# Report results
reportResults