# Proceso de Carga de Imágenes - Árbol de Accesibilidad

## 🔄 Flujo Completo del Proceso

```
Usuario Selecciona Imagen
    ↓
ImagePicker.pickImage()
    ↓
File.path (ruta temporal)
    ↓
ImageUtils.copyImageToPermanentLocation()
    ↓
Almacenamiento Permanente (/permanent_images/)
    ↓
Guardar ruta en UserProfile.avatarUrl
    ↓
UI muestra imagen con ImageUtils.createRobustImageWidget()
    ↓
Validación automática en cada carga
    ↓
Fallback si falla
```

## 🌳 Árbol de Accesibilidad del Proceso

### 1. **Selección de Imagen**

```
GestureDetector (onTap: _pickImage)
├── Container (Avatar Container)
│   ├── ClipOval
│   │   └── ImageUtils.createRobustImageWidget()
│   │       ├── FutureBuilder<String?> (Validación)
│   │       │   ├── Loading State
│   │       │   │   └── CircularProgressIndicator
│   │       │   ├── Success State
│   │       │   │   └── Image.file() (File válido)
│   │       │   └── Error State
│   │       │       └── FallbackWidget (Icon)
│   │       └── errorBuilder (Manejo de errores)
│   │           └── FallbackWidget
│   └── Border (Estilo visual)
└── IconButton (Editar)
    └── Icon (camera_alt)
```

### 2. **Proceso de Validación**

```
ImageUtils.validateAndRepairImagePath()
├── Check File.exists() (Ruta original)
│   ├── ✅ Exists → Return original path
│   └── ❌ Not exists → Continue validation
├── Check if path contains 'profile_images'
│   ├── ✅ Contains → Search in permanent storage
│   └── ❌ Not contains → Return null
├── _findImageInPermanentStorage()
│   ├── Extract filename from original path
│   ├── Build permanent path (/permanent_images/filename)
│   ├── Check if permanent file exists
│   │   ├── ✅ Exists → Return permanent path
│   │   └── ❌ Not exists → Return null
│   └── Log repair operation
└── Return validated path or null
```

### 3. **Widget de Carga Robusta**

```
ImageUtils.createRobustImageWidget()
├── Check if imagePath.isEmpty
│   ├── ✅ Empty → Return FallbackWidget
│   └── ❌ Not empty → Continue
├── FutureBuilder<String?>
│   ├── future: validateAndRepairImagePath()
│   └── builder: (context, snapshot)
│       ├── ConnectionState.waiting
│       │   └── LoadingContainer
│       │       ├── Container (Grey background)
│       │       └── CircularProgressIndicator
│       ├── ConnectionState.done
│       │   ├── snapshot.data == null
│       │   │   └── FallbackWidget
│       │   └── snapshot.data != null
│       │       └── Image.file()
│       │           ├── File (Validated path)
│       │           ├── errorBuilder
│       │           │   └── FallbackWidget
│       │           └── fit: BoxFit.cover
│       └── ConnectionState.none
│           └── FallbackWidget
└── FallbackWidget (Default)
    ├── Container (Grey background)
    └── Icon (person)
```

### 4. **Servicio de Mantenimiento**

```
ImageMaintenanceService
├── startPeriodicMaintenance()
│   ├── Timer.periodic (6 hours)
│   ├── _performMaintenance()
│   └── Log start
├── _performMaintenance()
│   ├── migrateImagesToPermanentStorage()
│   ├── cleanupOldImages()
│   ├── getProfileImagesSize()
│   └── Log completion
├── stopPeriodicMaintenance()
│   └── Timer.cancel()
└── dispose()
    └── stopPeriodicMaintenance()
```

## 📋 Proceso Detallado por Pasos

### **Paso 1: Selección de Imagen**

```dart
// 1. Usuario toca el avatar
GestureDetector(
  onTap: _pickImage,
  child: AvatarContainer,
)

// 2. Se abre el picker
final picker = ImagePicker();
final pickedFile = await picker.pickImage(
  source: ImageSource.gallery,
  maxWidth: 512,
  maxHeight: 512,
  imageQuality: 85,
);
```

### **Paso 2: Copia a Almacenamiento Permanente**

