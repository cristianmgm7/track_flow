#!/bin/bash

# Build script for different flavors
# Usage: ./scripts/build_flavors.sh [flavor] [mode] [platform] [version]
# 
# Examples:
#   ./scripts/build_flavors.sh staging release ios 1.0.2
#   ./scripts/build_flavors.sh development debug android
#   ./scripts/build_flavors.sh production release ios 1.1.0

FLAVOR=${1:-development}
BUILD_MODE=${2:-debug}
PLATFORM=${3:-android}
VERSION=${4:-1.0.0}

# Auto-generate build number for release builds (timestamp format: YYYYMMDDHHmm)
if [ "$BUILD_MODE" = "release" ]; then
    BUILD_NUMBER=$(date +%Y%m%d%H%M)
else
    BUILD_NUMBER="1"
fi

echo "🚀 Building TrackFlow"
echo "   Flavor: $FLAVOR"
echo "   Mode: $BUILD_MODE"
echo "   Platform: $PLATFORM"
echo "   Version: $VERSION"
echo "   Build Number: $BUILD_NUMBER"
echo ""

# Switch Firebase configuration for iOS builds
if [ "$PLATFORM" = "ios" ]; then
    echo "🔥 Switching Firebase configuration..."
    ./scripts/switch_firebase_config.sh $FLAVOR
    echo ""
fi

case $PLATFORM in
    android)
        echo "📱 Building for Android..."
        if [ "$BUILD_MODE" = "debug" ]; then
            flutter build apk --flavor $FLAVOR -t lib/main_$FLAVOR.dart --debug \
                --build-name=$VERSION --build-number=$BUILD_NUMBER
        else
            flutter build apk --flavor $FLAVOR -t lib/main_$FLAVOR.dart --release \
                --build-name=$VERSION --build-number=$BUILD_NUMBER
        fi
        ;;
    ios)
        echo "🍎 Building for iOS..."
        if [ "$BUILD_MODE" = "debug" ]; then
            flutter build ipa --flavor $FLAVOR -t lib/main_$FLAVOR.dart --debug \
                --build-name=$VERSION --build-number=$BUILD_NUMBER
        else
            flutter build ipa --flavor $FLAVOR -t lib/main_$FLAVOR.dart --release \
                --build-name=$VERSION --build-number=$BUILD_NUMBER
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