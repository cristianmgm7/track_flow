# 🔥 Firebase Paso a Paso (Para Principiantes)

Firebase es como el "cerebro en la nube" de tu app. Aquí se guardan los usuarios, proyectos, audios, etc.

## 🤔 **¿Por qué necesitas 3 Firebase projects?**

Imagina que tienes una tienda:

- 🏠 **Casa (Development):** Donde practicas vender, puedes hacer experimentos
- 🏪 **Tienda de Prueba (Staging):** Donde invitas amigos a probar antes de abrir
- 🏢 **Tienda Real (Production):** Donde vienen clientes reales con dinero real

## 🎯 **LO QUE VAMOS A HACER:**

1. ✅ Crear 3 proyectos Firebase
2. ✅ Configurar cada uno
3. ✅ Conectarlos con tu app
4. ✅ Probar que funciona

## 🚀 **PASO 1: Acceder a Firebase**

### 1.1: Ve a Firebase Console

```
🌐 Abre tu navegador
🔗 Ve a: https://console.firebase.google.com
🔑 Inicia sesión con tu cuenta Google
```

### 1.2: Deberías ver algo así:

```
┌─────────────────────────────────┐
│  🔥 Firebase Console            │
│                                │
│  📊 Tus proyectos:             │
│  └── track-flow-8e1c0          │ <- Este YA existe
│                                │
│  ➕ Agregar proyecto           │
└─────────────────────────────────┘
```

## 🏗️ **PASO 2: Crear Proyecto de DESARROLLO**

### 2.1: Crear el proyecto

```
1. 🖱️ Haz click en "➕ Agregar proyecto"
2. 📝 Nombre del proyecto: "trackflow-dev"
3. 📍 ID del proyecto: "trackflow-dev" (se auto-genera)
4. ▶️ Continuar
5. 📊 Google Analytics: DESACTÍVALO (no lo necesitas para desarrollo)
6. 🎉 Crear proyecto
```

### 2.2: Configurar servicios básicos

Una vez creado el proyecto:

#### 🔐 Authentication (Autenticación)

```
1. 🔑 Click en "Authentication" en el menú izquierdo
2. ▶️ "Comenzar"
3. 📧 Click en "Email/password"
4. ✅ Habilitar "Email/password"
4. ✅ Habilitar "Email link (sin contraseña)" (opcional)
5. 💾 Guardar
6. 🔍 Click en "Google"
7. ✅ Habilitar "Google"
8. 📧 Email de soporte: tu-email@gmail.com
9. 💾 Guardar
```

#### 🗃️ Firestore Database

```
1. 🗃️ Click en "Firestore Database" en el menú izquierdo
2. ▶️ "Crear base de datos"
3. 🔒 Modo: "Comenzar en modo de PRUEBA" (por ahora)
4. 🌍 Ubicación: "us-central1" (más cerca de ti)
5. ✅ Listo
```

#### 📁 Storage

```
1. 📁 Click en "Storage" en el menú izquierdo
2. ▶️ "Comenzar"
3. 🔒 Modo: "Comenzar en modo de PRUEBA" (por ahora)
4. 🌍 Ubicación: "us-central1" (igual que Firestore)
5. ✅ Listo
```

## 🧪 **PASO 3: Crear Proyecto de STAGING**

Repetir EXACTAMENTE igual que el paso 2, pero:

```
📝 Nombre: "trackflow-staging"
📍 ID: "trackflow-staging"
```

## 🚀 **PASO 4: Crear Proyecto de PRODUCTION**

Repetir EXACTAMENTE igual que el paso 2, pero:

```
📝 Nombre: "trackflow-prod"
📍 ID: "trackflow-prod"
```

## 📱 **PASO 5: Registrar tu App Android**

Para CADA proyecto (development, staging, production):

### 5.1: Agregar App Android

#### Para trackflow-dev:

```
1. 🏠 Ve al proyecto "trackflow-dev"
2. ⚙️ Click en el ícono de engranaje → "Configuración del proyecto"
3. 📱 Scroll down y click "➕ Agregar app" → Android
4. 📦 Package name: "com.trackflow.dev"
5. 🏷️ App nickname: "TrackFlow Dev Android"
6. 🔐 SHA-1: (déjalo vacío por ahora)
7. ▶️ "Registrar app"
```

#### Para trackflow-staging:

```
📦 Package name: "com.trackflow.staging"
🏷️ App nickname: "TrackFlow Staging Android"
```

#### Para trackflow-prod:

```
📦 Package name: "com.trackflow"
🏷️ App nickname: "TrackFlow Production Android"
```

### 5.2: Descargar archivos de configuración

Para CADA proyecto, después de registrar la app:

```
1. 📥 Click "Descargar google-services.json"
2. 📁 Guárdalo en tu computadora (lo usaremos después)
```

**⚠️ MUY IMPORTANTE:** Tendrás 3 archivos:

- `google-services-dev.json` (renómbrenlo así)
- `google-services-staging.json` (renómbrenlo así)
- `google-services-prod.json` (renómbrenlo así)

## 🍎 **PASO 6: Registrar tu App iOS** (Opcional por ahora)

