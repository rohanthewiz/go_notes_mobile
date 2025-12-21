#!/bin/bash

# Test script for GoNotes Flutter
# Runs all tests with coverage and generates HTML report

set -e

echo "🧪 Running GoNotes Flutter Tests"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get
echo ""

echo -e "${BLUE}🔍 Running analyzer...${NC}"
flutter analyze
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Analysis passed${NC}"
else
    echo -e "${RED}❌ Analysis failed${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}📝 Checking code formatting...${NC}"
flutter format --set-exit-if-changed .
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Code is properly formatted${NC}"
else
    echo -e "${YELLOW}⚠️  Code needs formatting. Run: flutter format .${NC}"
fi
echo ""

echo -e "${BLUE}🧪 Running tests with coverage...${NC}"
flutter test --coverage
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed${NC}"
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
echo ""

# Generate HTML coverage report if lcov is available
if command -v genhtml &> /dev/null; then
    echo -e "${BLUE}📊 Generating coverage report...${NC}"
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✅ Coverage report generated: coverage/html/index.html${NC}"

    # Calculate coverage percentage
    if command -v lcov &> /dev/null; then
        COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep lines | awk '{print $2}')
        echo -e "${BLUE}📈 Coverage: ${COVERAGE}${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  lcov not installed. Install it to generate HTML coverage reports.${NC}"
    echo "   macOS: brew install lcov"
    echo "   Ubuntu/Debian: sudo apt-get install lcov"
fi

echo ""
echo -e "${GREEN}✨ All checks completed successfully!${NC}"
