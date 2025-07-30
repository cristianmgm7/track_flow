# TrackFlow Production Environment Setup Guide

This guide covers the complete setup process for separating development, staging, and production environments in TrackFlow using Flutter flavors.

## 🎯 Overview

TrackFlow now supports three environments:
- **Development** (`com.trackflow.dev`) - For local development and testing
- **Staging** (`com.trackflow.staging`) - For pre-production testing
- **Production** (`com.trackflow`) - For live app distribution

Each environment has:
- ✅ Separate Firebase projects
- ✅ Unique package identifiers
- ✅ Environment-specific configurations
- ✅ Isolated data and authentication
- ✅ Different app names and icons (configurable)

## 📁 Project Structure

```
lib/
├── config/
│   ├── flavor_config.dart          # Flavor management
│   ├── environment_config.dart     # Environment-specific settings
│   └── firebase_config.dart        # Dynamic Firebase configuration
├── firebase_options_development.dart
├── firebase_options_staging.dart
├── firebase_options_production.dart
├── main_development.dart           # Development entry point
├── main_staging.dart              # Staging entry point
└── main_production.dart           # Production entry point

android/app/
├── src/
│   ├── development/               # Development-specific Android resources
│   ├── staging/                  # Staging-specific Android resources
│   └── production/               # Production-specific Android resources
└── build.gradle.kts             # Android flavor configuration

ios/
└── config/
    ├── development/              # Development iOS configuration
    ├── staging/                 # Staging iOS configuration
    └── production/              # Production iOS configuration

scripts/
├── build_flavors.sh             # Build script for different flavors
└── run_flavors.sh              # Run script for different flavors
```

## 🔧 Setup Instructions

### 1. Firebase Projects Setup

You need to create **three separate Firebase projects**:

#### Development Project
```bash
# Create project: trackflow-dev
firebase projects:create trackflow-dev
firebase use trackflow-dev

# Configure services
firebase firestore:rules set firestore.rules
firebase firestore:indexes set firestore.indexes.json
firebase storage:rules set storage.rules
```

#### Staging Project
```bash
# Create project: trackflow-staging
firebase projects:create trackflow-staging
firebase use trackflow-staging

# Configure services (repeat same configuration)
```

#### Production Project
```bash
# Create project: trackflow-prod
firebase projects:create trackflow-prod
firebase use trackflow-prod

# Configure services (repeat same configuration)
```

### 2. Firebase Configuration Files

For each project, download the configuration files:

#### Android
```bash
# Development
firebase apps:android:config 1:PROJECT-ID:android:APP-ID > android/app/src/development/google-services.json

# Staging  
firebase apps:android:config 1:PROJECT-ID:android:APP-ID > android/app/src/staging/google-services.json

# Production
firebase apps:android:config 1:PROJECT-ID:android:APP-ID > android/app/src/production/google-services.json
```

#### iOS
```bash
# Development
firebase apps:ios:config 1:PROJECT-ID:ios:APP-ID > ios/config/development/GoogleService-Info-Dev.plist

# Staging
firebase apps:ios:config 1:PROJECT-ID:ios:APP-ID > ios/config/staging/GoogleService-Info-Staging.plist

# Production
firebase apps:ios:config 1:PROJECT-ID:ios:APP-ID > ios/config/production/GoogleService-Info-Prod.plist
```

### 3. Update Firebase Options Files

Update the placeholder values in:
- `lib/firebase_options_development.dart`
- `lib/firebase_options_staging.dart`
- `lib/firebase_options_production.dart`

Replace `YOUR-*-API-KEY`, `YOUR-*-APP-ID`, etc. with actual values from Firebase console.

### 4. Environment Configuration

Update `lib/config/environment_config.dart` with your actual URLs:

```dart
static String get apiBaseUrl {
  switch (FlavorConfig.currentFlavor) {
    case Flavor.development:
      return 'https://api-dev.yourdomain.com';    // Your dev API
    case Flavor.staging:
      return 'https://api-staging.yourdomain.com'; // Your staging API
    case Flavor.production:
      return 'https://api.yourdomain.com';         // Your production API
  }
}
```

