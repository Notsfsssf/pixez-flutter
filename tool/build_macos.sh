#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Use the local environment when present; otherwise use Flutter from PATH.
if [[ -f .envrc.local.sh ]]; then
  source .envrc.local.sh
fi
if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode.app ]]; then
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
fi

flutter pub get
(
  cd plugins/rhttp/rhttp
  flutter pub get
  dart run build_runner build
)
dart run build_runner build
if [[ $# -eq 0 ]]; then
  set -- --debug
fi
flutter build macos "$@"
