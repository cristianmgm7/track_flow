## iOS CI con GitHub Actions (barato con self-hosted runner)

Objetivo: compilar y publicar a TestFlight para los 3 flavors (develop, staging, production) usando GitHub Actions. Para minimizar costos, usa un runner macOS self‑hosted (tu Mac/Mac mini). En GitHub‑hosted, macOS se cobra por minuto y suele salir similar a Codemagic.

### 1) Requisitos en el runner macOS (self‑hosted)
- Xcode 16.x y Command Line Tools instalados (abre Xcode una vez y acepta licencias).
- Flutter estable en PATH (`flutter --version`).
- CocoaPods (`sudo gem install cocoapods`).
- fastlane para subir a TestFlight (`sudo gem install fastlane`).
- Login en App Store Connect no es necesario si usas API Key (recomendado).

Registra el runner en tu repo:
1. GitHub → Settings → Actions → Runners → New self‑hosted runner (macOS).
2. Sigue el script de instalación y arráncalo con `./run.sh`. Opcional: configúralo como launch daemon para que se inicie al boot.

Sugerencia de etiquetas (labels): `self-hosted`, `macOS`, `xcode-16`.

### 2) Certificados y perfiles (firmado iOS)
Usaremos secretos en GitHub con los archivos en BASE64.

1. Certificado de distribución `.p12` y contraseña
   - Si los tienes en Codemagic, descárgalos desde Team → Code signing identities.
   - Convierte a base64:
     ```bash
     base64 -i IOS_DIST.p12 | pbcopy
     ```
2. Perfiles de aprovisionamiento `.mobileprovision` por flavor
   - `trackflow dev`, `trackflow staging`, `trackflow prod` (o equivalentes).
   - Convierte cada uno a base64:
     ```bash
     base64 -i trackflow_dev.mobileprovision | pbcopy
     ```

Crea estos Secrets en GitHub (Settings → Secrets and variables → Actions → New repository secret):
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_KEY_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY` (contenido del `.p8` pegado tal cual)
- `IOS_DIST_P12_B64`
- `IOS_DIST_P12_PASSWORD`
- `IOS_PROFILE_DEV_B64`
- `IOS_PROFILE_STAGING_B64`
- `IOS_PROFILE_PROD_B64`

### 3) Importar firma en el workflow
Script de importación (embebido en YAML o como script aparte). Ejemplo en línea:
```bash
set -euo pipefail
KEYCHAIN=build.keychain
KEYCHAIN_PWD=ci_password

security create-keychain -p "$KEYCHAIN_PWD" "$KEYCHAIN"
security default-keychain -s "$KEYCHAIN"
security unlock-keychain -p "$KEYCHAIN_PWD" "$KEYCHAIN"
security set-keychain-settings -lut 21600 "$KEYCHAIN"

echo "$IOS_DIST_P12_B64" | base64 --decode > ios_dist.p12
security import ios_dist.p12 -k "$KEYCHAIN" -P "$IOS_DIST_P12_PASSWORD" -A -T /usr/bin/codesign

PROFILES_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
mkdir -p "$PROFILES_DIR"
echo "$IOS_PROFILE_B64" | base64 --decode > "$PROFILES_DIR/$PROFILE_NAME.mobileprovision"
```

En cada flavor se asigna `IOS_PROFILE_B64` y `PROFILE_NAME` adecuados.

### 4) Build y export del IPA con Xcode
Usaremos `xcodebuild archive` y `-exportArchive` con `ios/ExportOptions.plist`.

```bash
set -euo pipefail

# 1) Versionado de build (creciente)
NEW_BUILD_NUMBER="$(date +%Y%m%d%H%M)"
echo "Build number: $NEW_BUILD_NUMBER"

# 2) Flutter build sin firmar (para generar Runner.xcarchive correctamente)
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter build ios --flavor "$FLAVOR" --release --no-codesign --build-number "$NEW_BUILD_NUMBER" --verbose

# 3) Pod install
cd ios && pod install --repo-update && cd ..

# 4) Archive
xcodebuild \
  -workspace ios/Runner.xcworkspace \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -sdk iphoneos \
  -archivePath "$PWD/build/Runner.xcarchive" \
  clean archive CODE_SIGN_STYLE=Manual

# 5) Export IPA
xcodebuild -exportArchive \
  -archivePath "$PWD/build/Runner.xcarchive" \
  -exportOptionsPlist ios/ExportOptions.plist \
  -exportPath "$PWD/build/ios/ipa"
```

### 5) Publicar a TestFlight (fastlane pilot)
Genera un JSON de API Key en runtime y súbelo:
```bash
cat > api_key.json <<EOF
{
  "key_id": "${APP_STORE_CONNECT_KEY_ID}",
  "issuer_id": "${APP_STORE_CONNECT_ISSUER_ID}",
  "key": "${APP_STORE_CONNECT_PRIVATE_KEY}",
  "in_house": false
}
EOF

IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -n1)
fastlane pilot upload --api_key_path api_key.json --ipa "$IPA_PATH" --skip_waiting_for_build_processing true
```

### 6) YAML de ejemplo por flavor
Ejemplo para `develop` (adaptar a `staging` y `production` cambiando variables y rama):

```yaml
name: iOS Develop → TestFlight

on:
  push:
    branches: [develop]

