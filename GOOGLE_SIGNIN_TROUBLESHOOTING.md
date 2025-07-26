# 🔧 Google Sign-In Troubleshooting Guide

## 🚨 **Error: "Something went wrong, please go back and try again"**

Este error es muy común en emuladores Android cuando se usa Google Sign-In. Aquí están todas las soluciones implementadas:

## ✅ **Soluciones Implementadas**

### **1. Configuración Mejorada del GoogleAuthService**

**Archivo:** `lib/features/auth/data/services/google_auth_service.dart`

**Cambios realizados:**

- ✅ Configuración específica para emuladores con Web Client ID
- ✅ Logging detallado para debugging
- ✅ Manejo específico de errores comunes
- ✅ Mejor manejo de excepciones

```dart
// Configuración específica para emuladores
final googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  clientId: '411076004525-6sfjv4mkbab89b81jn3so4o6s8om46sa.apps.googleusercontent.com', // Web client ID
);
```

### **2. AndroidManifest.xml Actualizado**

**Archivo:** `android/app/src/main/AndroidManifest.xml`

**Cambios realizados:**

- ✅ Permisos adicionales para Google Sign-In
- ✅ Configuración de cleartext traffic para emuladores
- ✅ Meta-data para Google Play Services

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<application android:usesCleartextTraffic="true">
  <meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
</application>
```

### **3. AndroidManifest.xml de Debug**

**Archivo:** `android/app/src/debug/AndroidManifest.xml`

**Cambios realizados:**

- ✅ Configuraciones específicas para debug
- ✅ Permisos adicionales para emuladores

### **4. Script de Limpieza Automática**

**Archivo:** `scripts/fix_google_signin.sh`

**Funcionalidades:**

- ✅ Limpia datos de la app
- ✅ Desinstala la app
- ✅ Limpia caché de Google Play Services
- ✅ Reconstruye e instala la app

## 🔍 **Diagnóstico del Problema**

### **Verificar SHA-1 del Emulador:**

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**SHA-1 del debug keystore:** `E5:43:24:6C:31:F0:79:BC:18:F3:B5:93:17:4E:69:D5:AC:08:59:47`

**✅ Confirmado:** Este SHA-1 está configurado en `google-services.json`

### **Verificar Google Play Services:**

```bash
~/Library/Android/sdk/platform-tools/adb shell pm list packages | grep "com.google.android.gms"
```

**✅ Confirmado:** Google Play Services está instalado

## 🛠️ **Pasos para Solucionar el Error**

### **Paso 1: Ejecutar el Script de Limpieza**

```bash
./scripts/fix_google_signin.sh
```

### **Paso 2: Verificar Configuración de Firebase**

1. **Ir a Firebase Console**
2. **Seleccionar tu proyecto:** `track-flow-8e1c0`
3. **Authentication > Sign-in method**
4. **Verificar que Google esté habilitado**
5. **Verificar que el SHA-1 esté configurado**

### **Paso 3: Verificar Configuración del Emulador**

1. **Abrir Google Play Store en el emulador**
2. **Actualizar Google Play Services**
3. **Actualizar Google Services Framework**
4. **Reiniciar el emulador**

### **Paso 4: Verificar Internet**

1. **Abrir navegador en el emulador**
2. **Verificar que puedas acceder a google.com**
3. **Verificar que no haya restricciones de red**

## 🎯 **Causas Comunes del Error**

### **1. SHA-1 No Configurado**

- **Síntoma:** Error inmediato al intentar sign in
- **Solución:** Agregar SHA-1 del debug keystore en Firebase Console

### **2. Google Play Services Desactualizado**

- **Síntoma:** Error después de seleccionar cuenta
- **Solución:** Actualizar Google Play Services en el emulador

### **3. Problemas de Red**

- **Síntoma:** Error de timeout
- **Solución:** Verificar conexión a internet del emulador

### **4. Configuración de Firebase Incorrecta**

- **Síntoma:** Error de developer_error
- **Solución:** Verificar configuración en Firebase Console

### **5. Caché Corrupto**

- **Síntoma:** Error persistente después de intentos
- **Solución:** Limpiar caché de Google Play Services

## 🔧 **Soluciones Adicionales**

### **Solución 1: Usar Emulador con Google Play**

```bash
# Crear emulador con Google Play Services
avdmanager create avd -n "Pixel_API_34_GooglePlay" -k "system-images;android-34;google_apis;x86_64"
```

### **Solución 2: Configurar Proxy (si es necesario)**

```bash
# Configurar proxy en el emulador
~/Library/Android/sdk/platform-tools/adb shell settings put global http_proxy host:port
```

### **Solución 3: Usar Dispositivo Físico**

- Los dispositivos físicos suelen tener menos problemas con Google Sign-In
- Google Play Services está pre-instalado y actualizado

### **Solución 4: Verificar Configuración de Red**

```bash
# Verificar conectividad del emulador
~/Library/Android/sdk/platform-tools/adb shell ping google.com
```

## 📊 **Logs para Debugging**

### **Habilitar Logs Detallados:**

```dart
// En GoogleAuthService
AppLogger.info('Starting Google authentication process', tag: 'GOOGLE_AUTH_SERVICE');
AppLogger.info('Google account selected: ${googleUser.email}', tag: 'GOOGLE_AUTH_SERVICE');
AppLogger.error('Google authentication failed: $e', tag: 'GOOGLE_AUTH_SERVICE', error: e);
```

### **Ver Logs en Tiempo Real:**

```bash
flutter logs
```

## 🎯 **Verificación de la Solución**

### **Pasos para Verificar:**

1. **Ejecutar el script de limpieza**
2. **Reiniciar el emulador**
3. **Intentar Google Sign-In**
4. **Verificar logs en consola**
5. **Confirmar que funciona**

### **Indicadores de Éxito:**

- ✅ No aparece el error "Something went wrong"
- ✅ Se abre el diálogo de selección de cuenta de Google
- ✅ Se completa la autenticación exitosamente
- ✅ Se redirige al onboarding o dashboard

## 🚀 **Próximos Pasos**

Si el problema persiste después de aplicar todas las soluciones:

1. **Verificar logs detallados** en la consola
2. **Probar en un dispositivo físico** para confirmar que la configuración funciona
3. **Verificar configuración de Firebase** en la consola web
4. **Contactar soporte** con los logs detallados

## 📝 **Notas Importantes**

- **SHA-1 del debug keystore:** `E5:43:24:6C:31:F0:79:BC:18:F3:B5:93:17:4E:69:D5:AC:08:59:47`
- **Package name:** `com.example.trackflow`
- **Web Client ID:** `411076004525-6sfjv4mkbab89b81jn3so4o6s8om46sa.apps.googleusercontent.com`
- **Android Client ID:** `411076004525-af3r31s3o9rlm5hkja66eho0tn4eiobd.apps.googleusercontent.com`

## 🎉 **Resultado Esperado**

Después de aplicar todas las soluciones, el Google Sign-In debería funcionar correctamente en el emulador, permitiendo:

- ✅ Selección de cuenta de Google
- ✅ Autenticación exitosa
- ✅ Extracción de datos de Google (nombre, email, foto)
- ✅ Pre-llenado en el onboarding
- ✅ Flujo completo de sign up/sign in
