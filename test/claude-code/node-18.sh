#!/bin/bash
set -e

source dev-container-features-test-lib

check "node-18-version" bash -c "node --version | grep -E '^v18\\.' && echo 'Node 18 installed'"

check "npm-compatible" bash -c "npm --version && echo 'NPM is compatible'"

check "claude-runs-on-node18" bash -c "(command -v claude || command -v claude-code) && echo 'Claude CLI available on Node 18'"

reportResults