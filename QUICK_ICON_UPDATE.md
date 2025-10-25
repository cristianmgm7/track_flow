# 🚀 Quick Icon Update Guide

## What You Need

**3 logo files** (one for each flavor) in `assets/logo/`:

```
assets/logo/
  ├── trackflow_dev.png      (or .jpg) - Development version
  ├── trackflow_staging.png  (or .jpg) - Staging version
  └── trackflow_prod.png     (or .jpg) - Production version
```

### Requirements:
- **Size:** Minimum 1024x1024px (2048x2048px recommended)
- **Format:** PNG preferred (or JPG)
- **Shape:** Square

---

## How to Update

### One Command to Rule Them All:

```bash
./scripts/update_all_icons.sh
```

This will:
- ✅ Generate all iOS icons (45 total: 15 per flavor)
- ✅ Generate all Android icons (20 total: 5 densities × 3 flavors + main)
- ✅ Create backups of existing icons
- ✅ Show you a complete summary

---

## Icon Sizes Generated

### iOS (per flavor)
- 15 different sizes from 20x20 to 1024x1024
- Includes: App icon, Settings, Spotlight, Notifications, App Store

### Android (per flavor)
- 5 densities: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi
- Sizes: 48px to 192px

---

## After Running the Script

1. **Clean your project:**
   ```bash
   flutter clean && flutter pub get
   ```

2. **Test each flavor:**
   ```bash
   flutter run --flavor development
   flutter run --flavor staging
   flutter run --flavor production
   ```

3. **Build for release:**
   ```bash
   flutter build apk --flavor production --release
   flutter build ios --flavor production --release
   ```

---

## Troubleshooting

### "ImageMagick not found"
```bash
brew install imagemagick
```

### Icons not updating on device?
```bash
# Uninstall the app completely
# Then rebuild and reinstall
flutter clean
flutter run --flavor development
```

### Need more help?
See the complete guide: `docs/ICON_UPDATE_GUIDE.md`

---

## Quick Tips

✅ **DO:**
- Use high-quality images (1024x1024 minimum)
- Center your design
- Use different colors/badges for each flavor
- Test on real devices

❌ **DON'T:**
- Use images smaller than 1024x1024
- Place text too close to edges
- Forget to test all 3 flavors

---

## File Locations

**Source files (you provide):**
- `assets/logo/trackflow_dev.png`
- `assets/logo/trackflow_staging.png`
- `assets/logo/trackflow_prod.png`

**Generated iOS icons:**
- `ios/Runner/Assets.xcassets/AppIcon-Dev.appiconset/`
- `ios/Runner/Assets.xcassets/AppIcon-Staging.appiconset/`
- `ios/Runner/Assets.xcassets/AppIcon-Prod.appiconset/`

**Generated Android icons:**
- `android/app/src/development/res/mipmap-*/`
- `android/app/src/staging/res/mipmap-*/`
- `android/app/src/production/res/mipmap-*/`

---

## That's It! 🎉

Just run `./scripts/update_all_icons.sh` whenever you update your logo files.

For more details, see: `docs/ICON_UPDATE_GUIDE.md`

