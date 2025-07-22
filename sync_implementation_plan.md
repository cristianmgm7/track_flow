
# Plan de Ejecución: Implementación de Sincronización Offline-First

Este documento detalla los pasos necesarios para implementar de manera robusta la funcionalidad de sincronización y soporte offline-first a lo largo de toda la base de código, basándose en la arquitectura de sincronización ya establecida.

## Funcionalidades Afectadas

La implementación debe cubrir todas las entidades de datos que se persisten local y remotamente. Las funcionalidades identificadas son:

- **Projects** (`ProjectDTO`)
- **Audio Tracks** (`AudioTrackDTO`)
- **Audio Comments** (`AudioCommentDTO`)
- **Playlists** (`PlaylistDTO`)
- **User Profile** (`UserProfileDTO`)
- **Collaborators** (relacionado con `ProjectDTO`)

## Orden de Implementación

El plan se divide en fases. Es crucial seguir el orden para construir sobre una base sólida.

---

### Fase 1: Fortalecer la Base de Datos Local (Isar)

El primer paso es modificar los modelos de datos locales (DTOs de Isar) para que puedan rastrear el estado de la sincronización. Esto es el prerrequisito para toda la lógica de sincronización.

**Tareas:**

1.  **Crear un `SyncStatus` Enum:**
    -   Definir un `enum` que represente el estado de una entidad.
    -   Ubicación: `lib/core/sync/domain/entities/sync_status.dart`
    -   Valores: `synced`, `pendingCreate`, `pendingUpdate`, `pendingDelete`.

2.  **Actualizar TODOS los DTOs de Isar:**
    -   Para cada DTO en la lista de funcionalidades afectadas (`ProjectDTO`, `AudioTrackDTO`, etc.), añadir los siguientes campos:
        ```dart
        import 'package:trackflow/core/sync/domain/entities/sync_status.dart';

        @collection
        class ProjectDTO {
          // ... otros campos
        
          @Index()
          @Enumerated(EnumType.name)
          late SyncStatus syncStatus;
        
          late DateTime lastModified;
        }
        ```
    -   Asegurarse de que `lastModified` se actualice siempre que se modifique el objeto localmente.
    -   **Acción:** Generar las nuevas migraciones de Isar ejecutando `flutter pub run build_runner build`.

---

### Fase 2: Implementar el `PendingOperationsManager`

Este manager es el corazón del "write-back" (sincronización hacia el servidor). Su trabajo es encontrar objetos con estado `pending*` y enviarlos a la fuente de datos remota.

**Tareas:**

1.  **Crear la lógica de procesamiento:**
    -   Implementar el método `processPendingOperations` en `lib/core/sync/domain/services/pending_operations_manager.dart`.
    -   La lógica debe:
        1.  Consultar en Isar todos los objetos que **no** tengan el estado `SyncStatus.synced`.
        2.  Iterar sobre los resultados.
        3.  Usar un `switch` sobre el `syncStatus` de cada objeto.
        4.  Para cada caso, llamar al método correspondiente del `DataSource` remoto (ej. `_remoteDataSource.createProject(dto)` para `pendingCreate`).
        5.  **En caso de éxito:** Actualizar el objeto en Isar a `SyncStatus.synced` y actualizar su `lastModified` con la versión del servidor si es posible.
        6.  **En caso de fallo (ej. sin red, error del servidor):** Mantener el estado `pending*` para reintentarlo más tarde. Implementar un contador de reintentos para evitar bucles infinitos.

2.  **Inyectar los `DataSources` remotos:**
    -   El `PendingOperationsManager` necesitará acceso a todos los `DataSource` remotos (de proyectos, tracks, etc.). Inyectarlos a través del constructor usando `get_it`.

---

### Fase 3: Implementar el `SyncStateManager`

Este manager se encarga de la sincronización "hacia abajo" (del servidor a la app).

**Tareas:**

1.  **Implementar la lógica de sincronización descendente:**
    -   En el `SyncStateManager`, implementar la lógica que busca datos nuevos o actualizados en el servidor.
    -   Una estrategia común es usar una consulta a Firestore que pida todos los documentos modificados después de la `lastModified` más reciente que se tenga en Isar.
    -   Para cada entidad obtenida del servidor:
        1.  Comprobar si ya existe en Isar.
        2.  Si no existe, añadirla con `syncStatus = SyncStatus.synced`.
        3.  Si existe, comparar `lastModified`. Si la versión del servidor es más nueva, actualizar el objeto local. Si la versión local es más nueva (porque tiene un estado `pending*`), se debe implementar una lógica de resolución de conflictos.

