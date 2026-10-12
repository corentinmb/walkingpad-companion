#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/walkingpad-tests.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
export WALKINGPAD_MODULE_CACHE=${WALKINGPAD_MODULE_CACHE:-$test_dir/module-cache}
sh tests/run-menubar-presentation.sh
sh tests/run-workout-stats.sh
sh tests/run-theme-contrast.sh
