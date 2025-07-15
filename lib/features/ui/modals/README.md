# TrackFlow Modal Components

Componentes de modales del sistema de diseño de TrackFlow.

## Ubicación y organización

```
lib/core/theme/components/modals/
├── app_action_sheet.dart     - Action sheets (recomendado ✅)
├── app_bottom_sheet.dart     - Bottom sheets base
├── app_dialog.dart           - Diálogos
└── app_form_sheet.dart       - Form sheets (recomendado ✅)
```

## Uso recomendado

### Para Action Sheets:

```dart
import 'package:trackflow/core/theme/ui/modals/app_action_sheet.dart';

// ✅ Recomendado para nuevos desarrollos
showTrackFlowActionSheet(
  context: context,
  title: 'Opciones del Proyecto',
  actions: [
    TrackFlowActionItem(
      icon: Icons.edit,
      title: 'Editar',
      subtitle: 'Editar nombre del proyecto',
      onTap: () => // acción
    ),
    TrackFlowActionItem(
      icon: Icons.delete,
      title: 'Eliminar',
      subtitle: 'Eliminar proyecto',
      onTap: () => // acción
    ),
  ],
);
```

### Para Form Sheets:

```dart
import 'package:trackflow/core/theme/components/modals/app_form_sheet.dart';

// ✅ Recomendado para nuevos desarrollos
showTrackFlowFormSheet(
  context: context,
  title: 'Crear Proyecto',
  child: CreateProjectForm(),
);
```

## Características importantes

### Action Sheets

- ✅ Automáticamente mantiene contexto de BLoCs (`useRootNavigator: false`)
- ✅ Diseño consistente con el sistema de diseño
- ✅ Soporte para iconos, títulos y subtítulos
- ✅ Navegación a sheets secundarios con `childSheetBuilder`

### Form Sheets

- ✅ Automáticamente mantiene contexto de BLoCs (`useRootNavigator: false`)
- ✅ DraggableScrollableSheet para UX mejorada
- ✅ Tamaños configurables (initialChildSize, minChildSize, maxChildSize)
- ✅ Botón de cierre integrado

## Migración de código legacy

### Imports antiguos (mantienen compatibilidad):

```dart
// ⚠️ Legacy - mantiene compatibilidad pero deprecated
import 'package:trackflow/core/presentation/widgets/trackflow_action_bottom_sheet.dart';
import 'package:trackflow/core/presentation/widgets/trackflow_form_bottom_sheet.dart';
```

### Imports nuevos (recomendados):

```dart
// ✅ Nuevos imports recomendados
import 'package:trackflow/core/theme/ui/modals/app_action_sheet.dart';
import 'package:trackflow/core/theme/components/modals/app_form_sheet.dart';
```

## Patrones de uso comunes

### 1. Project Actions:

```dart
class ProjectActions {
  static List<TrackFlowActionItem> onProjectList(BuildContext context) => [
    TrackFlowActionItem(
      icon: Icons.add,
      title: 'Create Project',
      subtitle: 'Start a new project from scratch',
      onTap: () {
        showTrackFlowFormSheet(
          context: context,
          title: 'Create Project',
          child: ProjectFormBottomSheet(),
        );
      },
    ),
  ];
}
```

### 2. Track Actions:

```dart
class TrackActions {
  static List<TrackFlowActionItem> forTrack(/* params */) => [
    TrackFlowActionItem(
      icon: Icons.edit,
      title: 'Rename',
      subtitle: 'Change the track\'s title',
      onTap: () {
        showTrackFlowFormSheet(
          context: context,
          title: 'Rename Track',
          child: RenameTrackForm(track: track),
        );
      },
    ),
  ];
}
```

## Beneficios del sistema actual

1. **Consistencia**: Todos los modales siguen el mismo patrón visual
2. **Contexto BLoC preservado**: Los formularios pueden acceder a todos los BLoCs necesarios
3. **Compatibilidad**: El código legacy sigue funcionando
4. **Organización**: Componentes centralizados en el sistema de diseño
5. **Documentación**: Clara separación entre componentes del sistema y legacy

## Próximos pasos

1. ✅ **Migración completada**: Todos los imports actualizados
2. ✅ **Compatibilidad**: Código legacy sigue funcionando
3. 🔄 **Recomendación**: Usar imports del sistema de diseño para nuevos desarrollos
4. 🔄 **Opcional**: Migrar gradualmente imports legacy a nuevos imports
