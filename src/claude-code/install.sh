#!/usr/bin/env bash
set -euo pipefail

# Feature options
ENABLE_FIREWALL="${ENABLEFIREWALL:-true}"
DANGEROUS_SKIP="${DANGEROUSSKIPPERMISSIONS:-false}"
NODE_VERSION="${NODEVERSION:-20}"
ADDITIONAL_DOMAINS="${ADDITIONALDOMAINS:-}"
API_KEY_SOURCE="${APIKEYSOURCE:-environment}"

# Set default user if not provided by devcontainer
_REMOTE_USER="${_REMOTE_USER:-${REMOTE_USER:-${USERNAME:-vscode}}}"
_REMOTE_USER_HOME="${_REMOTE_USER_HOME:-/home/${_REMOTE_USER}}"

echo "==============================================="
echo "Installing Claude Code Development Container"
echo "==============================================="

# Install minimal system dependencies
apt-get update
apt-get install -y --no-install-recommends \
    sudo \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    git \
    jq \
    net-tools \
    dnsutils \
    iptables \
    ipset

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
apt-get install -y nodejs

# Claude Code CLI will be installed next

# Install Claude Code CLI
echo "Installing Claude Code CLI..."
# Install via npm (the binary will be named 'claude')
if npm install -g @anthropic-ai/claude-code; then
    echo "Claude Code npm package installed successfully"
    # Ensure npm bin directory is in PATH
    export PATH="$(npm bin -g):$PATH"
else
    echo "npm installation failed, trying alternative method..."
    # Alternative: Try the native installer
    curl -fsSL https://claude.ai/install.sh | bash || {
        echo "Warning: Claude Code installation may have failed"
        echo "Please install manually after container creation"
    }
fi

# Verify installation (optional - may not be available in all environments)
if command -v claude &> /dev/null; then
    echo "✅ Claude Code CLI installed successfully"
    claude --version || true
elif command -v claude-code &> /dev/null; then
    echo "✅ Claude Code CLI installed successfully"
    claude-code --version || true
else
    echo "⚠️ Claude Code CLI not found in PATH"
    echo "You may need to install it manually with: npm install -g @anthropic-ai/claude-code"
fi

# Set environment variable to indicate devcontainer
echo "export CLAUDE_CODE_DEVCONTAINER=true" >> /etc/bash.bashrc

# Configure API key based on source
case "${API_KEY_SOURCE}" in
    environment)
        echo "API key will be sourced from environment variable"
        cat >> /etc/bash.bashrc << 'EOF'
# Claude Code API key configuration
if [ -n "$ANTHROPIC_API_KEY" ]; then
    export ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY"
fi
EOF
        ;;
    file)
        echo "API key will be sourced from file ~/.anthropic/api_key"
        mkdir -p "${_REMOTE_USER_HOME}/.anthropic"
        touch "${_REMOTE_USER_HOME}/.anthropic/api_key"
        chmod 600 "${_REMOTE_USER_HOME}/.anthropic/api_key"
        if id "${_REMOTE_USER}" &>/dev/null; then
            chown -R ${_REMOTE_USER}:${_REMOTE_USER} "${_REMOTE_USER_HOME}/.anthropic"
        fi
        ;;
    none)
        echo "API key configuration skipped"
        ;;
esac

# Configure dangerous skip permissions if enabled
if [ "${DANGEROUS_SKIP}" = "true" ]; then
    echo "WARNING: Configuring Claude Code with --dangerously-skip-permissions"
    cat > /usr/local/bin/claude << 'EOF'
#!/bin/bash
claude-code --dangerously-skip-permissions "$@"
EOF
    chmod +x /usr/local/bin/claude
fi

# Setup firewall if enabled
if [ "${ENABLE_FIREWALL}" = "true" ]; then
    echo "Configuring firewall setup..."
    
    # Copy firewall initialization script
    cp "$(dirname "$0")/init-firewall.sh" /usr/local/bin/init-firewall.sh
    chmod +x /usr/local/bin/init-firewall.sh
    
    # Setup sudoers to allow user to run firewall script
    mkdir -p /etc/sudoers.d
    echo "${_REMOTE_USER} ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/firewall
    chmod 0440 /etc/sudoers.d/firewall
    
    # Pass additional domains if provided via environment file
    if [ -n "${ADDITIONAL_DOMAINS}" ]; then
        echo "CLAUDE_ADDITIONAL_DOMAINS=\"${ADDITIONAL_DOMAINS}\"" >> /etc/environment
    fi
    
    # Create a startup script that will run firewall on container start
    cat > /usr/local/bin/start-firewall.sh << 'EOF'
#!/bin/bash
# Initialize firewall on container start with proper privileges
if [ -x /usr/local/bin/init-firewall.sh ]; then
    echo "Initializing Claude Code security firewall..."
    sudo /usr/local/bin/init-firewall.sh || {
        echo "Warning: Firewall initialization failed. Container requires NET_ADMIN capability."
        echo "Add '--cap-add=NET_ADMIN --cap-add=NET_RAW' to your docker run command or"
        echo "set 'capAdd: [\"NET_ADMIN\", \"NET_RAW\"]' in devcontainer.json"
    }
fi
EOF
    chmod +x /usr/local/bin/start-firewall.sh
    
    # Add to bashrc to run on login
    mkdir -p "${_REMOTE_USER_HOME}"
    echo "/usr/local/bin/start-firewall.sh" >> "${_REMOTE_USER_HOME}/.bashrc"
    
    echo "Firewall will be initialized on container start"
    echo "Note: Container must be run with NET_ADMIN and NET_RAW capabilities"
fi

# Create working directory
mkdir -p /workspace

echo "==============================================="
echo "Claude Code installation complete!"
echo "==============================================="