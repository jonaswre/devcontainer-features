# Claude Code DevContainer Feature

A production-ready, reusable devcontainer feature for Claude Code that follows official standards and provides enhanced security with firewall rules, developer tools, and flexible configuration options.

## 🚀 Features

- **Security-First Design**: Built-in firewall with domain whitelisting
- **Flexible Configuration**: Multiple options for different environments
- **Developer Tools**: Pre-installed productivity tools (ZSH, fzf, ripgrep, etc.)
- **Corporate Ready**: Proxy support and custom domain configuration
- **CI/CD Compatible**: Automated mode for pipeline integration
- **Session Persistence**: Maintains history and configurations

## 📦 Installation

### From GitHub Container Registry

```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {
      "enableFirewall": true
    }
  }
}
```

### Local Development

```json
{
  "features": {
    "./devcontainer-features/src/claude-code": {
      "enableFirewall": true
    }
  }
}
```

## ⚙️ Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enableFirewall` | boolean | `true` | Enable network firewall with domain whitelisting |
| `dangerousSkipPermissions` | boolean | `false` | Run Claude Code without permission prompts |
| `nodeVersion` | string | `"20"` | Node.js version (18, 20, or 22) |
| `installZsh` | boolean | `true` | Install ZSH with Oh My Zsh |
| `additionalDomains` | string | `""` | Comma-separated additional domains to whitelist |
| `proxyUrl` | string | `""` | Corporate proxy URL |
| `apiKeySource` | string | `"environment"` | Source for API key (`environment`, `file`, `none`) |

## 📚 Usage Examples

### Basic Setup

```json
{
  "name": "My Project",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {}
  },
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

### Corporate Environment

```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {
      "proxyUrl": "http://proxy.company.com:8080",
      "additionalDomains": "api.company.com,internal.company.com",
      "enableFirewall": true
    }
  }
}
```

### CI/CD Pipeline

```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {
      "dangerousSkipPermissions": true,
      "apiKeySource": "file",
      "enableFirewall": false
    }
  }
}
```

### Development with Latest Node.js

```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {
      "nodeVersion": "22",
      "installZsh": true,
      "enableFirewall": true
    }
  }
}
```

## 🔒 Security Features

### Firewall Configuration

When `enableFirewall` is enabled, the feature restricts network access to:

- **NPM/Node.js**: Registry and package downloads
- **GitHub**: Repository access and API
- **Anthropic**: Claude API endpoints
- **Development Tools**: Package managers, VS Code extensions
- **Custom Domains**: Your specified additional domains

### API Key Management

Three modes for API key configuration:

1. **Environment** (default): Pass through environment variable
2. **File**: Store in `~/.anthropic/api_key` with restricted permissions
3. **None**: Skip API key configuration

## 🛠️ Available Commands

After installation, these commands are available:

- `claude-code` - Main Claude Code CLI
- `claude-code-status` - Check installation and configuration
- `init-firewall.sh` - Reinitialize firewall rules (when enabled)
- `claude` - Wrapper with --dangerously-skip-permissions (when enabled)

## 📁 Repository Structure

```
devcontainer-features/
├── src/claude-code/
│   ├── devcontainer-feature.json   # Feature definition
│   ├── install.sh                  # Installation script
│   ├── init-firewall.sh           # Firewall configuration
│   └── README.md                   # Feature documentation
├── test/claude-code/
│   ├── scenarios.json              # Test scenarios
│   └── test.sh                     # Test script
├── .github/workflows/
│   ├── test.yaml                   # CI testing
│   └── release.yaml                # Automated releases
├── LICENSE                         # MIT License
└── README.md                       # This file
```

## 🧪 Testing

Run tests locally:

```bash
cd test/claude-code
chmod +x test.sh
./test.sh
```

## 🚢 Publishing

### To GitHub Container Registry

1. Organization name is already configured as `jonaswre`
2. Push to main branch
3. GitHub Actions will automatically publish

### Manual Publishing

```bash
devcontainer features publish ./src --namespace jonaswre
```

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Add tests for new functionality
4. Submit a pull request

## 📞 Support

- [Create an Issue](https://github.com/jonaswre/devcontainer-features/issues)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

---

Built with ❤️ following [Dev Container Feature Specification](https://containers.dev/implementors/features/)