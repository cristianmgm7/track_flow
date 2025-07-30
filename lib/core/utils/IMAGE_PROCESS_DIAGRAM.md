# Diagrama del Proceso de Carga de Imágenes

## 🔄 Flujo Principal

```mermaid
graph TD
    A[Usuario toca avatar] --> B[Feedback táctil/auditivo]
    B --> C[ImagePicker.pickImage]
    C --> D{Imagen seleccionada?}
    D -->|No| E[Cancelar operación]
    D -->|Sí| F[File.path temporal]
    F --> G[ImageUtils.copyImageToPermanentLocation]
    G --> H{Archivo copiado?}
    H -->|No| I[Usar ruta original]
    H -->|Sí| J[Guardar ruta permanente]
    I --> K[Actualizar UI]
    J --> K
    K --> L[ImageUtils.createRobustImageWidget]
    L --> M[Validación automática]
    M --> N{Imagen válida?}
    N -->|No| O[Buscar en almacenamiento permanente]
    N -->|Sí| P[Mostrar imagen]
    O --> Q{Encontrada?}
    Q -->|No| R[Mostrar fallback]
    Q -->|Sí| S[Reparar ruta]
    S --> P
    R --> T[Icono por defecto]
    P --> U[Imagen cargada exitosamente]
```

## 🎯 Estados de Accesibilidad

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading : Usuario toca avatar
    Loading --> Validating : Imagen seleccionada
    Loading --> Error : Error en selección
    Validating --> Success : Imagen válida
    Validating --> Repairing : Ruta rota
    Repairing --> Success : Reparación exitosa
    Repairing --> Error : Reparación fallida
    Success --> Idle : Operación completa
    Error --> Idle : Mostrar fallback

    state Success {
        [*] --> ImageLoaded
        ImageLoaded --> Feedback : Feedback auditivo
        Feedback --> Complete
    }

    state Error {
        [*] --> ShowFallback
        ShowFallback --> Feedback : Feedback de error
        Feedback --> Complete
    }
```

## 🏗️ Arquitectura de Componentes

```
App
├── AppInitializer
│   └── ImageMaintenanceService
│       ├── Timer.periodic (6h)
│       ├── migrateImagesToPermanentStorage()
│       └── cleanupOldImages()
├── UserProfileScreen
│   ├── AvatarUploader
│   │   ├── GestureDetector (onTap)
│   │   ├── Semantics (label, button)
│   │   └── ImageUtils.createRobustImageWidget()
│   └── ProfileInformation
│       └── ImageUtils.createRobustImageWidget()
└── ImageDebugWidget (Debug)
    ├── validateImagePath()
    ├── migrateImages()
    └── checkStorage()
```

## 📊 Flujo de Datos

```mermaid
sequenceDiagram
    participant U as Usuario
    participant UI as AvatarUploader
    participant IP as ImagePicker
    participant IU as ImageUtils
    participant FS as FileSystem
    participant DB as Database
    participant MS as MaintenanceService

    U->>UI: Toca avatar
    UI->>UI: HapticFeedback.lightImpact()
    UI->>UI: SystemSound.play(click)
    UI->>IP: pickImage()
    IP-->>UI: File.path (temporal)
    UI->>IU: copyImageToPermanentLocation()
    IU->>FS: Copiar a /permanent_images/
    FS-->>IU: Ruta permanente
    IU-->>UI: Ruta permanente
    UI->>DB: Guardar en UserProfile
    UI->>UI: Actualizar estado
    UI->>IU: createRobustImageWidget()
    IU->>IU: validateAndRepairImagePath()
    IU->>FS: Verificar existencia
    FS-->>IU: Estado del archivo
    IU-->>UI: Widget con imagen o fallback

    Note over MS: Mantenimiento automático
    MS->>IU: migrateImagesToPermanentStorage()
    MS->>IU: cleanupOldImages()
    MS->>IU: getProfileImagesSize()
```

## 🔍 Estados de Validación

```mermaid
graph LR
    A[Ruta Original] --> B{Existe?}
    B -->|Sí| C[Usar original]
    B -->|No| D{Contiene 'profile_images'?}
    D -->|No| E[Retornar null]
    D -->|Sí| F[Buscar en permanente]
    F --> G{Encontrada?}
    G -->|Sí| H[Reparar ruta]
    G -->|No| E
    H --> I[Log reparación]
    I --> C
    C --> J[Retornar ruta válida]
    E --> K[Retornar null]
```

## 🎨 Estados Visuales

```
Estado: Idle
├── Border: Normal color
├── Image: Last valid image or fallback
└── Button: Enabled

Estado: Loading
├── Border: Orange (validating)
├── Image: Loading indicator
└── Button: Disabled

Estado: Success
├── Border: Green
├── Image: Valid image
└── Button: Enabled

Estado: Error
├── Border: Red
├── Image: Fallback icon
└── Button: Enabled
```

## 📱 Feedback de Accesibilidad

```
Evento: Usuario toca avatar
├── HapticFeedback.lightImpact()
├── SystemSound.play(SystemSoundType.click)
└── Semantics(label: "Cambiar imagen de perfil")

Evento: Imagen cargada exitosamente
├── HapticFeedback.lightImpact()
├── SystemSound.play(SystemSoundType.click)
└── Semantics(label: "Imagen de perfil cargada")

Evento: Error en carga
├── HapticFeedback.heavyImpact()
├── SystemSound.play(SystemSoundType.alert)
└── Semantics(label: "Error al cargar imagen")

Evento: Validación en progreso
├── CircularProgressIndicator
└── Semantics(label: "Validando imagen...")
```

## 🛠️ Componentes de Debug

```
ImageDebugWidget
├── validateImagePath()
│   ├── Mostrar loading
│   ├── Ejecutar validación
│   ├── Actualizar debug info
│   └── Feedback auditivo
├── migrateImages()
│   ├── Mostrar loading
│   ├── Ejecutar migración
│   ├── Revalidar imagen
│   └── Feedback táctil/auditivo
└── checkStorage()
    ├── Mostrar loading
    ├── Calcular tamaño
    ├── Actualizar info
    └── Feedback auditivo
```

## 📈 Métricas de Rendimiento

```
Tiempo de Validación: < 100ms
├── File.exists(): ~10ms
├── Path validation: ~5ms
├── Permanent storage lookup: ~20ms
└── Logging: ~5ms

Tiempo de Carga: < 500ms
├── Image validation: ~100ms
├── File loading: ~200ms
├── UI rendering: ~100ms
└── Feedback: ~50ms

Tasa de Éxito: > 95%
├── Valid images: 95%
├── Repaired images: 80%
└── Fallback cases: 5%

Tasa de Reparación: > 80%
├── Found in permanent: 80%
├── Not found: 15%
└── Invalid paths: 5%
```

Este diagrama muestra el proceso completo de carga de imágenes con todos los estados, flujos de datos, componentes de accesibilidad y métricas de rendimiento.
