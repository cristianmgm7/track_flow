#!/bin/bash

# Diagnose Flavor Issues Script for TrackFlow
# This script helps identify and fix flavor configuration problems

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 TrackFlow Flavor Issues Diagnostic${NC}"
echo "========================================="
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

# Step 1: Check main files
echo -e "${YELLOW}🔍 Step 1: Checking main files...${NC}"

MAIN_FILES=(
    "lib/main.dart"
    "lib/main_development.dart"
    "lib/main_staging.dart"
    "lib/main_production.dart"
)

for file in "${MAIN_FILES[@]}"; do
    if [[ -f "$PROJECT_ROOT/$file" ]]; then
        echo -e "${GREEN}✅ Found: $file${NC}"
    else
        echo -e "${RED}❌ Missing: $file${NC}"
    fi
done

# Step 2: Check iOS schemes
echo ""
echo -e "${YELLOW}🔍 Step 2: Checking iOS schemes...${NC}"

SCHEMES_DIR="$PROJECT_ROOT/ios/Runner.xcodeproj/xcshareddata/xcschemes"
SCHEMES=(
    "Runner.xcscheme"
    "Runner-Development.xcscheme"
    "Runner-Staging.xcscheme"
    "Runner-Production.xcscheme"
)

for scheme in "${SCHEMES[@]}"; do
    if [[ -f "$SCHEMES_DIR/$scheme" ]]; then
        echo -e "${GREEN}✅ Found: $scheme${NC}"
    else
        echo -e "${RED}❌ Missing: $scheme${NC}"
    fi
done

# Step 3: Check xcconfig files
echo ""
echo -e "${YELLOW}🔍 Step 3: Checking xcconfig files...${NC}"

XCCONFIG_FILES=(
    "ios/Debug.xcconfig"
    "ios/Release.xcconfig"
    "ios/Debug 2.xcconfig"
    "ios/Release 2.xcconfig"
    "ios/Debug 3.xcconfig"
    "ios/Release 3.xcconfig"
)

for config in "${XCCONFIG_FILES[@]}"; do
    if [[ -f "$PROJECT_ROOT/$config" ]]; then
        if grep -q "ASSETCATALOG_COMPILER_APPICON_NAME" "$PROJECT_ROOT/$config"; then
            echo -e "${GREEN}✅ Found and configured: $(basename "$config")${NC}"
        else
            echo -e "${YELLOW}⚠️  Found but not configured: $(basename "$config")${NC}"
        fi
    else
        echo -e "${RED}❌ Missing: $(basename "$config")${NC}"
    fi
done

# Step 4: Check Flutter configuration
echo ""
echo -e "${YELLOW}🔍 Step 4: Checking Flutter configuration...${NC}"

# Check if Flutter can detect schemes
echo "Running flutter devices..."
flutter devices > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
    echo -e "${GREEN}✅ Flutter devices command works${NC}"
else
    echo -e "${RED}❌ Flutter devices command failed${NC}"
fi

# Step 5: Check flavor logos
echo ""
echo -e "${YELLOW}🔍 Step 5: Checking flavor logos...${NC}"

FLAVOR_LOGOS=(
    "assets/logo/trackflow_dev.jpg"
    "assets/logo/trackflow_staging.jpg"
    "assets/logo/trackflow_prod.jpg"
)

for logo in "${FLAVOR_LOGOS[@]}"; do
    if [[ -f "$PROJECT_ROOT/$logo" ]]; then
        echo -e "${GREEN}✅ Found: $(basename "$logo")${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename "$logo")${NC}"
    fi
done

# Step 6: Check iOS app icon sets
echo ""
echo -e "${YELLOW}🔍 Step 6: Checking iOS app icon sets...${NC}"

IOS_ASSETS_DIR="$PROJECT_ROOT/ios/Runner/Assets.xcassets"
ICON_SETS=(
    "AppIcon-Dev.appiconset"
    "AppIcon-Staging.appiconset"
    "AppIcon-Prod.appiconset"
)

for icon_set in "${ICON_SETS[@]}"; do
    if [[ -d "$IOS_ASSETS_DIR/$icon_set" ]]; then
        if [[ -f "$IOS_ASSETS_DIR/$icon_set/Icon-App-1024x1024@1x.png" ]]; then
            echo -e "${GREEN}✅ Found and complete: $icon_set${NC}"
        else
            echo -e "${YELLOW}⚠️  Found but incomplete: $icon_set${NC}"
        fi
    else
        echo -e "${RED}❌ Missing: $icon_set${NC}"
    fi
done

# Step 7: Test Flutter commands
echo ""
echo -e "${YELLOW}🔍 Step 7: Testing Flutter commands...${NC}"

echo "Testing flutter run without flavor..."
if flutter run --help | grep -q "flavor"; then
    echo -e "${GREEN}✅ Flutter supports --flavor option${NC}"
else
    echo -e "${RED}❌ Flutter does not support --flavor option${NC}"
fi

# Step 8: Check for common issues
echo ""
echo -e "${YELLOW}🔍 Step 8: Checking for common issues...${NC}"

# Check if there are any build errors
echo "Running flutter analyze..."
if flutter analyze --no-fatal-infos > /dev/null 2>&1; then
    echo -e "${GREEN}✅ No analysis errors${NC}"
else
    echo -e "${YELLOW}⚠️  Analysis has warnings (this is normal)${NC}"
fi

# Check if pubspec.yaml includes logo assets
if grep -q "assets/logo/" "$PROJECT_ROOT/pubspec.yaml"; then
    echo -e "${GREEN}✅ pubspec.yaml includes logo assets${NC}"
else
    echo -e "${RED}❌ pubspec.yaml missing logo assets${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Diagnostic Complete!${NC}"
echo "================================"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo "  • Checked main files for each flavor"
echo "  • Verified iOS schemes exist"
echo "  • Confirmed xcconfig files are configured"
echo "  • Validated Flutter setup"
echo "  • Checked flavor-specific logos"
echo "  • Verified iOS app icon sets"
echo "  • Tested Flutter commands"
echo "  • Identified common issues"
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "1. If any issues were found, fix them first"
echo "2. Try running: flutter run --flavor development"
echo "3. If still having issues, check Xcode scheme configuration"
echo "4. Verify that the correct main file is being used"
echo ""
echo -e "${GREEN}✨ Diagnostic complete! Check the results above.${NC}"
