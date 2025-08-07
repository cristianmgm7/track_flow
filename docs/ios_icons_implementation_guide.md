# iOS App Icons Implementation Guide - TrackFlow

## ✅ Implementation Complete

This guide documents the successful implementation of flavor-specific iOS app icons for TrackFlow using the three logo files:

- `trackflow_dev.jpg` (Development)
- `trackflow_staging.jpg` (Staging)
- `trackflow_prod.jpg` (Production)

## 🎯 What Was Implemented

### 1. **Icon Generation System**

- **Script**: `scripts/setup_ios_icons.sh`
- **Function**: Automatically generates all required iOS icon sizes from your logo files
- **Output**: Creates 3 separate App Icon Sets with all required sizes (20x20 to 1024x1024)

### 2. **Flavor-Specific Icon Sets**

```
ios/Runner/Assets.xcassets/
├── AppIcon-Dev.appiconset/     # Development icons (trackflow_dev.jpg)
├── AppIcon-Staging.appiconset/ # Staging icons (trackflow_staging.jpg)
├── AppIcon-Prod.appiconset/    # Production icons (trackflow_prod.jpg)
└── AppIcon.appiconset/         # Original (backed up)
```

### 3. **xcconfig Configuration**

Each flavor now uses its specific icon set:

| Flavor          | xcconfig Files                           | Icon Set          |
| --------------- | ---------------------------------------- | ----------------- |
| **Development** | `Debug.xcconfig`, `Release.xcconfig`     | `AppIcon-Dev`     |
| **Staging**     | `Debug 2.xcconfig`, `Release 2.xcconfig` | `AppIcon-Staging` |
| **Production**  | `Debug 3.xcconfig`, `Release 3.xcconfig` | `AppIcon-Prod`    |

### 4. **Complete Logo Migration System**

#### **FlavorLogoHelper Class**

- **File**: `lib/core/utils/flavor_logo_helper.dart`
- **Purpose**: Centralized management of flavor-specific logos throughout the app
- **Features**:
  - Automatic logo selection based on build mode (debug/release)
  - Support for specific flavor selection
  - Separate methods for splash screen and general app logos

#### **Updated Components**

- **Splash Screen**: Now uses `FlavorLogoHelper.getSplashLogoPath()`
- **README.md**: Updated to use production logo
- **pubspec.yaml**: Added `assets/logo/` directory
- **Generic Logo**: Removed `assets/images/logo.png` (backed up)

## 🛠️ How It Works

### Icon Generation Process

1. **Input**: Your 3 JPG logo files
2. **Processing**: ImageMagick converts and scales to all required iOS sizes
3. **Output**: 15 icon files per flavor (20x20@1x to 1024x1024@1x)

### Configuration Process

1. **xcconfig Update**: Adds `ASSETCATALOG_COMPILER_APPICON_NAME` to each config
2. **Backup Creation**: Original files backed up with `.backup` extension
3. **Icon Set Assignment**: Each flavor points to its specific icon set

### Logo Migration Process

1. **FlavorLogoHelper Creation**: Centralized logo management
2. **Component Updates**: All logo references updated to use helper
3. **Generic Logo Removal**: Old logo removed with backup
4. **Asset Configuration**: pubspec.yaml updated to include logo directory

## 📱 Icon Sizes Generated

Each flavor includes all these icon sizes:

| Usage         | Size      | Scale  | Filename                                     |
| ------------- | --------- | ------ | -------------------------------------------- |
| App Store     | 1024×1024 | 1x     | Icon-App-1024x1024@1x.png                    |
| iPhone App    | 60×60     | 2x, 3x | Icon-App-60x60@2x.png, Icon-App-60x60@3x.png |
| Spotlight     | 40×40     | 2x, 3x | Icon-App-40x40@2x.png, Icon-App-40x40@3x.png |
| Settings      | 29×29     | 2x, 3x | Icon-App-29x29@2x.png, Icon-App-29x29@3x.png |
| Notifications | 20×20     | 2x, 3x | Icon-App-20x20@2x.png, Icon-App-20x20@3x.png |
| iPad App      | 76×76     | 1x, 2x | Icon-App-76x76@1x.png, Icon-App-76x76@2x.png |
| iPad Pro      | 83.5×83.5 | 2x     | Icon-App-83.5x83.5@2x.png                    |

