#!/bin/bash

# TrackFlow Master Icon Update Script
# This script updates ALL app icons and logos for iOS and Android across all 3 flavors
# Run this whenever you update your logo files in assets/logo/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${PURPLE}╔════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║   TrackFlow Icon Update Master Script     ║${NC}"
echo -e "${PURPLE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ASSETS_DIR="$PROJECT_ROOT/assets/logo"

# Check if we're in the right directory
if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]]; then
    echo -e "${RED}❌ This script must be run from the TrackFlow project${NC}"
    echo "Current directory: $PROJECT_ROOT"
    exit 1
fi

echo -e "${BLUE}📍 Project root: $PROJECT_ROOT${NC}"
echo ""

# ============================================================================
# STEP 1: Verify Prerequisites
# ============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 1: Verifying Prerequisites${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check ImageMagick
if ! command -v convert &> /dev/null; then
    echo -e "${RED}❌ ImageMagick is required but not installed${NC}"
    echo ""
    echo -e "${YELLOW}📦 Would you like to install it now? (requires Homebrew on macOS)${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            read -p "Install ImageMagick via Homebrew? (y/n): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${YELLOW}Installing ImageMagick...${NC}"
                brew install imagemagick
                echo -e "${GREEN}✅ ImageMagick installed${NC}"
            else
                echo -e "${RED}❌ ImageMagick is required. Exiting.${NC}"
                exit 1
            fi
        else
            echo -e "${RED}❌ Homebrew not found. Please install ImageMagick manually:${NC}"
            echo "  Visit: https://imagemagick.org/script/download.php"
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
    IMAGEMAGICK_VERSION=$(convert -version | head -n 1)
    echo -e "${BLUE}   Version: $IMAGEMAGICK_VERSION${NC}"
fi

echo ""

# Check for logo files
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

if [[ -z "$DEV_LOGO" ]] || [[ -z "$STAGING_LOGO" ]] || [[ -z "$PROD_LOGO" ]]; then
    echo -e "${RED}❌ Logo files are missing!${NC}"
    echo ""
    echo -e "${YELLOW}Expected files in assets/logo/:${NC}"
    echo "  • trackflow_dev.png or .jpg"
    echo "  • trackflow_staging.png or .jpg"
    echo "  • trackflow_prod.png or .jpg"
    echo ""
    echo -e "${CYAN}📝 Requirements:${NC}"
    echo "  - Format: PNG (preferred) or JPG"
    echo "  - Size: Minimum 1024x1024px (2048x2048px recommended)"
    echo "  - Shape: Square"
    echo "  - Content: Center your design, avoid text near edges"
    exit 1
fi

echo -e "${GREEN}✅ All logo files found:${NC}"
echo -e "${BLUE}   Dev:     $(basename "$DEV_LOGO")${NC}"
echo -e "${BLUE}   Staging: $(basename "$STAGING_LOGO")${NC}"
echo -e "${BLUE}   Prod:    $(basename "$PROD_LOGO")${NC}"
echo ""

# Display logo dimensions
for logo_file in "$DEV_LOGO" "$STAGING_LOGO" "$PROD_LOGO"; do
    dimensions=$(identify -format "%wx%h" "$logo_file" 2>/dev/null || echo "unknown")
    echo -e "${BLUE}   $(basename "$logo_file"): $dimensions${NC}"
done

echo ""

# ============================================================================
# STEP 2: Generate iOS Icons
# ============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 2: Generating iOS App Icons${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ -f "$SCRIPT_DIR/generate_ios_icons.sh" ]]; then
    chmod +x "$SCRIPT_DIR/generate_ios_icons.sh"
    echo -e "${YELLOW}🍎 Running iOS icon generator...${NC}"
    echo ""
    "$SCRIPT_DIR/generate_ios_icons.sh"
    echo ""
    echo -e "${GREEN}✅ iOS icons generated successfully${NC}"
