#!/bin/bash

# Build Staging Release for iOS - Version 1.0.3
# This script builds an IPA ready for Transporter upload

set -e

echo "🚀 Building TrackFlow Staging Release for iOS"
echo "================================================"
echo ""
echo "📋 Build Configuration:"
echo "   Flavor: staging"
echo "   Platform: iOS"
echo "   Version: 1.0.3"
echo "   Build Number: $(date +%Y%m%d%H%M)"
echo "   Configuration: Release"
echo ""

# Navigate to project directory
cd /Users/cristian/Documents/track_flow

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean
flutter pub get
echo ""

# Switch Firebase configuration for staging
echo "🔥 Switching to Staging Firebase config..."
./scripts/switch_firebase_config.sh staging
echo ""

# Build the IPA
echo "🍎 Building iOS IPA for Staging..."
echo "   This may take several minutes..."
echo ""

flutter build ipa \
  --flavor staging \
  -t lib/main_staging.dart \
  --release \
  --build-name=1.0.3 \
  --build-number=$(date +%Y%m%d%H%M)

echo ""
echo "✅ BUILD COMPLETED!"
echo "================================================"
echo ""
echo "📦 Your IPA file is located at:"
echo "   build/ios/ipa/trackflow.ipa"
echo ""
echo "🚀 Next Steps:"
echo ""
echo "1. Open Transporter app (from Mac App Store)"
echo ""
echo "2. Drag and drop the IPA file into Transporter:"
echo "   /Users/cristian/Documents/track_flow/build/ios/ipa/trackflow.ipa"
echo ""
echo "3. Click 'Deliver' to upload to App Store Connect"
echo ""
echo "4. Once uploaded, go to App Store Connect:"
echo "   https://appstoreconnect.apple.com"
echo ""
echo "5. Select your app → TestFlight"
echo ""
echo "6. Add this build to TestFlight for testing"
echo ""
echo "================================================"
echo "✨ Your app will show the STAGING icon! 🎨"
echo ""

