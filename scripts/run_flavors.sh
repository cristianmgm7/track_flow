#!/bin/bash

# Run script for different flavors
# Usage: ./scripts/run_flavors.sh [development|staging|production] [debug|release]

FLAVOR=${1:-development}
BUILD_MODE=${2:-debug}

echo "🚀 Running TrackFlow"
echo "   Flavor: $FLAVOR"
echo "   Mode: $BUILD_MODE"
echo ""

if [ "$BUILD_MODE" = "debug" ]; then
    flutter run --flavor $FLAVOR -t lib/main_$FLAVOR.dart --debug
else
    flutter run --flavor $FLAVOR -t lib/main_$FLAVOR.dart --release
fi