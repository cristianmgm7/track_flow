# ⚡ TrackFlow - Comandos Rápidos

Los comandos que usas día a día para desarrollar TrackFlow de manera eficiente.

---

## 🚀 **COMANDOS DE DESARROLLO DIARIO**

### **Iniciar la App:**
```bash
# Development (tu entorno de desarrollo)
./scripts/run_flavors.sh development debug

# Staging (para probar con datos de staging)  
./scripts/run_flavors.sh staging debug

# Production (solo para verificar que compila)
./scripts/run_flavors.sh production debug
```

### **Comandos de Configuración Inicial:**
```bash
# Instalar dependencias
flutter pub get

# Generar código (después de cambios en entidades/DTOs)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Limpiar builds anteriores (cuando algo falla)
flutter clean && flutter pub get
```

---

## 🧪 **COMANDOS DE TESTING**

### **Tests Unitarios:**
```bash
# Todos los tests
flutter test

# Tests con coverage
flutter test --coverage

# Test específico
flutter test test/features/auth/domain/usecases/login_usecase_test.dart

# Tests de integración
flutter test integration_test/
```

### **Análisis de Código:**
```bash
# Análisis completo
flutter analyze

# Análisis con errores fatales
flutter analyze --fatal-infos

# Formatear código
dart format lib/ test/
```

---

## 🔨 **COMANDOS DE BUILD**

### **Builds Locales (para testing):**
```bash
# APK Debug por flavor
flutter build apk --flavor development --debug
flutter build apk --flavor staging --debug  
flutter build apk --flavor production --debug

# APK Release (firmado)
flutter build apk --flavor production --release
```

### **Builds para Tiendas:**
```bash
# Android App Bundle (Google Play Store)
flutter build appbundle --flavor production --release

# iOS Archive (App Store)
flutter build ipa --flavor production --release
```

### **Scripts Personalizados:**
```bash
# Build Release automático
./scripts/build_release.sh production android
./scripts/build_release.sh production ios

# Build por flavor
./scripts/build_flavors.sh staging release
```

---

## 🔥 **COMANDOS DE FIREBASE**

### **Testing de Configuración:**
```bash
# Verificar que Firebase esté bien configurado
flutter run --flavor development -d android
# Debe ver: "✅ Firebase initialized successfully for development"

flutter run --flavor staging -d android  
# Debe ver: "✅ Firebase initialized successfully for staging"
```

### **Debugging Firebase:**
```bash
# Ver logs detallados de Firebase
flutter run --flavor development --verbose

# Limpiar cache de Firebase
flutter clean
rm -rf ~/.gradle/caches/
flutter pub get
```

---

## 🎯 **COMANDOS DE FLAVORS**

### **Verificar Flavor Actual:**
```bash
# La app debe mostrar en logs:
# 🎯 Current Flavor: development/staging/production
```

### **Cambiar Entre Flavors:**
```bash
# Parar app actual (Ctrl+C)
# Ejecutar nuevo flavor:
./scripts/run_flavors.sh [FLAVOR] debug

# Donde [FLAVOR] es: development | staging | production
```

### **Verificar Configuración de Flavors:**
```bash
# Ver package names configurados
grep -r "applicationId" android/app/build.gradle.kts

# Ver Firebase project IDs
grep -r "projectId" lib/firebase_options_*.dart
```

---

## 🤖 **COMANDOS DE GITHUB ACTIONS**

### **Verificar Status de Workflows:**
```bash
# Ver último status en terminal
gh run list

# Ver detalles de un run específico  
gh run view [RUN_ID]

# Ver logs de un workflow
gh run view [RUN_ID] --log
```

### **Trigger Manual de Workflows:**
```bash
# Trigger build debug manualmente
gh workflow run "🔨 Build Debug APKs" -f flavor=staging

# Trigger deploy a Firebase
gh workflow run "📱 Deploy Firebase App Distribution" -f flavor=staging
```

### **Tags para Release:**
```bash
# Crear tag para release automático
git tag v1.0.0
git push origin v1.0.0

# Ver tags existentes
git tag -l

# Eliminar tag (si cometiste error)
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
```

---

## 🛠️ **COMANDOS DE DEBUGGING**

### **Problemas Comunes:**

#### **"No matching client found for package name"**
```bash
# Verificar que package names coincidan con Firebase
grep "applicationId" android/app/build.gradle.kts
# Debe coincidir con tu configuración en Firebase Console
```

#### **"BuildConfig fields not found"**
```bash
# Verificar que buildFeatures esté habilitado
grep -A5 "buildFeatures" android/app/build.gradle.kts
# Debe tener: buildConfig = true
```

#### **"Firebase initialization failed"**
```bash
# Verificar archivos de configuración
ls -la android/app/src/*/google-services.json
ls -la lib/firebase_options_*.dart

# Regenerar código
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### **"Gradle build failed"**
```bash
# Limpiar Gradle cache  
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

