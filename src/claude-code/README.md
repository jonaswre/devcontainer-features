# Claude Code Development Container Feature

Production-ready Claude Code setup with enhanced security, firewall rules, and developer tools following [official Anthropic standards](https://docs.anthropic.com/en/docs/claude-code).

## Features

- 🔒 **Security by Design**: Custom firewall restricting network access to only necessary services
- 🚀 **Production-Ready**: Built on Node.js with essential development dependencies
- 🛠️ **Developer Tools**: Git, ZSH, fzf, ripgrep, and more pre-installed
- 🔧 **VS Code Integration**: Pre-configured extensions and optimized settings
- 💾 **Session Persistence**: Preserves command history and configurations
- 🌍 **Cross-Platform**: Works on macOS, Windows, and Linux

## Quick Start

Add to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {
      "enableFirewall": true,
      "dangerousSkipPermissions": false
    }
  },
  "remoteEnv": {
    "ANTHROPIC_API_KEY": "${localEnv:ANTHROPIC_API_KEY}"
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| enableFirewall | boolean | true | Enable network firewall with restricted access |
| dangerousSkipPermissions | boolean | false | Run Claude with --dangerously-skip-permissions |
| nodeVersion | string | "20" | Node.js version (18, 20, or 22) |
| installZsh | boolean | true | Install ZSH with productivity enhancements |
| additionalDomains | string | "" | Additional domains to whitelist |
| proxyUrl | string | "" | Corporate proxy URL |
| apiKeySource | string | "environment" | API key configuration source |

## Security Considerations

⚠️ **Warning**: When `dangerousSkipPermissions` is enabled, Claude Code runs without permission prompts. Only use this in trusted environments with secure devcontainers.

The firewall restricts outbound connections to:
- NPM registry and Node.js resources
- GitHub repositories
- Anthropic API endpoints
- Essential development tools

## Examples

### Basic Setup
```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {}
  }
}
```

### Corporate Environment
```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {
      "proxyUrl": "http://proxy.company.com:8080",
      "additionalDomains": "internal.company.com,api.company.com"
    }
  }
}
```

### CI/CD Automation
```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:1": {
      "dangerousSkipPermissions": true,
      "enableFirewall": true,
      "apiKeySource": "file"
    }
  }
}
```

## Commands

After installation, these commands are available:

- `claude-code-status` - Check installation and configuration status
- `claude-code --help` - Get started with Claude Code
- `init-firewall.sh` - Reinitialize firewall rules (when enabled)

## License

MIT - See LICENSE file for details