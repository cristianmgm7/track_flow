#!/bin/bash

# TrackFlow Flavor Runner Script
# This script properly runs Flutter with the correct flavor and scheme

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 TrackFlow Flavor Runner${NC}"
echo "=========================="
echo ""

# Check if flavor is provided
if [[ $# -eq 0 ]]; then
    echo -e "${RED}❌ Error: Please specify a flavor${NC}"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  ./scripts/run_flavor.sh [development|staging|production] [device_id]"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  ./scripts/run_flavor.sh development"
    echo "  ./scripts/run_flavor.sh staging 00008030-00010C31110A802E"
    echo "  ./scripts/run_flavor.sh production"
    echo ""
    exit 1
fi

FLAVOR=$1
DEVICE_ID=${2:-""}

# Validate flavor
case $FLAVOR in
    development|dev)
        SCHEME="Runner-Development"
        MAIN_FILE="lib/main_development.dart"
        FIREBASE_CONFIG="development"
        echo -e "${GREEN}✅ Running Development Flavor${NC}"
        ;;
    staging)
        SCHEME="Runner-Staging"
        MAIN_FILE="lib/main_staging.dart"
        FIREBASE_CONFIG="staging"
        echo -e "${GREEN}✅ Running Staging Flavor${NC}"
        ;;
    production|prod)
        SCHEME="Runner-Production"
        MAIN_FILE="lib/main_production.dart"
        FIREBASE_CONFIG="production"
        echo -e "${GREEN}✅ Running Production Flavor${NC}"
        ;;
    *)
        echo -e "${RED}❌ Invalid flavor: $FLAVOR${NC}"
        echo -e "${YELLOW}Valid flavors: development, staging, production${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}📱 Scheme: $SCHEME${NC}"
echo -e "${BLUE}📄 Main file: $MAIN_FILE${NC}"
echo -e "${BLUE}🔥 Firebase config: $FIREBASE_CONFIG${NC}"
echo ""

# Step 1: Switch Firebase configuration
echo -e "${YELLOW}🔧 Step 1: Switching Firebase configuration...${NC}"
./scripts/switch_firebase_config.sh $FIREBASE_CONFIG

# Step 2: Configure app icon
echo -e "${YELLOW}🔧 Step 2: Configuring app icon...${NC}"
./scripts/fix_app_icon_dynamic.sh $FLAVOR

# Step 3: Build and run
echo -e "${YELLOW}🔧 Step 3: Building and running...${NC}"

# Construct the Flutter command
FLUTTER_CMD="flutter run --target $MAIN_FILE"

# Add device if specified
if [[ -n "$DEVICE_ID" ]]; then
    FLUTTER_CMD="$FLUTTER_CMD -d $DEVICE_ID"
    echo -e "${BLUE}📱 Device: $DEVICE_ID${NC}"
fi

echo -e "${BLUE}🚀 Command: $FLUTTER_CMD${NC}"
echo ""

# Execute the command
eval $FLUTTER_CMD
