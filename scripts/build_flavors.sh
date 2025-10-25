#!/bin/bash

# Build script for different flavors
# Usage: ./scripts/build_flavors.sh [flavor] [mode] [platform] [version]
# 
# Examples:
#   ./scripts/build_flavors.sh staging release ios 1.0.2
#   ./scripts/build_flavors.sh development debug android
#   ./scripts/build_flavors.sh production release ios 1.1.0

INPUT_FLAVOR=${1:-development}
BUILD_MODE=${2:-debug}
PLATFORM=${3:-android}
VERSION=${4:-1.0.0}

# Normalize flavor aliases
case $INPUT_FLAVOR in
    dev|develop|development)
        FLAVOR_SCHEME="develop"
        FLAVOR_MAIN="development"
        FLAVOR_FIREBASE="development"
        ;;
    staging)
        FLAVOR_SCHEME="staging"
        FLAVOR_MAIN="staging"
        FLAVOR_FIREBASE="staging"
        ;;
    prod|production)
        FLAVOR_SCHEME="production"
        FLAVOR_MAIN="production"
        FLAVOR_FIREBASE="production"
        ;;
    *)
        echo "❌ Invalid flavor: $INPUT_FLAVOR"
        echo "   Supported: development/dev/develop, staging, production/prod"
        exit 1
        ;;
esac

# Auto-generate build number for release builds (timestamp format: YYYYMMDDHHmm)
if [ "$BUILD_MODE" = "release" ]; then
    BUILD_NUMBER=$(date +%Y%m%d%H%M)
else
    BUILD_NUMBER="1"
fi

echo "🚀 Building TrackFlow"
echo "   Flavor: $FLAVOR_SCHEME"
echo "   Mode: $BUILD_MODE"
echo "   Platform: $PLATFORM"
echo "   Version: $VERSION"
echo "   Build Number: $BUILD_NUMBER"
echo ""

# Switch Firebase configuration for iOS builds
if [ "$PLATFORM" = "ios" ]; then
    echo "🔥 Switching Firebase configuration..."
    ./scripts/switch_firebase_config.sh $FLAVOR_FIREBASE
    echo ""
fi

case $PLATFORM in
    android)
        echo "📱 Building for Android..."
        if [ "$BUILD_MODE" = "debug" ]; then
            flutter build apk --flavor $FLAVOR_SCHEME -t lib/main_$FLAVOR_MAIN.dart --debug \
                --build-name=$VERSION --build-number=$BUILD_NUMBER
        else
            flutter build apk --flavor $FLAVOR_SCHEME -t lib/main_$FLAVOR_MAIN.dart --release \
                --build-name=$VERSION --build-number=$BUILD_NUMBER
        fi
        ;;
    ios)
        echo "🍎 Building for iOS..."
        if [ "$BUILD_MODE" = "debug" ]; then
            flutter build ipa --flavor $FLAVOR_SCHEME -t lib/main_$FLAVOR_MAIN.dart --debug \
                --build-name=$VERSION --build-number=$BUILD_NUMBER
        else
            flutter build ipa --flavor $FLAVOR_SCHEME -t lib/main_$FLAVOR_MAIN.dart --release \
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