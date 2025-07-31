# 🔄 GitHub Actions - Automatización Completa para TrackFlow

Esta guía te ayudará a configurar un sistema completo de CI/CD con GitHub Actions para automatizar testing, builds y deployments.

## 📋 **¿QUÉ VAMOS A AUTOMATIZAR?**

```
🧪 TESTING      →  Tests unitarios, análisis de código, coverage
🔨 BUILDING     →  APKs/IPAs automáticos para cada flavor
🚀 DEPLOYMENT   →  Subida automática a Firebase App Distribution
📱 RELEASE      →  Builds de producción para las tiendas
🔔 NOTIFICACIONES → Slack/Discord cuando algo falla o se completa
```

---

## 🏗️ **ESTRUCTURA DE WORKFLOWS**

Vamos a crear 4 workflows principales:

```
.github/workflows/
├── ci.yml                 # 🧪 Tests y validación continua
├── build-debug.yml        # 🔨 Builds de desarrollo/staging  
├── build-release.yml      # 🚀 Builds de producción
└── deploy-firebase.yml    # 📱 Distribución con Firebase
```

---

## 🧪 **WORKFLOW 1: CI.YML - TESTING Y VALIDACIÓN**

```yaml
name: 🧪 CI - Tests y Análisis

on:
  push:
    branches: [ main, develop, feature/*, fix/*, hotfix/* ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    name: 🧪 Tests Unitarios y Análisis
    runs-on: ubuntu-latest
    
    steps:
    - name: 📥 Checkout código
      uses: actions/checkout@v4
      
    - name: ☕ Setup Java 17
      uses: actions/setup-java@v4
      with:
        distribution: 'zulu'
        java-version: '17'
        
    - name: 🎯 Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.24.3'
        channel: 'stable'
        cache: true
        
    - name: 📦 Instalar dependencias
      run: flutter pub get
      
    - name: 🔧 Generar código
      run: flutter packages pub run build_runner build --delete-conflicting-outputs
      
    - name: 🔍 Análisis de código
      run: flutter analyze --fatal-infos
      
    - name: 🧪 Ejecutar tests unitarios
      run: flutter test --coverage --reporter github
```

---

## 🔨 **WORKFLOW 2: BUILD-DEBUG.YML - BUILDS DE DESARROLLO**

Para builds automáticos de development y staging cuando se hace push a ramas específicas.

---

## 🚀 **WORKFLOW 3: BUILD-RELEASE.YML - BUILDS DE PRODUCCIÓN**

Para crear releases oficiales con signing para las tiendas de aplicaciones.

---

## 📱 **WORKFLOW 4: DEPLOY-FIREBASE.YML - DISTRIBUCIÓN**

Para distribuir builds automáticamente a testers usando Firebase App Distribution.

---

## 🔐 **CONFIGURACIÓN DE SECRETS**

Para que GitHub Actions funcione, necesitas configurar estos secrets en tu repositorio:

### Ir a GitHub.com → Tu Repo → Settings → Secrets and variables → Actions

### 🔥 **Firebase Secrets:**
```
FIREBASE_SERVICE_ACCOUNT
- Contenido del archivo JSON de service account de Firebase

FIREBASE_APP_ID_DEV  
- App ID de Firebase para development

FIREBASE_APP_ID_STAGING
- App ID de Firebase para staging

FIREBASE_APP_ID_PROD
- App ID de Firebase para production
```

### 🤖 **Android Secrets:**
```
ANDROID_KEYSTORE_BASE64
- Tu keystore convertido a base64: base64 < keystore.jks

ANDROID_KEYSTORE_PASSWORD
- Password del keystore

ANDROID_KEY_PASSWORD  
- Password de la key

ANDROID_KEY_ALIAS
- Alias de la key

GOOGLE_PLAY_SERVICE_ACCOUNT
- JSON de service account de Google Play Console
```

### 🍎 **iOS Secrets:**
```
IOS_CERTIFICATE_BASE64
- Certificado de distribución convertido a base64

IOS_CERTIFICATE_PASSWORD
- Password del certificado

APPLE_ISSUER_ID
- Issuer ID de App Store Connect

APPLE_API_KEY_ID  
- Key ID de App Store Connect API

APPLE_API_PRIVATE_KEY
- Private key de App Store Connect API
```

### 🔔 **Notificaciones (Opcional):**
```
SLACK_WEBHOOK_URL
- URL del webhook de Slack para notificaciones

GMAIL_USERNAME
- Email para enviar notificaciones

GMAIL_PASSWORD
- App password de Gmail

BETA_TESTERS_EMAIL_LIST
- Lista de emails de beta testers separados por coma
```

