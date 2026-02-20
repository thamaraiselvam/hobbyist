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

# ─── Step 2: Start Maestro driver ────────────────────────────────────────────
# NOTE: Do NOT run `adb forward tcp:7001 tcp:7001` here.
# Maestro CLI uses dadb internally to create its own TCP tunnel to device:7001.
# A pre-existing adb forward is not needed and would cause false positives in
# the /proc/net/tcp readiness poll below (host port 7001 would appear bound
# before the device gRPC server is actually ready).
# This aligns with the CI pipeline which also omits adb forward for the same reason.

log "Starting Maestro gRPC driver..."
adb shell am instrument -w \
  dev.mobile.maestro.test/androidx.test.runner.AndroidJUnitRunner &
DRIVER_PID=$!

# Poll /proc/net/tcp on the device instead of a blind sleep.
# Port 7001 = 0x1B59 in hex. This is a true positive: it only succeeds once
# the gRPC server has actually bound to device:7001.
log "Polling device port 7001 via /proc/net/tcp (up to 60s)..."
READY=0
for i in $(seq 1 30); do
  if adb shell grep -q 1B59 /proc/net/tcp /proc/net/tcp6 2>/dev/null; then
    log "Maestro gRPC server ready on device after $((i * 2))s"
    READY=1
    break
  fi
  sleep 2
done
if [ "$READY" -eq 0 ]; then
  log "WARNING: Device port 7001 not seen within 60s — continuing anyway"
fi

# ─── Step 3: Pre-suite app setup ─────────────────────────────────────────────

log "Clearing app state..."
adb shell pm clear "$APP_ID"

log "Granting notification permission..."
adb shell pm grant "$APP_ID" android.permission.POST_NOTIFICATIONS

# Grant SCHEDULE_EXACT_ALARM via appops (special app access, API 31+).
# requestPermissions() in notification_service.dart calls
# requestExactAlarmsPermission() immediately after the POST_NOTIFICATIONS dialog.
# On API 33+ with targetSdk 36, requestExactAlarmsPermission() opens the system
# "Alarms & Reminders" settings screen, navigating away from the add hobby form
# so create_hobby_button is never found. Pre-granting makes
# canScheduleExactAlarms() return true and the redirect never fires.
log "Granting exact alarm permission..."
adb shell appops set "$APP_ID" SCHEDULE_EXACT_ALARM allow

# Wait for the POST_NOTIFICATIONS grant to be committed to Android's permission
# database before starting the app. Without this, areNotificationsEnabled() may
# read stale state (not-granted) even though pm grant has returned, causing
# requestPermissions() to fire the OS dialog during the notify toggle test.
log "Verifying notification permission is committed..."
PERM_CONFIRMED=0
for i in $(seq 1 10); do
  if adb shell dumpsys package "$APP_ID" 2>/dev/null \
      | grep -q "POST_NOTIFICATIONS.*granted=true"; then
    log "Permission confirmed after ${i}s"
    PERM_CONFIRMED=1
    break
  fi
  sleep 1
done
if [ "$PERM_CONFIRMED" -eq 0 ]; then
  log "WARNING: Could not confirm permission grant — proceeding anyway"
fi

log "Launching app..."
adb shell am start -n "$MAIN_ACTIVITY"

# Wait for the app to reach the splash screen
sleep 3

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
