#!/bin/bash

# Cleanup Generic Logo Script for TrackFlow
# This script removes the generic logo.png and verifies all references have been updated

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧹 TrackFlow Generic Logo Cleanup${NC}"
echo "====================================="
echo ""

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
GENERIC_LOGO="$PROJECT_ROOT/assets/images/logo.png"

# Check if we're in the right directory
if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]]; then
    echo -e "${RED}❌ This script must be run from the TrackFlow project root${NC}"
    exit 1
fi

echo -e "${BLUE}📍 Project root: $PROJECT_ROOT${NC}"
echo ""

# Step 1: Check for remaining references to the generic logo
echo -e "${YELLOW}🔍 Step 1: Checking for remaining references to generic logo...${NC}"

# Search for references to the old logo
REMAINING_REFERENCES=$(grep -r "assets/images/logo.png" "$PROJECT_ROOT" \
    --exclude-dir=.git \
    --exclude-dir=build \
    --exclude-dir=.dart_tool \
    --exclude-dir=node_modules \
    --exclude-dir=android/.gradle \
    --exclude-dir=ios/Pods \
    --exclude-dir=macos/Pods \
    --exclude=*.bin \
    --exclude=*.lock \
    --exclude=cleanup_generic_logo.sh \
    2>/dev/null || true)

if [[ -n "$REMAINING_REFERENCES" ]]; then
    echo -e "${RED}❌ Found remaining references to generic logo:${NC}"
    echo "$REMAINING_REFERENCES"
    echo ""
    echo -e "${YELLOW}⚠️  Please update these references before removing the generic logo${NC}"
    exit 1
else
    echo -e "${GREEN}✅ No remaining references to generic logo found${NC}"
fi

# Step 2: Check if flavor-specific logos exist
echo ""
echo -e "${YELLOW}🔍 Step 2: Verifying flavor-specific logos exist...${NC}"

FLAVOR_LOGOS=(
    "$PROJECT_ROOT/assets/logo/trackflow_dev.jpg"
    "$PROJECT_ROOT/assets/logo/trackflow_staging.jpg"
    "$PROJECT_ROOT/assets/logo/trackflow_prod.jpg"
)

for logo in "${FLAVOR_LOGOS[@]}"; do
    if [[ -f "$logo" ]]; then
        echo -e "${GREEN}✅ Found: $(basename "$logo")${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename "$logo")${NC}"
        echo -e "${YELLOW}⚠️  Cannot remove generic logo without flavor-specific logos${NC}"
        exit 1
    fi
done

# Step 3: Backup and remove generic logo
echo ""
echo -e "${YELLOW}🗑️  Step 3: Removing generic logo...${NC}"

if [[ -f "$GENERIC_LOGO" ]]; then
    # Create backup
    BACKUP_PATH="$GENERIC_LOGO.backup"
    cp "$GENERIC_LOGO" "$BACKUP_PATH"
    echo -e "${GREEN}💾 Created backup: $BACKUP_PATH${NC}"
    
    # Remove the generic logo
    rm "$GENERIC_LOGO"
    echo -e "${GREEN}🗑️  Removed: $GENERIC_LOGO${NC}"
else
    echo -e "${YELLOW}ℹ️  Generic logo already removed or doesn't exist${NC}"
fi

# Step 4: Verify the cleanup
echo ""
echo -e "${YELLOW}🔍 Step 4: Final verification...${NC}"

# Check if the file is really gone
if [[ -f "$GENERIC_LOGO" ]]; then
    echo -e "${RED}❌ Generic logo still exists${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Generic logo successfully removed${NC}"
fi

# Final search to make sure no references remain
FINAL_CHECK=$(grep -r "assets/images/logo.png" "$PROJECT_ROOT" \
    --exclude-dir=.git \
    --exclude-dir=build \
    --exclude-dir=.dart_tool \
    --exclude-dir=node_modules \
    --exclude-dir=android/.gradle \
    --exclude-dir=ios/Pods \
    --exclude-dir=macos/Pods \
    --exclude=*.bin \
    --exclude=*.lock \
    --exclude=cleanup_generic_logo.sh \
    2>/dev/null || true)

if [[ -n "$FINAL_CHECK" ]]; then
    echo -e "${RED}❌ Warning: Still found references after cleanup:${NC}"
    echo "$FINAL_CHECK"
else
    echo -e "${GREEN}✅ No references to generic logo remain${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Generic Logo Cleanup Complete!${NC}"
echo "====================================="
echo ""
echo -e "${BLUE}📋 What was done:${NC}"
echo "  • Verified all references updated to flavor-specific logos"
echo "  • Created backup of generic logo"
echo "  • Removed generic logo.png"
echo "  • Verified cleanup was successful"
echo ""
echo -e "${YELLOW}💡 Next steps:${NC}"
echo "1. Test the app to ensure logos display correctly"
echo "2. Run: flutter clean && flutter pub get"
echo "3. Test each flavor to verify correct logos"
echo ""
echo -e "${GREEN}✨ Your app now uses flavor-specific logos exclusively!${NC}" 