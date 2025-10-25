# 📱 TrackFlow App Icons & Logos Update Guide

Complete guide for updating app icons and logos across all 3 flavors (Development, Staging, Production) for both iOS and Android.

## 🎯 Quick Start

### 1. Prepare Your Logo Files

Create or update 3 logo files in `assets/logo/`:

```
assets/logo/
  ├── trackflow_dev.png      (or .jpg)
  ├── trackflow_staging.png  (or .jpg)
  └── trackflow_prod.png     (or .jpg)
```

### 2. Run the Update Script

```bash
./scripts/update_all_icons.sh
```

That's it! The script will generate all required sizes for iOS and Android.

---

## 📋 Image Requirements

### File Specifications

| Property | Requirement | Recommendation |
|----------|-------------|----------------|
| **Format** | PNG or JPG | PNG (supports transparency) |
| **Size** | Minimum 1024x1024px | 2048x2048px or higher |
| **Shape** | Square | Square (1:1 aspect ratio) |
| **Color Mode** | RGB | RGB with sRGB color profile |
| **DPI** | Any | 72 DPI or higher |

### Design Guidelines

✅ **DO:**
- Center your logo/design in the square
- Use high-quality, crisp graphics
- Test how it looks at small sizes (20x20px)
- Use contrasting colors for visibility
- Leave ~10% padding from edges for iOS rounded corners
- Use different visual indicators for each flavor (color, badge, etc.)

❌ **DON'T:**
- Place important text near edges (will be cut by rounded corners)
- Use fine details that disappear at small sizes
- Rely on transparency for the main design (Android may show background)
- Use image dimensions smaller than 1024x1024px

### Flavor Differentiation Examples

**Development**: Add "DEV" badge, use distinct color (e.g., orange/yellow tint)
**Staging**: Add "STAGE" badge, use another color (e.g., blue/purple tint)
**Production**: Clean, final version without badges

---

## 🔧 What Gets Generated

### iOS Icons (per flavor)

Location: `ios/Runner/Assets.xcassets/AppIcon-{Flavor}.appiconset/`

| Icon Name | Size | Scale | Purpose |
|-----------|------|-------|---------|
| Icon-App-20x20@1x | 20x20 | 1x | iPhone Notification |
| Icon-App-20x20@2x | 40x40 | 2x | iPhone Notification |
| Icon-App-20x20@3x | 60x60 | 3x | iPhone Notification |
| Icon-App-29x29@1x | 29x29 | 1x | iPhone Settings |
| Icon-App-29x29@2x | 58x58 | 2x | iPhone Settings |
| Icon-App-29x29@3x | 87x87 | 3x | iPhone Settings |
| Icon-App-40x40@1x | 40x40 | 1x | iPhone Spotlight |
| Icon-App-40x40@2x | 80x80 | 2x | iPhone Spotlight |
| Icon-App-40x40@3x | 120x120 | 3x | iPhone Spotlight |
| Icon-App-60x60@2x | 120x120 | 2x | iPhone App |
| Icon-App-60x60@3x | 180x180 | 3x | iPhone App |
| Icon-App-76x76@1x | 76x76 | 1x | iPad App |
| Icon-App-76x76@2x | 152x152 | 2x | iPad App |
| Icon-App-83.5x83.5@2x | 167x167 | 2x | iPad Pro |
| Icon-App-1024x1024@1x | 1024x1024 | 1x | **App Store** (no alpha!) |

**Total: 15 icons per flavor × 3 flavors = 45 iOS icons**

### Android Icons (per flavor)

Location: `android/app/src/{flavor}/res/mipmap-*/`

| Density | Size | DPI | Purpose |
|---------|------|-----|---------|
| mdpi | 48x48 | 160 | Medium density screens |
| hdpi | 72x72 | 240 | High density screens |
| xhdpi | 96x96 | 320 | Extra-high density screens |
| xxhdpi | 144x144 | 480 | Extra-extra-high density |
| xxxhdpi | 192x192 | 640 | Extra-extra-extra-high |

**Total: 5 icons per flavor × 3 flavors = 15 Android icons**
**Plus: 5 icons in main/res as fallback**

---

## 🛠️ Manual Process (if scripts don't work)

### Prerequisites

Install ImageMagick:

```bash
# macOS
brew install imagemagick

# Ubuntu/Debian
sudo apt-get install imagemagick

# Verify installation
convert -version
```

### Option A: Using the Individual Scripts

