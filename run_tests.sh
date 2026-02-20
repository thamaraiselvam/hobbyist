#!/usr/bin/env bash
# run_tests.sh — Full Maestro test suite runner with ADB setup and teardown.
#
# Usage:
#   ./run_tests.sh              # Run full suite (driver install + suite + clear)
#   ./run_tests.sh --skip-install  # Skip APK install (driver already installed)
#
# Assumes:
#   - An Android emulator is already running (adb devices shows a device)
#   - maestro CLI is installed and on PATH
#   - ~/.maestro/lib/maestro-client.jar exists

set -euo pipefail

APP_ID="tham.hobbyist.app"
MAIN_ACTIVITY="tham.hobbyist.app/.MainActivity"
SUITE="maestro-tests/suite.yml"
MAESTRO_JAR="$HOME/.maestro/lib/maestro-client.jar"

# ─── Helpers ─────────────────────────────────────────────────────────────────

log() { echo "▶ $*"; }
fail() { echo "✗ $*" >&2; exit 1; }

# ─── Step 1: Install Maestro driver APKs ─────────────────────────────────────

install_driver() {
  log "Installing Maestro driver APKs..."
  [ -f "$MAESTRO_JAR" ] || fail "maestro-client.jar not found at $MAESTRO_JAR"

  TMPDIR=$(mktemp -d)
  pushd "$TMPDIR" > /dev/null
  jar xf "$MAESTRO_JAR" maestro-app.apk maestro-server.apk
  adb install -r maestro-app.apk
  adb install -r maestro-server.apk
  popd > /dev/null
  rm -rf "$TMPDIR"
  log "Driver APKs installed."
}

if [[ "${1:-}" != "--skip-install" ]]; then
  install_driver
fi

# ─── Step 2: Start Maestro driver and forward port ───────────────────────────

log "Starting Maestro driver..."
adb shell am instrument -w \
  dev.mobile.maestro.test/androidx.test.runner.AndroidJUnitRunner &
DRIVER_PID=$!

log "Forwarding port 7001..."
adb forward tcp:7001 tcp:7001

# Give the driver a moment to initialise
sleep 2

# ─── Step 3: Pre-suite app setup ─────────────────────────────────────────────

log "Clearing app state..."
adb shell pm clear "$APP_ID"

log "Granting notification permission..."
adb shell pm grant "$APP_ID" android.permission.POST_NOTIFICATIONS

log "Launching app..."
adb shell am start -n "$MAIN_ACTIVITY"

# Wait for the app to reach the splash screen
sleep 2

# ─── Step 4: Run the suite ───────────────────────────────────────────────────

log "Running test suite: $SUITE"
maestro test "$SUITE"
SUITE_EXIT=$?

# ─── Step 5: Post-suite teardown ─────────────────────────────────────────────

log "Clearing app state after suite..."
adb shell pm clear "$APP_ID"

# Stop the driver process
kill "$DRIVER_PID" 2>/dev/null || true

if [ "$SUITE_EXIT" -eq 0 ]; then
  log "✓ All tests passed. App state cleared."
else
  fail "Suite finished with failures (exit $SUITE_EXIT). App state cleared."
fi
