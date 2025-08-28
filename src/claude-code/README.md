# Claude Code DevContainer Feature

Minimal installation of Claude Code CLI with optional security firewall for DevContainers.

## Features

- **Claude Code CLI**: Installs the official Claude Code command-line interface
- **Security Firewall** (optional): Restricts network access to approved domains only
- **Node.js**: Configurable Node.js version (18, 20, or 22)
- **Proxy Support**: Configure corporate proxy settings if needed
- **API Key Management**: Flexible API key configuration options

## Installation

Add this feature to your `devcontainer.json`:

```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:latest": {}
  }
}
```

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enableFirewall` | boolean | `true` | Enable network firewall with restricted access |
| `dangerousSkipPermissions` | boolean | `false` | Run Claude Code with --dangerously-skip-permissions flag |
| `nodeVersion` | string | `"20"` | Node.js version to install (18, 20, or 22) |
| `additionalDomains` | string | `""` | Additional domains to whitelist (comma-separated) |
| `proxyUrl` | string | `""` | Corporate proxy URL |
| `apiKeySource` | string | `"environment"` | API key source: environment, file, or none |

## Security Firewall

When `enableFirewall` is enabled, the feature restricts network access to:
- GitHub (github.com, raw.githubusercontent.com)
- NPM Registry (registry.npmjs.org)
- Node.js (nodejs.org)
- Anthropic API (api.anthropic.com)
- Your additional domains

**Important**: The firewall requires NET_ADMIN and NET_RAW capabilities:

```json
{
  "capAdd": ["NET_ADMIN", "NET_RAW"]
}
```

Or when running Docker directly:
```bash
docker run --cap-add=NET_ADMIN --cap-add=NET_RAW ...
```

## API Key Configuration

Set your Anthropic API key based on the `apiKeySource` option:

- **environment** (default): Set `ANTHROPIC_API_KEY` environment variable
- **file**: Place key in `~/.anthropic/api_key`
- **none**: Manual configuration required

## Examples

### Basic Installation
```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:latest": {}
  }
}
```

### Without Firewall
```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:latest": {
      "enableFirewall": false
    }
  }
}
```

### With Corporate Proxy
```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:latest": {
      "proxyUrl": "http://proxy.company.com:8080",
      "additionalDomains": "api.company.com,cdn.company.com"
    }
  }
}
```

### Node.js 22
```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:latest": {
      "nodeVersion": "22"
    }
  }
}
```

## Requirements

- Debian/Ubuntu-based container
- sudo (automatically installed)
- For firewall: NET_ADMIN and NET_RAW capabilities

## License

MIT