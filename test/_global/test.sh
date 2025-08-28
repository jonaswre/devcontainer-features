#!/bin/bash
set -e

source dev-container-features-test-lib

check "node-installed" node --version
check "npm-installed" npm --version
check "git-installed" git --version
check "environment-var" bash -c "[ -n \"\$CLAUDE_CODE_DEVCONTAINER\" ] && echo 'Set'"

check "claude-cli" bash -c "command -v claude || command -v claude-code || echo 'Not found'"

check "ripgrep" bash -c "command -v rg && rg --version | head -n1 || echo 'Not installed'"
check "fzf" bash -c "command -v fzf && fzf --version || echo 'Not installed'"

reportResults