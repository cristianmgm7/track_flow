#!/bin/bash

# Rebuild App with New Icons
# This script ensures your new icons are properly included in the build

set -e

FLAVOR=${1:-staging}
PLATFORM=${2:-ios}
VERSION=${3:-1.0.3}

echo "🎨 Rebuilding TrackFlow with New Icons"
echo "=========================================="
echo ""
echo "Flavor: $FLAVOR"
echo "Platform: $PLATFORM"
echo "Version: $VERSION"
echo ""

cd /Users/cristian/Documents/track_flow

# Step 1: Clean everything thoroughly
echo "🧹 Step 1: Deep cleaning..."
echo ""

# Flutter clean
flutter clean

# Remove build folders
rm -rf build/
rm -rf .dart_tool/

# iOS specific cleaning
if [ "$PLATFORM" = "ios" ]; then
    echo "🍎 Cleaning iOS build artifacts..."
    cd ios
    
    # Clean Xcode derived data for this project
    rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
    
    # Clean pods
    rm -rf Pods/
    rm -rf .symlinks/
    rm -rf Flutter/Flutter.framework
    rm -rf Flutter/Flutter.podspec
    
    # Clean Xcode build
    xcodebuild clean -workspace Runner.xcworkspace -scheme Runner -configuration Release 2>/dev/null || true
    
    cd ..
fi

# Android specific cleaning
if [ "$PLATFORM" = "android" ]; then
    echo "🤖 Cleaning Android build artifacts..."
    cd android
    ./gradlew clean
    cd ..
fi

echo "✅ Clean complete"
echo ""

# Step 2: Get dependencies
echo "📦 Step 2: Getting dependencies..."
flutter pub get
echo ""

# Step 3: iOS Pod install
if [ "$PLATFORM" = "ios" ]; then
    echo "📦 Step 3: Installing iOS pods..."
    cd ios
    pod install --repo-update
    cd ..
    echo ""
fi

# Step 4: Verify icons exist
echo "🔍 Step 4: Verifying icon files..."
echo ""

if [ "$PLATFORM" = "ios" ]; then
    ICON_DIR="ios/Runner/Assets.xcassets/AppIcon-${FLAVOR^}.appiconset"
    
    if [ "$FLAVOR" = "development" ]; then
        ICON_DIR="ios/Runner/Assets.xcassets/AppIcon-Dev.appiconset"
    elif [ "$FLAVOR" = "staging" ]; then
        ICON_DIR="ios/Runner/Assets.xcassets/AppIcon-Staging.appiconset"
    elif [ "$FLAVOR" = "production" ]; then
        ICON_DIR="ios/Runner/Assets.xcassets/AppIcon-Prod.appiconset"
    fi
    
    if [ -d "$ICON_DIR" ]; then
        ICON_COUNT=$(ls -1 "$ICON_DIR"/*.png 2>/dev/null | wc -l)
        echo "✅ Found $ICON_COUNT icon files in $ICON_DIR"
    else
        echo "❌ Icon directory not found: $ICON_DIR"
        echo "   Run: ./scripts/generate_ios_icons_sips.sh"
        exit 1
    fi
fi

if [ "$PLATFORM" = "android" ]; then
    ICON_DIR="android/app/src/$FLAVOR/res/mipmap-hdpi"
    
    if [ -f "$ICON_DIR/ic_launcher.png" ]; then
        echo "✅ Found Android icons for $FLAVOR flavor"
    else
        echo "❌ Android icons not found for $FLAVOR"
        echo "   Run: ./scripts/generate_android_icons_sips.sh"
        exit 1
    fi
fi

echo ""

# Step 5: Switch Firebase config (iOS only)
if [ "$PLATFORM" = "ios" ]; then
    echo "🔥 Step 5: Switching Firebase configuration..."
    ./scripts/switch_firebase_config.sh $FLAVOR
    echo ""
fi

# Step 6: Build
echo "🚀 Step 6: Building $PLATFORM for $FLAVOR..."
echo ""

if [ "$PLATFORM" = "ios" ]; then
    echo "Building iOS IPA (this may take several minutes)..."
    flutter build ipa \
        --flavor $FLAVOR \
        -t lib/main_$FLAVOR.dart \
        --release \
        --build-name=$VERSION \
        --build-number=$(date +%Y%m%d%H%M)
    
    echo ""
    echo "✅ IPA BUILD COMPLETE!"
    echo ""
    echo "📦 Your IPA is at:"
    echo "   build/ios/ipa/trackflow.ipa"
    
elif [ "$PLATFORM" = "android" ]; then
    echo "Building Android APK..."
    flutter build apk \
        --flavor $FLAVOR \
        -t lib/main_$FLAVOR.dart \
        --release \
        --build-name=$VERSION \
        --build-number=$(date +%Y%m%d%H%M)
    
    echo ""
    echo "✅ APK BUILD COMPLETE!"
    echo ""
    echo "📦 Your APK is at:"
    echo "   build/app/outputs/flutter-apk/app-$FLAVOR-release.apk"
fi

echo ""
echo "=========================================="
echo "✨ Build complete with NEW ICONS! 🎨"
echo ""
echo "🔍 To verify the icon:"
if [ "$PLATFORM" = "ios" ]; then
    echo "   1. Install on device via Xcode or Transporter"
    echo "   2. Check home screen - you should see your $FLAVOR icon"
    echo "   3. Icon set used: AppIcon-${FLAVOR^}"
else
    echo "   1. Install APK on Android device"
    echo "   2. Check home screen - you should see your $FLAVOR icon"
    echo "   3. Icon location: android/app/src/$FLAVOR/res/mipmap-*/"
fi
echo ""


