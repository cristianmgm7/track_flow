# 📱 TrackFlow Icon Requirements Summary

## 🎯 What You Need to Provide

### 3 Square Logo Images

Place these in `assets/logo/`:

```
┌─────────────────────────┐
│  trackflow_dev.png      │  → Development flavor (e.g., with "DEV" badge)
├─────────────────────────┤
│  trackflow_staging.png  │  → Staging flavor (e.g., with "STAGE" badge)  
├─────────────────────────┤
│  trackflow_prod.png     │  → Production flavor (clean, final version)
└─────────────────────────┘
```

### Image Specifications

| Property | Requirement | Why |
|----------|-------------|-----|
| **Minimum Size** | 1024 × 1024 px | Needed for App Store (iOS) |
| **Recommended Size** | 2048 × 2048 px | Better quality for all sizes |
| **Format** | PNG (preferred) or JPG | PNG supports transparency |
| **Aspect Ratio** | 1:1 (Square) | Required by both platforms |
| **Color Mode** | RGB | Standard for digital displays |

---

## 🔄 What Gets Generated

### From 3 Images → 65 Total Icons

```
Your 3 Source Images
        ↓
┌───────┴───────┐
│               │
iOS             Android
45 icons        20 icons
```

#### iOS Breakdown (per flavor)
```
Development   → 15 icons (20x20 to 1024x1024)
Staging       → 15 icons (20x20 to 1024x1024)
Production    → 15 icons (20x20 to 1024x1024)
────────────────────────────────────────────
Total iOS     = 45 icons
```

#### Android Breakdown (per flavor)
```
Development   → 5 icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
Staging       → 5 icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
Production    → 5 icons (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
Main (backup) → 5 icons (uses production)
────────────────────────────────────────────
Total Android = 20 icons
```

---

## 📊 Complete Size Chart

### iOS Icon Sizes (per flavor)

| Purpose | Sizes Generated |
|---------|----------------|
| **App Icon** | 120×120, 180×180 |
| **Spotlight** | 40×40, 80×80, 120×120 |
| **Settings** | 29×29, 58×58, 87×87 |
| **Notification** | 20×20, 40×40, 60×60 |
| **iPad App** | 76×76, 152×152 |
| **iPad Pro** | 167×167 |
| **App Store** | 1024×1024 (no transparency!) |

**Total per flavor: 15 images**

### Android Icon Densities (per flavor)

| Density | Size | Typical Devices |
|---------|------|----------------|
| **mdpi** | 48×48 | Older phones |
| **hdpi** | 72×72 | Medium-res phones |
| **xhdpi** | 96×96 | HD phones |
| **xxhdpi** | 144×144 | Full HD phones |
| **xxxhdpi** | 192×192 | QHD+ phones |

**Total per flavor: 5 images**

---

## 🎨 Design Recommendations

### Safe Zone

```
┌─────────────────────────┐
│ ◄─ 10% padding          │
│  ┌─────────────────┐    │
│  │                 │    │
│  │   Your Logo     │ ◄── Safe zone (80% of image)
│  │   Goes Here     │    │
│  │                 │    │
│  └─────────────────┘    │
│          10% padding ─► │
└─────────────────────────┘
```

**Why?** iOS and Android apply masks/rounded corners. Keep important content centered.

### Flavor Differentiation

**Development:**
```
┌─────────────────┐
│  ┌───┐          │
│  │DEV│ [Logo]   │  ← Add "DEV" badge or use distinct color
│  └───┘          │     (e.g., orange/yellow tint)
└─────────────────┘
```

**Staging:**
```
┌─────────────────┐
│  ┌─────┐        │
│  │STAGE│ [Logo] │  ← Add "STAGE" badge or different color
│  └─────┘        │     (e.g., blue/purple tint)
└─────────────────┘
```

**Production:**
```
┌─────────────────┐
│                 │
│     [Logo]      │  ← Clean, final version
│                 │     No badges, polished look
└─────────────────┘
```

---

## 🚀 Quick Start Process

### Step 1: Create Your Logos

Use your preferred design tool:
- Figma (free, collaborative)
- Adobe Illustrator (professional)
- Photoshop (raster editing)
- Sketch (macOS only)
- GIMP (free alternative)

Export at **2048×2048px** as PNG.

### Step 2: Place Files

```bash
# From your design tool, export to:
assets/logo/trackflow_dev.png
assets/logo/trackflow_staging.png
assets/logo/trackflow_prod.png
```

### Step 3: Run Generation Script

```bash
./scripts/update_all_icons.sh
```

### Step 4: Clean & Test