jobs:
  ios-develop:
    runs-on: self-hosted
    labels: [self-hosted, macOS]
    env:
      FLAVOR: develop
      SCHEME: develop
      CONFIG: Release-develop
      BUNDLE_ID: com.trackflow.dev
    steps:
      - uses: actions/checkout@v4
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
      - name: Import signing (p12 + profile)
        env:
          IOS_DIST_P12_B64: ${{ secrets.IOS_DIST_P12_B64 }}
          IOS_DIST_P12_PASSWORD: ${{ secrets.IOS_DIST_P12_PASSWORD }}
          IOS_PROFILE_B64: ${{ secrets.IOS_PROFILE_DEV_B64 }}
          PROFILE_NAME: trackflow_dev
        run: |
          KEYCHAIN=build.keychain; PASS=ci_password
          security create-keychain -p "$PASS" "$KEYCHAIN"
          security default-keychain -s "$KEYCHAIN"
          security unlock-keychain -p "$PASS" "$KEYCHAIN"
          security set-keychain-settings -lut 21600 "$KEYCHAIN"
          echo "$IOS_DIST_P12_B64" | base64 --decode > ios_dist.p12
          security import ios_dist.p12 -k "$KEYCHAIN" -P "$IOS_DIST_P12_PASSWORD" -A -T /usr/bin/codesign
          mkdir -p "$HOME/Library/MobileDevice/Provisioning Profiles"
          echo "$IOS_PROFILE_B64" | base64 --decode > "$HOME/Library/MobileDevice/Provisioning Profiles/$PROFILE_NAME.mobileprovision"
      - name: Copy Firebase plist (flavor)
        run: |
          cp -f ios/config/development/GoogleService-Info-Dev.plist ios/Runner/GoogleService-Info-Dev.plist
      - name: Build & Export IPA
        run: |
          set -euo pipefail
          NEW_BUILD_NUMBER="$(date +%Y%m%d%H%M)"; echo "Build: $NEW_BUILD_NUMBER"
          flutter pub get
          flutter packages pub run build_runner build --delete-conflicting-outputs
          flutter build ios --flavor $FLAVOR --release --no-codesign --build-number $NEW_BUILD_NUMBER --verbose
          cd ios && pod install --repo-update && cd ..
          xcodebuild -workspace ios/Runner.xcworkspace -scheme "$SCHEME" -configuration "$CONFIG" -sdk iphoneos -archivePath "$PWD/build/Runner.xcarchive" clean archive CODE_SIGN_STYLE=Manual
          xcodebuild -exportArchive -archivePath "$PWD/build/Runner.xcarchive" -exportOptionsPlist ios/ExportOptions.plist -exportPath "$PWD/build/ios/ipa"
      - name: Upload to TestFlight (fastlane)
        env:
          APP_STORE_CONNECT_ISSUER_ID: ${{ secrets.APP_STORE_CONNECT_ISSUER_ID }}
          APP_STORE_CONNECT_KEY_ID: ${{ secrets.APP_STORE_CONNECT_KEY_ID }}
          APP_STORE_CONNECT_PRIVATE_KEY: ${{ secrets.APP_STORE_CONNECT_PRIVATE_KEY }}
        run: |
          sudo gem install fastlane --no-document
          cat > api_key.json <<EOF
          {"key_id":"${APP_STORE_CONNECT_KEY_ID}","issuer_id":"${APP_STORE_CONNECT_ISSUER_ID}","key":"${APP_STORE_CONNECT_PRIVATE_KEY}","in_house":false}
          EOF
          IPA_PATH=$(find build/ios/ipa -name "*.ipa" | head -n1)
          fastlane pilot upload --api_key_path api_key.json --ipa "$IPA_PATH" --skip_waiting_for_build_processing true
```

Para `staging` cambia:
- `branches: [staging]`
- `FLAVOR: staging`, `SCHEME: staging`, `CONFIG: Release-staging`, `BUNDLE_ID: com.trackflow.staging`
- `IOS_PROFILE_B64: ${{ secrets.IOS_PROFILE_STAGING_B64 }}`
- Copia de plist: `ios/config/staging/GoogleService-Info-Staging.plist -> ios/Runner/GoogleService-Info-Staging.plist`

Para `production` cambia:
- `branches: [main]`
- `FLAVOR: production`, `SCHEME: production`, `CONFIG: Release-production`, `BUNDLE_ID: com.trackflow`
- `IOS_PROFILE_B64: ${{ secrets.IOS_PROFILE_PROD_B64 }}`
- Copia de plist: `ios/config/production/GoogleService-Info-Prod.plist -> ios/Runner/GoogleService-Info-Prod.plist`

### 7) Consejos de costos y performance
- Self‑hosted = $0/min en computación; recuerda apagar el runner cuando no lo uses.
- Habilita cachés (Pods, DerivedData) si el runner es efímero. En runner dedicado, la caché ya queda en disco.
- Mantén `flutter`, `cocoapods` y `fastlane` actualizados con una tarea manual ocasional.

### 8) Checklist de verificación
- [ ] App “TrackFlow Dev/Staging/Prod” existe en App Store Connect con sus bundle ids.
- [ ] Perfiles y certificado válidos, no expirados.
- [ ] Secrets creados en el repo.
- [ ] Runner self‑hosted activo y con labels correctos.
- [ ] Primer build develop/staging en TestFlight subido con éxito.

Con esto mañana podemos exportar tus certificados desde Codemagic, crear los secrets y pegar el YAML para cada flavor. Después ajustamos detalles finos (grupos de TestFlight, export options, etc.).