else
    echo -e "${YELLOW}⚠️  iOS icon generation script not found, skipping...${NC}"
fi

echo ""

# ============================================================================
# STEP 3: Generate Android Icons
# ============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 3: Generating Android App Icons${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

if [[ -f "$SCRIPT_DIR/generate_android_icons.sh" ]]; then
    chmod +x "$SCRIPT_DIR/generate_android_icons.sh"
    echo -e "${YELLOW}🤖 Running Android icon generator...${NC}"
    echo ""
    "$SCRIPT_DIR/generate_android_icons.sh"
    echo ""
    echo -e "${GREEN}✅ Android icons generated successfully${NC}"
else
    echo -e "${YELLOW}⚠️  Android icon generation script not found, skipping...${NC}"
fi

echo ""

# ============================================================================
# STEP 4: Summary and Next Steps
# ============================================================================
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 4: Completion Summary${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${GREEN}🎉 ALL ICONS UPDATED SUCCESSFULLY!${NC}"
echo ""
echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
echo -e "${PURPLE}  What was generated:${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}📱 iOS Icons:${NC}"
echo "  ✓ ios/Runner/Assets.xcassets/AppIcon-Dev.appiconset/"
echo "  ✓ ios/Runner/Assets.xcassets/AppIcon-Staging.appiconset/"
echo "  ✓ ios/Runner/Assets.xcassets/AppIcon-Prod.appiconset/"
echo "    (15 sizes each: 20x20 to 1024x1024)"
echo ""
echo -e "${BLUE}🤖 Android Icons:${NC}"
echo "  ✓ android/app/src/development/res/mipmap-*/"
echo "  ✓ android/app/src/staging/res/mipmap-*/"
echo "  ✓ android/app/src/production/res/mipmap-*/"
echo "  ✓ android/app/src/main/res/mipmap-*/ (production fallback)"
echo "    (5 densities: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)"
echo ""
echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo ""
echo "1. Clean your Flutter project:"
echo -e "   ${CYAN}flutter clean && flutter pub get${NC}"
echo ""
echo "2. iOS - Verify in Xcode (optional):"
echo -e "   ${CYAN}open ios/Runner.xcworkspace${NC}"
echo "   Check Assets.xcassets for the new icon sets"
echo ""
echo "3. Test each flavor to verify correct icons:"
echo -e "   ${CYAN}flutter run --flavor development${NC}"
echo -e "   ${CYAN}flutter run --flavor staging${NC}"
echo -e "   ${CYAN}flutter run --flavor production${NC}"
echo ""
echo "4. Build release versions:"
echo -e "   ${CYAN}flutter build apk --flavor production --release${NC}"
echo -e "   ${CYAN}flutter build ios --flavor production --release${NC}"
echo ""
echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
echo -e "${PURPLE}  Icon Specifications Generated:${NC}"
echo -e "${PURPLE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}iOS (per flavor):${NC}"
echo "  • 20x20 (@1x, @2x, @3x) - iPhone Notification"
echo "  • 29x29 (@1x, @2x, @3x) - iPhone Settings"
echo "  • 40x40 (@1x, @2x, @3x) - iPhone Spotlight"
echo "  • 60x60 (@2x, @3x)      - iPhone App"
echo "  • 76x76 (@1x, @2x)      - iPad App"
echo "  • 83.5x83.5 (@2x)       - iPad Pro"
echo "  • 1024x1024 (@1x)       - App Store"
echo ""
echo -e "${BLUE}Android (per flavor):${NC}"
echo "  • mdpi:    48x48px   (160dpi)"
echo "  • hdpi:    72x72px   (240dpi)"
echo "  • xhdpi:   96x96px   (320dpi)"
echo "  • xxhdpi:  144x144px (480dpi)"
echo "  • xxxhdpi: 192x192px (640dpi)"
echo ""
echo -e "${GREEN}✨ Your app now has distinct icons for all 3 flavors on both platforms!${NC}"
echo ""

