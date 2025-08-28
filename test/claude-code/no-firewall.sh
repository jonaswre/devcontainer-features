#!/bin/bash
set -e

source dev-container-features-test-lib

# Test basics work without firewall
check "node" node --version
check "claude-cli" bash -c "command -v claude || command -v claude-code"
check "no-firewall-script" bash -c "[ ! -f /usr/local/bin/init-firewall.sh ]"

reportResults