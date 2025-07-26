#!/bin/bash

echo "🌐 Fixing emulator network connectivity for Google Sign-In..."

# Set ADB path for macOS
ADB_PATH="$HOME/Library/Android/sdk/platform-tools/adb"

# Check if emulator is running
if ! $ADB_PATH devices | grep -q "emulator"; then
    echo "❌ No emulator found. Please start an emulator first."
    exit 1
fi

echo "📱 Emulator detected. Starting network fix process..."

# 1. Clear Google Play Services cache
echo "🧹 Clearing Google Play Services cache..."
$ADB_PATH shell pm clear com.google.android.gms

# 2. Clear Google Services Framework cache
echo "🧹 Clearing Google Services Framework cache..."
$ADB_PATH shell pm clear com.google.android.gsf

# 3. Clear Google Play Store cache
echo "🧹 Clearing Google Play Store cache..."
$ADB_PATH shell pm clear com.android.vending

# 4. Reset network settings
echo "🔄 Resetting network settings..."
$ADB_PATH shell settings put global airplane_mode_on 1
$ADB_PATH shell am broadcast -a android.intent.action.AIRPLANE_MODE
sleep 2
$ADB_PATH shell settings put global airplane_mode_on 0
$ADB_PATH shell am broadcast -a android.intent.action.AIRPLANE_MODE

# 5. Clear DNS cache
echo "🔄 Clearing DNS cache..."
$ADB_PATH shell settings put global private_dns_mode off
sleep 1
$ADB_PATH shell settings put global private_dns_mode opportunistic

# 6. Test connectivity
echo "🌐 Testing connectivity..."
$ADB_PATH shell ping -c 3 google.com

# 7. Check Google Play Services version
echo "📱 Checking Google Play Services version..."
$ADB_PATH shell dumpsys package com.google.android.gms | grep versionName

# 8. Force stop and restart Google Play Services
echo "🔄 Restarting Google Play Services..."
$ADB_PATH shell am force-stop com.google.android.gms
sleep 2

echo "✅ Network fix completed!"
echo ""
echo "💡 Next steps:"
echo "   1. Open Google Play Store in the emulator"
echo "   2. Update Google Play Services if available"
echo "   3. Try Google Sign-In again"
echo "   4. If it still doesn't work, try creating a new emulator with Google Play Services"
echo ""
echo "🔧 To create a new emulator with Google Play Services:"
echo "   ~/Library/Android/sdk/emulator/emulator -avd Pixel_7a_GooglePlay -gpu swiftshader_indirect" 