---

## 📱 **COMANDOS DE DISPOSITIVOS**

### **Listar Dispositivos:**
```bash
# Ver dispositivos conectados
flutter devices

# Emuladores disponibles
flutter emulators

# Ejecutar emulador específico
flutter emulators --launch Pixel_8a
```

### **Instalar APK Manualmente:**
```bash
# Después de build, instalar en dispositivo
adb install build/app/outputs/flutter-apk/app-staging-debug.apk

# Desinstalar versión anterior
adb uninstall com.trackflow.staging

# Ver logs del dispositivo
adb logcat | grep flutter
```

---

## 🔍 **COMANDOS DE MONITOREO**

### **Performance:**
```bash
# Ejecutar con profiling
flutter run --profile --flavor staging

# Análizar tamaño de APK
flutter build apk --analyze-size --flavor production --release
```

### **Logs en Vivo:**
```bash
# Seguir logs en tiempo real
flutter logs

# Logs específicos de Firebase
flutter logs | grep -i firebase

# Logs específicos de errores
flutter logs | grep -i error
```

---

## 🚀 **FLUJOS DE TRABAJO RÁPIDOS**

### **Desarrollo de Nueva Feature:**
```bash
# 1. Crear branch
git checkout -b feature/mi-nueva-feature

# 2. Desarrollar con hot reload
./scripts/run_flavors.sh development debug

# 3. Tests mientras desarrollas
flutter test test/features/mi_feature/

# 4. Push para CI
git add . && git commit -m "feat: nueva funcionalidad"
git push origin feature/mi-nueva-feature
```

### **Fix Rápido de Bug:**
```bash
# 1. Reproducir en staging
./scripts/run_flavors.sh staging debug

# 2. Fix y test
flutter test

# 3. Verificar en development
./scripts/run_flavors.sh development debug

# 4. Deploy para testers
git push origin develop  # Trigger automático de build-debug.yml
```

### **Preparar Release:**
```bash
# 1. Merge todo a main
git checkout main
git merge develop

# 2. Crear tag
git tag v1.0.0

# 3. Push para trigger automático
git push origin main --tags
# GitHub Actions automáticamente:
# - Ejecuta tests
# - Genera builds para tiendas
# - Crea GitHub Release
```

---

## 📋 **CHECKLISTS RÁPIDOS**

### **Antes de Hacer PR:**
```bash
□ flutter analyze  # Sin errores
□ flutter test     # Todos pasan  
□ Build funciona   # Al menos development
□ Commits limpios  # Mensajes descriptivos
```

### **Antes de Release:**
```bash
□ Tests pasan en todos los flavors
□ Firebase configurado correctamente
□ App funciona offline
□ Logs deshabilitados en production
□ Version number actualizada en pubspec.yaml
```

### **Después de Deploy:**
```bash
□ Verificar que testers recibieron notificación
□ Probar descarga desde Firebase App Distribution  
□ Verificar que funciona en dispositivos reales
□ Monitorear crashes en Firebase Crashlytics
```

---

## 🆘 **COMANDOS DE EMERGENCIA**

### **"¡Mi build está roto!"**
```bash
# Reset completo
flutter clean
rm -rf build/
rm pubspec.lock
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### **"¡GitHub Actions falló!"**
```bash
# Ver logs del error
gh run view --log

# Re-ejecutar workflow
gh run rerun [RUN_ID]

# Verificar secrets configurados
gh secret list
```

### **"¡Firebase no conecta!"**
```bash
# Verificar configuración
cat lib/firebase_options_development.dart | grep projectId
cat android/app/src/development/google-services.json | grep project_id

# Debe coincidir con tu proyecto en Firebase Console
```

---

## 💡 **TIPS DE PRODUCTIVIDAD**

### **Aliases Útiles (opcional):**
```bash
# Agregar a tu ~/.bashrc o ~/.zshrc:
alias tf-dev="./scripts/run_flavors.sh development debug"
alias tf-staging="./scripts/run_flavors.sh staging debug"  
alias tf-test="flutter test"
alias tf-analyze="flutter analyze"
alias tf-clean="flutter clean && flutter pub get"
alias tf-build="flutter packages pub run build_runner build --delete-conflicting-outputs"
```

### **Workflow Óptimo:**
1. 🌅 **Mañana:** `tf-dev` + desarrollo con hot reload
2. 🔄 **Durante el día:** `tf-test` frecuentemente  
3. 🌆 **Antes de push:** `tf-analyze` + `tf-test`
4. 📱 **Deploy:** Push a develop para distribución automática

---

**⚡ Con estos comandos puedes desarrollar TrackFlow de manera súper eficiente. ¡Guarda este archivo como referencia rápida!**