#!/bin/bash
set -e

source dev-container-features-test-lib

TOTAL_TESTS=0
PASSED_TESTS=0

run_check() {
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    if check "$@"; then
        PASSED_TESTS=$((PASSED_TESTS + 1))
    fi
}

echo "Running Claude Code Integration Tests"
echo "======================================"

run_check "node-installed" node --version
run_check "npm-installed" npm --version
run_check "git-installed" git --version

run_check "env-configured" bash -c "[ \"\$CLAUDE_CODE_DEVCONTAINER\" = 'true' ]"

run_check "claude-cli" bash -c "command -v claude || command -v claude-code"

run_check "dev-tools-rg" command -v rg
run_check "dev-tools-fzf" command -v fzf
run_check "dev-tools-jq" command -v jq
run_check "dev-tools-bat" command -v bat

if [ "${ENABLEFIREWALL:-true}" = "true" ]; then
    run_check "firewall-script" bash -c "[ -f /usr/local/bin/init-firewall.sh ]"
    run_check "firewall-executable" bash -c "[ -x /usr/local/bin/init-firewall.sh ]"
    run_check "iptables-installed" command -v iptables
    run_check "ipset-installed" command -v ipset
fi

if [ "${INSTALLZSH:-true}" = "true" ]; then
    run_check "zsh-installed" command -v zsh
fi

if [ -n "${PROXYURL:-}" ]; then
    run_check "proxy-http" bash -c "[ \"\$HTTP_PROXY\" = '${PROXYURL}' ]"
    run_check "proxy-https" bash -c "[ \"\$HTTPS_PROXY\" = '${PROXYURL}' ]"
fi

run_check "workspace-dir" bash -c "[ -d /workspace ]"

echo ""
echo "Integration Test Summary"
echo "========================"
echo "Tests run: $TOTAL_TESTS"
echo "Tests passed: $PASSED_TESTS"

if [ "$PASSED_TESTS" -eq "$TOTAL_TESTS" ]; then
    echo "✅ All integration tests passed!"
else
    echo "❌ Some tests failed: $((TOTAL_TESTS - PASSED_TESTS)) failures"
fi

reportResults