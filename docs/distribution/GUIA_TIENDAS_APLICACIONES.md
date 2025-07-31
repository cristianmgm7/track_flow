# 🚀 Guía Completa para Lanzar TrackFlow en las Tiendas

Esta guía te llevará paso a paso desde tener tu app funcionando hasta publicarla en Google Play Store y App Store.

## 📋 **PREREQUISITOS**

✅ Ya tienes configurado:
- 3 flavors funcionando (development, staging, production)
- Firebase configurado para todos los ambientes
- App corriendo sin errores en emulador/dispositivo

## 🎯 **PROCESO COMPLETO DE LANZAMIENTO**

```
DESARROLLO → TESTING → SIGNING → STORES → PUBLICACIÓN
     ↓           ↓         ↓         ↓         ↓
   [Listo]   [Paso 1]  [Paso 2]  [Paso 3]  [Paso 4]
```

---

## 📱 **PASO 1: PREPARACIÓN PARA RELEASE**

### 1.1: Configurar App Icons y Splash Screen

```bash
# Instalar herramientas para iconos
flutter pub add flutter_launcher_icons --dev
flutter pub add flutter_native_splash --dev
```

#### Crear flutter_launcher_icons.yaml:
```yaml
flutter_launcher_icons:
  android: "ic_launcher"
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21
  
  # Iconos por flavor
  android_flavor:
    development:
      image_path: "assets/icon/app_icon_dev.png"
    staging:
      image_path: "assets/icon/app_icon_staging.png"
    production:
      image_path: "assets/icon/app_icon.png"
```

#### Crear flutter_native_splash.yaml:
```yaml
flutter_native_splash:
  color: "#1a1a1a"
  image: assets/splash/splash_logo.png
  branding: assets/splash/flutter_logo.png
  color_dark: "#1a1a1a"
  image_dark: assets/splash/splash_logo.png
  
  android_12:
    image: assets/splash/splash_logo.png
    icon_background_color: "#1a1a1a"
```

### 1.2: Generar iconos
```bash
flutter pub get
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

### 1.3: Configurar App Metadata

#### android/app/src/main/AndroidManifest.xml:
```xml
<application
    android:label="@string/app_name"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
    
    <!-- Permisos necesarios para audio -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
</application>
```

### 1.4: Actualizar pubspec.yaml con información de release:
```yaml
name: trackflow
description: Professional audio collaboration platform for music creators
publish_to: 'none'
version: 1.0.0+1

flutter:
  assets:
    - assets/icon/
    - assets/splash/
```

---

## 🔐 **PASO 2: SIGNING Y CERTIFICADOS**

### 2.1: Android Signing (Google Play)

#### Crear keystore de producción:
```bash
cd android/app

# Generar keystore (GUARDA BIEN ESTA PASSWORD!)
keytool -genkey -v -keystore ../keystore/trackflow-release-key.keystore \
        -alias trackflow-key-alias \
        -keyalg RSA -keysize 2048 -validity 10000

# Crear directorio si no existe
mkdir -p ../keystore
```

#### Crear android/key.properties:
```properties
storePassword=TU_STORE_PASSWORD
keyPassword=TU_KEY_PASSWORD  
keyAlias=trackflow-key-alias
storeFile=../keystore/trackflow-release-key.keystore
```

#### Actualizar android/app/build.gradle.kts:
```kotlin
// Cargar signing properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... configuración existente ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 2.2: iOS Signing (App Store)

```bash
# 1. Necesitas pagar Apple Developer Program ($99/año)
# 2. Configurar en Xcode:
open ios/Runner.xcworkspace

# En Xcode:
# - Signing & Capabilities
# - Team: Selecciona tu Apple Developer Team
# - Bundle Identifier: com.trackflow (para production)
```

---

## 🏪 **PASO 3: CONFIGURACIÓN DE TIENDAS**

### 3.1: Google Play Console

#### Crear cuenta y app:
```
1. 📝 Ve a: https://play.google.com/console
2. 💳 Pagar $25 (una sola vez, de por vida)
3. ➕ Crear nueva aplicación
4. 📱 Nombre: "TrackFlow"
5. 🗣️ Idioma: Español
6. 📱 Tipo: Aplicación
7. 🆓 Gratis o de pago: Gratis (por ahora)
```

