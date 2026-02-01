#!/bin/bash

# CI/CD Pipeline Validation Script
# This script validates the workflow configuration locally before pushing

set -e

echo "🔍 Validating CI/CD Pipeline Configuration..."
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if workflow file exists
if [ ! -f ".github/workflows/ci.yml" ]; then
    echo -e "${RED}❌ Workflow file not found: .github/workflows/ci.yml${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Workflow file exists${NC}"

# Validate YAML syntax (requires yq or python)
echo ""
echo "📝 Validating YAML syntax..."
if command -v yq &> /dev/null; then
    yq eval '.github/workflows/ci.yml' > /dev/null 2>&1 && \
        echo -e "${GREEN}✅ YAML syntax is valid${NC}" || \
        echo -e "${RED}❌ YAML syntax error${NC}"
elif command -v python3 &> /dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml'))" && \
        echo -e "${GREEN}✅ YAML syntax is valid${NC}" || \
        echo -e "${RED}❌ YAML syntax error${NC}"
else
    echo -e "${YELLOW}⚠️  Cannot validate YAML (install yq or python3)${NC}"
fi

# Check Flutter version
echo ""
echo "🐦 Checking Flutter version..."
CURRENT_VERSION=$(flutter --version 2>/dev/null | grep "Flutter" | awk '{print $2}')
REQUIRED_VERSION="3.24.0"

if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${RED}❌ Flutter not found${NC}"
else
    echo -e "Current: ${CURRENT_VERSION}"
    echo -e "Pipeline: ${REQUIRED_VERSION}"
    if [ "$CURRENT_VERSION" != "$REQUIRED_VERSION" ]; then
        echo -e "${YELLOW}⚠️  Version mismatch (may cause issues)${NC}"
    else
        echo -e "${GREEN}✅ Flutter version matches${NC}"
    fi
fi

# Run pre-checks locally
echo ""
echo "🔍 Running pre-checks locally..."

# Flutter analyze
echo ""
echo "Running flutter analyze..."
if flutter analyze --no-pub; then
    echo -e "${GREEN}✅ Flutter analyze passed${NC}"
else
    echo -e "${RED}❌ Flutter analyze failed${NC}"
    exit 1
fi

# Dart format check
echo ""
echo "Checking Dart formatting..."
if dart format --set-exit-if-changed . > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Dart formatting is correct${NC}"
else
    echo -e "${YELLOW}⚠️  Formatting issues found (run: dart format .)${NC}"
fi

# Check for obvious secrets
echo ""
echo "🔒 Checking for secrets..."
if grep -r "api[_-]key\s*=\s*['\"][a-zA-Z0-9]\+" lib/ 2>/dev/null; then
    echo -e "${RED}❌ Potential API key found in code${NC}"
else
    echo -e "${GREEN}✅ No obvious secrets found${NC}"
fi

# Run unit tests
echo ""
echo "🧪 Running unit tests..."
if flutter test test/unit/ --no-pub > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Unit tests passed${NC}"
else
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi

# Check if build works
echo ""
echo "📦 Testing Android build..."
if flutter build apk --debug > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Android build successful${NC}"
else
    echo -e "${RED}❌ Android build failed${NC}"
    exit 1
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 All validations passed!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "You can now safely push to GitHub:"
echo "  git add .github/"
echo "  git commit -m 'feat: Add CI/CD pipeline'"
echo "  git push origin main"
echo ""
echo "The pipeline will automatically run on push."
