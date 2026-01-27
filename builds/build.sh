#!/bin/bash

# Hobbyist APK Build Script
# This script builds the Hobbyist Flutter app for Android

set -e  # Exit on any error

echo "========================================"
echo "  Hobbyist APK Build Script"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
echo -e "${YELLOW}Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter not found in PATH${NC}"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
echo -e "${GREEN}✓ Found: $FLUTTER_VERSION${NC}"
echo ""

# Change to project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo -e "${YELLOW}Project directory: $PROJECT_DIR${NC}"
echo ""

# Clean previous builds
echo -e "${YELLOW}Step 1: Cleaning previous build artifacts...${NC}"
flutter clean
echo -e "${GREEN}✓ Clean complete${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}Step 2: Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✓ Dependencies obtained${NC}"
echo ""

# Run code generation if needed
echo -e "${YELLOW}Step 3: Running code generation...${NC}"
flutter pub run build_runner build --delete-conflicting-outputs 2>/dev/null || true
echo ""

# Build APK in release mode
echo -e "${YELLOW}Step 4: Building APK in release mode...${NC}"
echo "This may take several minutes..."
flutter build apk --release

APK_PATH="build/app/outputs/apk/release/app-release.apk"

if [ -f "$APK_PATH" ]; then
    echo -e "${GREEN}✓ APK built successfully!${NC}"
    echo ""
    
    # Get file size
    APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
    echo -e "${GREEN}APK Size: $APK_SIZE${NC}"
    
    # Copy to builds directory
    BUILDS_DIR="$PROJECT_DIR/builds"
    mkdir -p "$BUILDS_DIR"
    
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    DEST_APK="$BUILDS_DIR/hobbyist-release-$TIMESTAMP.apk"
    
    echo -e "${YELLOW}Copying APK to builds directory...${NC}"
    cp "$APK_PATH" "$DEST_APK"
    echo -e "${GREEN}✓ APK saved to: $DEST_APK${NC}"
    echo ""
    
    echo "========================================"
    echo -e "${GREEN}Build Complete!${NC}"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "1. Transfer the APK to your Android device"
    echo "2. Install using: adb install $DEST_APK"
    echo "   OR tap the APK file on your device"
    echo ""
    echo "APK Location: $DEST_APK"
    echo ""
else
    echo -e "${RED}✗ Build failed - APK not found at $APK_PATH${NC}"
    exit 1
fi
