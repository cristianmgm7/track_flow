#!/bin/bash

# Fix App Icon Configuration Script
# This script ensures the correct app icon is used for each flavor

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎨 TrackFlow App Icon Fix${NC}"
echo "=========================="
echo ""

# Check if flavor is provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}❌ Error: Please specify a flavor${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./scripts/fix_app_icon.sh [development|staging|production]"
    echo ""
    exit 1
fi

FLAVOR=$1

# Define icon mappings
case $FLAVOR in
    development|dev)
        ICON_NAME="AppIcon-Dev"
        echo -e "${GREEN}✅ Setting Development Icon: $ICON_NAME${NC}"
        ;;
    staging)
        ICON_NAME="AppIcon-Staging"
        echo -e "${GREEN}✅ Setting Staging Icon: $ICON_NAME${NC}"
        ;;
    production|prod)
        ICON_NAME="AppIcon-Prod"
        echo -e "${GREEN}✅ Setting Production Icon: $ICON_NAME${NC}"
        ;;
    *)
        echo -e "${RED}❌ Invalid flavor: $FLAVOR${NC}"
        exit 1
        ;;
esac

# Step 1: Update the default AppIcon.appiconset to point to the correct icon
echo -e "${YELLOW}🔧 Step 1: Updating default app icon reference...${NC}"

# Create a symbolic link from the default AppIcon to the flavor-specific icon
cd ios/Runner/Assets.xcassets

# Remove existing default AppIcon if it's not a symlink
if [[ ! -L "AppIcon.appiconset" ]]; then
    echo -e "${BLUE}📁 Backing up existing AppIcon.appiconset...${NC}"
    rm -rf "AppIcon.appiconset"
fi

# Create symbolic link
echo -e "${BLUE}🔗 Creating symbolic link: AppIcon.appiconset -> $ICON_NAME.appiconset${NC}"
ln -sf "$ICON_NAME.appiconset" "AppIcon.appiconset"

# Verify the link
if [[ -L "AppIcon.appiconset" ]]; then
    echo -e "${GREEN}✅ Symbolic link created successfully${NC}"
    echo -e "${BLUE}📋 AppIcon.appiconset -> $(readlink AppIcon.appiconset)${NC}"
else
    echo -e "${RED}❌ Failed to create symbolic link${NC}"
    exit 1
fi

cd ../../..

echo ""
echo -e "${GREEN}🎉 App Icon Configuration Fixed!${NC}"
echo "====================================="
echo ""
echo -e "${BLUE}📱 Next steps:${NC}"
echo "1. Clean your project: flutter clean"
echo "2. Rebuild: flutter pub get"
echo "3. Run your flavor again"
echo ""
echo -e "${YELLOW}💡 The app should now show the correct icon for $FLAVOR flavor${NC}"
