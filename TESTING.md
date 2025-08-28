# Testing DevContainer Features

## Quick Start

Run all tests locally:
```bash
./test-runner.sh --all
```

## Test Structure

Our testing follows the DevContainer specification with three levels:

### 1. Unit Tests (Basic Functionality)
Located in `test/_global/test.sh` and `test/claude-code/test.sh`

These verify:
- Tool installation (Node.js, npm, git, Claude CLI)
- Environment configuration
- Basic functionality

### 2. Scenario Tests (Configuration Variations)
Defined in `test/claude-code/scenarios.json`

Test different configurations:
- Different base images (Debian, Ubuntu)
- Node.js versions (18, 20, 22)
- Firewall enabled/disabled
- Proxy configuration
- Minimal vs full setup

### 3. Integration Tests (Real-world Usage)
Located in `test/claude-code/integration-test.sh`

Comprehensive testing of:
- All components working together
- Network restrictions (when firewall enabled)
- Development tool availability
- API key configuration

## Running Tests Locally

### Prerequisites
```bash
# Install DevContainer CLI
npm install -g @devcontainers/cli

# Install Docker (required)
# https://docs.docker.com/get-docker/
```

### Test Commands

Run all tests:
```bash
./test-runner.sh --all
```

Run specific test types:
```bash
# Basic functionality only
./test-runner.sh --basic

# Scenario tests only  
./test-runner.sh --scenarios

# Specific scenario
./test-runner.sh --scenario node-22

# Lint scripts only
./test-runner.sh --lint

# Validate structure only
./test-runner.sh --validate
```

### Using DevContainer CLI Directly

Test the feature:
```bash
devcontainer features test ./src/claude-code
```

Test specific scenario:
```bash
devcontainer features test \
  --features ./src/claude-code \
  --filter node-22
```

Test with specific base image:
```bash
devcontainer features test \
  --features ./src/claude-code \
  --base-image ubuntu:22.04
```

## Test Scenarios

| Scenario | Description | Key Options |
|----------|-------------|-------------|
| `default-debian` | Default setup on Debian | All defaults |
| `default-ubuntu` | Default setup on Ubuntu | All defaults |
| `with-firewall` | Firewall enabled with domains | `enableFirewall: true` |
| `no-firewall` | No network restrictions | `enableFirewall: false` |
| `node-18` | Node.js 18 installation | `nodeVersion: "18"` |
| `node-22` | Node.js 22 installation | `nodeVersion: "22"` |
| `minimal` | Minimal installation | No ZSH, no firewall |
| `dangerous-skip` | Skip permissions mode | `dangerousSkipPermissions: true` |
| `with-proxy` | Corporate proxy setup | `proxyUrl` configured |
| `full-featured` | All features enabled | Everything enabled |

## CI/CD Pipeline

GitHub Actions automatically runs tests on:
- Push to main/develop branches
- Pull requests
- Manual trigger

Workflow stages:
1. **Test** - Basic tests on multiple base images
2. **Test Scenarios** - All configuration variations
3. **Integration Test** - Full feature testing
4. **Validate Structure** - JSON validation, script linting
5. **Release** - Package for distribution (main branch only)

## Writing New Tests

### Adding a Test Scenario

1. Edit `test/claude-code/scenarios.json`:
```json
{
  "my-scenario": {
    "image": "debian:latest",
    "features": {
      "claude-code": {
        "enableFirewall": true,
        "nodeVersion": "22"
      }
    }
  }
}
```

2. Create test script `test/claude-code/my-scenario.sh`:
```bash
#!/bin/bash
set -e

source dev-container-features-test-lib

check "my-test" command -to-test

reportResults
```

### Using Test Library

The DevContainer test library provides:
- `check "name" command` - Run test and report result
- `reportResults` - Output final test report

Example:
```bash
#!/bin/bash
set -e

source dev-container-features-test-lib

# Simple command check
check "node-installed" node --version

# Complex check with bash
check "env-var" bash -c "[ \"\$MY_VAR\" = 'expected' ]"

# Check file exists
check "file-exists" bash -c "[ -f /path/to/file ]"

reportResults
```

## Debugging Failed Tests

### Verbose Output
```bash
devcontainer features test \
  --features ./src/claude-code \
  --log-level trace
```

### Test Manually in Container
```bash
# Build test container
docker build -t test-feature .

# Run interactively
docker run -it --rm test-feature bash

# Test commands manually
node --version
claude --version
```

### Common Issues

1. **Permission Errors**
   - Ensure scripts are executable: `chmod +x *.sh`
   - Check Docker permissions

2. **Firewall Tests Fail**
   - CI environments may lack NET_ADMIN capability
   - Test locally with proper permissions

3. **Network Timeouts**
   - Proxy configuration needed
   - DNS resolution issues

4. **Version Mismatches**
   - Check Node.js version compatibility
   - Verify package versions in install.sh

## Test Coverage

Current coverage:
- ✅ Installation verification
- ✅ Tool availability
- ✅ Environment configuration
- ✅ Option handling
- ✅ Multiple base images
- ✅ Multiple architectures (amd64, arm64)
- ✅ Error handling
- ✅ Network restrictions (when applicable)

## Best Practices

1. **Keep Tests Fast** - Focus on critical functionality
2. **Test User-Facing Features** - Not implementation details
3. **Use Proper Assertions** - Check exit codes and output
4. **Handle CI Limitations** - Some features need special capabilities
5. **Document Expected Failures** - Some tests may fail in CI but work in production

## Support

For issues or questions:
- Open an issue in the repository
- Check existing test output in GitHub Actions
- Run tests locally with trace logging for debugging