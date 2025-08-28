# DevContainer Features

Simple, focused DevContainer features.

## Available Features

### Claude Code (`claude-code`)
Minimal installation of Claude Code CLI with optional security firewall.

```json
{
  "features": {
    "ghcr.io/jonaswre/devcontainer-features/claude-code:latest": {}
  }
}
```

**What it does:**
- Installs Claude Code CLI
- Optionally restricts network access (firewall)
- Configures API key management

**Options:**
- `enableFirewall` - Enable network restrictions (default: true)
- `nodeVersion` - Node.js version: 18, 20, or 22 (default: 20)
- `apiKeySource` - Where to store API key (default: environment)

See [src/claude-code/README.md](src/claude-code/README.md) for full documentation.

## Philosophy

These features follow KISS (Keep It Simple, Stupid):
- Do one thing well
- Minimal dependencies
- No bloat
- Easy to understand
- Fast to install

## License

MIT