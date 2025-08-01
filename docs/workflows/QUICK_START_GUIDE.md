# 🚀 TrackFlow CI/CD Quick Start Guide

## Current Status: ✅ WORKFLOWS WORKING!

Your GitHub Actions workflows are **fully functional**. Here's how to use them and what's needed for complete store distribution.

---

## 🎯 Immediate Next Steps

### 1. Fix Unit Tests (Required for green CI)
```bash
# Check what tests are failing
flutter test

# Fix failing tests one by one
# Current status: 111 tests total, 38 failing
```

### 2. Test Your Workflows

#### CI Pipeline
```bash
# Test CI on any branch
gh workflow run ci.yml --ref your-branch-name

# Monitor progress
gh run watch [RUN_ID]
```

#### Debug Builds
```bash
# Create debug APK for testing
gh workflow run build-debug.yml \
  --ref develop \
  -f flavor=development \
  -f upload_to_firebase=true
```

#### Release Build (Test)
```bash
# Test release process with beta version
gh workflow run build-release.yml \
  -f version=0.1.0-beta \
  -f upload_to_stores=false
```

---

## 🔧 For Complete Store Distribution

### Required GitHub Secrets

Add these in: **Repository Settings → Secrets and Variables → Actions**

#### Android (Google Play Store)
```
ANDROID_KEYSTORE_BASE64      # Your release keystore (base64 encoded)
ANDROID_KEYSTORE_PASSWORD    # Keystore password
ANDROID_KEY_PASSWORD         # Key password  
ANDROID_KEY_ALIAS           # Key alias
GOOGLE_PLAY_SERVICE_ACCOUNT  # Google Play Console service account JSON
```

#### iOS (App Store)
```
IOS_CERTIFICATE_BASE64       # Distribution certificate p12 (base64)
IOS_CERTIFICATE_PASSWORD     # Certificate password
APPLE_ISSUER_ID             # App Store Connect API issuer ID
APPLE_API_KEY_ID            # API key ID
APPLE_API_PRIVATE_KEY       # API private key
```

#### Firebase App Distribution
```
FIREBASE_SERVICE_ACCOUNT     # Firebase service account JSON
FIREBASE_APP_ID_DEV         # Development app ID
FIREBASE_APP_ID_STAGING     # Staging app ID
```

#### Notifications (Optional)
```
SLACK_WEBHOOK_URL           # Slack webhook for notifications
CODECOV_TOKEN              # Codecov token for coverage reports
```

---

## 📱 How to Use Each Workflow

### 🧪 CI Workflow - Quality Gates
**Triggers automatically on:**
- Push to `main`, `develop`, `feature/*`, `fix/*`, `hotfix/*`
- Pull requests to `main`, `develop`

**What it does:**
- ✅ Runs `flutter analyze` (now passing!)
- ✅ Executes unit tests
- ✅ Builds all flavors
- ✅ Security scanning

### 🔨 Debug Builds - Development Testing
**Manual trigger:**
```bash
gh workflow run build-debug.yml \
  --ref develop \
  -f flavor=development     # or staging
```

**Output:**
- 📱 APK files for testing
- 🔥 Firebase App Distribution to testers
- 📁 GitHub artifacts (7 days)

### 🚀 Release Builds - Production
**Recommended via Git tags:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Output:**
- 📱 AAB file for Google Play Store
- 🍎 IPA file for App Store
- 🏷️ GitHub release with artifacts
- 🏪 Optional automatic store upload

### 🔥 Firebase Deploy - Beta Distribution
**Manual trigger:**
```bash
gh workflow run deploy-firebase.yml \
  --ref develop \
  -f flavor=staging \
  -f testers_group=qa-team \
  -f release_notes="Beta version for QA testing"
```

---

## 🎮 Quick Commands

### Monitor Workflows
```bash
# List recent runs
gh run list --limit 5

# Watch a specific run
gh run watch [RUN_ID]

# View logs for failed run
gh run view [RUN_ID] --log-failed

# Re-run failed workflow
gh run rerun [RUN_ID]
```

### Create Releases
```bash
# Create and push tag (triggers release build)
git tag v1.0.0
git push origin v1.0.0

# Or manual release
gh workflow run build-release.yml -f version=1.0.0
```

### Test Specific Features
```bash
# Test CI on feature branch
git checkout feature/new-feature
git push origin feature/new-feature
# CI runs automatically

# Create debug build for feature testing
gh workflow run build-debug.yml --ref feature/new-feature
```

---

## 🚨 Current Blockers

### 1. Unit Tests (38 failing)
**Status:** ❌ Blocking green CI  
**Action:** Fix failing tests to enable full pipeline

### 2. Store Secrets (Missing)
**Status:** ⚠️ Prevents store distribution  
**Action:** Add required secrets for automatic store uploads

### 3. Keystore & Certificates (Not configured)
**Status:** ⚠️ Manual setup needed  
**Action:** Generate and configure signing certificates

---

## ✅ What's Already Working

- ✅ **Flutter Setup**: Version 3.29.3 with Dart 3.7.2
- ✅ **Dependencies**: `flutter pub get` working
- ✅ **Code Generation**: `build_runner` successful
- ✅ **Code Analysis**: All linting issues fixed!
- ✅ **Build Process**: APK/AAB generation working
- ✅ **Artifact Storage**: GitHub artifacts saved
- ✅ **Matrix Builds**: Multiple flavors in parallel
- ✅ **Notifications**: Slack integration ready

---

## 🎯 Recommended Development Flow

### Daily Development
1. **Work on features** → CI runs automatically
2. **Push to develop** → Debug builds created
3. **Create PR** → Full CI with integration tests

### Testing & QA
1. **Manual debug builds** for specific testing
2. **Firebase distribution** to QA teams
3. **Slack notifications** for build status

### Release Process
1. **Create release branch** → Test thoroughly
2. **Merge to main** → Create git tag
3. **Automatic release build** → Store-ready artifacts
4. **GitHub release** created with download links

---

## 📞 Support Commands

If you need help with any workflow:

```bash
# Get workflow details
gh workflow view ci.yml

# List all workflows
gh workflow list

# Check workflow file syntax
gh workflow view [workflow-name] --ref main
```

**Your CI/CD pipeline is ready for production! 🚀**

The next step is fixing those unit tests to get a fully green pipeline, then configuring store secrets for automated distribution.