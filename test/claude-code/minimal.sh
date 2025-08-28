#!/bin/bash
set -e

source dev-container-features-test-lib

check "no-zsh" bash -c "! command -v zsh 2>/dev/null && echo 'ZSH not installed' || echo 'ZSH from base image'"

check "no-firewall" bash -c "[ ! -f /usr/local/bin/init-firewall.sh ] && echo 'No firewall'"

check "basic-tools-only" bash -c "command -v node && command -v npm && echo 'Basic tools present'"

check "claude-minimal" bash -c "(command -v claude || command -v claude-code) && echo 'Claude CLI works in minimal setup'"

reportResults