# Claude Code Feature - Development Notes

## Purpose
This feature installs Claude Code CLI in DevContainers with optional security restrictions.

## Core Principles
1. **KISS** - Keep It Simple, Stupid
2. **Minimal Dependencies** - Only what's absolutely required
3. **No Feature Creep** - Resist adding "nice to have" features
4. **Fast Installation** - Less packages = faster setup

## What This Feature Does
- Installs Node.js (required for Claude Code)
- Installs Claude Code CLI via npm
- Optionally sets up a firewall to restrict network access
- Configures API key location

## What This Feature Does NOT Do
- Does NOT install development tools (use other features for that)
- Does NOT install build tools or languages
- Does NOT configure IDE settings
- Does NOT install productivity tools

## Key Files
- `install.sh` - Main installation script (151 lines)
- `init-firewall.sh` - Firewall configuration script
- `devcontainer-feature.json` - Feature metadata (48 lines)

## Testing
Keep tests simple:
- Test that Claude Code installs
- Test that firewall works when enabled
- Test different Node versions
- That's it!

## Maintenance Guidelines
Before adding anything, ask:
1. Is it required for Claude Code to work?
2. Will 90% of users need it?
3. Can users add it themselves if needed?

If any answer is "no", don't add it.

## Common Requests to Reject
- "Add Python/Ruby/Go/etc" - No, use language-specific features
- "Add more dev tools" - No, use devcontainers/features
- "Add shell customizations" - No, that's user preference
- "Add more npm packages" - No, project-specific

## Dependencies Breakdown
Essential only:
- `sudo` - For firewall permissions
- `curl, ca-certificates, gnupg, lsb-release` - For Node.js installation
- `git` - Claude Code requires it
- `jq` - JSON parsing for configuration
- `net-tools, dnsutils` - Network debugging if firewall issues
- `iptables, ipset` - Firewall implementation

## Remember
Every line of code is a liability. Less code = fewer bugs = happier users.