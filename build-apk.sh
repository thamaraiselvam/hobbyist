#!/bin/bash

# Build APK script for Hobbyist app
set -e

echo "Starting Hobbyist APK build..."
export PATH=$PATH:/tmp/flutter/bin

# Clean previous builds
echo "Cleaning previous build artifacts..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build APK in release mode
echo "Building APK in release mode..."
flutter build apk --release

# Create builds directory if it doesn't exist
mkdir -p builds

# Get the APK filename
APK_SOURCE="build/app/outputs/apk/release/app-release.apk"
APK_DEST="builds/hobbyist-release-$(date +%Y%m%d-%H%M%S).apk"

# Copy APK to builds directory
if [ -f "$APK_SOURCE" ]; then
    echo "Copying APK to builds directory..."
    cp "$APK_SOURCE" "$APK_DEST"
    echo "✓ APK saved to: $APK_DEST"
    ls -lh "$APK_DEST"
else
    echo "✗ APK not found at $APK_SOURCE"
    exit 1
fi

echo "Build complete!"
