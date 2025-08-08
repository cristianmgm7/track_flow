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
