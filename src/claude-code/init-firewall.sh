#!/usr/bin/env bash
set -euo pipefail

echo "Initializing Claude Code security firewall..."

# Check if running with necessary privileges
if ! command -v iptables &> /dev/null; then
    echo "Warning: iptables not available, skipping firewall setup"
    exit 0
fi

# Check if ipset is available
if ! command -v ipset &> /dev/null; then
    echo "Installing ipset..."
    if apt-get update && apt-get install -y ipset; then
        USE_IPSET=true
    else
        echo "Failed to install ipset, falling back to iptables-only mode"
        USE_IPSET=false
    fi
else
    USE_IPSET=true
fi

# Preserve Docker DNS rules if they exist
DOCKER_DNS_RULES=$(iptables-save -t nat 2>/dev/null | grep "127\.0\.0\.11" || true)

# Flush existing rules
iptables -F OUTPUT 2>/dev/null || true
iptables -F INPUT 2>/dev/null || true

# Restore Docker DNS rules if they existed
if [ -n "$DOCKER_DNS_RULES" ]; then
    echo "Restoring Docker DNS rules..."
    echo "$DOCKER_DNS_RULES" | while read -r rule; do
        # Extract and re-apply the rule
        eval "iptables -t nat $rule" 2>/dev/null || true
    done
fi

# IMPORTANT: Set up allow rules BEFORE setting DROP policies

# Allow DNS (required for domain resolution)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow SSH (for git operations)
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Create ipset for allowed domains if available
if [ "$USE_IPSET" = true ]; then
    ipset destroy allowed-domains 2>/dev/null || true
    ipset create allowed-domains hash:net
fi

# Whitelist essential domains
ALLOWED_DOMAINS=(
    # NPM and Node.js
    "registry.npmjs.org"
    "nodejs.org"
    "npm.nodejs.org"
    
    # GitHub
    "github.com"
    "api.github.com"
    "raw.githubusercontent.com"
    "objects.githubusercontent.com"
    "codeload.github.com"
    
    # Anthropic
    "api.anthropic.com"
    "console.anthropic.com"
    "storage.googleapis.com"
    
    # Package managers
    "pypi.org"
    "files.pythonhosted.org"
    
    # Development tools
    "deb.nodesource.com"
    "download.docker.com"
    
    # VS Code
    "update.code.visualstudio.com"
    "marketplace.visualstudio.com"
)

# Add user-specified additional domains
if [ -n "${CLAUDE_ADDITIONAL_DOMAINS:-}" ]; then
    IFS=',' read -ra EXTRA_DOMAINS <<< "$CLAUDE_ADDITIONAL_DOMAINS"
    ALLOWED_DOMAINS+=("${EXTRA_DOMAINS[@]}")
fi

# Resolve and allow each domain
for domain in "${ALLOWED_DOMAINS[@]}"; do
    # Resolve domain to IPs
    ips=$(dig +short "$domain" 2>/dev/null | grep -E '^[0-9.]+$' || true)
    
    if [ -n "$ips" ]; then
        while IFS= read -r ip; do
            if [ "$USE_IPSET" = true ]; then
                ipset add allowed-domains "$ip" 2>/dev/null || true
            else
                # Fallback to individual iptables rules
                iptables -A OUTPUT -d "$ip" -p tcp --dport 443 -j ACCEPT
                iptables -A OUTPUT -d "$ip" -p tcp --dport 80 -j ACCEPT
            fi
            echo "✓ Allowed: $domain ($ip)"
        done <<< "$ips"
    else
        echo "⚠ Could not resolve: $domain"
    fi
done

# If using ipset, add the rules to allow HTTP/HTTPS traffic to the set
# MUST be added BEFORE setting DROP policies
if [ "$USE_IPSET" = true ]; then
    iptables -A OUTPUT -p tcp --dport 443 -m set --match-set allowed-domains dst -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 80 -m set --match-set allowed-domains dst -j ACCEPT
fi

# Allow established connections BEFORE setting DROP policies
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# NOW set default policies to DROP
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

# Explicitly reject remaining traffic for immediate feedback
iptables -A OUTPUT -j REJECT --reject-with icmp-admin-prohibited

# Log dropped packets (for debugging)
iptables -A OUTPUT -m limit --limit 2/min -j LOG --log-prefix "Firewall Dropped: " --log-level 4

echo "Firewall initialization complete!"
echo "Run 'iptables -L -n' to view active rules"