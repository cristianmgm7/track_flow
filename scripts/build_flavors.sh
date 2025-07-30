#!/bin/bash

# Build script for different flavors
# Usage: ./scripts/build_flavors.sh [development|staging|production] [debug|release] [android|ios]

FLAVOR=${1:-development}
BUILD_MODE=${2:-debug}
PLATFORM=${3:-android}

echo "🚀 Building TrackFlow"
echo "   Flavor: $FLAVOR"
echo "   Mode: $BUILD_MODE"
echo "   Platform: $PLATFORM"
echo ""

case $PLATFORM in
    android)
        echo "📱 Building for Android..."
        if [ "$BUILD_MODE" = "debug" ]; then
            flutter build apk --flavor $FLAVOR -t lib/main_$FLAVOR.dart --debug
        else
            flutter build apk --flavor $FLAVOR -t lib/main_$FLAVOR.dart --release
        fi
        ;;
    ios)
        echo "🍎 Building for iOS..."
        if [ "$BUILD_MODE" = "debug" ]; then
            flutter build ipa --flavor $FLAVOR -t lib/main_$FLAVOR.dart --debug
        else
            flutter build ipa --flavor $FLAVOR -t lib/main_$FLAVOR.dart --release
        fi
        ;;
    *)
        echo "❌ Unsupported platform: $PLATFORM"
        echo "   Supported platforms: android, ios"
        exit 1
        ;;
esac

echo ""
echo "✅ Build completed!"