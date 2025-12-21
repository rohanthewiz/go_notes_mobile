#!/bin/bash

# Build release versions for all platforms
# Usage: ./scripts/build-release.sh [android|ios|web|all]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

PLATFORM=${1:-all}

echo "🏗️  Building GoNotes Flutter Release"
echo "===================================="
echo ""

# Run tests first
echo -e "${BLUE}🧪 Running tests first...${NC}"
./scripts/test.sh
echo ""

build_android() {
    echo -e "${BLUE}📱 Building Android APK...${NC}"
    flutter build apk --release
    echo -e "${GREEN}✅ Android APK built: build/app/outputs/flutter-apk/app-release.apk${NC}"
    echo ""

    echo -e "${BLUE}📦 Building Android App Bundle...${NC}"
    flutter build appbundle --release
    echo -e "${GREEN}✅ Android App Bundle built: build/app/outputs/bundle/release/app-release.aab${NC}"
    echo ""
}

build_ios() {
    echo -e "${BLUE}🍎 Building iOS...${NC}"
    flutter build ios --release --no-codesign
    echo -e "${GREEN}✅ iOS build complete${NC}"
    echo -e "${YELLOW}⚠️  Remember to sign the app in Xcode before distributing${NC}"
    echo ""
}

build_web() {
    echo -e "${BLUE}🌐 Building Web...${NC}"
    flutter build web --release
    echo -e "${GREEN}✅ Web build complete: build/web/${NC}"
    echo ""
}

case $PLATFORM in
    android)
        build_android
        ;;
    ios)
        build_ios
        ;;
    web)
        build_web
        ;;
    all)
        build_android
        if [[ "$OSTYPE" == "darwin"* ]]; then
            build_ios
        else
            echo -e "${YELLOW}⚠️  Skipping iOS build (macOS required)${NC}"
            echo ""
        fi
        build_web
        ;;
    *)
        echo -e "${RED}❌ Invalid platform: $PLATFORM${NC}"
        echo "Usage: ./scripts/build-release.sh [android|ios|web|all]"
        exit 1
        ;;
esac

echo -e "${GREEN}✨ Build complete!${NC}"
