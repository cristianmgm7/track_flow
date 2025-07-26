#!/bin/bash

echo "🔧 Fixing Google Sign-In issues in emulator..."

# Set ADB path for macOS
ADB_PATH="$HOME/Library/Android/sdk/platform-tools/adb"

# Check if emulator is running
if ! $ADB_PATH devices | grep -q "emulator"; then
    echo "❌ No emulator found. Please start an emulator first."
    exit 1
fi

echo "📱 Emulator detected. Starting fix process..."

# 1. Clear app data
echo "🧹 Clearing app data..."
$ADB_PATH shell pm clear com.example.trackflow

# 2. Uninstall app
echo "🗑️ Uninstalling app..."
$ADB_PATH uninstall com.example.trackflow

# 3. Clear Google Play Services cache (optional)
echo "🔄 Clearing Google Play Services cache..."
$ADB_PATH shell pm clear com.google.android.gms

# 4. Clear Google Services Framework cache
echo "🔄 Clearing Google Services Framework cache..."
$ADB_PATH shell pm clear com.google.android.gsf

# 5. Rebuild and install
echo "🔨 Rebuilding app..."
flutter clean
flutter pub get
flutter build apk --debug

# 6. Install the new APK
echo "📦 Installing new APK..."
flutter install

echo "✅ Fix completed! Try Google Sign-In again."
echo ""
echo "💡 If the issue persists, try these additional steps:"
echo "   1. Restart the emulator"
echo "   2. Update Google Play Services in the emulator"
echo "   3. Check your internet connection"
echo "   4. Verify Firebase configuration" 