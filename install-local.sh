#!/bin/bash

# Build and install a local Switcher development release.
#
# Ad-hoc signing changes Switcher's TCC code requirement on every rebuild. The
# Accessibility row can still look enabled while referring to the previous
# signature, so a local reinstall must remove that stale decision and let macOS
# ask the user again. This script cannot grant Accessibility; only the user can.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_CONFIG="${1:-release}"
APP_BUNDLE="$PROJECT_DIR/Switcher.app"
INSTALL_PATH="/Applications/Switcher.app"
BUNDLE_ID="com.simpleswitcher.app"
EXECUTABLE_PATH="$INSTALL_PATH/Contents/MacOS/SimpleSwitcher"

if [[ "$BUILD_CONFIG" != "release" && "$BUILD_CONFIG" != "debug" ]]; then
    echo "Usage: $0 [release|debug]"
    exit 2
fi

"$PROJECT_DIR/build-app.sh" "$BUILD_CONFIG"

# Quit only the installed Switcher executable. Validate every PID before using
# it so a failed or surprising process lookup can never broaden the target.
PIDS="$(pgrep -f "^$EXECUTABLE_PATH$" || true)"
if [[ -n "$PIDS" ]]; then
    for pid in $PIDS; do
        if [[ ! "$pid" =~ ^[0-9]+$ ]]; then
            echo "Refusing to terminate unexpected PID value: $pid"
            exit 1
        fi
        kill -TERM "$pid"
    done

    for _ in {1..50}; do
        if ! pgrep -f "^$EXECUTABLE_PATH$" >/dev/null; then
            break
        fi
        sleep 0.1
    done

    if pgrep -f "^$EXECUTABLE_PATH$" >/dev/null; then
        echo "Switcher did not quit; installation stopped without replacing it."
        exit 1
    fi
fi

ditto "$APP_BUNDLE" "$INSTALL_PATH"
codesign --verify --deep --strict "$INSTALL_PATH"

# Remove the permission decision tied to the previous ad-hoc signature. The new
# app will call AXIsProcessTrustedWithOptions on launch and macOS will ask again.
tccutil reset Accessibility "$BUNDLE_ID"

open "$INSTALL_PATH"

echo ""
echo "Installed $INSTALL_PATH"
echo "Enable Switcher in System Settings > Privacy & Security > Accessibility."
