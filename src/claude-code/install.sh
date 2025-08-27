#!/usr/bin/env bash
set -euo pipefail

# Feature options
ENABLE_FIREWALL="${ENABLEFIREWALL:-true}"
DANGEROUS_SKIP="${DANGEROUSSKIPPERMISSIONS:-false}"
NODE_VERSION="${NODEVERSION:-20}"
INSTALL_ZSH="${INSTALLZSH:-true}"
ADDITIONAL_DOMAINS="${ADDITIONALDOMAINS:-}"
PROXY_URL="${PROXYURL:-}"
API_KEY_SOURCE="${APIKEYSOURCE:-environment}"

echo "==============================================="
echo "Installing Claude Code Development Container"
echo "==============================================="

# Install system dependencies
apt-get update
apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    lsb-release \
    git \
    build-essential \
    python3 \
    python3-pip \
    jq \
    fzf \
    ripgrep \
    bat \
    htop \
    net-tools \
    dnsutils \
    iptables

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -
apt-get install -y nodejs

# Install global npm packages
npm install -g \
    typescript \
    ts-node \
    nodemon \
    prettier \
    eslint

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

# Install ZSH and Oh My Zsh if requested
if [ "${INSTALL_ZSH}" = "true" ]; then
    echo "Installing ZSH with productivity enhancements..."
    apt-get install -y zsh
    
    # Install Oh My Zsh for the user (skip if already installed)
    if [ ! -d "/home/${_REMOTE_USER}/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        export RUNZSH=no
        export CHSH=no
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
            echo "Oh My Zsh installation failed, continuing without it"
        }
        # Fix ownership
        chown -R ${_REMOTE_USER}:${_REMOTE_USER} /home/${_REMOTE_USER}/.oh-my-zsh 2>/dev/null || true
    else
        echo "Oh My Zsh already installed"
    fi
    
    # Configure ZSH plugins
    cat >> /home/${_REMOTE_USER}/.zshrc << 'EOF'

# Claude Code devcontainer configuration
export CLAUDE_CODE_DEVCONTAINER=true

# Productivity aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph'

# FZF configuration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Claude Code helpers
alias claude-status='claude-code --version && echo "API Key configured: ${ANTHROPIC_API_KEY:+Yes}"'
alias claude-test='claude-code --help'

EOF
    
    # Set ZSH as default shell
    chsh -s $(which zsh) ${_REMOTE_USER}
fi

# Configure proxy if provided
if [ -n "${PROXY_URL}" ]; then
    echo "Configuring proxy settings..."
    cat >> /etc/environment << EOF
HTTP_PROXY=${PROXY_URL}
HTTPS_PROXY=${PROXY_URL}
http_proxy=${PROXY_URL}
https_proxy=${PROXY_URL}
NO_PROXY=localhost,127.0.0.1,*.local
no_proxy=localhost,127.0.0.1,*.local
EOF
    
    # Configure npm proxy
    npm config set proxy ${PROXY_URL}
    npm config set https-proxy ${PROXY_URL}
    
    # Configure git proxy
    git config --global http.proxy ${PROXY_URL}
    git config --global https.proxy ${PROXY_URL}
fi

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
        mkdir -p /home/${_REMOTE_USER}/.anthropic
        touch /home/${_REMOTE_USER}/.anthropic/api_key
        chmod 600 /home/${_REMOTE_USER}/.anthropic/api_key
        chown -R ${_REMOTE_USER}:${_REMOTE_USER} /home/${_REMOTE_USER}/.anthropic
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
    echo "/usr/local/bin/start-firewall.sh" >> /home/${_REMOTE_USER}/.bashrc
    
    echo "Firewall will be initialized on container start"
    echo "Note: Container must be run with NET_ADMIN and NET_RAW capabilities"
fi

# Create session persistence directory
mkdir -p /home/${_REMOTE_USER}/.claude-code-sessions
chown -R ${_REMOTE_USER}:${_REMOTE_USER} /home/${_REMOTE_USER}/.claude-code-sessions

# Create helper script for status checking
cat > /usr/local/bin/claude-code-status << 'EOF'
#!/bin/bash
echo "Claude Code Development Container Status"
echo "========================================"
echo "Claude Code Version: $(claude --version 2>/dev/null || claude-code --version 2>/dev/null || echo 'Not installed')"
echo "Node.js Version: $(node --version)"
echo "NPM Version: $(npm --version)"
echo "API Key Configured: ${ANTHROPIC_API_KEY:+Yes}"
echo "Firewall Enabled: $(iptables -L -n 2>/dev/null | grep -q "Chain" && echo "Yes" || echo "No")"
echo "Dangerous Skip Mode: $(command -v claude | grep -q dangerously && echo "Yes" || echo "No")"
echo ""
echo "Run 'claude-code --help' to get started"
EOF
chmod +x /usr/local/bin/claude-code-status

echo "==============================================="
echo "Claude Code installation complete!"
echo "Run 'claude-code-status' to verify setup"
echo "==============================================="