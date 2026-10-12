#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/walkingpad-stats.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
swiftc -module-cache-path "$test_dir/module-cache" \
    walkingpad-client/services/Workout.swift \
    walkingpad-client/models/WorkoutsSaveData.swift \
    walkingpad-client/models/DeviceState.swift \
    walkingpad-client/models/Change.swift \
    walkingpad-client/utils/DateExtension.swift \
    tests/WorkoutStatsTests.swift -o "$test_dir/workout-stats-tests"
"$test_dir/workout-stats-tests"