```bash
# iOS only
./scripts/generate_ios_icons.sh

# Android only
./scripts/generate_android_icons.sh

# Or run the complete setup (iOS + config)
./scripts/setup_ios_icons.sh
```

### Option B: Using flutter_launcher_icons

1. Add dependency to `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

2. Create `flutter_launcher_icons.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  
  # Development
  image_path_android: "assets/logo/trackflow_dev.png"
  image_path_ios: "assets/logo/trackflow_dev.png"
  android_gravity: "center"
  
  # This will need to be run 3 times with different configs
  # Or use flavor-specific configuration
```

3. Run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

**Note:** The custom scripts (`update_all_icons.sh`) are recommended as they handle all 3 flavors automatically.

---

## 📱 Platform-Specific Notes

### iOS

1. **App Store Icon (1024x1024)**: Must NOT have alpha channel (transparency)
   - Script automatically removes alpha for this size
   - Renders on white background if source has transparency

2. **Xcode Configuration**: 
   - Icons are linked via `xcconfig` files
   - Each flavor points to its own `.appiconset`
   - Verification: Open `ios/Runner.xcworkspace` in Xcode

3. **Rounded Corners**: 
   - iOS automatically applies rounded corners
   - Don't create rounded corners yourself
   - Leave padding for corner masking

### Android

1. **Adaptive Icons** (Future Enhancement):
   - Current: Single layer icon
   - Future: Separate foreground/background layers
   - See: [Android Adaptive Icons](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)

2. **Flavor-Specific Resources**:
   - Icons in `src/{flavor}/res/mipmap-*/` override main
   - Main icons serve as fallback
   - Each flavor gets its own `ic_launcher.png`

3. **Shape Masking**:
   - Different devices apply different masks (circle, squircle, etc.)
   - Keep important content in center "safe zone"
   - Test on various devices/launchers

---

## 🧪 Testing Your New Icons

### Development Testing

```bash
# Test each flavor
flutter clean && flutter pub get

# Development
flutter run --flavor development -t lib/main_development.dart

# Staging  
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor production -t lib/main_production.dart
```

### Check Icon on Device

1. **Install the app** on a physical device
2. **Close the app** completely
3. **Check home screen** - icon should update
4. **Check app switcher** - recent apps view
5. **Check settings** - app list
6. **Check notifications** - notification icon

### Build Release Versions

```bash
# Android
flutter build apk --flavor production --release
flutter build appbundle --flavor production --release

# iOS (requires macOS)
flutter build ios --flavor production --release
```

---

## 🐛 Troubleshooting

### Icons Not Updating on Device

**iOS:**
```bash
# Clean and rebuild
flutter clean
cd ios
pod cache clean --all
pod deintegrate
pod install
cd ..
flutter run --flavor development
```

**Android:**
```bash
# Clean and rebuild  
flutter clean
cd android
./gradlew clean
cd ..
flutter run --flavor development
```

**Device Cache:**
- Uninstall the app completely
- Restart the device
- Reinstall the app

### ImageMagick Not Found

```bash
# macOS - Install Homebrew first
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install imagemagick

# Verify
which convert
convert -version
```

### Script Permission Denied

```bash
chmod +x scripts/*.sh
./scripts/update_all_icons.sh
```

### Wrong Icon Showing

1. Check flavor configuration in `build.gradle.kts` (Android)
2. Check flavor configuration in `xcconfig` files (iOS)
3. Verify correct icon set exists for the flavor
4. Clean build and reinstall

### Icons Look Blurry

- Source images too small (need 1024x1024 minimum)
- Use higher resolution source (2048x2048 recommended)
- Check if source is already compressed/low quality
- Use PNG instead of JPG for better quality

---

## 📂 File Structure Reference

```
trackflow/
├── assets/
│   └── logo/
│       ├── trackflow_dev.png       ← Your source files
│       ├── trackflow_staging.png   ← Your source files  
│       └── trackflow_prod.png      ← Your source files
│
├── android/
│   └── app/
│       └── src/
│           ├── development/
│           │   └── res/
│           │       ├── mipmap-mdpi/
│           │       │   └── ic_launcher.png
│           │       ├── mipmap-hdpi/
│           │       ├── mipmap-xhdpi/
│           │       ├── mipmap-xxhdpi/
│           │       └── mipmap-xxxhdpi/
│           ├── staging/
│           │   └── res/
│           │       └── mipmap-*/
│           ├── production/
│           │   └── res/
│           │       └── mipmap-*/
│           └── main/
│               └── res/
│                   └── mipmap-*/
│
├── ios/
│   └── Runner/
│       └── Assets.xcassets/
│           ├── AppIcon-Dev.appiconset/
│           │   ├── Contents.json
│           │   └── Icon-App-*.png (15 files)
│           ├── AppIcon-Staging.appiconset/
│           │   ├── Contents.json
│           │   └── Icon-App-*.png (15 files)
│           └── AppIcon-Prod.appiconset/
│               ├── Contents.json
│               └── Icon-App-*.png (15 files)
│
└── scripts/
    ├── update_all_icons.sh          ← Master script (run this!)
    ├── generate_ios_icons.sh         ← iOS icon generator
    ├── generate_android_icons.sh     ← Android icon generator
    └── setup_ios_icons.sh           ← iOS complete setup
