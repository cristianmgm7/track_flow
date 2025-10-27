#!/bin/bash

echo "🔧 Fixing development flavor build..."

# 1. Clean everything
echo "1. Cleaning build artifacts..."
flutter clean
rm -rf build/
rm -rf ios/build/
rm -rf ~/Library/Developer/Xcode/DerivedData/

# 2. Remove and reinstall pods
echo "2. Reinstalling pods..."
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# 3. Get dependencies
echo "3. Getting Flutter dependencies..."
flutter pub get

# 4. Build for development
echo "4. Building development flavor..."
flutter build ipa --flavor development --release

echo "✅ Done!"


