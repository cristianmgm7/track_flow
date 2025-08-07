#!/bin/bash

# iOS xcconfig Icon Configuration Script for TrackFlow Flavors
# This script updates the xcconfig files to use flavor-specific app icons

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}⚙️  TrackFlow iOS xcconfig Icon Configuration${NC}"
echo "================================================"

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IOS_DIR="$PROJECT_ROOT/ios"

# Check if xcconfig files exist
XCCONFIG_FILES=(
    "$IOS_DIR/Debug.xcconfig"
    "$IOS_DIR/Release.xcconfig"
    "$IOS_DIR/Debug 2.xcconfig"
    "$IOS_DIR/Release 2.xcconfig"
    "$IOS_DIR/Debug 3.xcconfig"
    "$IOS_DIR/Release 3.xcconfig"
)

for file in "${XCCONFIG_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}❌ Missing xcconfig file: $file${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✅ Found all xcconfig files${NC}"

# Function to backup and update xcconfig file
update_xcconfig() {
    local file_path=$1
    local icon_name=$2
    local flavor_name=$3
    
    echo -e "${YELLOW}🔄 Updating $flavor_name configuration...${NC}"
    
    # Create backup
    cp "$file_path" "$file_path.backup"
    echo "  💾 Created backup: $file_path.backup"
    
    # Check if ASSETCATALOG_COMPILER_APPICON_NAME already exists
    if grep -q "ASSETCATALOG_COMPILER_APPICON_NAME" "$file_path"; then
        # Update existing line
        sed -i.bak "s/ASSETCATALOG_COMPILER_APPICON_NAME.*/ASSETCATALOG_COMPILER_APPICON_NAME = $icon_name/" "$file_path"
        echo "  ✏️  Updated existing ASSETCATALOG_COMPILER_APPICON_NAME"
    else
        # Add new line
        echo "" >> "$file_path"
        echo "# App Icon Configuration" >> "$file_path"
        echo "ASSETCATALOG_COMPILER_APPICON_NAME = $icon_name" >> "$file_path"
        echo "  ➕ Added ASSETCATALOG_COMPILER_APPICON_NAME"
    fi
    
    echo -e "${GREEN}✅ Updated $flavor_name configuration${NC}"
}

# Update each xcconfig file
echo ""
echo -e "${BLUE}📝 Updating xcconfig files...${NC}"

# Development configurations
update_xcconfig "$IOS_DIR/Debug.xcconfig" "AppIcon-Dev" "Development Debug"
update_xcconfig "$IOS_DIR/Release.xcconfig" "AppIcon-Dev" "Development Release"

# Staging configurations  
update_xcconfig "$IOS_DIR/Debug 2.xcconfig" "AppIcon-Staging" "Staging Debug"
update_xcconfig "$IOS_DIR/Release 2.xcconfig" "AppIcon-Staging" "Staging Release"

# Production configurations
update_xcconfig "$IOS_DIR/Debug 3.xcconfig" "AppIcon-Prod" "Production Debug"
update_xcconfig "$IOS_DIR/Release 3.xcconfig" "AppIcon-Prod" "Production Release"

# Clean up temporary .bak files
find "$IOS_DIR" -name "*.bak" -delete

echo ""
echo -e "${GREEN}✅ All xcconfig files updated successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Configuration Summary:${NC}"
echo "  • Development (Debug/Release): AppIcon-Dev"
echo "  • Staging (Debug/Release): AppIcon-Staging"
echo "  • Production (Debug/Release): AppIcon-Prod"
echo ""
echo -e "${YELLOW}⚠️  Next steps:${NC}"
echo "1. Clean and rebuild your iOS project"
echo "2. Test each flavor to verify correct icons"
echo "3. Run: flutter clean && flutter pub get"
echo ""
echo -e "${GREEN}🎉 xcconfig configuration complete!${NC}" 