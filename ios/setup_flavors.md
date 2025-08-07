# iOS Flavors Setup Guide - TrackFlow

## ✅ COMPLETED: Standard Flutter Configurations

The main Flutter configuration issue has been **RESOLVED**! 

### What was fixed:
- ✅ Added standard **Debug** and **Release** configurations 
- ✅ Fixed Flutter build mode settings (`FLUTTER_BUILD_MODE = debug/release`)
- ✅ Made Debug the default configuration
- ✅ Fixed CocoaPods configuration references

### Current working configurations:
```
- Debug ← DEFAULT (works with Flutter)
- Release ← Standard Flutter config  
- Debug dev, Debug prod, Debug staging
- Release dev, Release prod, Release staging
```

## 🚀 You can now run Flutter commands successfully:

```bash
# This should work now:
flutter run --target lib/main_development.dart

# Build commands:
flutter build ios --debug --target lib/main_development.dart
flutter build ios --release --target lib/main_production.dart
```

## 🔧 OPTIONAL: Set up Xcode Schemes for --flavor support

Currently Flutter uses the default Debug/Release configs. To use `--flavor` commands, you need to create Xcode schemes:

### Step 1: Open Xcode
```bash
open ios/Runner.xcworkspace
```

### Step 2: Create Schemes
1. **Product** → **Scheme** → **Manage Schemes**
2. **Click "+"** to add new scheme
3. **Create these schemes**:

#### Development Scheme:
- **Name**: `development`
- **Target**: Runner
- **Build Configuration**:
  - Debug: **Debug dev**
  - Release: **Release dev**

#### Staging Scheme:
- **Name**: `staging` 
- **Target**: Runner
- **Build Configuration**:
  - Debug: **Debug staging**
  - Release: **Release staging**

#### Production Scheme:
- **Name**: `production`
- **Target**: Runner  
- **Build Configuration**:
  - Debug: **Debug prod**
  - Release: **Release prod**

### Step 3: Make Schemes Shared
- ✅ **Check "Shared"** for each scheme (to commit to git)

### Step 4: After creating schemes, you can use:
```bash
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging --target lib/main_staging.dart  
flutter run --flavor production --target lib/main_production.dart
```

## 📱 Bundle Identifiers per Flavor

Your current xcconfig files define:
- **Development**: `com.crd.producer-gmail.com.trackflow.dev`
- **Staging**: `com.crd.producer-gmail.com.trackflow.staging` 
- **Production**: `com.crd.producer-gmail.com.trackflow`

## 🔥 Firebase Configuration

Each flavor uses its own Firebase config:
- **Development**: `GoogleService-Info-Dev.plist`
- **Staging**: `GoogleService-Info-Staging.plist`
- **Production**: `GoogleService-Info-Prod.plist`

## ✅ Verification Commands

```bash
# Check configurations
cd ios && xcodebuild -project Runner.xcodeproj -list

# Test Flutter build (should work now)
flutter build ios --debug --no-codesign
```

---

## 🎯 SUMMARY: Main Issue Fixed!

The critical Flutter configuration error is **RESOLVED**. You can now:
- ✅ Run Flutter commands without the "Debug configuration" error
- ✅ Build and deploy your iOS app
- ✅ Use standard Flutter workflows

The schemes setup above is optional for `--flavor` support, but not required for basic functionality.
