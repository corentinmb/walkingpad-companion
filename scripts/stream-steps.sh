#!/bin/bash
# Launch the app with immediate Bluetooth packet logging.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP="$ROOT/dist/Walkingpad Companion.app/Contents/MacOS/Walkingpad Companion"
if [[ ! -x "$APP" ]]; then
  echo 'Build the app first: bash scripts/build-app.sh debug' >&2
  exit 1
fi
if pgrep -x 'Walkingpad Companion' >/dev/null; then
  echo 'Quit Walkingpad Companion before starting this terminal session.' >&2
  exit 1
fi
echo 'Waiting for Bluetooth data (500 ms status requests). Ctrl+C to stop.' >&2
NSUnbufferedIO=YES "$APP" --bluetooth-steps | awk '/^\[Bluetooth\]/ { print; fflush() }'