```bash
flutter clean && flutter pub get
flutter run --flavor development
flutter run --flavor staging
flutter run --flavor production
```

---

## 📁 Current Status

### ✅ Already Set Up (iOS)

You already have iOS icon sets generated:
- `ios/Runner/Assets.xcassets/AppIcon-Dev.appiconset/` ✅
- `ios/Runner/Assets.xcassets/AppIcon-Staging.appiconset/` ✅
- `ios/Runner/Assets.xcassets/AppIcon-Prod.appiconset/` ✅

### ⚠️ Needs Setup (Android)

Android currently uses generic icons (same for all flavors).

Running `update_all_icons.sh` will create:
- `android/app/src/development/res/mipmap-*/` 🆕
- `android/app/src/staging/res/mipmap-*/` 🆕
- `android/app/src/production/res/mipmap-*/` 🆕

---

## 🔍 Before & After

### BEFORE (Current)
```
iOS:     ✅ 3 flavors with distinct icons
Android: ⚠️  All flavors share the same icon
```

### AFTER (After running script)
```
iOS:     ✅ 3 flavors with YOUR new icons
Android: ✅ 3 flavors with YOUR new icons (distinct)
```

---

## 💡 Pro Tips

1. **Test Small Sizes**
   - Your icon will be displayed as small as 20×20px
   - Make sure it's recognizable at tiny sizes
   - Avoid fine details that disappear when small

2. **Use Vectors When Possible**
   - Design in vector format (AI, Figma, Sketch)
   - Export to PNG at high resolution
   - Keep the vector source for future edits

3. **Color Contrast**
   - Test on both light and dark backgrounds
   - iOS uses white/black backgrounds in different contexts
   - Android launchers have various background colors

4. **Iterate and Test**
   - Generate icons
   - Test on real devices
   - Adjust design if needed
   - Re-run script (it's fast!)

5. **Version Control**
   - Commit both source and generated icons
   - Tag releases with version numbers
   - Keep design files outside repo (optional)

---

## 🎯 Checklist

Before running the script:

- [ ] I have 3 logo files ready (dev, staging, production)
- [ ] Each file is at least 1024×1024px (preferably 2048×2048px)
- [ ] Files are in PNG or JPG format
- [ ] Files are placed in `assets/logo/` directory
- [ ] Files are named correctly (trackflow_dev, trackflow_staging, trackflow_prod)
- [ ] ImageMagick is installed (`brew install imagemagick`)
- [ ] Logo looks good at small sizes
- [ ] Each flavor is visually distinct

After running the script:

- [ ] Script completed without errors
- [ ] iOS icons generated (check `ios/Runner/Assets.xcassets/`)
- [ ] Android icons generated (check `android/app/src/*/res/mipmap-*/`)
- [ ] Ran `flutter clean && flutter pub get`
- [ ] Tested development flavor
- [ ] Tested staging flavor
- [ ] Tested production flavor
- [ ] Icons look correct on device home screen
- [ ] Icons look correct in app switcher
- [ ] Icons committed to git

---

## 🆘 Common Questions

**Q: Can I use different sizes for each flavor?**
A: Yes! Just provide different source images. The script handles the rest.

**Q: Do I need to manually create 65 icons?**
A: No! Just provide 3 source images, the script creates all 65.

**Q: What if I only want to update one flavor?**
A: Replace just that one source file and re-run the script. It updates all but you can commit only what changed.

**Q: Can I use logos with transparency?**
A: Yes for most icons. The App Store icon (1024×1024) will have transparency removed automatically.

**Q: How often should I update icons?**
A: Whenever you rebrand or want to refresh the app's look. For flavors, typically only update when visual differentiation is needed.

**Q: Will this work on Windows/Linux?**
A: The scripts are designed for macOS/Linux with Bash. For Windows, use WSL (Windows Subsystem for Linux) or Git Bash.

---

## 📚 Further Reading

- [Complete Guide](docs/ICON_UPDATE_GUIDE.md) - Detailed documentation
- [Quick Reference](QUICK_ICON_UPDATE.md) - TL;DR version
- [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/app-icons) - iOS guidelines
- [Material Design](https://material.io/design/iconography) - Android guidelines

---

## 🎉 Summary

**What you need:** 3 square images (1024×1024 minimum)

**What you get:** 65 icons in all required sizes for iOS & Android

**How long it takes:** < 1 minute to run the script

**Difficulty:** Easy! Just run one script

---

Ready to update your icons? Run:

```bash
./scripts/update_all_icons.sh
```

🚀 **Let's make your app look amazing!**

