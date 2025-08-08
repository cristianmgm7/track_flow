#!/bin/bash

# Setup Firebase Configurations for TrackFlow Flavors
# This script copies the correct Firebase configuration files for each flavor

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔥 TrackFlow Firebase Configuration Setup${NC}"
echo "============================================="
echo ""

# Define paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IOS_RUNNER_DIR="$PROJECT_ROOT/ios/Runner"
IOS_CONFIG_DIR="$PROJECT_ROOT/ios/config"

# Check if we're in the right directory
if [[ ! -f "$PROJECT_ROOT/pubspec.yaml" ]]; then
    echo -e "${RED}❌ This script must be run from the TrackFlow project root${NC}"
    exit 1
fi

echo -e "${BLUE}📍 Project root: $PROJECT_ROOT${NC}"
echo ""

# Step 1: Backup current Firebase config
echo -e "${YELLOW}🔧 Step 1: Backing up current Firebase config...${NC}"

if [[ -f "$IOS_RUNNER_DIR/GoogleService-Info.plist" ]]; then
    cp "$IOS_RUNNER_DIR/GoogleService-Info.plist" "$IOS_RUNNER_DIR/GoogleService-Info.plist.backup"
    echo -e "${GREEN}✅ Backed up: GoogleService-Info.plist${NC}"
else
    echo -e "${YELLOW}⚠️  No existing GoogleService-Info.plist found${NC}"
fi

# Step 2: Verify Firebase config files exist
echo ""
echo -e "${YELLOW}🔧 Step 2: Verifying Firebase config files...${NC}"

FIREBASE_CONFIGS=(
    "$IOS_CONFIG_DIR/development/GoogleService-Info-Dev.plist"
    "$IOS_CONFIG_DIR/staging/GoogleService-Info-Staging.plist"
    "$IOS_CONFIG_DIR/production/GoogleService-Info-Prod.plist"
)

for config in "${FIREBASE_CONFIGS[@]}"; do
    if [[ -f "$config" ]]; then
        echo -e "${GREEN}✅ Found: $(basename "$config")${NC}"
    else
        echo -e "${RED}❌ Missing: $(basename "$config")${NC}"
        exit 1
    fi
done

# Step 3: Create symbolic links for each flavor
echo ""
echo -e "${YELLOW}🔧 Step 3: Setting up Firebase configs for each flavor...${NC}"

# Development
if [[ -f "$IOS_CONFIG_DIR/development/GoogleService-Info-Dev.plist" ]]; then
    ln -sf "$IOS_CONFIG_DIR/development/GoogleService-Info-Dev.plist" "$IOS_RUNNER_DIR/GoogleService-Info-Dev.plist"
    echo -e "${GREEN}✅ Created symlink: GoogleService-Info-Dev.plist${NC}"
fi

# Staging
if [[ -f "$IOS_CONFIG_DIR/staging/GoogleService-Info-Staging.plist" ]]; then
    ln -sf "$IOS_CONFIG_DIR/staging/GoogleService-Info-Staging.plist" "$IOS_RUNNER_DIR/GoogleService-Info-Staging.plist"
    echo -e "${GREEN}✅ Created symlink: GoogleService-Info-Staging.plist${NC}"
fi

# Production
if [[ -f "$IOS_CONFIG_DIR/production/GoogleService-Info-Prod.plist" ]]; then
    ln -sf "$IOS_CONFIG_DIR/production/GoogleService-Info-Prod.plist" "$IOS_RUNNER_DIR/GoogleService-Info-Prod.plist"
    echo -e "${GREEN}✅ Created symlink: GoogleService-Info-Prod.plist${NC}"
fi

# Step 4: Verify xcconfig files reference correct Firebase configs
echo ""
echo -e "${YELLOW}🔧 Step 4: Verifying xcconfig Firebase references...${NC}"

XCCONFIG_FILES=(
    "$PROJECT_ROOT/ios/Debug.xcconfig"
    "$PROJECT_ROOT/ios/Release.xcconfig"
    "$PROJECT_ROOT/ios/Debug 2.xcconfig"
    "$PROJECT_ROOT/ios/Release 2.xcconfig"
    "$PROJECT_ROOT/ios/Debug 3.xcconfig"
    "$PROJECT_ROOT/ios/Release 3.xcconfig"
)

for config in "${XCCONFIG_FILES[@]}"; do
    if [[ -f "$config" ]]; then
        if grep -q "FIREBASE_CONFIG_FILE" "$config"; then
            firebase_file=$(grep "FIREBASE_CONFIG_FILE" "$config" | cut -d'=' -f2 | tr -d ' ')
            echo -e "${GREEN}✅ $(basename "$config"): $firebase_file${NC}"
        else
            echo -e "${YELLOW}⚠️  $(basename "$config"): No Firebase config specified${NC}"
        fi
    else
        echo -e "${RED}❌ Missing: $(basename "$config")${NC}"
    fi
done

# Step 5: Create a script to switch Firebase configs
echo ""
echo -e "${YELLOW}🔧 Step 5: Creating Firebase config switcher...${NC}"

cat > "$PROJECT_ROOT/scripts/switch_firebase_config.sh" << 'EOF'
#!/bin/bash

# Switch Firebase Configuration Script
# Usage: ./scripts/switch_firebase_config.sh [development|staging|production]

set -e

FLAVOR=${1:-development}
IOS_RUNNER_DIR="$(dirname "$0")/../ios/Runner"

case $FLAVOR in
    development|dev)
        cp "$IOS_RUNNER_DIR/GoogleService-Info-Dev.plist" "$IOS_RUNNER_DIR/GoogleService-Info.plist"
        echo "✅ Switched to Development Firebase config"
        ;;
    staging)
        cp "$IOS_RUNNER_DIR/GoogleService-Info-Staging.plist" "$IOS_RUNNER_DIR/GoogleService-Info.plist"
        echo "✅ Switched to Staging Firebase config"
        ;;
    production|prod)
        cp "$IOS_RUNNER_DIR/GoogleService-Info-Prod.plist" "$IOS_RUNNER_DIR/GoogleService-Info.plist"
        echo "✅ Switched to Production Firebase config"
        ;;
    *)
        echo "❌ Invalid flavor. Use: development, staging, or production"
        exit 1
        ;;
esac
EOF

chmod +x "$PROJECT_ROOT/scripts/switch_firebase_config.sh"
echo -e "${GREEN}✅ Created: scripts/switch_firebase_config.sh${NC}"

echo ""
echo -e "${GREEN}🎉 Firebase Configuration Setup Complete!${NC}"
echo "============================================="
echo ""
echo -e "${BLUE}📋 What was set up:${NC}"
echo "  • Firebase config files verified"
echo "  • Symbolic links created for each flavor"
echo "  • xcconfig files verified"
echo "  • Firebase config switcher script created"
echo ""
echo -e "${YELLOW}🚀 Next steps:${NC}"
echo "1. Clean and rebuild your project:"
echo "   flutter clean && flutter pub get"
echo ""
echo "2. Switch to development Firebase config:"
echo "   ./scripts/switch_firebase_config.sh development"
echo ""
echo "3. Test the development flavor:"
echo "   flutter run --flavor development"
echo ""
echo -e "${GREEN}✨ Your Firebase configurations are now ready!${NC}"