## 🚀 Building and Running

### Development Commands

```bash
# Run development flavor
flutter run --flavor development -t lib/main_development.dart

# Or use the script
./scripts/run_flavors.sh development debug

# Build development APK
flutter build apk --flavor development -t lib/main_development.dart

# Build development IPA
flutter build ipa --flavor development -t lib/main_development.dart
```

### Staging Commands

```bash
# Run staging flavor
flutter run --flavor staging -t lib/main_staging.dart

# Or use the script
./scripts/run_flavors.sh staging debug

# Build staging APK
flutter build apk --flavor staging -t lib/main_staging.dart

# Build staging IPA  
flutter build ipa --flavor staging -t lib/main_staging.dart
```

### Production Commands

```bash
# Run production flavor (release mode recommended)
flutter run --flavor production -t lib/main_production.dart --release

# Or use the script
./scripts/run_flavors.sh production release

# Build production APK (signed)
flutter build apk --flavor production -t lib/main_production.dart --release

# Build production IPA (signed)
flutter build ipa --flavor production -t lib/main_production.dart --release
```

### Using Build Scripts

```bash
# Build for Android
./scripts/build_flavors.sh [development|staging|production] [debug|release] android

# Build for iOS
./scripts/build_flavors.sh [development|staging|production] [debug|release] ios

# Examples:
./scripts/build_flavors.sh development debug android
./scripts/build_flavors.sh production release ios
```

## 📦 Package Identifiers

Each environment uses different package identifiers:

| Environment | Android Package ID | iOS Bundle ID |
|-------------|-------------------|---------------|
| Development | `com.trackflow.dev` | `com.trackflow.dev` |
| Staging | `com.trackflow.staging` | `com.trackflow.staging` |
| Production | `com.trackflow` | `com.trackflow` |

This allows all three versions to be installed simultaneously on the same device.

## 🔐 Signing Configuration

### Android Signing

1. **Create signing keys for each environment:**

```bash
# Development (optional - can use debug key)
keytool -genkey -v -keystore android/app/dev-release-key.keystore -alias dev-key -keyalg RSA -keysize 2048 -validity 10000

# Staging
keytool -genkey -v -keystore android/app/staging-release-key.keystore -alias staging-key -keyalg RSA -keysize 2048 -validity 10000

# Production  
keytool -genkey -v -keystore android/app/production-release-key.keystore -alias production-key -keyalg RSA -keysize 2048 -validity 10000
```

2. **Update `android/app/build.gradle.kts`:**

```kotlin
android {
    signingConfigs {
        create("development") {
            keyAlias = "dev-key"
            keyPassword = "your-key-password"
            storeFile = file("dev-release-key.keystore")
            storePassword = "your-store-password"
        }
        
        create("staging") {
            keyAlias = "staging-key"
            keyPassword = "your-key-password"
            storeFile = file("staging-release-key.keystore")
            storePassword = "your-store-password"
        }
        
        create("production") {
            keyAlias = "production-key"
            keyPassword = "your-key-password"
            storeFile = file("production-release-key.keystore")
            storePassword = "your-store-password"
        }
    }
    
    buildTypes {
        release {
            signingConfig = when {
                project.hasProperty("flavor") -> {
                    when (project.property("flavor")) {
                        "development" -> signingConfigs.getByName("development")
                        "staging" -> signingConfigs.getByName("staging")
                        "production" -> signingConfigs.getByName("production")
                        else -> signingConfigs.getByName("debug")
                    }
                }
                else -> signingConfigs.getByName("debug")
            }
        }
    }
}
```

### iOS Signing

1. **Create separate provisioning profiles** for each environment in Apple Developer Console
2. **Configure schemes** in Xcode for each flavor
3. **Update bundle identifiers** to match environment configuration

## 🧪 Testing Different Environments

### Local Testing

```bash
# Test development environment
flutter test --flavor development

# Test staging environment  
flutter test --flavor staging

# Test production environment
flutter test --flavor production
```