---

### Fase 4: Actualizar los Repositorios

Con los managers listos, hay que actualizar todos los repositorios para que usen la nueva metadata de sincronización. El `ProjectsRepositoryImpl` ya es un buen modelo.

**Tareas:**

1.  **Replicar el patrón en todos los repositorios:**
    -   Aplicar el mismo patrón de `ProjectsRepositoryImpl` a los repositorios de `AudioTrack`, `AudioComment`, `Playlist` y `UserProfile`.
    -   **Creación (`create*`)**: Si hay conexión, llamar al `remoteDataSource`, y si tiene éxito, guardar en local con `SyncStatus.synced`. Si no hay conexión, guardar en local con `SyncStatus.pendingCreate`.
    -   **Actualización (`update*`)**: Actualizar siempre en local primero. Si hay conexión, intentar actualizar en remoto. Si no hay conexión o falla, establecer el estado a `SyncStatus.pendingUpdate`.
    -   **Borrado (`delete*`)**: Implementar "soft deletes". En lugar de borrar de Isar, cambiar el estado a `SyncStatus.pendingDelete`. El `PendingOperationsManager` se encargará de la eliminación real.
    -   **Lectura (`watch*`)**: Asegurarse de que las consultas de lectura de Isar filtren los objetos marcados como `pendingDelete`.

---

## Sugerencias Adicionales a la Arquitectura

La infraestructura actual es muy sólida. Las siguientes son sugerencias para mejorarla aún más y evitar problemas futuros:

1.  **Resolución de Conflictos (Importante):**
    -   La estrategia actual es implícitamente "el último que escribe, gana", lo cual es propenso a la pérdida de datos.
    -   **Sugerencia:** Implementar una estrategia de resolución de conflictos explícita. Al recibir un objeto del servidor en `SyncStateManager`, si choca con una versión local en estado `pendingUpdate`, se debe decidir qué hacer:
        -   **Opción A (Simple):** La versión del servidor siempre gana, pero se notifica al usuario que sus cambios locales fueron descartados.
        -   **Opción B (Compleja):** Intentar fusionar los cambios si no hay conflicto en los mismos campos.
        -   **Opción C (Recomendada):** Guardar la versión del servidor y notificar al usuario, dándole la opción de ver las diferencias y decidir qué versión conservar.

2.  **Servicio de Sincronización en Segundo Plano (Nativo):**
    -   El `BackgroundSyncCoordinator` actual parece funcionar mientras la aplicación está viva (en primer o segundo plano).
    -   **Sugerencia:** Para una sincronización verdaderamente en segundo plano (incluso si el usuario cierra la app), considerar el uso de `workmanager` en Android y `BackgroundTasks` en iOS. Estos pueden invocar un `Isolate` de Dart para ejecutar el `PendingOperationsManager` periódicamente, incluso si la app no está en primer plano.

3.  **Abstracción de la Lógica de Sincronización:**
    -   La lógica dentro de `PendingOperationsManager` y `SyncStateManager` puede volverse muy repetitiva si se maneja cada tipo de DTO con un `if/else` o `switch`.
    -   **Sugerencia:** Crear una interfaz genérica `ISyncableRepository<T>` que los repositorios puedan implementar. Luego, los managers pueden operar sobre una lista de `ISyncableRepository`, haciendo el código más genérico y fácil de extender.

    ```dart
    abstract class ISyncableRepository<T> {
      Future<void> pushPendingChanges(); // Sube los `pending*`
      Future<void> pullLatestChanges();  // Baja los cambios del servidor
    }
    ```

4.  **Manejo de Errores y Reintentos:**
    -   El `PendingOperationsManager` debe tener una estrategia de reintentos robusta.
    -   **Sugerencia:** Implementar un backoff exponencial para los reintentos. Si una operación falla repetidamente, se debe espaciar cada vez más el tiempo de reintento y, eventualmente, marcarla como `failed` y notificar al usuario.

Este plan proporciona una hoja de ruta clara. Comenzar con la Fase 1 es fundamental, ya que todo lo demás depende de que los datos locales puedan rastrear su estado de sincronización.
