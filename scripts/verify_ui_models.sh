#!/bin/bash

echo "🔍 Verifying UI Models Migration..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall status
ERRORS=0

# Check for domain entities in state files
echo "1. Checking for domain entities in state files..."
DOMAIN_IN_STATES=$(grep -r "import.*domain/entities" lib/features/*/presentation/bloc/*_state.dart 2>/dev/null || true)
if [ -n "$DOMAIN_IN_STATES" ]; then
  echo -e "${RED}❌ ERROR: Found domain entity imports in state files:${NC}"
  echo "$DOMAIN_IN_STATES"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ No domain entities in state files${NC}"
fi

# Check for manual equality workarounds
echo ""
echo "2. Checking for manual equality workarounds..."
MANUAL_WORKAROUNDS=$(grep -r "\.map((.*) => \[" lib/features/*/presentation/bloc/*_state.dart 2>/dev/null || true)
if [ -n "$MANUAL_WORKAROUNDS" ]; then
  echo -e "${YELLOW}⚠️  WARNING: Found potential manual equality workarounds:${NC}"
  echo "$MANUAL_WORKAROUNDS"
else
  echo -e "${GREEN}✅ No manual equality workarounds found${NC}"
fi

# Check for domain entities in presentation widgets (excluding forms which use domain entities)
echo ""
echo "3. Checking for domain entities in widgets..."
DOMAIN_IN_WIDGETS=$(grep -r "import.*domain/entities" \
  lib/features/dashboard/presentation/widgets/ \
  lib/features/projects/presentation/widgets/ \
  lib/features/projects/presentation/components/ \
  lib/features/audio_track/presentation/widgets/ \
  lib/features/audio_track/presentation/component/ \
  lib/features/audio_comment/presentation/components/ \
  lib/features/voice_memos/presentation/voice_memos_screen/ \
  lib/features/track_version/presentation/widgets/ \
  lib/features/track_version/presentation/components/ \
  lib/features/playlist/presentation/widgets/ \
  2>/dev/null | grep -v "_form" | grep -v "dialog" || true)
if [ -n "$DOMAIN_IN_WIDGETS" ]; then
  echo -e "${YELLOW}⚠️  WARNING: Found domain entity imports in widgets (check if they're UI models):${NC}"
  echo "$DOMAIN_IN_WIDGETS"
else
  echo -e "${GREEN}✅ No unexpected domain entities in widgets${NC}"
fi

# Check that UI model files exist
echo ""
echo "4. Checking UI model files exist..."
MISSING_FILES=""
for model in project_ui_model audio_track_ui_model user_profile_ui_model audio_comment_ui_model voice_memo_ui_model track_version_ui_model; do
  FILE=$(find lib/features -name "${model}.dart" 2>/dev/null)
  if [ -z "$FILE" ]; then
    MISSING_FILES="${MISSING_FILES}\n  - ${model}.dart"
  fi
done

if [ -n "$MISSING_FILES" ]; then
  echo -e "${RED}❌ ERROR: Missing UI model files:${NC}${MISSING_FILES}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ All expected UI model files exist${NC}"
fi

# Run Flutter analyze
echo ""
echo "5. Running Flutter analyze..."
FLUTTER_CMD=""
if command -v flutter &> /dev/null; then
  FLUTTER_CMD="flutter"
elif [ -x ~/fvm/default/bin/flutter ]; then
  FLUTTER_CMD=~/fvm/default/bin/flutter
elif [ -x ~/flutter/bin/flutter ]; then
  FLUTTER_CMD=~/flutter/bin/flutter
else
  echo -e "${YELLOW}⚠️  WARNING: Flutter not found, skipping analyze${NC}"
  FLUTTER_CMD=""
fi

if [ -n "$FLUTTER_CMD" ]; then
  ANALYZE_OUTPUT=$($FLUTTER_CMD analyze --no-fatal-infos 2>&1)
  ERROR_COUNT=$(echo "$ANALYZE_OUTPUT" | grep -c "^error •" || true)
  
  if [ "$ERROR_COUNT" -gt 0 ]; then
    echo -e "${RED}❌ Flutter analyze found $ERROR_COUNT error(s):${NC}"
    echo "$ANALYZE_OUTPUT" | grep "^error •"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}✅ Flutter analyze passed (no errors)${NC}"
  fi
fi

# Check for fromDomain factories in UI models
echo ""
echo "6. Checking UI models have fromDomain() factories..."
MISSING_FACTORIES=""
for model_file in $(find lib/features -name "*_ui_model.dart" 2>/dev/null); do
  if ! grep -q "factory.*fromDomain" "$model_file"; then
    MISSING_FACTORIES="${MISSING_FACTORIES}\n  - $(basename $model_file)"
  fi
done

if [ -n "$MISSING_FACTORIES" ]; then
  echo -e "${YELLOW}⚠️  WARNING: UI models missing fromDomain() factory:${NC}${MISSING_FACTORIES}"
else
  echo -e "${GREEN}✅ All UI models have fromDomain() factories${NC}"
fi

# Check for Equatable in UI models
echo ""
echo "7. Checking UI models extend Equatable..."
NON_EQUATABLE=""
for model_file in $(find lib/features -name "*_ui_model.dart" 2>/dev/null); do
  if ! grep -q "extends Equatable" "$model_file"; then
    NON_EQUATABLE="${NON_EQUATABLE}\n  - $(basename $model_file)"
  fi
done

if [ -n "$NON_EQUATABLE" ]; then
  echo -e "${RED}❌ ERROR: UI models not extending Equatable:${NC}${NON_EQUATABLE}"
  ERRORS=$((ERRORS + 1))
else
  echo -e "${GREEN}✅ All UI models extend Equatable${NC}"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════"
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}✅ All verifications passed!${NC}"
  echo ""
  echo "UI Models migration is complete and verified."
  exit 0
else
  echo -e "${RED}❌ Found $ERRORS error(s) during verification${NC}"
  echo ""
  echo "Please fix the errors above and run this script again."
  exit 1
fi