### Integration Testing

```bash
# Run integration tests for specific flavor
flutter drive --flavor development --target=test_driver/app.dart
```

## 🚨 Important Security Notes

### 1. Environment Isolation
- **Never use production Firebase keys in development**
- **Keep environment variables secure**
- **Use different API keys for each environment**

### 2. Signing Keys
- **Store production signing keys securely**
- **Never commit signing keys to repository**
- **Use CI/CD secrets for automated builds**

### 3. Firebase Security Rules
- **Development:** More permissive rules for testing
- **Staging:** Production-like rules for integration testing  
- **Production:** Strict security rules

## 📊 Environment Monitoring

### Logging Configuration

Each environment has different logging levels configured in `environment_config.dart`:

```dart
static bool get enableLogging {
  switch (FlavorConfig.currentFlavor) {
    case Flavor.development:
      return true;    // Verbose logging
    case Flavor.staging:
      return true;    // Detailed logging for debugging
    case Flavor.production:
      return false;   // Minimal logging
  }
}
```

### Crashlytics Configuration

```dart
static bool get enableCrashlytics {
  switch (FlavorConfig.currentFlavor) {
    case Flavor.development:
      return false;   // Disabled to avoid noise
    case Flavor.staging:
      return true;    // Enabled for pre-production testing
    case Flavor.production:
      return true;    // Enabled for production monitoring
  }
}
```

## 🔄 CI/CD Pipeline Setup

### GitHub Actions Example

```yaml
name: Build and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        flavor: [development, staging, production]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.3'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test
    
    - name: Build Android APK
      run: flutter build apk --flavor ${{ matrix.flavor }} -t lib/main_${{ matrix.flavor }}.dart --release
    
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: apk-${{ matrix.flavor }}
        path: build/app/outputs/flutter-apk/app-${{ matrix.flavor }}-release.apk
```

## 🛠️ Troubleshooting

### Common Issues

1. **Flavor not recognized:**
   ```bash
   # Make sure flavor is properly configured in build.gradle.kts
   flutter clean
   flutter pub get
   ```

2. **Firebase configuration errors:**
   ```bash
   # Verify correct configuration files are in place
   # Check that Firebase project IDs match
   ```

3. **Package ID conflicts:**
   ```bash
   # Uninstall previous versions with different package IDs
   adb uninstall com.example.trackflow
   ```

4. **Build failures:**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

### Debugging

```bash
# Enable verbose logging
flutter run --verbose --flavor development -t lib/main_development.dart

# Check flavor configuration
flutter run --flavor development -t lib/main_development.dart --dart-define=FLUTTER_BUILD_MODE=debug
```

## 📋 Checklist Before Production Launch

### Development Environment ✅
- [x] Firebase project created and configured
- [x] Development flavor builds successfully
- [x] All tests pass
- [x] Debug logging enabled

### Staging Environment ⚠️
- [ ] Firebase staging project created
- [ ] Staging configuration files in place
- [ ] Integration tests pass
- [ ] Performance testing completed
- [ ] Security testing completed

### Production Environment ❌
- [ ] Firebase production project created
- [ ] Production signing certificates configured
- [ ] Production configuration files in place
- [ ] App Store/Play Store metadata ready
- [ ] Privacy policy and terms of service ready
- [ ] Production monitoring configured
- [ ] Backup and disaster recovery plan
- [ ] Final security audit completed

## 🎉 Next Steps

1. **Create Firebase projects** for staging and production
2. **Configure signing certificates** for release builds
3. **Set up CI/CD pipeline** for automated builds
4. **Configure app store listings** for each environment
5. **Implement feature flags** for gradual rollouts
6. **Set up monitoring and analytics** for production

---

## 📞 Support

For questions or issues with this setup:
1. Check the troubleshooting section above
2. Review Firebase documentation for your specific use case
3. Consult Flutter flavor documentation
4. Check project-specific documentation in `/docs`

---

**Created:** $(date)  
**Version:** 1.0.0  
**Environment:** TrackFlow Production Setup  
**Author:** TrackFlow Development Team  