---

## 🚀 **PASO A PASO: CONFIGURAR GITHUB ACTIONS**

### Paso 1: Crear los archivos workflow

Los workflows ya están creados en `.github/workflows/`. Solo necesitas:

```bash
git add .github/workflows/
git commit -m "feat: Add GitHub Actions workflows for CI/CD"
git push origin main
```

### Paso 2: Configurar Firebase Service Account

```bash
# 1. Ve a Firebase Console → Project Settings → Service Accounts
# 2. Click "Generate new private key"
# 3. Descarga el JSON
# 4. En GitHub: Settings → Secrets → New secret
# 5. Nombre: FIREBASE_SERVICE_ACCOUNT
# 6. Valor: Contenido completo del JSON
```

### Paso 3: Obtener Firebase App IDs

```bash
# Ve a Firebase Console → Project Settings → General → Your apps
# Copia los App IDs:

# Development: 1:664691871365:android:7ba3bcfca58beafeeca3ec
# Staging: [tu-staging-app-id]  
# Production: [tu-production-app-id]
```

### Paso 4: Configurar Android Keystore

```bash
# Si no tienes keystore, créalo:
keytool -genkey -v -keystore trackflow-release-key.keystore \
        -alias trackflow-key-alias \
        -keyalg RSA -keysize 2048 -validity 10000

# Convertir a base64 para GitHub:
base64 trackflow-release-key.keystore > keystore-base64.txt

# Agregar a GitHub Secrets:
# ANDROID_KEYSTORE_BASE64: contenido de keystore-base64.txt
# ANDROID_KEYSTORE_PASSWORD: tu password del keystore
# ANDROID_KEY_PASSWORD: tu password de la key
# ANDROID_KEY_ALIAS: trackflow-key-alias
```

### Paso 5: Probar los workflows

```bash
# Push a develop para triggear build-debug:
git checkout develop
git commit --allow-empty -m "test: Trigger GitHub Actions"
git push origin develop

# Crear tag para triggear release:
git tag v1.0.0
git push origin v1.0.0
```

---

## 🎯 **FLUJO DE TRABAJO CON GITHUB ACTIONS**

### 🔄 **Desarrollo Diario:**
```
1. 💻 Haces cambios en feature branch
2. 📤 Push → GitHub Actions ejecuta CI (tests, análisis)
3. 🔀 Creas PR → GitHub Actions valida todo  
4. ✅ Merge a develop → Build automático de staging
5. 📱 Firebase App Distribution notifica a testers
```

### 🚀 **Release de Producción:**
```
1. 🏷️ Creas tag v1.0.0
2. 🤖 GitHub Actions:
   - Ejecuta todos los tests
   - Build de Android (.aab)
   - Build de iOS (.ipa)  
   - Crea GitHub Release
   - [Opcional] Sube a las tiendas
3. 🎉 Release listo para publicar
```

### 📱 **Testing con Beta Testers:**
```
1. 🎯 Manual trigger de deploy-firebase.yml
2. 📱 Seleccionas flavor (staging/development)
3. 👥 Seleccionas grupo de testers
4. 🚀 GitHub Actions distribuye automáticamente
5. 🔔 Testers reciben notificación
```

---

## 🔧 **PERSONALIZACIÓN AVANZADA**

### Agregar más flavors:
```yaml
strategy:
  matrix:
    flavor: [development, staging, production, demo]
```

### Builds solo para cambios específicos:
```yaml
on:
  push:
    paths:
    - 'lib/**'
    - 'android/**'
    - 'pubspec.yaml'
```

### Tests en múltiples versiones de Flutter:
```yaml
strategy:
  matrix:
    flutter-version: ['3.24.3', '3.27.0']
```

### Builds paralelos para diferentes arquitecturas:
```yaml
strategy:
  matrix:
    arch: [arm64-v8a, armeabi-v7a, x86_64]
```

---

## 📊 **MONITOREO Y MÉTRICAS**

### Ver status de workflows:
- 🔗 GitHub.com → Tu repo → Actions
- 📊 Ve estadísticas de success/failure
- 🔍 Analiza logs detallados de cada step

### Configurar badges en README:
```markdown
![CI](https://github.com/tu-usuario/trackflow/workflows/🧪%20CI%20-%20Tests%20y%20Análisis/badge.svg)
![Build](https://github.com/tu-usuario/trackflow/workflows/🔨%20Build%20Debug%20APKs/badge.svg)
```

