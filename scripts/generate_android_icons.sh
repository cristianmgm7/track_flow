#!/bin/bash

# Android App Icons Generator for TrackFlow Flavors
# This script generates all required Android app icon sizes from the three logo files
# and sets up the flavor-specific icon structure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 TrackFlow Android App Icons Generator${NC}"
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
ANDROID_SRC_DIR="$PROJECT_ROOT/android/app/src"

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

# Define Android icon sizes (density, size in pixels)
# Android launcher icons should be:
# - mdpi: 48x48
# - hdpi: 72x72
# - xhdpi: 96x96
# - xxhdpi: 144x144
# - xxxhdpi: 192x192
declare -A ICON_SIZES=(
    ["mdpi"]="48"
    ["hdpi"]="72"
    ["xhdpi"]="96"
    ["xxhdpi"]="144"
    ["xxxhdpi"]="192"
)

# Function to generate icons for a flavor
generate_icons_for_flavor() {
    local flavor=$1
    local source_logo=$2
    local flavor_dir=$3
    
    echo -e "${YELLOW}🔄 Generating Android icons for $flavor...${NC}"
    
    # Generate each density
    for density in "${!ICON_SIZES[@]}"; do
        local size=${ICON_SIZES[$density]}
        local output_dir="$flavor_dir/res/mipmap-$density"
        local output_file="$output_dir/ic_launcher.png"
        
        # Create output directory
        mkdir -p "$output_dir"
        
        echo "  📱 Creating mipmap-$density/ic_launcher.png (${size}x${size})"
        
        # Generate icon with rounded corners (Android adaptive icons)
        # Using a slight corner radius for better appearance
        convert "$source_logo" \
            -resize "${size}x${size}" \
            -background transparent \
            -gravity center \
            -extent "${size}x${size}" \
            -quality 100 \
            "$output_file"
    done
    
    echo -e "${GREEN}✅ Generated all Android icons for $flavor${NC}"
}

# Backup main icons if they exist
if [[ -d "$ANDROID_SRC_DIR/main/res/mipmap-mdpi" ]]; then
    echo -e "${YELLOW}💾 Backing up existing main icons...${NC}"
    BACKUP_DIR="$ANDROID_SRC_DIR/main/res_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    for density in "${!ICON_SIZES[@]}"; do
        if [[ -d "$ANDROID_SRC_DIR/main/res/mipmap-$density" ]]; then
            cp -r "$ANDROID_SRC_DIR/main/res/mipmap-$density" "$BACKUP_DIR/"
        fi
    done
    echo -e "${GREEN}✅ Backup saved to: $BACKUP_DIR${NC}"
fi

# Generate icons for each flavor
echo ""
generate_icons_for_flavor "Development" "$DEV_LOGO" "$ANDROID_SRC_DIR/development"
echo ""
generate_icons_for_flavor "Staging" "$STAGING_LOGO" "$ANDROID_SRC_DIR/staging"
echo ""
generate_icons_for_flavor "Production" "$PROD_LOGO" "$ANDROID_SRC_DIR/production"

# Update main icons with production logo as fallback
echo ""
echo -e "${YELLOW}📋 Updating main/res icons with production logo...${NC}"
for density in "${!ICON_SIZES[@]}"; do
    local size=${ICON_SIZES[$density]}
    local output_dir="$ANDROID_SRC_DIR/main/res/mipmap-$density"
    local output_file="$output_dir/ic_launcher.png"
    
    mkdir -p "$output_dir"
    
    echo "  📱 Creating main mipmap-$density/ic_launcher.png (${size}x${size})"
    
    convert "$PROD_LOGO" \
        -resize "${size}x${size}" \
        -background transparent \
        -gravity center \
        -extent "${size}x${size}" \
        -quality 100 \
        "$output_file"
done

echo ""
echo -e "${GREEN}✅ Android app icons generated successfully!${NC}"
echo ""
echo -e "${BLUE}📱 Generated icons for:${NC}"
echo "  • development/res/mipmap-*"
echo "  • staging/res/mipmap-*"
echo "  • production/res/mipmap-*"
echo "  • main/res/mipmap-* (production as fallback)"
echo ""
echo -e "${YELLOW}📝 Note:${NC}"
echo "  Each flavor now has its own ic_launcher.png in all densities:"
echo "  - mdpi (48x48)"
echo "  - hdpi (72x72)"
echo "  - xhdpi (96x96)"
echo "  - xxhdpi (144x144)"
echo "  - xxxhdpi (192x192)"
echo ""
echo -e "${GREEN}🎉 Android icon generation complete!${NC}"

