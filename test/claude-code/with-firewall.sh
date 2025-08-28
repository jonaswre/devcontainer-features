#!/bin/bash
set -e

source dev-container-features-test-lib

check "firewall-script-exists" bash -c "[ -f /usr/local/bin/init-firewall.sh ] && echo 'Firewall script present'"

check "firewall-executable" bash -c "[ -x /usr/local/bin/init-firewall.sh ] && echo 'Script is executable'"

check "iptables-available" bash -c "command -v iptables && echo 'iptables installed'"

check "additional-domains" bash -c "grep -q 'api.example.com' /usr/local/bin/init-firewall.sh && echo 'Additional domain configured'"

check "firewall-env-var" bash -c "[ \"\${ENABLEFIREWALL}\" = 'true' ] && echo 'Firewall enabled in environment'"

reportResults