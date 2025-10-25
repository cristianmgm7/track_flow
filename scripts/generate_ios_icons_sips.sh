#!/bin/bash

# iOS App Icons Generator for TrackFlow Flavors (using macOS sips)
# This script generates all required iOS app icon sizes using macOS built-in sips tool

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🎨 TrackFlow iOS App Icons Generator (using sips)${NC}"
echo "=========================================="

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_ROOT/assets/logo"
IOS_ASSETS_DIR="$PROJECT_ROOT/ios/Runner/Assets.xcassets"

# Source logos - support both JPG and PNG
find_logo() {
    local base_name=$1
    if [[ -f "$ASSETS_DIR/${base_name}.png" ]]; then
        echo "$ASSETS_DIR/${base_name}.png"
    elif [[ -f "$ASSETS_DIR/${base_name}.jpg" ]]; then
        echo "$ASSETS_DIR/${base_name}.jpg"
    else
        echo ""
    fi
}

DEV_LOGO=$(find_logo "trackflow_dev")
STAGING_LOGO=$(find_logo "trackflow_staging")
PROD_LOGO=$(find_logo "trackflow_prod")

# Check if source logos exist
if [[ -z "$DEV_LOGO" ]] || [[ -z "$STAGING_LOGO" ]] || [[ -z "$PROD_LOGO" ]]; then
    echo -e "${RED}❌ One or more logo files are missing:${NC}"
    echo "  Expected: $ASSETS_DIR/trackflow_dev.png or .jpg"
    echo "  Expected: $ASSETS_DIR/trackflow_staging.png or .jpg"
    echo "  Expected: $ASSETS_DIR/trackflow_prod.png or .jpg"
    exit 1
fi

echo -e "${GREEN}✅ Found all logo files${NC}"
echo "  Dev: $DEV_LOGO"
echo "  Staging: $STAGING_LOGO"
echo "  Prod: $PROD_LOGO"

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

        # Use sips to resize images
        # For the 1024x1024 App Store icon, we'll handle alpha channel separately
        sips -z "$height" "$width" "$source_logo" --out "$output_path" &>/dev/null
        
        # For the App Store icon, remove alpha channel if it's PNG
        if [[ "$filename" == "Icon-App-1024x1024@1x.png" ]]; then
            # Convert to format without alpha
            sips -s format jpeg "$output_path" --out "${output_path}.tmp.jpg" &>/dev/null
            sips -s format png "${output_path}.tmp.jpg" --out "$output_path" &>/dev/null
            rm -f "${output_path}.tmp.jpg"
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

# Backup existing icons
if [[ -d "$IOS_ASSETS_DIR/AppIcon-Dev.appiconset" ]]; then
    echo -e "${YELLOW}💾 Backing up existing icons...${NC}"
    BACKUP_DIR="$IOS_ASSETS_DIR/backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    [[ -d "$IOS_ASSETS_DIR/AppIcon-Dev.appiconset" ]] && cp -r "$IOS_ASSETS_DIR/AppIcon-Dev.appiconset" "$BACKUP_DIR/"
    [[ -d "$IOS_ASSETS_DIR/AppIcon-Staging.appiconset" ]] && cp -r "$IOS_ASSETS_DIR/AppIcon-Staging.appiconset" "$BACKUP_DIR/"
    [[ -d "$IOS_ASSETS_DIR/AppIcon-Prod.appiconset" ]] && cp -r "$IOS_ASSETS_DIR/AppIcon-Prod.appiconset" "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Backup saved to: $BACKUP_DIR${NC}"
fi

# Generate icons for each flavor
echo ""
generate_icons_for_flavor "Development" "$DEV_LOGO" "$IOS_ASSETS_DIR/AppIcon-Dev.appiconset"
echo ""
generate_icons_for_flavor "Staging" "$STAGING_LOGO" "$IOS_ASSETS_DIR/AppIcon-Staging.appiconset"
echo ""
generate_icons_for_flavor "Production" "$PROD_LOGO" "$IOS_ASSETS_DIR/AppIcon-Prod.appiconset"

# Create Contents.json files
create_contents_json "$IOS_ASSETS_DIR/AppIcon-Dev.appiconset"
create_contents_json "$IOS_ASSETS_DIR/AppIcon-Staging.appiconset"
create_contents_json "$IOS_ASSETS_DIR/AppIcon-Prod.appiconset"

echo ""
echo -e "${GREEN}✅ iOS app icons generated successfully!${NC}"
echo ""
echo -e "${BLUE}📱 Generated icon sets:${NC}"
echo "  • AppIcon-Dev.appiconset (Development)"
echo "  • AppIcon-Staging.appiconset (Staging)"
echo "  • AppIcon-Prod.appiconset (Production)"
echo ""
echo -e "${GREEN}🎉 Icon generation complete!${NC}"

