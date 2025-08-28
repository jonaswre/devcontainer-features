#!/bin/bash
# Manual firewall test - run this locally with Docker to test firewall blocking

echo "🔥 Testing Firewall Functionality"
echo "=================================="
echo ""
echo "This test requires Docker with NET_ADMIN capability."
echo "Run locally with: ./test-firewall.sh"
echo ""

# Build and run a test container with capabilities
docker run --rm \
  --cap-add=NET_ADMIN \
  --cap-add=NET_RAW \
  -v "$(pwd):/workspace" \
  -w /workspace \
  mcr.microsoft.com/devcontainers/base:debian \
  bash -c "
    # Install the feature
    cd /workspace
    ./src/claude-code/install.sh
    
    # Initialize firewall
    echo '🚀 Initializing firewall...'
    /usr/local/bin/init-firewall.sh
    
    # Test blocking
    echo '🧪 Testing network blocking...'
    
    # Should be blocked
    if curl -s --max-time 2 https://google.com >/dev/null 2>&1; then
      echo '❌ FAIL: google.com is accessible (should be blocked)'
      exit 1
    else
      echo '✅ PASS: google.com is blocked'
    fi
    
    # Should be allowed
    if curl -s --max-time 2 https://api.github.com/zen >/dev/null 2>&1; then
      echo '✅ PASS: github.com is accessible'
    else
      echo '❌ FAIL: github.com is not accessible (should be allowed)'
      exit 1
    fi
    
    echo ''
    echo '🎉 Firewall test passed!'
  "