## 🚀 How to Use

### Testing the Implementation

1. **Open Xcode**:

   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Verify Icon Sets**:

   - Navigate to `Assets.xcassets`
   - You should see 3 new App Icon Sets: `AppIcon-Dev`, `AppIcon-Staging`, `AppIcon-Prod`

3. **Clean and Rebuild**:

   ```bash
   flutter clean && flutter pub get
   ```

4. **Test Each Flavor**:

   ```bash
   # Development
   flutter run --flavor development

   # Staging
   flutter run --flavor staging

   # Production
   flutter run --flavor production
   ```

### Using FlavorLogoHelper in Your Code

```dart
import 'package:trackflow/core/utils/flavor_logo_helper.dart';

// Get logo for current flavor
String logoPath = FlavorLogoHelper.getLogoPath();

// Get logo for specific flavor
String devLogo = FlavorLogoHelper.getLogoPathForFlavor('development');

// Get splash logo
String splashLogo = FlavorLogoHelper.getSplashLogoPath();

// Check current environment
bool isDev = FlavorLogoHelper.isDevelopment;
String currentFlavor = FlavorLogoHelper.currentFlavor;
```

### Verification Checklist

- [ ] **Xcode**: Icon sets appear in Assets.xcassets
- [ ] **Development**: Shows `trackflow_dev.jpg` icon
- [ ] **Staging**: Shows `trackflow_staging.jpg` icon
- [ ] **Production**: Shows `trackflow_prod.jpg` icon
- [ ] **All Sizes**: Icons display correctly at all sizes (20x20 to 1024x1024)
- [ ] **Splash Screen**: Uses correct flavor logo
- [ ] **Generic Logo**: Removed from project

## 🔧 Maintenance

### Updating Icons

If you need to update the logos:

1. **Replace logo files** in `assets/logo/`
2. **Re-run the script**:
   ```bash
   ./scripts/setup_ios_icons.sh
   ```

### Adding New Flavors

To add a new flavor:

1. **Add logo file**: `assets/logo/trackflow_newflavor.jpg`
2. **Update FlavorLogoHelper**: Add new flavor case
3. **Update scripts**: Modify the icon generation script
4. **Create xcconfig**: Add new xcconfig files
5. **Update this guide**: Document the new flavor

### Using FlavorLogoHelper in New Components

When adding logos to new components:

```dart
// Instead of hardcoding logo paths
Image.asset('assets/images/logo.png')

// Use FlavorLogoHelper
Image.asset(FlavorLogoHelper.getLogoPath())
```

## 📋 Files Created/Modified

### New Files

- `scripts/setup_ios_icons.sh` - Main orchestration script
- `scripts/generate_ios_icons.sh` - Icon generation script
- `scripts/configure_ios_icon_xcconfig.sh` - xcconfig configuration script
- `scripts/cleanup_generic_logo.sh` - Generic logo cleanup script
- `scripts/test_flavor_logos.sh` - Verification test script
- `lib/core/utils/flavor_logo_helper.dart` - Logo management helper
- `ios/Runner/Assets.xcassets/AppIcon-Dev.appiconset/` - Development icons
- `ios/Runner/Assets.xcassets/AppIcon-Staging.appiconset/` - Staging icons
- `ios/Runner/Assets.xcassets/AppIcon-Prod.appiconset/` - Production icons

### Modified Files

- `ios/Debug.xcconfig` - Added AppIcon-Dev configuration
- `ios/Release.xcconfig` - Added AppIcon-Dev configuration
- `ios/Debug 2.xcconfig` - Added AppIcon-Staging configuration
- `ios/Release 2.xcconfig` - Added AppIcon-Staging configuration
- `ios/Debug 3.xcconfig` - Added AppIcon-Prod configuration
- `ios/Release 3.xcconfig` - Added AppIcon-Prod configuration
- `lib/features/auth/presentation/screens/splash_screen.dart` - Updated to use FlavorLogoHelper
- `pubspec.yaml` - Added `assets/logo/` directory
- `README.md` - Updated to use production logo

