#!/bin/bash
set -e

source dev-container-features-test-lib

check "node-version" node --version
check "npm-version" npm --version
check "git-available" git --version

check "claude-code-env" bash -c "[ \"\$CLAUDE_CODE_DEVCONTAINER\" = 'true' ] && echo 'Environment configured'"

check "claude-cli-exists" bash -c "command -v claude || command -v claude-code || (echo 'Claude CLI not found' && exit 1)"

if command -v claude &>/dev/null; then
    check "claude-version" claude --version || true
elif command -v claude-code &>/dev/null; then
    check "claude-version" claude-code --version || true
fi

check "dev-tools-ripgrep" bash -c "command -v rg && echo 'Ripgrep installed'"
check "dev-tools-fzf" bash -c "command -v fzf && echo 'FZF installed'"

if [ -f /usr/local/bin/init-firewall.sh ]; then
    check "firewall-script" bash -c "[ -x /usr/local/bin/init-firewall.sh ] && echo 'Firewall script executable'"
fi

check "working-directory" bash -c "[ -d /workspace ] && echo 'Workspace directory exists'"

reportResults