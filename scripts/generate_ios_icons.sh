#!/bin/bash

# iOS App Icons Generator for TrackFlow Flavors
# This script generates all required iOS app icon sizes from the three logo files
# and sets up the flavor-specific icon structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎨 TrackFlow iOS App Icons Generator${NC}"
echo "=========================================="

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick is required but not installed.${NC}"
    echo "Please install ImageMagick:"
    echo "  macOS: brew install imagemagick"
    echo "  Ubuntu: sudo apt-get install imagemagick"
    exit 1
fi

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_ROOT/assets/logo"
IOS_ASSETS_DIR="$PROJECT_ROOT/ios/Runner/Assets.xcassets"

# Source logos
DEV_LOGO="$ASSETS_DIR/trackflow_dev.jpg"
STAGING_LOGO="$ASSETS_DIR/trackflow_staging.jpg"
PROD_LOGO="$ASSETS_DIR/trackflow_prod.jpg"

# Check if source logos exist
if [[ ! -f "$DEV_LOGO" ]] || [[ ! -f "$STAGING_LOGO" ]] || [[ ! -f "$PROD_LOGO" ]]; then
    echo -e "${RED}❌ One or more logo files are missing:${NC}"
    echo "  Expected: $DEV_LOGO"
    echo "  Expected: $STAGING_LOGO"
    echo "  Expected: $PROD_LOGO"
    exit 1
fi

echo -e "${GREEN}✅ Found all logo files${NC}"

# Define icon sizes (filename, width, height)
declare -a ICON_SIZES=(
    "Icon-App-20x20@1x.png 20 20"
    "Icon-App-20x20@2x.png 40 40"
    "Icon-App-20x20@3x.png 60 60"
    "Icon-App-29x29@1x.png 29 29"
    "Icon-App-29x29@2x.png 58 58"
    "Icon-App-29x29@3x.png 87 87"
    "Icon-App-40x40@1x.png 40 40"
    "Icon-App-40x40@2x.png 80 80"
    "Icon-App-40x40@3x.png 120 120"
    "Icon-App-60x60@2x.png 120 120"
    "Icon-App-60x60@3x.png 180 180"
    "Icon-App-76x76@1x.png 76 76"
    "Icon-App-76x76@2x.png 152 152"
    "Icon-App-83.5x83.5@2x.png 167 167"
    "Icon-App-1024x1024@1x.png 1024 1024"
)

# Function to generate icons for a flavor
generate_icons_for_flavor() {
    local flavor=$1
    local source_logo=$2
    local output_dir=$3
    
    echo -e "${YELLOW}🔄 Generating icons for $flavor...${NC}"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Generate each icon size
    for icon_info in "${ICON_SIZES[@]}"; do
        read -r filename width height <<< "$icon_info"
        local output_path="$output_dir/$filename"

        echo "  📱 Creating $filename (${width}x${height})"

        # Generate icons. The App Store marketing icon (1024x1024) MUST NOT contain an alpha channel.
        # For that specific size, render on a solid white background and explicitly remove alpha.
        if [[ "$filename" == "Icon-App-1024x1024@1x.png" ]]; then
            convert "$source_logo" \
                -resize "${width}x${height}" \
                -background white \
                -gravity center \
                -extent "${width}x${height}" \
                -alpha remove -alpha off \
                -quality 100 \
                "$output_path"
        else
            convert "$source_logo" \
                -resize "${width}x${height}" \
                -background transparent \
                -gravity center \
                -extent "${width}x${height}" \
                -quality 100 \
                "$output_path"
        fi
    done
    
    echo -e "${GREEN}✅ Generated all icons for $flavor${NC}"
}

# Function to create Contents.json for app icon set
create_contents_json() {
    local output_dir=$1
    local contents_json="$output_dir/Contents.json"
    
    cat > "$contents_json" << 'EOF'
{
  "images" : [
    {
      "filename" : "Icon-App-20x20@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-29x29@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-40x40@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-60x60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-60x60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-76x76@1x.png",
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-76x76@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "Icon-App-1024x1024@1x.png",
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
}

# Create temporary directory for processing
TEMP_DIR=$(mktemp -d)
echo -e "${BLUE}📁 Using temporary directory: $TEMP_DIR${NC}"

# Generate icons for each flavor
generate_icons_for_flavor "Development" "$DEV_LOGO" "$TEMP_DIR/AppIcon-Dev.appiconset"
generate_icons_for_flavor "Staging" "$STAGING_LOGO" "$TEMP_DIR/AppIcon-Staging.appiconset"
generate_icons_for_flavor "Production" "$PROD_LOGO" "$TEMP_DIR/AppIcon-Prod.appiconset"

# Create Contents.json files
create_contents_json "$TEMP_DIR/AppIcon-Dev.appiconset"
create_contents_json "$TEMP_DIR/AppIcon-Staging.appiconset"
create_contents_json "$TEMP_DIR/AppIcon-Prod.appiconset"

# Backup existing icons
if [[ -d "$IOS_ASSETS_DIR/AppIcon.appiconset" ]]; then
    echo -e "${YELLOW}💾 Backing up existing icons...${NC}"
    cp -r "$IOS_ASSETS_DIR/AppIcon.appiconset" "$IOS_ASSETS_DIR/AppIcon.appiconset.backup"
fi

# Copy new icon sets to iOS assets
echo -e "${YELLOW}📋 Copying icon sets to iOS assets...${NC}"
cp -r "$TEMP_DIR"/* "$IOS_ASSETS_DIR/"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo -e "${GREEN}✅ iOS app icons generated successfully!${NC}"
echo ""
echo -e "${BLUE}📱 Generated icon sets:${NC}"
echo "  • AppIcon-Dev.appiconset (Development)"
echo "  • AppIcon-Staging.appiconset (Staging)"
echo "  • AppIcon-Prod.appiconset (Production)"
echo ""
echo -e "${YELLOW}⚠️  Next steps:${NC}"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Verify the new icon sets appear in Assets.xcassets"
echo "3. Update xcconfig files (see next script)"
echo ""
echo -e "${GREEN}🎉 Icon generation complete!${NC}" 