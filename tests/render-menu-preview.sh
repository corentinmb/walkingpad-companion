#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
preview_dir=${1:-/tmp/walkingpad-menu-previews}
test_dir=$(mktemp -d "${TMPDIR:-/tmp}/walkingpad-preview.XXXXXX")
trap 'rm -rf "$test_dir"' EXIT
swiftc -module-cache-path "${WALKINGPAD_MODULE_CACHE:-$test_dir/module-cache}" \
    walkingpad-client/models/DeviceState.swift \
    walkingpad-client/models/MenuBarPresentation.swift \
    walkingpad-client/designSystem/WalkingpadTheme.swift \
    walkingpad-client/designSystem/WalkingpadComponents.swift \
    walkingpad-client/designSystem/WalkingpadProgressRing.swift \
    walkingpad-client/views/MenuBarPanel.swift \
    tests/RenderMenuBarPreview.swift -o "$test_dir/render-preview"
"$test_dir/render-preview" "$preview_dir"
