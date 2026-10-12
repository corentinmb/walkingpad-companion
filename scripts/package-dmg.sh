#!/bin/bash
# Package an already built app; no compilation or system configuration changes.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="${1:-$ROOT/dist/Walkingpad Companion.app}"
[[ -d "$APP/Contents" ]] || { echo "Missing app: $APP — run scripts/build-app.sh first." >&2; exit 2; }
codesign --verify --deep --strict "$APP"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")
[[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo 'Invalid app version.' >&2; exit 2; }
EXECUTABLE=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleExecutable' "$APP/Contents/Info.plist")
ARCHS=$(lipo -archs "$APP/Contents/MacOS/$EXECUTABLE")
case "$ARCHS" in
  'x86_64 arm64'|'arm64 x86_64') ARCH=universal ;;
  arm64|x86_64) ARCH="$ARCHS" ;;
  *) echo "Unsupported app architectures: $ARCHS" >&2; exit 2 ;;
esac
NAME="Walkingpad-Companion-$VERSION-$ARCH"
mkdir -p "$ROOT/dist"
STAGING=$(mktemp -d "${TMPDIR:-/tmp}/walkingpad-dmg.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
ditto "$APP" "$STAGING/Walkingpad Companion.app"
ln -s /Applications "$STAGING/Applications"
hdiutil create -volname 'Walkingpad Companion' -srcfolder "$STAGING" \
  -ov -format UDZO "$ROOT/dist/$NAME.dmg"
if [[ -n "${WALKINGPAD_SIGN_IDENTITY:-}" ]]; then
  codesign --force --timestamp --sign "$WALKINGPAD_SIGN_IDENTITY" "$ROOT/dist/$NAME.dmg"
fi
# Replace only the archive for this version to avoid adding duplicate ZIP entries.
rm -f "$ROOT/dist/$NAME.zip"
ditto -c -k --sequesterRsrc --keepParent "$APP" "$ROOT/dist/$NAME.zip"
(cd "$ROOT/dist" && shasum -a 256 "$NAME.dmg" "$NAME.zip" > SHA256SUMS)
printf '\nPackaged: dist/%s.{dmg,zip}\nChecksums: dist/SHA256SUMS\n' "$NAME"
