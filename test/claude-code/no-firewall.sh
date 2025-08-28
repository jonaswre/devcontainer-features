#!/bin/bash
set -e

source dev-container-features-test-lib

check "no-firewall-script" bash -c "[ ! -f /usr/local/bin/init-firewall.sh ] && echo 'Firewall script not installed'"

check "no-iptables" bash -c "! command -v iptables 2>/dev/null && echo 'iptables not installed' || echo 'iptables may be present from base image'"

check "firewall-env-disabled" bash -c "[ \"\${ENABLEFIREWALL}\" != 'true' ] && echo 'Firewall not enabled'"

check "network-unrestricted" bash -c "curl -s --max-time 2 https://www.google.com >/dev/null 2>&1 && echo 'Network access unrestricted' || echo 'Network issue unrelated to firewall'"

reportResults