### Métricas útiles:
- ⏱️ Tiempo promedio de build
- ✅ Porcentaje de éxito de tests
- 📦 Tamaño de APKs/IPAs por versión
- 🐛 Análisis de código (issues detectados)

---

## 🚨 **SOLUCIÓN DE PROBLEMAS COMUNES**

### ❌ "Flutter not found"
```yaml
- name: 🎯 Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.24.3'  # Especifica versión exacta
    channel: 'stable'
    cache: true
```

### ❌ "Android SDK not found"
```yaml
- name: ☕ Setup Java 17
  uses: actions/setup-java@v4
  with:
    distribution: 'zulu'
    java-version: '17'        # Java 17 es requerido
```

### ❌ "Keystore not found"
- Verifica que `ANDROID_KEYSTORE_BASE64` sea correcto
- Asegúrate de que `key.properties` se cree antes del build

### ❌ "Firebase token invalid"
- Regenera el service account JSON en Firebase Console
- Verifica que tenga permisos de Firebase App Distribution

### ❌ "iOS build fails"
- Verifica certificados en Apple Developer Account
- Asegúrate de que provisioning profiles estén actualizados

---

## 🎉 **BENEFICIOS DE ESTA CONFIGURACIÓN**

### ✅ **Automatización Completa:**
- 🧪 Tests automáticos en cada PR
- 🔨 Builds automáticos por flavor
- 📱 Distribución automática a testers
- 🚀 Releases automáticos con tagging

### ✅ **Calidad de Código:**
- 🔍 Análisis estático automático
- 📊 Coverage de tests
- 🔒 Security scanning
- 📏 Métricas de tamaño de builds

### ✅ **Eficiencia del Equipo:**
- ⚡ Feedback rápido en PRs
- 🔔 Notificaciones automáticas
- 📦 Artefactos organizados
- 🎯 Deploy simplificado

### ✅ **Preparación para Producción:**
- 🏪 Ready para tiendas de aplicaciones
- 🔐 Signing automático
- 🏷️ Versionado automático
- 📝 Release notes automáticos

---

## 📚 **RECURSOS ADICIONALES**

### Documentación útil:
- 📘 [GitHub Actions para Flutter](https://docs.github.com/en/actions)
- 🔥 [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- 🤖 [Google Play Publishing API](https://developers.google.com/android-publisher)
- 🍎 [App Store Connect API](https://developer.apple.com/app-store-connect/api/)

### Actions útiles adicionales:
- 🧪 [Flutter Action](https://github.com/subosito/flutter-action)
- 🔥 [Firebase Distribution Action](https://github.com/wzieba/Firebase-Distribution-Github-Action)
- 🍎 [iOS Actions](https://github.com/apple-actions)
- 📊 [Codecov Action](https://github.com/codecov/codecov-action)

---

## 🎯 **CHECKLIST DE CONFIGURACIÓN**

### Workflows:
- [ ] ✅ ci.yml creado y funcionando
- [ ] ✅ build-debug.yml creado y funcionando
- [ ] ✅ build-release.yml creado y funcionando  
- [ ] ✅ deploy-firebase.yml creado y funcionando

### Secrets configurados:
- [ ] ✅ FIREBASE_SERVICE_ACCOUNT
- [ ] ✅ FIREBASE_APP_ID_DEV
- [ ] ✅ FIREBASE_APP_ID_STAGING
- [ ] ✅ ANDROID_KEYSTORE_BASE64
- [ ] ✅ ANDROID_KEYSTORE_PASSWORD
- [ ] ✅ ANDROID_KEY_PASSWORD
- [ ] ✅ ANDROID_KEY_ALIAS

### Pruebas:
- [ ] ✅ Push a feature branch ejecuta CI
- [ ] ✅ PR ejecuta tests y validaciones
- [ ] ✅ Push a develop ejecuta build debug
- [ ] ✅ Tag ejecuta build release
- [ ] ✅ Manual trigger de deploy funciona

### Notificaciones:
- [ ] ✅ Slack webhook configurado
- [ ] ✅ Testers reciben notificaciones
- [ ] ✅ Team es notificado de fallos

## 🎉 **¡FELICIDADES!**

Con esta configuración tienes un sistema completo de CI/CD que te permitirá:
- 🚀 Desarrollar más rápido y con confianza
- 🔍 Detectar problemas temprano
- 📱 Distribuir versiones automáticamente
- 🏪 Estar listo para lanzar a producción

¡Tu flujo de desarrollo ahora es completamente profesional! 🎵✨