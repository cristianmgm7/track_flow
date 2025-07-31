# 🔥 Siguiente Paso: Completar Firebase Staging y Production

¡Excelente! Ya tienes **trackflow-dev** funcionando perfectamente. 🎉

Ahora necesitas completar los otros 2 ambientes para estar listo para lanzar tu app.

## 📋 **LO QUE FALTA POR HACER:**

### 🧪 **PASO 1: Crear Proyecto STAGING**

```bash
1. 🌐 Ve a: https://console.firebase.google.com
2. ➕ Click "Agregar proyecto" 
3. 📝 Nombre: "trackflow-staging"
4. 📍 ID: "trackflow-staging" 
5. 📊 Analytics: DESACTIVAR
6. 🎉 Crear proyecto
```

**Configurar servicios básicos:**
- 🔐 Authentication → Email/password + Google (igual que development)
- 🗃️ Firestore → Modo prueba → us-central1
- 📁 Storage → Modo prueba → us-central1

**Registrar app Android:**
- 📱 Agregar app → Android
- 📦 Package: `com.trackflow.staging`
- 🏷️ Nickname: "TrackFlow Staging Android"
- 📥 Descargar `google-services.json` → Renombrar a `google-services-staging.json`

### 🚀 **PASO 2: Crear Proyecto PRODUCTION**

```bash
1. ➕ Click "Agregar proyecto"
2. 📝 Nombre: "trackflow-prod" 
3. 📍 ID: "trackflow-prod"
4. 📊 Analytics: ACTIVAR (para production sí es útil)
5. 🎉 Crear proyecto
```

**Configurar servicios básicos:**
- 🔐 Authentication → Email/password + Google
- 🗃️ Firestore → Modo prueba → us-central1 (luego cambiaremos reglas)
- 📁 Storage → Modo prueba → us-central1

**Registrar app Android:**
- 📱 Agregar app → Android  
- 📦 Package: `com.trackflow`
- 🏷️ Nickname: "TrackFlow Production Android"
- 📥 Descargar `google-services.json` → Renombrar a `google-services-prod.json`

### 📁 **PASO 3: Colocar archivos de configuración**

```bash
# Crear carpetas para staging y production:
mkdir -p android/app/src/staging
mkdir -p android/app/src/production  

# Copiar archivos descargados:
cp ~/Downloads/google-services-staging.json android/app/src/staging/google-services.json
cp ~/Downloads/google-services-prod.json android/app/src/production/google-services.json
```

### 🔧 **PASO 4: Actualizar Firebase Options**

Para cada proyecto, necesitas los valores reales de Firebase Console:

#### Para STAGING:
```
Firebase Console → trackflow-staging → ⚙️ Configuración → General → Tus apps → Android
```

Copia estos valores a `lib/firebase_options_staging.dart`:
- API Key
- App ID  
- Sender ID
- Project ID: `trackflow-staging`
- Storage Bucket: `trackflow-staging.firebasestorage.app`

#### Para PRODUCTION:
```
Firebase Console → trackflow-prod → ⚙️ Configuración → General → Tus apps → Android  
```

Copia estos valores a `lib/firebase_options_production.dart`:
- API Key
- App ID
- Sender ID  
- Project ID: `trackflow-prod`
- Storage Bucket: `trackflow-prod.firebasestorage.app`

## 🧪 **PASO 5: Probar los nuevos ambientes**

```bash
# Probar staging:
./scripts/run_flavors.sh staging debug

# Probar production:  
./scripts/run_flavors.sh production debug
```

**Deberías ver:**
```
🎯 Current Flavor: staging
✅ Firebase initialized successfully for staging
```

## 🔐 **PASO 6: Configurar Reglas de Seguridad** 

### Para STAGING (Restrictivo pero flexible):

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Solo usuarios autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Storage Rules:**
```javascript  
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /projects/{projectId}/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Para PRODUCTION (Muy restrictivo):

**Firestore Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /projects/{projectId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        (resource.data.ownerId == request.auth.uid ||
         request.auth.uid in resource.data.collaborators);
    }
  }
}
```

**Storage Rules:** (Igual que staging)

## ✅ **CHECKLIST DE PROGRESO:**

**Staging:**
- [ ] ✅ Proyecto creado en Firebase Console
- [ ] ✅ Authentication configurado  
- [ ] ✅ Firestore creado
- [ ] ✅ Storage configurado
- [ ] ✅ App Android registrada
- [ ] ✅ google-services.json descargado y colocado
- [ ] ✅ firebase_options_staging.dart actualizado con valores reales
- [ ] ✅ App corre sin errores

**Production:**  
- [ ] ✅ Proyecto creado en Firebase Console
- [ ] ✅ Authentication configurado
- [ ] ✅ Firestore creado  
- [ ] ✅ Storage configurado
- [ ] ✅ App Android registrada
- [ ] ✅ google-services.json descargado y colocado
- [ ] ✅ firebase_options_production.dart actualizado con valores reales
- [ ] ✅ App corre sin errores
- [ ] ✅ Reglas de seguridad configuradas

## 🎯 **DESPUÉS DE ESTO:**

Una vez completado, tendrás 3 ambientes completamente funcionales:

- 🏠 **Development:** Para programar y hacer pruebas
- 🧪 **Staging:** Para probar con usuarios beta  
- 🚀 **Production:** Para usuarios reales en las tiendas

¡Estarás listo para crear tu primera build de release! 🎉

---

**💡 Consejo:** Guarda estos links para acceso rápido:
- [trackflow-dev](https://console.firebase.google.com/project/trackflow-dev)
- [trackflow-staging](https://console.firebase.google.com/project/trackflow-staging)  
- [trackflow-prod](https://console.firebase.google.com/project/trackflow-prod)