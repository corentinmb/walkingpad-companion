#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/walkingpad-theme.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
swiftc -module-cache-path "${WALKINGPAD_MODULE_CACHE:-$test_dir/module-cache}" \
    walkingpad-client/designSystem/WalkingpadTheme.swift \
    tests/ThemeContrastTests.swift -o "$test_dir/theme-tests"
"$test_dir/theme-tests"
