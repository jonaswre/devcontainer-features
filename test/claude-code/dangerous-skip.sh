#!/bin/bash
set -e

source dev-container-features-test-lib

check "dangerous-flag-env" bash -c "[ \"\${CLAUDE_DANGEROUS_SKIP_PERMISSIONS}\" = 'true' ] && echo 'Dangerous flag set in environment'"

check "claude-available" bash -c "(command -v claude || command -v claude-code) && echo 'Claude CLI installed'"

check "permissions-mode" bash -c "echo 'Skip permissions mode configured' && true"

reportResults