```dart
// 3. Copiar a ubicación permanente
final permanentPath = await ImageUtils.copyImageToPermanentLocation(
  pickedFile.path,
);

// 4. Actualizar estado
setState(() {
  _avatarUrl = permanentPath ?? pickedFile.path;
});
```

### **Paso 3: Guardar en Base de Datos**

```dart
// 5. Guardar en UserProfile
final profile = UserProfile(
  // ... otros campos
  avatarUrl: permanentPath,
);

// 6. Persistir en Isar/Firestore
await userProfileRepository.updateProfile(profile);
```

### **Paso 4: Carga en UI**

```dart
// 7. Mostrar con widget robusto
ImageUtils.createRobustImageWidget(
  imagePath: profile.avatarUrl,
  width: 120,
  height: 120,
  fit: BoxFit.cover,
  fallbackWidget: Icon(Icons.person),
)
```

### **Paso 5: Validación Automática**

```dart
// 8. Validación automática en cada carga
FutureBuilder<String?>(
  future: ImageUtils.validateAndRepairImagePath(imagePath),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingIndicator();
    }

    final validPath = snapshot.data;
    if (validPath == null) {
      return FallbackWidget();
    }

    return Image.file(File(validPath));
  },
)
```

## 🔍 Estados de Accesibilidad

### **Estado: Cargando**

```
Semantics(
  label: 'Cargando imagen de perfil',
  child: CircularProgressIndicator(),
)
```

### **Estado: Imagen Cargada**

```
Semantics(
  label: 'Imagen de perfil de ${userName}',
  image: true,
  child: Image.file(),
)
```

### **Estado: Error/Fallback**

```
Semantics(
  label: 'Imagen de perfil no disponible',
  child: Icon(Icons.person),
)
```

### **Estado: Botón de Edición**

```
Semantics(
  label: 'Cambiar imagen de perfil',
  button: true,
  child: IconButton(),
)
```

## 🛠️ Componentes de Accesibilidad

### **AvatarUploader**

```dart
Semantics(
  label: 'Selector de imagen de perfil',
  button: true,
  child: GestureDetector(
    onTap: _handleAvatarTap,
    child: AvatarContainer,
  ),
)
```

### **ImageDebugWidget**

```dart
Semantics(
  label: 'Información de debug de imagen',
  child: Card(
    child: Column(
      children: [
        Semantics(
          label: 'Estado de validación: ${_debugInfo}',
          child: Text(_debugInfo),
        ),
        Semantics(
          label: 'Botón para revalidar imagen',
          button: true,
          child: ElevatedButton(
            onPressed: _validateImagePath,
            child: Text('Revalidar'),
          ),
        ),
      ],
    ),
  ),
)
```

## 📊 Métricas de Accesibilidad

### **Indicadores de Rendimiento**

- **Tiempo de validación**: < 100ms
- **Tiempo de carga**: < 500ms
- **Tasa de éxito**: > 95%
- **Tasa de reparación**: > 80%

### **Logs de Accesibilidad**

```dart
// Logs para debugging de accesibilidad
AppLogger.info(
  'Image validation completed for user: ${userId}',
  tag: 'IMAGE_ACCESSIBILITY',
  extra: {
    'originalPath': originalPath,
    'validatedPath': validatedPath,
    'validationTime': validationTime,
    'success': success,
  },
);
```

## 🎯 Mejoras de Accesibilidad

### **1. Feedback Táctil**

```dart
// Vibración al seleccionar imagen
HapticFeedback.lightImpact();
```

### **2. Feedback Auditivo**

```dart
// Sonido de éxito/error
if (success) {
  SystemSound.play(SystemSoundType.click);
} else {
  SystemSound.play(SystemSoundType.alert);
}
```

### **3. Indicadores Visuales**

```dart
// Indicador de estado
Container(
  decoration: BoxDecoration(
    border: Border.all(
      color: _isValidating ? Colors.orange : Colors.green,
      width: 2,
    ),
  ),
  child: ImageWidget,
)
```

Este árbol de accesibilidad asegura que el proceso de carga de imágenes sea completamente accesible para usuarios con diferentes necesidades, proporcionando feedback apropiado en cada etapa del proceso.
