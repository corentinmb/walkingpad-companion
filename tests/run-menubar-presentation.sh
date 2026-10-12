#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/walkingpad-presentation.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
swiftc -module-cache-path "${WALKINGPAD_MODULE_CACHE:-$test_dir/module-cache}" walkingpad-client/models/DeviceState.swift \
    walkingpad-client/models/MenuBarPresentation.swift \
    tests/MenuBarPresentationTests.swift -o "$test_dir/presentation-tests"
"$test_dir/presentation-tests"
