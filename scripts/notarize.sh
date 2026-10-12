#!/bin/bash
# Explicitly opt in with a Keychain profile and Developer ID identity.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
[[ -n "${WALKINGPAD_NOTARY_PROFILE:-}" ]] || { echo 'Set WALKINGPAD_NOTARY_PROFILE to your notarytool Keychain profile.' >&2; exit 2; }
[[ "${WALKINGPAD_SIGN_IDENTITY:-}" == 'Developer ID Application:'* ]] || { echo 'Set WALKINGPAD_SIGN_IDENTITY to your Developer ID Application identity.' >&2; exit 2; }
APP="$ROOT/dist/Walkingpad Companion.app"
[[ -d "$APP" ]] || { echo 'Build the signed app first.' >&2; exit 2; }
codesign --verify --deep --strict "$APP"
STAGING=$(mktemp -d "${TMPDIR:-/tmp}/walkingpad-notary.XXXXXX")
trap 'rm -rf "$STAGING"' EXIT
ditto -c -k --keepParent "$APP" "$STAGING/Walkingpad.zip"
xcrun notarytool submit "$STAGING/Walkingpad.zip" --keychain-profile "$WALKINGPAD_NOTARY_PROFILE" --wait
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"
# ZIP and DMG now both include the stapled app.
"$ROOT/scripts/package-dmg.sh" "$APP"
VERSION=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$APP/Contents/Info.plist")
# Derive the exact filenames from the checksum manifest written by the packager.
DMG=$(awk '/\.dmg$/ {sub(/^.*  /, ""); print}' "$ROOT/dist/SHA256SUMS")
ZIP=$(awk '/\.zip$/ {sub(/^.*  /, ""); print}' "$ROOT/dist/SHA256SUMS")
xcrun notarytool submit "$ROOT/dist/$DMG" --keychain-profile "$WALKINGPAD_NOTARY_PROFILE" --wait
xcrun stapler staple "$ROOT/dist/$DMG"
xcrun stapler validate "$ROOT/dist/$DMG"
(cd "$ROOT/dist" && shasum -a 256 "$DMG" "$ZIP" > SHA256SUMS)
printf 'Notarized app and DMG for version %s. Checksums refreshed.\n' "$VERSION"