```

---

## 🎨 Design Tools & Resources

### Recommended Tools

- **Figma** - Free, collaborative design tool
- **Sketch** - macOS design app
- **Adobe Illustrator** - Professional vector graphics
- **Photoshop** - Raster image editing
- **GIMP** - Free alternative to Photoshop

### Online Icon Generators

- [AppIcon.co](https://www.appicon.co/) - Generate all sizes from one image
- [MakeAppIcon](https://makeappicon.com/) - Free icon generator
- [Icon Kitchen](https://icon.kitchen/) - Android adaptive icons
- [App Icon Generator](https://www.appicongenerator.com/)

### Design Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)
- [Material Design Icons](https://material.io/design/iconography)
- [Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/)

---

## 🔄 Updating Icons Later

When you need to update icons:

1. **Replace** the 3 source files in `assets/logo/`
2. **Run** `./scripts/update_all_icons.sh`
3. **Clean** `flutter clean`
4. **Test** each flavor
5. **Commit** all generated icon files to git

**Tip:** Keep your source files (AI, PSD, Figma, etc.) outside the repo in a design folder for future edits.

---

## 📝 Checklist for App Store Submission

### Before Submitting

- [ ] All 3 flavors have distinct, recognizable icons
- [ ] Production icon looks professional and polished
- [ ] Icons tested on various device sizes
- [ ] Icons tested in dark mode (if applicable)
- [ ] 1024x1024 App Store icon has no transparency
- [ ] Icons match app branding and design language
- [ ] All build variants tested and verified
- [ ] Icons committed to version control

### iOS App Store

- [ ] 1024x1024 icon in App Store Connect
- [ ] Icon follows [Apple's guidelines](https://developer.apple.com/app-store/product-page/)
- [ ] No rounded corners (Apple adds them)
- [ ] No alpha channel in 1024x1024 version

### Google Play Store

- [ ] 512x512 high-res icon for Play Store
- [ ] Icon follows [Material Design guidelines](https://material.io/design/iconography)
- [ ] Adaptive icon (future enhancement)
- [ ] Feature graphic (1024x500) prepared

---

## 💡 Best Practices

1. **Version Control**: Commit both source and generated icons
2. **Consistency**: Use the same design language across flavors
3. **Testing**: Test on real devices, not just simulators
4. **Optimization**: Use PNG-8 if possible (smaller file size)
5. **Accessibility**: Ensure good contrast for visibility
6. **Documentation**: Keep notes on design decisions
7. **Backups**: Scripts create backups before overwriting
8. **Automation**: Use scripts to avoid manual errors

---

## 🆘 Getting Help

### Common Issues

1. **"ImageMagick not found"** → Install via Homebrew (macOS)
2. **"Logo files missing"** → Add 3 images to `assets/logo/`
3. **"Icons not updating"** → Clean build + restart device
4. **"Wrong flavor icon"** → Check flavor configuration files

### Support

- Check Flutter docs: [flutter.dev](https://flutter.dev)
- iOS guidelines: [developer.apple.com](https://developer.apple.com)
- Android guidelines: [developer.android.com](https://developer.android.com)

---

## 📜 Summary

| Task | Command |
|------|---------|
| **Update all icons** | `./scripts/update_all_icons.sh` |
| **iOS only** | `./scripts/generate_ios_icons.sh` |
| **Android only** | `./scripts/generate_android_icons.sh` |
| **Clean project** | `flutter clean && flutter pub get` |
| **Test flavor** | `flutter run --flavor {flavor}` |
| **Build release** | `flutter build {platform} --flavor {flavor} --release` |

**Remember:** Always test your icons on actual devices before submitting to app stores!

---

*Last updated: 2025-10-25*