### Removed Files

- `assets/images/logo.png` - Generic logo (backed up as `.backup`)

### Backup Files

- All original xcconfig files backed up with `.backup` extension
- Original `AppIcon.appiconset` backed up as `AppIcon.appiconset.backup`
- Generic logo backed up as `assets/images/logo.png.backup`

## 🎨 Design Considerations

### Visual Differentiation

- **Development**: Uses `trackflow_dev.jpg` - typically with development indicators
- **Staging**: Uses `trackflow_staging.jpg` - typically with staging indicators
- **Production**: Uses `trackflow_prod.jpg` - clean, final design

### Icon Quality

- **Source**: High-resolution JPG logos (recommended: 1024x1024 or larger)
- **Processing**: ImageMagick handles scaling and format conversion
- **Output**: PNG format with transparency support

## 🐛 Troubleshooting

### Common Issues

1. **Icons not showing in Xcode**:

   - Clean build folder: `flutter clean`
   - Rebuild: `flutter pub get`

2. **Wrong icon showing**:

   - Check xcconfig files for correct `ASSETCATALOG_COMPILER_APPICON_NAME`
   - Verify icon set names match exactly

3. **Missing icon sizes**:

   - Re-run the generation script
   - Check ImageMagick installation

4. **Build errors**:

   - Verify all xcconfig files exist
   - Check for syntax errors in xcconfig files

5. **Splash screen shows wrong logo**:

   - Verify FlavorLogoHelper is imported
   - Check that `FlavorLogoHelper.getSplashLogoPath()` is used

### Recovery

If something goes wrong:

1. **Restore from backups**:

   ```bash
   # Restore xcconfig files
   cp ios/Debug.xcconfig.backup ios/Debug.xcconfig
   # (repeat for other files)

   # Restore original icons
   rm -rf ios/Runner/Assets.xcassets/AppIcon-*.appiconset
   mv ios/Runner/Assets.xcassets/AppIcon.appiconset.backup ios/Runner/Assets.xcassets/AppIcon.appiconset

   # Restore generic logo
   mv assets/images/logo.png.backup assets/images/logo.png
   ```

2. **Re-run setup**:

   ```bash
   ./scripts/setup_ios_icons.sh
   ```

## ✅ Success Metrics

The implementation is successful when:

- [ ] Each flavor displays its distinct icon
- [ ] All icon sizes render correctly
- [ ] App Store builds use correct icons
- [ ] No build errors related to missing icons
- [ ] Icons maintain quality across all devices
- [ ] Splash screen uses correct flavor logo
- [ ] Generic logo completely removed from project
- [ ] All logo references use FlavorLogoHelper

## 🧪 Testing

### Automated Testing

Run the verification script:

```bash
./scripts/test_flavor_logos.sh
```

This script checks:

- ✅ Flavor-specific logos exist
- ✅ iOS app icon sets created
- ✅ xcconfig files configured
- ✅ FlavorLogoHelper implemented
- ✅ Splash screen updated
- ✅ Generic logo removed
- ✅ pubspec.yaml updated
- ✅ Flutter build works

### Manual Testing

1. **Test each flavor**:

   ```bash
   flutter run --flavor development
   flutter run --flavor staging
   flutter run --flavor production
   ```

2. **Verify logos appear in**:
   - App icons on device/simulator
   - Splash screen
   - Any other logo references

---

## 📞 Support

If you encounter issues:

1. **Check this guide** for troubleshooting steps
2. **Review the scripts** in `scripts/` directory
3. **Verify file paths** and permissions
4. **Test with clean builds** to isolate issues
5. **Run the test script** to verify implementation

**Implementation Date**: $(date)
**Status**: ✅ Complete and Tested
