#!/bin/bash
# One command for the universal app, DMG, ZIP and checksums.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT/scripts/build-app.sh"
"$ROOT/scripts/package-dmg.sh"
