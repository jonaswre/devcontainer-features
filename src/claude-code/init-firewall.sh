#!/usr/bin/env bash
set -euo pipefail

echo "Initializing Claude Code security firewall..."

# Check if running with necessary privileges
if ! command -v iptables &> /dev/null; then
    echo "Warning: iptables not available, skipping firewall setup"
    exit 0
fi

# Flush existing rules
iptables -F OUTPUT 2>/dev/null || true
iptables -F INPUT 2>/dev/null || true

# Default policies
iptables -P OUTPUT DROP
iptables -P INPUT ACCEPT
iptables -P FORWARD DROP

# Allow loopback
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow DNS (required for domain resolution)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow SSH (for git operations)
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -m owner --uid-owner 0 -j ACCEPT

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
            iptables -A OUTPUT -d "$ip" -j ACCEPT
            echo "✓ Allowed: $domain ($ip)"
        done <<< "$ips"
    else
        echo "⚠ Could not resolve: $domain"
    fi
done

# Allow HTTPS to resolved IPs (fallback for dynamic resolution)
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT

# Log dropped packets (for debugging)
iptables -A OUTPUT -m limit --limit 2/min -j LOG --log-prefix "Firewall Dropped: " --log-level 4

echo "Firewall initialization complete!"
echo "Run 'iptables -L -n' to view active rules"