#!/bin/bash
set -e

source dev-container-features-test-lib

check "node-20" bash -c "node --version | grep -E '^v20\\.' && echo 'Node 20 installed'"

check "zsh-installed" bash -c "command -v zsh && echo 'ZSH available'"

check "firewall-configured" bash -c "[ -f /usr/local/bin/init-firewall.sh ] && echo 'Firewall script present'"

check "custom-domain" bash -c "grep -q 'custom.api.com' /usr/local/bin/init-firewall.sh && echo 'Custom domain added'"

check "api-key-source" bash -c "[ \"\${CLAUDE_API_KEY_SOURCE}\" = 'environment' ] && echo 'API key source configured'"

check "all-dev-tools" bash -c "command -v rg && command -v fzf && echo 'All dev tools installed'"

check "claude-full-setup" bash -c "(command -v claude || command -v claude-code) && echo 'Claude CLI in full setup'"

reportResults