#### Información de la app:
```
📱 Título corto: TrackFlow
📝 Descripción corta: "Plataforma de colaboración musical profesional"

📝 Descripción completa:
"TrackFlow es la plataforma definitiva para colaboración musical. 
Permite a productores, músicos y ingenieros de audio trabajar 
juntos de forma remota con comentarios precisos, gestión de 
versiones y flujos de trabajo profesionales."

🏷️ Categoría: Música y audio
🏷️ Etiquetas: música, audio, colaboración, producción musical
```

#### Assets requeridos:
```
📱 Icono: 512x512 PNG
📸 Screenshots: 
   - Teléfono: 16:9 (1920x1080) - mínimo 2, máximo 8
   - Tablet: 16:10 (1920x1200) - opcional
🎬 Video promocional: YouTube link (opcional pero recomendado)
🖼️ Gráfico promocional: 1024x500 PNG
🎨 Banner de función: 1024x500 PNG (opcional)
```

### 3.2: App Store Connect (iOS)

#### Crear cuenta y app:
```
1. 📝 Ve a: https://appstoreconnect.apple.com
2. 💳 Apple Developer Program: $99/año
3. ➕ Nueva App
4. 📱 Plataforma: iOS
5. 🆔 Bundle ID: com.trackflow
6. 📱 Nombre: TrackFlow
7. 🔤 SKU: trackflow-ios-2024
```

#### Información de la app:
```
📱 Nombre: TrackFlow
📝 Subtítulo: "Colaboración Musical Profesional"
🏷️ Categoría primaria: Música
🏷️ Categoría secundaria: Productividad

📝 Descripción:
"TrackFlow revoluciona la colaboración musical. Trabaja con tu 
equipo desde cualquier lugar, comparte pistas de audio, recibe 
comentarios precisos y gestiona versiones como un profesional."

🔍 Palabras clave: música,audio,colaboración,producción,estudio,músicos,productores
```

#### Assets requeridos:
```
📱 Icono: 1024x1024 PNG
📸 Screenshots iPhone: 
   - 6.7": 1290x2796
   - 6.5": 1242x2688  
   - 5.5": 1242x2208
📸 Screenshots iPad: 2048x2732
🎬 Video preview: 30 segundos máximo
```

---

## 🔨 **PASO 4: BUILD DE RELEASE**

### 4.1: Android Release Build

```bash
# Build para Google Play Store
./scripts/build_release.sh production android

# O manualmente:
flutter build appbundle --flavor production --release
```

Esto genera: `build/app/outputs/bundle/productionRelease/app-production-release.aab`

### 4.2: iOS Release Build

```bash
# Build para App Store
./scripts/build_release.sh production ios

# O manualmente:
flutter build ipa --flavor production --release
```

### 4.3: Crear scripts/build_release.sh:
```bash
#!/bin/bash

FLAVOR=$1
PLATFORM=$2

if [ -z "$FLAVOR" ] || [ -z "$PLATFORM" ]; then
    echo "❌ Usage: ./build_release.sh <flavor> <platform>"
    echo "   Flavors: development, staging, production"
    echo "   Platforms: android, ios"
    exit 1
fi

echo "🚀 Building TrackFlow Release"
echo "   Flavor: $FLAVOR"
echo "   Platform: $PLATFORM"

# Limpiar build anterior
flutter clean
flutter pub get

# Generar código si es necesario
flutter packages pub run build_runner build --delete-conflicting-outputs

if [ "$PLATFORM" = "android" ]; then
    echo "📱 Building Android App Bundle..."
    flutter build appbundle --flavor $FLAVOR --release
    
    echo "✅ Android build completed!"
    echo "📁 Location: build/app/outputs/bundle/${FLAVOR}Release/"
    
elif [ "$PLATFORM" = "ios" ]; then
    echo "🍎 Building iOS Archive..."
    flutter build ipa --flavor $FLAVOR --release
    
    echo "✅ iOS build completed!"
    echo "📁 Location: build/ios/ipa/"
else
    echo "❌ Unsupported platform: $PLATFORM"
    exit 1
fi

echo "🎉 Release build completed successfully!"
```

---

## 📤 **PASO 5: SUBIR A LAS TIENDAS**

### 5.1: Subir a Google Play

```bash
# 1. Ve a Google Play Console
# 2. Tu app → Release → Production
# 3. Crear nueva release
# 4. Subir el archivo .aab
# 5. Completar información de release:

Release notes (en español):
v1.0.0
• Lanzamiento inicial de TrackFlow
• Colaboración en tiempo real para proyectos musicales  
• Gestión profesional de versiones de audio
• Comentarios precisos en pistas de audio
• Integración con Google Drive para almacenamiento
```

### 5.2: Subir a App Store

