# 🚀 TrackFlow Launch Checklist

Use this concise checklist to prepare and execute a release safely.

---

## 1) Pre-release validation

- [ ] Version updated in `pubspec.yaml` (e.g., `1.0.0+1`)
- [ ] `flutter analyze` clean
- [ ] `flutter test` passing (CI green)
- [ ] Firebase configs valid for all flavors
- [ ] Android signing ready (`key.properties`, keystore in place or in CI secrets)
- [ ] iOS signing ready (certificates/profiles or CI secrets)

## 2) Required GitHub Secrets (CI/CD)

- **Android**: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`, `ANDROID_KEY_ALIAS`, `GOOGLE_PLAY_SERVICE_ACCOUNT` (if auto-upload)
- **iOS**: `IOS_CERTIFICATE_BASE64`, `IOS_CERTIFICATE_PASSWORD`, `APPLE_ISSUER_ID`, `APPLE_API_KEY_ID`, `APPLE_API_PRIVATE_KEY`
- **Firebase**: `FIREBASE_SERVICE_ACCOUNT`, `FIREBASE_APP_ID_DEV`, `FIREBASE_APP_ID_STAGING`
- Optional: `SLACK_WEBHOOK_URL`, `CODECOV_TOKEN`

## 3) Dry-run (optional)

```bash
# Trigger release build without store upload
gh workflow run build-release.yml -f version=0.1.0-beta -f upload_to_stores=false
gh run list --limit 5
```

## 4) Production release

```bash
# Create and push tag to trigger production release build
git tag v1.0.0
git push origin v1.0.0

# Monitor
gh run list --limit 5
gh run watch [RUN_ID]
```

Expected outputs:

- Android: AAB artifact, optional auto-upload to Play Console
- iOS: IPA artifact, optional TestFlight upload
- GitHub Release created with artifacts

## 5) Beta distribution (manual as needed)

```bash
gh workflow run deploy-firebase.yml \
  --ref develop \
  -f flavor=staging \
  -f testers_group=qa-team \
  -f release_notes="Beta for QA"
```

## 6) Post-release checks

- [ ] Install from Play/Internal or TestFlight (or APK/AAB/IPA locally)
- [ ] Smoke test: login, critical flows, audio playback
- [ ] Crashlytics monitoring
- [ ] Announce release (Slack/Email)

## 7) Rollback plan (quick)

- Android: Unpublish from current track or roll back to previous release
- iOS: Remove build from review and submit previous stable build
- Hotfix: `git tag v1.0.1` after fix → triggers new release build

---

## Quick commands

```bash
# CI on a branch
gh workflow run ci.yml --ref your-branch

# Debug APK for testing
gh workflow run build-debug.yml --ref develop -f flavor=development

# Release via tag
git tag v1.0.0 && git push origin v1.0.0

# View logs
gh run view [RUN_ID] --log-failed
```
