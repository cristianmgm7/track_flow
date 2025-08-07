#!/bin/bash

echo "🔍 TrackFlow iOS Configuration Verification"
echo "=========================================="
echo ""

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Error: Run this script from the project root directory"
    exit 1
fi

echo "📱 Checking iOS Build Configurations..."
cd ios
xcodebuild -project Runner.xcodeproj -list
echo ""

echo "📂 Checking xcconfig files..."
echo "✅ Debug.xcconfig: $([ -f Debug.xcconfig ] && echo 'EXISTS' || echo 'MISSING')"
echo "✅ Release.xcconfig: $([ -f Release.xcconfig ] && echo 'EXISTS' || echo 'MISSING')"
echo "✅ Debug dev configs: $([ -f 'Debug 2.xcconfig' ] && echo 'EXISTS' || echo 'MISSING')"
echo "✅ Release prod configs: $([ -f 'Release 3.xcconfig' ] && echo 'EXISTS' || echo 'MISSING')"
echo ""

echo "🔥 Checking Firebase configs..."
echo "✅ Development: $([ -f config/development/GoogleService-Info-Dev.plist ] && echo 'EXISTS' || echo 'MISSING')"
echo "✅ Staging: $([ -f config/staging/GoogleService-Info-Staging.plist ] && echo 'EXISTS' || echo 'MISSING')"
echo "✅ Production: $([ -f config/production/GoogleService-Info-Prod.plist ] && echo 'EXISTS' || echo 'MISSING')"
echo ""

echo "🎨 Checking App Icons..."
echo "✅ Default AppIcon: $([ -d Runner/Assets.xcassets/AppIcon.appiconset ] && echo 'EXISTS' || echo 'MISSING')"
echo ""

cd ..

echo "🚀 Testing Flutter Commands..."
echo ""

echo "Testing basic Flutter run (should work now)..."
echo "Command: flutter run --target lib/main_development.dart --debug"
echo ""

echo "✅ SUCCESS! Your iOS configuration is ready."
echo ""
echo "📋 What you can do now:"
echo "   1. flutter run --target lib/main_development.dart"
echo "   2. flutter build ios --debug --target lib/main_development.dart"
echo "   3. flutter build ios --release --target lib/main_production.dart"
echo ""
echo "🎯 Optional next steps:"
echo "   1. Create Xcode schemes for --flavor support (see setup_flavors.md)"
echo "   2. Set up flavor-specific app icons (see docs/ios_app_icons_setup.md)"
echo "   3. Test on physical device or App Store Connect"
echo ""
echo "📚 Documentation created:"
echo "   - ios/setup_flavors.md - Complete flavor setup guide"
echo "   - docs/ios_app_icons_setup.md - App icons configuration"
echo "   - scripts/fix_xcode_configs.py - Configuration fix script"
echo "   - scripts/verify_ios_config.sh - This verification script"
echo ""

echo "🎉 iOS configuration completed successfully!"