#!/usr/bin/env bash
# run_tests.sh — Full Maestro test suite runner with ADB setup and teardown.
#
# Usage:
#   ./run_tests.sh              # Run full suite (suite + clear)
#
# Assumes:
#   - An Android emulator is already running (adb devices shows a device)
#   - maestro CLI is installed and on PATH
#   - maestro can see an available device via `maestro devices`

set -euo pipefail

APP_ID="tham.hobbyist.app"
MAIN_ACTIVITY="tham.hobbyist.app/.MainActivity"
SUITE="maestro-tests/suite.yml"

# ─── Helpers ─────────────────────────────────────────────────────────────────

log() { echo "▶ $*"; }
fail() { echo "✗ $*" >&2; exit 1; }

# ─── Step 1: Pre-suite app setup ─────────────────────────────────────────────

log "Clearing app state..."
adb shell pm clear "$APP_ID"

log "Granting notification permission..."
adb shell pm grant "$APP_ID" android.permission.POST_NOTIFICATIONS

log "Launching app..."
adb shell am start -n "$MAIN_ACTIVITY"

# Wait for the app to reach the splash screen
sleep 2

# ─── Step 2: Run the suite ───────────────────────────────────────────────────

log "Maestro version: $(maestro --version)"
log "Available devices:"
maestro devices

log "Running test suite: $SUITE"
if maestro test "$SUITE"; then
  SUITE_EXIT=0
else
  log "First test run failed, retrying once after cool-down..."
  sleep 8
  maestro test "$SUITE"
  SUITE_EXIT=$?
fi

# ─── Step 3: Post-suite teardown ─────────────────────────────────────────────

log "Clearing app state after suite..."
adb shell pm clear "$APP_ID"

if [ "$SUITE_EXIT" -eq 0 ]; then
  log "✓ All tests passed. App state cleared."
else
  fail "Suite finished with failures (exit $SUITE_EXIT). App state cleared."
fi
