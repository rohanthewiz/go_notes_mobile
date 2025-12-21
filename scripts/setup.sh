#!/bin/bash

# Setup script for GoNotes Flutter
# Installs dependencies and prepares the development environment

set -e

echo "🚀 GoNotes Flutter Setup"
echo "========================"
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

echo -e "${GREEN}✅ Flutter is installed${NC}"
flutter --version
echo ""

# Run Flutter doctor
echo -e "${BLUE}🏥 Running Flutter doctor...${NC}"
flutter doctor
echo ""

# Get dependencies
echo -e "${BLUE}📦 Getting dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Run code generation if needed
if grep -q "build_runner" pubspec.yaml; then
    echo -e "${BLUE}🔧 Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
    echo -e "${GREEN}✅ Code generation complete${NC}"
    echo ""
fi

# Format code
echo -e "${BLUE}📝 Formatting code...${NC}"
flutter format .
echo -e "${GREEN}✅ Code formatted${NC}"
echo ""

# Run analyzer
echo -e "${BLUE}🔍 Running analyzer...${NC}"
flutter analyze
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ No analysis issues${NC}"
else
    echo -e "${YELLOW}⚠️  Some analysis issues found${NC}"
fi
echo ""

# Make scripts executable
echo -e "${BLUE}🔐 Making scripts executable...${NC}"
chmod +x scripts/*.sh
echo -e "${GREEN}✅ Scripts are executable${NC}"
echo ""

# Check for connected devices
echo -e "${BLUE}📱 Checking for connected devices...${NC}"
flutter devices
echo ""

echo -e "${GREEN}✨ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Connect a device or start an emulator"
echo "  2. Run: flutter run"
echo "  3. Run tests: ./scripts/test.sh"
echo ""
echo "Happy coding! 💙"
