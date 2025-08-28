#!/bin/bash

log_info() {
    echo "[INFO] $1" >&2
}

log_error() {
    echo "[ERROR] $1" >&2
}

log_warning() {
    echo "[WARNING] $1" >&2
}

verify_command() {
    local cmd="$1"
    local name="${2:-$1}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        log_info "✅ $name is installed"
        return 0
    else
        log_error "❌ $name is not installed"
        return 1
    fi
}

verify_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        log_info "✅ $description exists at $file"
        return 0
    else
        log_error "❌ $description not found at $file"
        return 1
    fi
}

verify_env_var() {
    local var_name="$1"
    local expected="${2:-}"
    
    eval "local value=\$$var_name"
    
    if [ -n "$value" ]; then
        if [ -n "$expected" ] && [ "$value" != "$expected" ]; then
            log_error "❌ $var_name is set but has unexpected value: $value (expected: $expected)"
            return 1
        fi
        log_info "✅ $var_name is set: $value"
        return 0
    else
        log_error "❌ $var_name is not set"
        return 1
    fi
}

verify_version() {
    local cmd="$1"
    local expected_pattern="$2"
    local name="${3:-$1}"
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=$("$cmd" --version 2>&1 | head -n1)
        if echo "$version" | grep -qE "$expected_pattern"; then
            log_info "✅ $name version matches: $version"
            return 0
        else
            log_warning "⚠️  $name version mismatch: $version (expected pattern: $expected_pattern)"
            return 1
        fi
    else
        log_error "❌ $name not found"
        return 1
    fi
}

test_network_access() {
    local url="$1"
    local should_succeed="${2:-true}"
    local description="${3:-Network test}"
    
    if curl -s --max-time 2 "$url" >/dev/null 2>&1; then
        if [ "$should_succeed" = "true" ]; then
            log_info "✅ $description: $url is accessible"
            return 0
        else
            log_error "❌ $description: $url should be blocked but is accessible"
            return 1
        fi
    else
        if [ "$should_succeed" = "false" ]; then
            log_info "✅ $description: $url is blocked as expected"
            return 0
        else
            log_error "❌ $description: $url is not accessible"
            return 1
        fi
    fi
}

report_test_results() {
    local total="$1"
    local passed="$2"
    local failed=$((total - passed))
    
    echo ""
    echo "======================================="
    echo "Test Results Summary"
    echo "======================================="
    echo "Total tests: $total"
    echo "Passed: $passed ✅"
    echo "Failed: $failed ❌"
    
    if [ "$failed" -eq 0 ]; then
        echo ""
        echo "All tests passed! 🎉"
        return 0
    else
        echo ""
        echo "Some tests failed. Please review the output above."
        return 1
    fi
}