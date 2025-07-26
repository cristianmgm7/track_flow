# 🌐 Emulator Network Connectivity Fix Guide

## 🚨 **Problema: "Something went wrong" en Google Sign-In en Emuladores**

El problema principal es que **el emulador no tiene conectividad de red completa** para acceder a los servicios de Google, aunque Flutter sí pueda hacer algunas conexiones.

## ✅ **Soluciones Implementadas**

### **1. Script de Limpieza de Red**

**Archivo:** `scripts/fix_emulator_network.sh`

**Funcionalidades:**

- ✅ Limpia caché de Google Play Services
- ✅ Limpia caché de Google Services Framework
- ✅ Limpia caché de Google Play Store
- ✅ Resetea configuraciones de red
- ✅ Limpia caché DNS
- ✅ Reinicia Google Play Services

### **2. GoogleAuthService Mejorado**

**Archivo:** `lib/features/auth/data/services/google_auth_service.dart`

**Cambios:**

- ✅ Usa `serverClientId` en lugar de `clientId`
- ✅ Manejo específico de errores de red
- ✅ Logging detallado para debugging

## 🛠️ **Pasos para Solucionar el Problema**

### **Paso 1: Ejecutar el Script de Red**

```bash
./scripts/fix_emulator_network.sh
```

### **Paso 2: Verificar Conectividad**

```bash
# Verificar ping a Google
~/Library/Android/sdk/platform-tools/adb shell ping -c 3 google.com

# Verificar Google Play Services
~/Library/Android/sdk/platform-tools/adb shell pm list packages | grep "com.google.android.gms"
```

### **Paso 3: Actualizar Google Play Services**

1. **Abrir Google Play Store** en el emulador
2. **Buscar "Google Play Services"**
3. **Actualizar si hay una versión disponible**

### **Paso 4: Probar Google Sign-In**

1. **Abrir la app**
2. **Intentar "Continue with Google"**
3. **Verificar logs en consola**

## 🔧 **Soluciones Alternativas**

### **Solución A: Crear Nuevo Emulador con Google Play Services**

**Desde Android Studio:**

1. **Abrir Android Studio**
2. **Tools > AVD Manager**
3. **Create Virtual Device**
4. **Seleccionar dispositivo (ej: Pixel 7a)**
5. **Seleccionar imagen con Google Play Services**
6. **Finalizar creación**

### **Solución B: Usar Dispositivo Físico**

- Los dispositivos físicos suelen tener menos problemas
- Google Play Services está pre-instalado y actualizado
- Conectividad de red más estable

### **Solución C: Configurar Proxy (si es necesario)**

```bash
# Configurar proxy en el emulador
~/Library/Android/sdk/platform-tools/adb shell settings put global http_proxy host:port

# Limpiar proxy
~/Library/Android/sdk/platform-tools/adb shell settings put global http_proxy :0
```

## 📊 **Diagnóstico del Problema**

### **Verificar Estado Actual:**

```bash
# 1. Verificar conectividad
~/Library/Android/sdk/platform-tools/adb shell ping -c 3 google.com

# 2. Verificar Google Play Services
~/Library/Android/sdk/platform-tools/adb shell dumpsys package com.google.android.gms | grep versionName

# 3. Verificar configuración de red
~/Library/Android/sdk/platform-tools/adb shell settings get global http_proxy

# 4. Verificar aplicaciones instaladas
~/Library/Android/sdk/platform-tools/adb shell pm list packages | grep google
```

### **Indicadores de Problema:**

- ❌ Ping a google.com falla
- ❌ Google Play Services no está instalado
- ❌ Proxy configurado incorrectamente
- ❌ Caché corrupto de Google Play Services

## 🎯 **Causas Comunes**

### **1. Emulador sin Google Play Services**

- **Síntoma:** Error inmediato al intentar sign in
- **Solución:** Crear nuevo emulador con Google Play Services

### **2. Google Play Services Desactualizado**

- **Síntoma:** Error después de seleccionar cuenta
- **Solución:** Actualizar Google Play Services

### **3. Problemas de Red del Emulador**

- **Síntoma:** Error de timeout o network error
- **Solución:** Ejecutar script de limpieza de red

### **4. Caché Corrupto**

- **Síntoma:** Error persistente después de intentos
- **Solución:** Limpiar caché de Google Play Services

## 🚀 **Pasos de Verificación**

### **Después de Aplicar Soluciones:**

1. **Verificar Conectividad:**

   ```bash
   ~/Library/Android/sdk/platform-tools/adb shell ping -c 3 google.com
   ```

2. **Verificar Google Play Services:**

   ```bash
   ~/Library/Android/sdk/platform-tools/adb shell dumpsys package com.google.android.gms | grep versionName
   ```

3. **Probar Google Sign-In:**

   - Abrir app
   - Intentar "Continue with Google"
   - Verificar que no aparezca "Something went wrong"

4. **Verificar Logs:**
   ```bash
   flutter logs
   ```

## 📝 **Notas Importantes**

### **Configuración Actual:**

- **SHA-1 del debug keystore:** `E5:43:24:6C:31:F0:79:BC:18:F3:B5:93:17:4E:69:D5:AC:08:59:47`
- **Package name:** `com.example.trackflow`
- **Web Client ID:** `411076004525-6sfjv4mkbab89b81jn3so4o6s8om46sa.apps.googleusercontent.com`
- **Google Play Services:** Versión 25.24.31

### **Comandos Útiles:**

```bash
# Limpiar caché de Google Play Services
~/Library/Android/sdk/platform-tools/adb shell pm clear com.google.android.gms

# Reiniciar Google Play Services
~/Library/Android/sdk/platform-tools/adb shell am force-stop com.google.android.gms

# Verificar dispositivos conectados
~/Library/Android/sdk/platform-tools/adb devices

# Instalar app en emulador
flutter install --debug
```

## 🎉 **Resultado Esperado**

Después de aplicar las soluciones:

- ✅ **Ping a google.com exitoso**
- ✅ **Google Play Services actualizado**
- ✅ **Google Sign-In funciona sin errores**
- ✅ **Selección de cuenta de Google exitosa**
- ✅ **Autenticación completa**
- ✅ **Pre-llenado de datos en onboarding**

## 🆘 **Si el Problema Persiste**

1. **Crear nuevo emulador** con Google Play Services desde Android Studio
2. **Usar dispositivo físico** para testing
3. **Verificar configuración de Firebase** en la consola web
4. **Contactar soporte** con logs detallados
