#!/bin/bash
set -e

source dev-container-features-test-lib

check "node-22-version" bash -c "node --version | grep -E '^v22\\.' && echo 'Node 22 installed'"

check "npm-compatible" bash -c "npm --version && echo 'NPM is compatible'"

check "claude-runs-on-node22" bash -c "(command -v claude || command -v claude-code) && echo 'Claude CLI available on Node 22'"

reportResults