```bash
# 1. Usar Xcode o Application Loader
# 2. Subir el archivo .ipa
# 3. Esperar procesamiento (puede tomar 1-2 horas)
# 4. En App Store Connect:
#    - Seleccionar build
#    - Completar información
#    - Enviar para revisión

Release notes (en español):
v1.0.0
• ¡Presentamos TrackFlow!
• Colabora musicalmente desde cualquier lugar
• Comentarios precisos en audio con timestamps
• Gestión profesional de proyectos musicales
• Sincronización automática entre dispositivos
```

---

## 🧪 **PASO 6: TESTING ANTES DE LANZAR**

### 6.1: Testing Interno (Google Play)

```bash
# 1. Google Play Console → Testing → Internal testing
# 2. Crear nueva release con mismo .aab
# 3. Agregar testers (emails)
# 4. Compartir link de testing
```

### 6.2: TestFlight (iOS)

```bash
# 1. App Store Connect → TestFlight
# 2. Automáticamente disponible después de subir build
# 3. Agregar testers externos
# 4. Enviar invitaciones
```

### 6.3: Checklist de Testing:

```
□ App inicia correctamente
□ Login con Google funciona
□ Crear proyecto funciona
□ Subir audio funciona
□ Reproducir audio funciona
□ Comentarios en audio funcionan
□ Notificaciones funcionan
□ Sync entre dispositivos funciona
□ Logout funciona
□ App no crashea en casos edge
```

---

## 🎯 **PASO 7: LANZAMIENTO**

### 7.1: Timeline típico:

```
📅 Google Play Store: 
   - Review: 1-3 días
   - Disponible inmediatamente después de aprobación

📅 App Store:
   - Review: 1-7 días
   - Disponible inmediatamente después de aprobación
```

### 7.2: Post-lanzamiento:

```bash
# Monitorear métricas:
1. 📊 Descargas e instalaciones
2. ⭐ Ratings y reviews  
3. 💥 Crashes (Firebase Crashlytics)
4. 📈 Retención de usuarios
5. 💬 Feedback de usuarios
```

---

## 🚨 **SOLUCIÓN DE PROBLEMAS COMUNES**

### Android:
```
❌ "App Bundle error"
✅ Verificar signing configuration

❌ "Missing permissions"  
✅ Revisar AndroidManifest.xml

❌ "API level too low"
✅ Actualizar minSdkVersion en build.gradle
```

### iOS:
```
❌ "Missing provisioning profile"
✅ Configurar en Xcode Signing & Capabilities

❌ "Invalid bundle identifier"
✅ Verificar que coincida con App Store Connect

❌ "Missing icon sizes"
✅ Usar flutter_launcher_icons para generar todos los tamaños
```

---

## 🔄 **ACTUALIZACIONES FUTURAS**

### Para versiones posteriores:

```bash
# 1. Actualizar version en pubspec.yaml
version: 1.1.0+2

# 2. Build nueva release
./scripts/build_release.sh production android
./scripts/build_release.sh production ios

# 3. Subir a tiendas con release notes actualizados
```

---

## 📝 **CHECKLIST COMPLETO DE LANZAMIENTO**

### Preparación:
- [ ] ✅ Iconos generados para todos los tamaños
- [ ] ✅ Splash screen configurado
- [ ] ✅ App metadata actualizado
- [ ] ✅ Permisos correctos configurados

### Signing:
- [ ] ✅ Keystore de Android creado y configurado
- [ ] ✅ iOS signing configurado en Xcode
- [ ] ✅ key.properties protegido (no en git)

### Tiendas:
- [ ] ✅ Google Play Console configurado
- [ ] ✅ App Store Connect configurado  
- [ ] ✅ Screenshots y assets subidos
- [ ] ✅ Descripciones completadas

### Builds:
- [ ] ✅ Android release build exitoso
- [ ] ✅ iOS release build exitoso
- [ ] ✅ Testing interno completado

### Lanzamiento:
- [ ] ✅ Subido a Google Play
- [ ] ✅ Subido a App Store
- [ ] ✅ Release notes escritos
- [ ] ✅ Apps enviadas para revisión

## 🎉 **¡FELICIDADES!**

Una vez completados todos estos pasos, ¡TrackFlow estará disponible para el mundo! 🌍

---

**💡 Consejos finales:**
- 📱 Manten siempre backups de tus keystores/certificados
- 📊 Configura Firebase Analytics para métricas
- 🐛 Usa Firebase Crashlytics para detectar errores
- 📝 Escucha feedback de usuarios para mejoras futuras