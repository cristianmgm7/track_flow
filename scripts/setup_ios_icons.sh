#!/bin/bash

# TrackFlow iOS App Icons Complete Setup Script
# This script orchestrates the entire process of setting up flavor-specific iOS app icons

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🎨 TrackFlow iOS App Icons Complete Setup${NC}"
echo "=============================================="
echo ""

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if we're in the right directory
if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]]; then
    echo -e "${RED}❌ This script must be run from the TrackFlow project root${NC}"
    exit 1
fi

echo -e "${BLUE}📍 Project root: $PROJECT_ROOT${NC}"
echo ""

# Step 1: Check prerequisites
echo -e "${YELLOW}🔍 Step 1: Checking prerequisites...${NC}"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick is required but not installed.${NC}"
    echo ""
    echo -e "${YELLOW}📦 Installing ImageMagick...${NC}"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install imagemagick
        else
            echo -e "${RED}❌ Homebrew is required to install ImageMagick on macOS${NC}"
            echo "Please install Homebrew first: https://brew.sh"
            exit 1
        fi
    else
        echo -e "${RED}❌ Please install ImageMagick manually:${NC}"
        echo "  Ubuntu/Debian: sudo apt-get install imagemagick"
        echo "  CentOS/RHEL: sudo yum install ImageMagick"
        exit 1
    fi
else
    echo -e "${GREEN}✅ ImageMagick is installed${NC}"
fi

# Check if logo files exist
ASSETS_DIR="$PROJECT_ROOT/assets/logo"
DEV_LOGO="$ASSETS_DIR/trackflow_dev.jpg"
STAGING_LOGO="$ASSETS_DIR/trackflow_staging.jpg"
PROD_LOGO="$ASSETS_DIR/trackflow_prod.jpg"

if [[ ! -f "$DEV_LOGO" ]] || [[ ! -f "$STAGING_LOGO" ]] || [[ ! -f "$PROD_LOGO" ]]; then
    echo -e "${RED}❌ One or more logo files are missing:${NC}"
    echo "  Expected: $DEV_LOGO"
    echo "  Expected: $STAGING_LOGO"
    echo "  Expected: $PROD_LOGO"
    exit 1
fi

echo -e "${GREEN}✅ All logo files found${NC}"
echo ""

# Step 2: Generate iOS app icons
echo -e "${YELLOW}🎨 Step 2: Generating iOS app icons...${NC}"
echo ""

# Make the icon generation script executable and run it
chmod +x "$SCRIPT_DIR/generate_ios_icons.sh"
"$SCRIPT_DIR/generate_ios_icons.sh"

echo ""

# Step 3: Configure xcconfig files
echo -e "${YELLOW}⚙️  Step 3: Configuring xcconfig files...${NC}"
echo ""

# Make the xcconfig configuration script executable and run it
chmod +x "$SCRIPT_DIR/configure_ios_icon_xcconfig.sh"
"$SCRIPT_DIR/configure_ios_icon_xcconfig.sh"

echo ""

# Step 4: Final verification
echo -e "${YELLOW}🔍 Step 4: Final verification...${NC}"

IOS_ASSETS_DIR="$PROJECT_ROOT/ios/Runner/Assets.xcassets"

# Check if icon sets were created
ICON_SETS=("AppIcon-Dev.appiconset" "AppIcon-Staging.appiconset" "AppIcon-Prod.appiconset")
for icon_set in "${ICON_SETS[@]}"; do
    if [[ -d "$IOS_ASSETS_DIR/$icon_set" ]]; then
        echo -e "${GREEN}✅ $icon_set created successfully${NC}"
    else
        echo -e "${RED}❌ $icon_set is missing${NC}"
    fi
done

echo ""

# Step 5: Success message and next steps
echo -e "${GREEN}🎉 iOS App Icons Setup Complete!${NC}"
echo "======================================"
echo ""
echo -e "${BLUE}📱 What was created:${NC}"
echo "  • AppIcon-Dev.appiconset (Development flavor)"
echo "  • AppIcon-Staging.appiconset (Staging flavor)"
echo "  • AppIcon-Prod.appiconset (Production flavor)"
echo "  • Updated xcconfig files for all flavors"
echo ""
echo -e "${YELLOW}🚀 Next steps:${NC}"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Verify the new icon sets appear in Assets.xcassets"
echo "3. Clean and rebuild your project:"
echo "   flutter clean && flutter pub get"
echo "4. Test each flavor to verify correct icons:"
echo "   • Development: flutter run --flavor development"
echo "   • Staging: flutter run --flavor staging"
echo "   • Production: flutter run --flavor production"
echo ""
echo -e "${PURPLE}💡 Tips:${NC}"
echo "  • Each flavor will now have its own distinct app icon"
echo "  • The icons are automatically scaled to all required sizes"
echo "  • Backups of original files were created (.backup extension)"
echo ""
echo -e "${GREEN}✨ Setup complete! Your iOS app now has flavor-specific icons!${NC}" 