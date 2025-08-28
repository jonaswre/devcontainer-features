#!/bin/bash
# KISS Test Runner - Simple local testing

echo "🧪 Testing Claude Code Feature"
echo "=============================="

# Check prerequisites
if ! command -v devcontainer >/dev/null 2>&1; then
    echo "❌ DevContainer CLI not installed"
    echo "Install with: npm install -g @devcontainers/cli"
    exit 1
fi

# Run tests
echo "Running tests..."
devcontainer features test \
    --features claude-code \
    --base-image mcr.microsoft.com/devcontainers/base:debian

echo "✅ Tests complete!"