# iOS App Icons Setup Guide - TrackFlow Flavors

## Current Status ✅

Your iOS project is properly configured with:
- ✅ Standard Debug and Release configurations (Flutter compatible)
- ✅ Flavor-specific configurations (Debug dev, Release prod, etc.)
- ✅ Proper xcconfig files for each flavor
- ✅ Bundle identifiers configured per flavor
- ✅ Firebase configuration files for each environment

## App Icons Structure

Your current app icons are located at:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
├── Contents.json
├── Icon-App-1024x1024@1x.png
├── Icon-App-20x20@1x.png
├── Icon-App-20x20@2x.png
├── Icon-App-20x20@3x.png
├── Icon-App-29x29@1x.png
├── Icon-App-29x29@2x.png
├── Icon-App-29x29@3x.png
├── Icon-App-40x40@1x.png
├── Icon-App-40x40@2x.png
├── Icon-App-40x40@3x.png
├── Icon-App-60x60@2x.png
├── Icon-App-60x60@3x.png
├── Icon-App-76x76@1x.png
├── Icon-App-76x76@2x.png
└── Icon-App-83.5x83.5@2x.png
```

## 🎨 Setting Up Flavor-Specific App Icons

### Option 1: Separate Asset Catalogs per Flavor (Recommended)

Create separate app icon sets for each flavor:

```
ios/Runner/Assets.xcassets/
├── AppIcon-Dev.appiconset/     # Development icons
├── AppIcon-Staging.appiconset/ # Staging icons  
├── AppIcon-Prod.appiconset/    # Production icons
└── AppIcon.appiconset/         # Default/fallback icons
```

### Option 2: Configure in Build Settings

Add app icon configuration to your xcconfig files:

#### For Development (`ios/Debug.xcconfig` & `ios/Release.xcconfig`):
```bash
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-Dev
```

#### For Staging (`ios/Debug 2.xcconfig` & `ios/Release 2.xcconfig`):
```bash  
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-Staging
```

#### For Production (`ios/Debug 3.xcconfig` & `ios/Release 3.xcconfig`):
```bash
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon-Prod
```

## 🛠️ Implementation Steps

### Step 1: Create App Icon Sets in Xcode

1. **Open Xcode**: `open ios/Runner.xcworkspace`
2. **Navigate to Assets.xcassets** in the project navigator
3. **Right-click** → **New App Icon**
4. **Rename to**:
   - `AppIcon-Dev` (Development)
   - `AppIcon-Staging` (Staging)  
   - `AppIcon-Prod` (Production)

### Step 2: Add Your Icon Images

For each app icon set, add the required sizes:
- **1024x1024@1x** (App Store)
- **60x60@2x** & **60x60@3x** (iPhone App)
- **40x40@2x** & **40x40@3x** (Spotlight)
- **29x29@2x** & **29x29@3x** (Settings)
- **20x20@2x** & **20x20@3x** (Notifications)

### Step 3: Update xcconfig Files

Add the `ASSETCATALOG_COMPILER_APPICON_NAME` setting to your configuration files.

### Step 4: Visual Differentiation Ideas

Consider these approaches for different flavors:
- **Development**: Add "DEV" badge overlay
- **Staging**: Add "STAGING" badge or different color tint
- **Production**: Clean, final design without badges

## 🎯 App Icon Sizes Required

| Usage | Size | Scale | Filename |
|-------|------|-------|----------|
| App Store | 1024×1024 | 1x | Icon-App-1024x1024@1x.png |
| iPhone App | 60×60 | 2x, 3x | Icon-App-60x60@2x.png, Icon-App-60x60@3x.png |
| Spotlight | 40×40 | 2x, 3x | Icon-App-40x40@2x.png, Icon-App-40x40@3x.png |
| Settings | 29×29 | 2x, 3x | Icon-App-29x29@2x.png, Icon-App-29x29@3x.png |
| Notifications | 20×20 | 2x, 3x | Icon-App-20x20@2x.png, Icon-App-20x20@3x.png |

## 🚀 Quick Setup Commands

After setting up your icons in Xcode, test each flavor:

```bash
# Test development build
flutter build ios --debug --target lib/main_development.dart

# Test staging build (once schemes are set up)
flutter build ios --debug --target lib/main_staging.dart

# Test production build
flutter build ios --release --target lib/main_production.dart
```

## 📱 Current Bundle Identifiers

Your flavors use these bundle IDs:
- **Development**: `com.crd.producer-gmail.com.trackflow.dev`
- **Staging**: `com.crd.producer-gmail.com.trackflow.staging`
- **Production**: `com.crd.producer-gmail.com.trackflow`

Make sure your App Store Connect records match these identifiers.

## ✅ Verification Checklist

- [ ] Created separate app icon sets for each flavor
- [ ] Updated xcconfig files with `ASSETCATALOG_COMPILER_APPICON_NAME`
- [ ] Added all required icon sizes (1024x1024 down to 20x20)
- [ ] Tested build for each flavor
- [ ] Verified correct icons appear for each flavor
- [ ] Registered bundle IDs in App Store Connect (for distribution)

## 🎨 Design Tips

### Development Icons
- Add a colored badge or overlay
- Use different background colors
- Include "DEV" text overlay

### Staging Icons  
- Similar to production but with "STAGING" badge
- Slightly different color scheme
- Clear visual distinction from production

### Production Icons
- Clean, final design
- No development badges
- Professional appearance for App Store

---

## 📋 Next Steps

1. **Design your app icons** for each flavor
2. **Export in all required sizes**
3. **Set up icon sets in Xcode** (following steps above)
4. **Update xcconfig files** with the appropriate `ASSETCATALOG_COMPILER_APPICON_NAME` settings
5. **Test builds** to verify correct icons are used

Your iOS configuration is solid - now it's just a matter of creating the visual assets!