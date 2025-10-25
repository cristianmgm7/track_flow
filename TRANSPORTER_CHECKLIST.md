# 📱 iOS Build & Transporter Upload Checklist

## For Staging Release v1.0.3

---

## ✅ Pre-Build Checklist

Before building, ensure:

- [ ] **Xcode is installed** and up to date
- [ ] **Xcode Command Line Tools** installed: `xcode-select --install`
- [ ] **Certificates & Provisioning Profiles** configured in Xcode
  - Open: `/Users/cristian/Documents/track_flow/ios/Runner.xcworkspace`
  - Check: Signing & Capabilities tab
  - Ensure: Staging flavor has proper provisioning profile
- [ ] **App Store Connect** account has access
- [ ] **Transporter app** installed (from Mac App Store)
- [ ] **Firebase config** is correct for staging
- [ ] **Version number** updated if needed: `1.0.3`

---

## 🚀 Build Steps

### Option 1: Using the Custom Script (Recommended)

```bash
./BUILD_STAGING_IOS.sh
```

This script will:
- Clean previous builds
- Switch to staging Firebase config
- Build the IPA with correct version (1.0.3)
- Show you the exact location of the IPA file

### Option 2: Manual Build Command

```bash
cd /Users/cristian/Documents/track_flow

# Clean
flutter clean
flutter pub get

# Switch Firebase config
./scripts/switch_firebase_config.sh staging

# Build IPA
flutter build ipa \
  --flavor staging \
  -t lib/main_staging.dart \
  --release \
  --build-name=1.0.3 \
  --build-number=$(date +%Y%m%d%H%M)
```

---

## 📦 IPA Location

After successful build:

```
/Users/cristian/Documents/track_flow/build/ios/ipa/trackflow.ipa
```

Or in Finder:
1. Navigate to your project folder
2. `build` → `ios` → `ipa` → `trackflow.ipa`

---

## 📤 Upload with Transporter

### Step 1: Open Transporter
- Download from Mac App Store if not installed
- Launch Transporter app

### Step 2: Sign In
- Sign in with your Apple Developer account
- Same account used in App Store Connect

### Step 3: Add IPA
Two ways:
1. **Drag & Drop**: Drag `trackflow.ipa` into Transporter window
2. **Click +**: Click the + button and select the IPA file

### Step 4: Verify Details
Transporter will show:
- App name: **TrackFlow Staging**
- Bundle ID: `com.trackflow.staging`
- Version: **1.0.3**
- Build number: (auto-generated timestamp)
- Icon: Your **staging icon** 🎨

### Step 5: Deliver
- Click **"Deliver"** button
- Wait for upload (may take 5-15 minutes depending on connection)
- You'll see progress bar

### Step 6: Confirmation
- ✅ Success message when complete
- You'll receive email confirmation from Apple

---

## 🧪 TestFlight Setup

After successful upload:

### 1. Go to App Store Connect
```
https://appstoreconnect.apple.com
```

### 2. Select Your App
- Navigate to "My Apps"
- Click on TrackFlow (or your app name)

### 3. Go to TestFlight Tab
- Click "TestFlight" in the top menu
- Wait for build to process (5-30 minutes)

### 4. Build Processing
Apple will:
- ✅ Process the build
- ✅ Run automated checks
- ✅ Make it available for testing

You'll receive email when processing is complete.

### 5. Add to Testing Group
Once processed:
- Select the build
- Click "Add to Group"
- Choose internal or external testers
- Build becomes available to testers

### 6. Testers Get Notified
- Testers receive email notification
- They can install via TestFlight app
- **Your staging icon will appear** on their device! 🎨

---

## 🎨 Icon Verification

Your **Staging** build will show:
- ✅ Staging-specific icon (from `trackflow_staging.png`)
- ✅ App name: "TrackFlow Staging"
- ✅ Different from Development and Production

This makes it easy for testers to identify which version they're using!

---

## 🐛 Troubleshooting

### Build Fails with Signing Error
**Fix:**
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select "Runner" project
3. Go to "Signing & Capabilities"
4. Ensure "Staging" configuration has:
   - Team selected
   - Provisioning profile assigned
5. Clean and rebuild

### "Application failed to verify"
**Fix:**
- Ensure certificates are valid in Apple Developer portal
- Re-download provisioning profiles
- Clean build folder: `flutter clean`

### Upload Fails in Transporter
**Fix:**
- Check internet connection
- Verify Apple Developer account has upload permissions
- Try re-uploading (sometimes temporary server issues)
- Check App Store Connect for any app-specific issues

### Build Number Already Used
**Fix:**
- The script auto-generates unique build numbers using timestamp
- If manually building, increment build number
- Build numbers must be unique for each upload

### Wrong Icon Appears
**Fix:**
- Verify icon generation ran successfully
- Check `ios/Runner/Assets.xcassets/AppIcon-Staging.appiconset/`
- Re-run: `./scripts/generate_ios_icons_sips.sh`
- Clean and rebuild

---

## 📝 Build Information

**Flavor:** Staging  
**Version:** 1.0.3  
**Target:** lib/main_staging.dart  
**Configuration:** Release  
**Bundle ID:** com.trackflow.staging  
**Icon Set:** AppIcon-Staging.appiconset  

---

## 🔄 For Future Builds

To build other flavors or versions:

**Development:**
```bash
./scripts/build_flavors.sh development release ios 1.0.3
```

**Production:**
```bash
./scripts/build_flavors.sh production release ios 1.0.3
```

**Different Version:**
```bash
./scripts/build_flavors.sh staging release ios 1.0.4
```

---

## 📞 Quick Reference

| What | Where |
|------|-------|
| **Build Script** | `./BUILD_STAGING_IOS.sh` |
| **IPA Location** | `build/ios/ipa/trackflow.ipa` |
| **Transporter** | Mac App Store |
| **App Store Connect** | https://appstoreconnect.apple.com |
| **Icon Assets** | `ios/Runner/Assets.xcassets/AppIcon-Staging.appiconset/` |
| **Firebase Config** | Switched via `scripts/switch_firebase_config.sh` |

---

## ✨ Summary

1. **Run:** `./BUILD_STAGING_IOS.sh`
2. **Open:** Transporter app
3. **Upload:** Drag IPA file
4. **Wait:** Build processing in App Store Connect
5. **Test:** Add to TestFlight group
6. **Verify:** Check staging icon on test devices! 🎨

---

**Your new staging icon will be visible to all testers! 🚀**

Good luck with your release!

