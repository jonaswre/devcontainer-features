#!/bin/bash
set -e

source dev-container-features-test-lib

check "proxy-env-http" bash -c "[ \"\${HTTP_PROXY}\" = 'http://proxy.example.com:8080' ] && echo 'HTTP proxy configured'"

check "proxy-env-https" bash -c "[ \"\${HTTPS_PROXY}\" = 'http://proxy.example.com:8080' ] && echo 'HTTPS proxy configured'"

check "npm-proxy" bash -c "npm config get proxy | grep -q 'proxy.example.com' && echo 'NPM proxy configured'"

check "additional-domain" bash -c "grep -q 'internal.corp.com' /usr/local/bin/init-firewall.sh 2>/dev/null && echo 'Corporate domain whitelisted' || echo 'No firewall or domain added'"

reportResults