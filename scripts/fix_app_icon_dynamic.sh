#!/bin/bash

# Dynamic App Icon Configuration Script
# This script properly configures app icons for each flavor

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎨 TrackFlow Dynamic App Icon Configuration${NC}"
echo "============================================="
echo ""

# Check if flavor is provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}❌ Error: Please specify a flavor${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./scripts/fix_app_icon_dynamic.sh [development|staging|production]"
    echo ""
    exit 1
fi

FLAVOR=$1

# Define icon mappings
case $FLAVOR in
    development|dev)
        ICON_NAME="AppIcon-Dev"
        echo -e "${GREEN}✅ Configuring Development Icon: $ICON_NAME${NC}"
        ;;
    staging)
        ICON_NAME="AppIcon-Staging"
        echo -e "${GREEN}✅ Configuring Staging Icon: $ICON_NAME${NC}"
        ;;
    production|prod)
        ICON_NAME="AppIcon-Prod"
        echo -e "${GREEN}✅ Configuring Production Icon: $ICON_NAME${NC}"
        ;;
    *)
        echo -e "${RED}❌ Invalid flavor: $FLAVOR${NC}"
        exit 1
        ;;
esac

# Step 1: Restore the original AppIcon.appiconset if it's a symlink
echo -e "${YELLOW}🔧 Step 1: Restoring original AppIcon.appiconset...${NC}"

cd ios/Runner/Assets.xcassets

# Check if AppIcon.appiconset is a symbolic link
if [[ -L "AppIcon.appiconset" ]]; then
    echo -e "${BLUE}📁 Removing symbolic link...${NC}"
    rm "AppIcon.appiconset"
    
    # Restore from backup if it exists
    if [[ -d "AppIcon.appiconset.backup" ]]; then
        echo -e "${BLUE}📁 Restoring from backup...${NC}"
        cp -r "AppIcon.appiconset.backup" "AppIcon.appiconset"
    else
        echo -e "${YELLOW}⚠️  No backup found, creating default AppIcon...${NC}"
        # Create a basic AppIcon structure
        mkdir -p "AppIcon.appiconset"
        cat > "AppIcon.appiconset/Contents.json" << 'EOF'
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    fi
fi

# Step 2: Copy the flavor-specific icon to the default AppIcon location
echo -e "${YELLOW}🔧 Step 2: Copying $ICON_NAME to AppIcon...${NC}"

if [[ -d "$ICON_NAME.appiconset" ]]; then
    echo -e "${BLUE}📁 Copying $ICON_NAME.appiconset to AppIcon.appiconset...${NC}"
    rm -rf "AppIcon.appiconset"
    cp -r "$ICON_NAME.appiconset" "AppIcon.appiconset"
    echo -e "${GREEN}✅ Icon copied successfully${NC}"
else
    echo -e "${RED}❌ Error: $ICON_NAME.appiconset not found${NC}"
    exit 1
fi

cd ../../..

echo ""
echo -e "${GREEN}🎉 Dynamic App Icon Configuration Complete!${NC}"
echo "============================================="
echo ""
echo -e "${BLUE}📱 Next steps:${NC}"
echo "1. Clean your project: flutter clean"
echo "2. Rebuild: flutter pub get"
echo "3. Run your flavor again"
echo ""
echo -e "${YELLOW}💡 Now each flavor will use its specific icon when you run it${NC}"
echo -e "${YELLOW}💡 You'll need to run this script each time you switch flavors${NC}"
