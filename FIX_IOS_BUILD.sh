#!/bin/bash

# Fix iOS Build - "Argument list too long" Error
# This script cleans and rebuilds the iOS dependencies properly

set -e

echo "🔧 Fixing iOS Build Issue"
echo "==========================================="
echo ""

cd /Users/cristian/Documents/track_flow

# Step 1: Clean all iOS build artifacts
echo "🧹 Step 1: Cleaning iOS build artifacts..."
cd ios

# Remove all pods and caches
rm -rf Pods/
rm -rf .symlinks/
rm -rf Flutter/Flutter.framework
rm -rf Flutter/Flutter.podspec
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*

# Clean Xcode build
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner 2>/dev/null || true

cd ..
echo "✅ iOS artifacts cleaned"
echo ""

# Step 2: Flutter clean
echo "🧹 Step 2: Flutter clean..."
flutter clean
rm -rf build/
rm -rf .dart_tool/
echo "✅ Flutter cleaned"
echo ""

# Step 3: Get Flutter dependencies
echo "📦 Step 3: Getting Flutter dependencies..."
flutter pub get
echo "✅ Dependencies fetched"
echo ""

# Step 4: Reinstall CocoaPods with fixed Podfile
echo "📦 Step 4: Installing iOS CocoaPods (this may take a few minutes)..."
cd ios
pod deintegrate 2>/dev/null || true
pod install --repo-update
cd ..
echo "✅ Pods installed successfully"
echo ""

# Step 5: Verify pod installation
echo "🔍 Step 5: Verifying pod installation..."
POD_COUNT=$(find ios/Pods -name "*.podspec" 2>/dev/null | wc -l)
echo "   Found $POD_COUNT pods installed"
echo ""

echo "==========================================="
echo "✅ iOS Build Environment Fixed!"
echo ""
echo "🚀 Now you can build with:"
echo ""
echo "   For Development:"
echo "   flutter build ipa --flavor development -t lib/main_development.dart --release"
echo ""
echo "   For Staging:"
echo "   flutter build ipa --flavor staging -t lib/main_staging.dart --release"
echo ""
echo "   For Production:"
echo "   flutter build ipa --flavor production -t lib/main_production.dart --release"
echo ""
echo "   Or use the build script:"
echo "   ./scripts/build_flavors.sh staging release ios 1.0.3"
echo ""