Si planeas lanzar en iPhone:

### Para cada proyecto:

```
1. 📱 Click "➕ Agregar app" → iOS
2. 📦 Bundle ID:
   - Dev: "com.trackflow.dev"
   - Staging: "com.trackflow.staging"
   - Prod: "com.trackflow"
3. 🏷️ App nickname: "TrackFlow [Environment] iOS"
4. 📥 Descargar "GoogleService-Info.plist"
```

## 🔌 **PASO 7: Conectar Firebase con tu App**

### 7.1: Colocar archivos de configuración

```bash
# Ve a tu proyecto:
cd /Users/cristianmurillo/development/trackflow

# Crea las carpetas (si no existen):
mkdir -p android/app/src/development
mkdir -p android/app/src/staging
mkdir -p android/app/src/production

# Copia los archivos descargados:
cp ~/Downloads/google-services-dev.json android/app/src/development/google-services.json
cp ~/Downloads/google-services-staging.json android/app/src/staging/google-services.json
cp ~/Downloads/google-services-prod.json android/app/src/production/google-services.json
```

### 7.2: Actualizar archivos de configuración Dart

Necesitas actualizar 3 archivos con información real:

#### 🔧 lib/firebase_options_development.dart

```dart
// Encuentra esta línea y cámbiala:
projectId: 'trackflow-dev',  // Cambiar de placeholder a tu ID real

// También actualiza:
apiKey: 'TU-API-KEY-DEVELOPMENT',
appId: 'TU-APP-ID-DEVELOPMENT',
messagingSenderId: 'TU-SENDER-ID-DEVELOPMENT',
storageBucket: 'trackflow-dev.firebasestorage.app',
```

**🤔 ¿De dónde saco esos valores?**

1. Ve a Firebase Console → trackflow-dev
2. ⚙️ Configuración del proyecto → General
3. Scroll down a "Tus apps" → Tu app Android
4. Ahí están todos los valores

#### 🔧 lib/firebase_options_staging.dart

Igual que arriba, pero con valores del proyecto "trackflow-staging"

#### 🔧 lib/firebase_options_production.dart

Igual que arriba, pero con valores del proyecto "trackflow-prod"

## 🧪 **PASO 8: PROBAR que funciona**

### 8.1: Probar conexión básica

```bash
# Limpia y reconstruye:
flutter clean
flutter pub get

# Corre la versión development:
./scripts/run_flavors.sh development debug
```

### 8.2: Ver los logs

En la consola deberías ver:

```
🎯 Current Flavor: development
🔥 Initializing Firebase for development...
✅ Firebase initialized successfully for development
```

### 8.3: Si hay errores:

```
❌ Error común: "No matching client found"
Solución: Verifica que el package name coincida

❌ Error común: "API key not valid"
Solución: Verifica que copiaste bien los valores en firebase_options_development.dart
```

## 🔐 **PASO 9: Configurar Reglas de Seguridad**

### 9.1: Firestore Rules (Para cada proyecto)

#### Desarrollo (Permisivo):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // DESARROLLO: Acceso total (para testing)
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

#### Staging (Restrictivo pero flexible):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // STAGING: Solo usuarios autenticados
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

#### Producción (Muy restrictivo):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // PRODUCCIÓN: Reglas específicas por colección
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

### 9.2: Storage Rules (Similar para cada proyecto)

#### Desarrollo:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

#### Staging y Producción:

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

## ✅ **CHECKLIST FINAL**

Marca lo que ya completaste:

### Firebase Projects:

- [ ] ✅ Creé proyecto "trackflow-dev"
- [ ] ✅ Creé proyecto "trackflow-staging"
- [ ] ✅ Creé proyecto "trackflow-prod"

### Configuración por proyecto:

- [ ] ✅ Activé Authentication (Email + Google)
- [ ] ✅ Creé Firestore Database
- [ ] ✅ Configuré Storage
- [ ] ✅ Registré app Android
- [ ] ✅ Descargué google-services.json

### Conexión con la app:

- [ ] ✅ Coloqué google-services.json en carpetas correctas
- [ ] ✅ Actualicé firebase_options_development.dart con valores reales
- [ ] ✅ Actualicé firebase_options_staging.dart con valores reales
- [ ] ✅ Actualicé firebase_options_production.dart con valores reales

### Pruebas:

- [ ] ✅ La app corre sin errores de Firebase
- [ ] ✅ Veo logs de "Firebase initialized successfully"
- [ ] ✅ Configuré reglas de seguridad básicas

## 🎉 **¡Felicidades!**

Si marcaste todas las casillas, ¡tu Firebase está configurado correctamente!

## 🔜 **Próximos Pasos**

1. 🧪 Hacer primera build de prueba
2. 📱 Probarla en tu teléfono
3. 🏪 Prepararla para las tiendas

---

**💡 Consejo:** Guarda las URLs de tus 3 proyectos Firebase:

- Dev: https://console.firebase.google.com/project/trackflow-dev
- Staging: https://console.firebase.google.com/project/trackflow-staging
- Prod: https://console.firebase.google.com/project/trackflow-prod
