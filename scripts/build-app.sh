#!/bin/bash
# Build a self-contained, locally signed app bundle using the tracked Xcode project.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
case "${1:-release}" in
  release) CONFIG=Release ;;
  debug) CONFIG=Debug ;;
  *) echo "Choose debug or release." >&2; exit 2 ;;
esac
VERSION="${WALKINGPAD_VERSION:-$(cat "$ROOT/VERSION")}"
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: use MAJOR.MINOR.PATCH." >&2; exit 2
fi
ARCHS="${WALKINGPAD_ARCHS:-arm64 x86_64}"
case "$ARCHS" in arm64|x86_64|'arm64 x86_64') ;; *) echo "Unsupported architecture list." >&2; exit 2 ;; esac
IDENTITY="${WALKINGPAD_SIGN_IDENTITY:--}"
if [[ "$IDENTITY" != '-' && "$IDENTITY" != 'Developer ID Application:'* ]]; then
  echo "Use a Developer ID Application signing identity, or omit it for a local build." >&2; exit 2
fi
BUILD_DIR="${WALKINGPAD_BUILD_DIR:-$ROOT/.build/xcode}"
APP_NAME='Walkingpad Companion'
mkdir -p "$ROOT/dist"
printf 'Building %s %s (%s, %s)…\n' "$APP_NAME" "$VERSION" "$CONFIG" "$ARCHS"
xcodebuild -project "$ROOT/walkingpad-client.xcodeproj" -scheme walkingpad-client \
  -configuration "$CONFIG" -destination 'generic/platform=macOS' \
  -derivedDataPath "$BUILD_DIR" "ARCHS=$ARCHS" ONLY_ACTIVE_ARCH=NO \
  "MARKETING_VERSION=$VERSION" "CODE_SIGN_IDENTITY=$IDENTITY" \
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO build
BUILT_APP="$BUILD_DIR/Build/Products/$CONFIG/$APP_NAME.app"
[[ -d "$BUILT_APP" ]] || { echo "Build did not produce $BUILT_APP" >&2; exit 1; }
# Remove only this generated bundle to avoid retaining stale resources between builds.
rm -rf "$ROOT/dist/$APP_NAME.app"
ditto "$BUILT_APP" "$ROOT/dist/$APP_NAME.app"
codesign --verify --deep --strict "$ROOT/dist/$APP_NAME.app"
printf '\nBuilt: %s\n' "$ROOT/dist/$APP_NAME.app"
printf 'Run: open "%s"\n' "$ROOT/dist/$APP_NAME.app"
