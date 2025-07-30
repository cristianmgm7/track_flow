# Sistema de Manejo de Imágenes - Solución para Pérdida de Archivos

## Problema Resuelto

El error `Unable to load asset: "/data/user/0/com.example.trackflow/app_flutter/profile_images/image_1753020503579.png"` se debía a que las imágenes se almacenaban en el directorio temporal de la app, que se limpia automáticamente por el sistema.

## Solución Implementada

### 1. **Almacenamiento Permanente**

- Las imágenes ahora se copian a un directorio permanente (`permanent_images/`) dentro del directorio de documentos de la app
- Este directorio persiste entre reinicios de la app y limpiezas del sistema

### 2. **Validación y Reparación Automática**

- El sistema valida automáticamente las rutas de imágenes
- Si una imagen no existe en la ruta original, busca en el almacenamiento permanente
- Repara automáticamente las rutas rotas

### 3. **Widgets Robustos**

- Nuevo `ImageUtils.createRobustImageWidget()` que maneja errores de carga
- Fallback automático a iconos por defecto cuando las imágenes fallan
- Indicadores de carga mientras se valida la imagen

### 4. **Mantenimiento Automático**

- Servicio de mantenimiento que se ejecuta cada 6 horas
- Migración automática de imágenes existentes a almacenamiento permanente
- Limpieza de archivos temporales antiguos (90 días en lugar de 30)

## Archivos Modificados

### Core Utils

- `lib/core/utils/image_utils.dart` - Sistema principal de manejo de imágenes
- `lib/core/services/image_maintenance_service.dart` - Servicio de mantenimiento
- `lib/core/app/services/app_initializer.dart` - Integración en inicialización

### Components

- `lib/features/user_profile/presentation/components/avatar_uploader.dart` - Avatar robusto
- `lib/features/user_profile/presentation/components/user_profile_information_component.dart` - Perfil con imágenes robustas

### Debug

- `lib/features/user_profile/presentation/widgets/image_debug_widget.dart` - Widget de debug

## Uso

### Para Imágenes de Perfil

```dart
// Usar el widget robusto
ImageUtils.createRobustImageWidget(
  imagePath: profile.avatarUrl,
  width: 120,
  height: 120,
  fit: BoxFit.cover,
  fallbackWidget: Icon(Icons.person),
)
```

### Para Copiar Imágenes a Almacenamiento Permanente

```dart
// Al seleccionar una imagen
final permanentPath = await ImageUtils.copyImageToPermanentLocation(
  pickedFile.path,
);
```

### Para Validar y Reparar Rutas

```dart
// Validar automáticamente una ruta
final validPath = await ImageUtils.validateAndRepairImagePath(imagePath);
```

## Beneficios

1. **Persistencia**: Las imágenes no se pierden al reiniciar la app
2. **Robustez**: Manejo automático de errores y fallbacks
3. **Eficiencia**: Limpieza automática de archivos temporales
4. **Debugging**: Herramientas para monitorear el estado de las imágenes
5. **Migración**: Sistema automático para mover imágenes existentes

## Monitoreo

El sistema registra todas las operaciones importantes:

- Migración de imágenes
- Validación de rutas
- Limpieza de archivos
- Errores de carga

Los logs se pueden ver con el tag `IMAGE_UTILS` o `IMAGE_MAINTENANCE`.

## Próximos Pasos

1. **Testing**: Probar el sistema con diferentes escenarios
2. **Optimización**: Ajustar intervalos de mantenimiento según uso
3. **UI**: Mejorar indicadores visuales de estado de imágenes
4. **Backup**: Considerar sincronización con servidor para respaldo
