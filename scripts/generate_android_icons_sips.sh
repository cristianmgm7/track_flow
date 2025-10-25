#!/bin/bash

# Android App Icons Generator for TrackFlow Flavors (using macOS sips)
# This script generates all required Android app icon sizes using macOS built-in sips tool

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 TrackFlow Android App Icons Generator (using sips)${NC}"
echo "=========================================="

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

# Function to get size for density
get_size_for_density() {
    case "$1" in
        mdpi) echo "48" ;;
        hdpi) echo "72" ;;
        xhdpi) echo "96" ;;
        xxhdpi) echo "144" ;;
        xxxhdpi) echo "192" ;;
    esac
}

# Function to generate icons for a flavor
generate_icons_for_flavor() {
    local flavor=$1
    local source_logo=$2
    local flavor_dir=$3
    
    echo -e "${YELLOW}🔄 Generating Android icons for $flavor...${NC}"
    
    # Generate each density
    for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
        local size=$(get_size_for_density "$density")
        local output_dir="$flavor_dir/res/mipmap-$density"
        local output_file="$output_dir/ic_launcher.png"
        
        # Create output directory
        mkdir -p "$output_dir"
        
        echo "  📱 Creating mipmap-$density/ic_launcher.png (${size}x${size})"
        
        # Generate icon using sips
        sips -z "$size" "$size" "$source_logo" --out "$output_file" &>/dev/null
    done
    
    echo -e "${GREEN}✅ Generated all Android icons for $flavor${NC}"
}

# Backup main icons if they exist
if [[ -d "$ANDROID_SRC_DIR/main/res/mipmap-mdpi" ]]; then
    echo -e "${YELLOW}💾 Backing up existing main icons...${NC}"
    BACKUP_DIR="$ANDROID_SRC_DIR/main/res_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
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
for density in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
    size=$(get_size_for_density "$density")
    output_dir="$ANDROID_SRC_DIR/main/res/mipmap-$density"
    output_file="$output_dir/ic_launcher.png"
    
    mkdir -p "$output_dir"
    
    echo "  📱 Creating main mipmap-$density/ic_launcher.png (${size}x${size})"
    
    sips -z "$size" "$size" "$PROD_LOGO" --out "$output_file" &>/dev/null
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

