# BLoCs Documentation

Este documento proporciona una visión general de todos los BLoCs (Business Logic Components) en el codebase de TrackFlow, sus responsabilidades y métodos públicos.

## Resumen General

**Total de BLoCs:** 11

Los BLoCs están organizados por features siguiendo la arquitectura Clean Architecture y están registrados como injectable usando el patrón de inyección de dependencias.

## Lista de BLoCs por Feature

### 1. AuthBloc
**Ubicación:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

**Responsabilidad:** Gestión de autenticación y onboarding de usuarios

**Métodos públicos (eventos que maneja):**
- `AuthCheckRequested` - Verificar estado de autenticación
- `AuthSignInRequested` - Iniciar sesión con email/password
- `AuthSignUpRequested` - Registrar nuevo usuario
- `AuthSignOutRequested` - Cerrar sesión
- `AuthGoogleSignInRequested` - Iniciar sesión con Google
- `OnboardingMarkCompleted` - Marcar onboarding como completado
- `WelcomeScreenMarkCompleted` - Marcar pantalla de bienvenida como vista

**Casos de uso dependientes:** 7
- SignInUseCase, SignUpUseCase, SignOutUseCase, GoogleSignInUseCase, GetAuthStateUseCase, OnboardingUseCase

---

### 2. MagicLinkBloc
**Ubicación:** `lib/features/magic_link/presentation/blocs/magic_link_bloc.dart`

**Responsabilidad:** Gestión de magic links para invitaciones a proyectos

**Métodos públicos (eventos que maneja):**
- `MagicLinkRequested` - Generar magic link
- `MagicLinkValidated` - Validar magic link
- `MagicLinkConsumed` - Consumir magic link
- `MagicLinkResent` - Reenviar magic link
- `MagicLinkStatusChecked` - Verificar estado del magic link
- `MagicLinkHandleRequested` - Procesar magic link completo (validar + consumir + unir a proyecto)

**Casos de uso dependientes:** 6
- GenerateMagicLinkUseCase, ValidateMagicLinkUseCase, ConsumeMagicLinkUseCase, ResendMagicLinkUseCase, GetMagicLinkStatusUseCase, JoinProjectWithIdUseCase

---

### 3. ProjectsBloc
**Ubicación:** `lib/features/projects/presentation/blocs/projects_bloc.dart`

**Responsabilidad:** Gestión CRUD de proyectos y observación de lista de proyectos

**Métodos públicos (eventos que maneja):**
- `CreateProjectRequested` - Crear nuevo proyecto
- `UpdateProjectRequested` - Actualizar proyecto existente
- `DeleteProjectRequested` - Eliminar proyecto
- `StartWatchingProjects` - Observar cambios en lista de proyectos

**Casos de uso dependientes:** 4
- CreateProjectUseCase, UpdateProjectUseCase, DeleteProjectUseCase, WatchAllProjectsUseCase

**Características especiales:**
- Gestiona stream subscription para observar proyectos en tiempo real
- Incluye mapeo detallado de tipos de failure a mensajes de usuario

---

### 4. ProjectDetailBloc
**Ubicación:** `lib/features/project_detail/presentation/bloc/project_detail_bloc.dart`

**Responsabilidad:** Gestión de detalles de proyecto incluyendo tracks y colaboradores

**Métodos públicos (eventos que maneja):**
- `WatchProjectDetail` - Observar detalles de proyecto, tracks y colaboradores

**Casos de uso dependientes:** 1
- WatchProjectDetailUseCase

**Características especiales:**
- Gestiona estado complejo con múltiples entidades (proyecto, tracks, colaboradores)
- Manejo de estados de carga independientes para tracks y colaboradores

---

### 5. AudioTrackBloc
**Ubicación:** `lib/features/audio_track/presentation/bloc/audio_track_bloc.dart`

**Responsabilidad:** Gestión CRUD de audio tracks dentro de proyectos

**Métodos públicos (eventos que maneja):**
- `WatchAudioTracksByProjectEvent` - Observar tracks de un proyecto
- `DeleteAudioTrackEvent` - Eliminar track
- `UploadAudioTrackEvent` - Subir nuevo track
- `EditAudioTrackEvent` - Editar nombre de track
- `AudioTracksUpdated` - Evento interno para actualizaciones de stream

**Casos de uso dependientes:** 4
- WatchTracksByProjectIdUseCase, DeleteAudioTrack, UploadAudioTrackUseCase, EditAudioTrackUseCase

**Características especiales:**
- Gestiona stream subscription para observar tracks en tiempo real
- Override del método close() para limpiar subscriptions

---

### 6. AudioPlayerBloc
**Ubicación:** `lib/features/audio_player/presentation/bloc/audio_player_bloc.dart`

**Responsabilidad:** Control puro de reproducción de audio (NO contexto de negocio)

**Métodos públicos (eventos que maneja):**
- `AudioPlayerInitializeRequested` - Inicializar reproductor
- `PlayAudioRequested` - Reproducir track específico
- `PlayPlaylistRequested` - Reproducir playlist
- `PauseAudioRequested` - Pausar reproducción
- `ResumeAudioRequested` - Reanudar reproducción
- `StopAudioRequested` - Detener reproducción
- `SkipToNextRequested` - Siguiente track
- `SkipToPreviousRequested` - Track anterior
- `SeekToPositionRequested` - Buscar posición específica
- `ToggleShuffleRequested` - Alternar modo aleatorio
- `ToggleRepeatModeRequested` - Alternar modo repetición
- `SetRepeatModeRequested` - Establecer modo repetición específico
- `SetVolumeRequested` - Establecer volumen
- `SetPlaybackSpeedRequested` - Establecer velocidad de reproducción
- `SavePlaybackStateRequested` - Guardar estado de reproducción
- `SessionStateChanged` - Evento interno para cambios de sesión
- `PlaybackPositionUpdated` - Evento interno para actualizaciones de posición

**Casos de uso dependientes:** 12
- InitializeAudioPlayerUseCase, PlayAudioUseCase, PlayPlaylistUseCase, PauseAudioUseCase, ResumeAudioUseCase, StopAudioUseCase, SkipToNextUseCase, SkipToPreviousUseCase, SeekAudioUseCase, ToggleShuffleUseCase, ToggleRepeatModeUseCase, SetVolumeUseCase, SetPlaybackSpeedUseCase, SavePlaybackStateUseCase, RestorePlaybackStateUseCase

**Características especiales:**
- BLoC más complejo con 15+ eventos públicos
- Gestiona AudioPlaybackService directamente
- Stream subscription para cambios de sesión
- Restauración automática de estado al inicializar
- Mapeo de PlaybackState a estados específicos del BLoC

---

### 7. AudioCommentBloc
**Ubicación:** `lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart`

**Responsabilidad:** Gestión de comentarios en audio tracks

**Métodos públicos (eventos que maneja):**
- `WatchCommentsByTrackEvent` - Observar comentarios de un track
- `AddAudioCommentEvent` - Agregar nuevo comentario
- `DeleteAudioCommentEvent` - Eliminar comentario
- `AudioCommentsUpdated` - Evento interno para actualizaciones de stream

**Casos de uso dependientes:** 3
- WatchCommentsByTrackUseCase, AddAudioCommentUseCase, DeleteAudioCommentUseCase

**Características especiales:**
- Stream subscription para observar comentarios en tiempo real

---

### 8. UserProfileBloc
**Ubicación:** `lib/features/user_profile/presentation/bloc/user_profile_bloc.dart`

**Responsabilidad:** Gestión de perfiles de usuario

**Métodos públicos (eventos que maneja):**
- `WatchUserProfile` - Observar perfil de usuario (propio o de otro usuario)
- `SaveUserProfile` - Guardar cambios en perfil

**Casos de uso dependientes:** 2
- WatchUserProfileUseCase, UpdateUserProfileUseCase

**Características especiales:**
- Puede observar perfil propio o de otro usuario específico
- Re-observa automáticamente después de guardar cambios

---

### 9. ManageCollaboratorsBloc
**Ubicación:** `lib/features/manage_collaborators/presentation/bloc/manage_collaborators_bloc.dart`

**Responsabilidad:** Gestión de colaboradores en proyectos

**Métodos públicos (eventos que maneja):**
- `WatchCollaborators` - Observar colaboradores de un proyecto
- `AddCollaborator` - Agregar colaborador al proyecto
- `RemoveCollaborator` - Remover colaborador del proyecto
- `UpdateCollaboratorRole` - Actualizar rol de colaborador
- `LeaveProject` - Abandonar proyecto (usuario actual)

**Casos de uso dependientes:** 5
- AddCollaboratorAndSyncProfileService, RemoveCollaboratorUseCase, UpdateCollaboratorRoleUseCase, LeaveProjectUseCase, WatchUserProfilesUseCase

**Características especiales:**
- Manejo específico de ProjectPermissionException
- Conserva último estado exitoso en caso de errores
- Stream subscription para observar perfiles de colaboradores

---

### 10. TrackCacheBloc
**Ubicación:** `lib/features/audio_cache/track/presentation/bloc/track_cache_bloc.dart`

**Responsabilidad:** Gestión de caché de tracks individuales

**Métodos públicos (eventos que maneja):**
- `CacheTrackRequested` - Cachear track específico
- `RemoveTrackCacheRequested` - Remover track del caché
- `GetTrackCacheStatusRequested` - Obtener estado de caché de track

**Casos de uso dependientes:** 3
- CacheTrackUseCase, GetTrackCacheStatusUseCase, RemoveTrackCacheUseCase

---

### 11. PlaylistCacheBloc
**Ubicación:** `lib/features/audio_cache/playlist/presentation/bloc/playlist_cache_bloc.dart`

**Responsabilidad:** Gestión de caché de playlists (múltiples tracks)

**Métodos públicos (eventos que maneja):**
- `CachePlaylistRequested` - Cachear playlist completa
- `GetPlaylistCacheStatusRequested` - Obtener estado de tracks en playlist
- `GetPlaylistCacheStatsRequested` - Obtener estadísticas detalladas de caché
- `GetDetailedProgressRequested` - Obtener progreso detallado de caché
- `RemovePlaylistCacheRequested` - Remover playlist del caché

**Casos de uso dependientes:** 3
- CachePlaylistUseCase, GetPlaylistCacheStatusUseCase, RemovePlaylistCacheUseCase

**Características especiales:**
- Manejo de estadísticas complejas de caché
- Progreso detallado con múltiples métricas
- Opera sobre múltiples tracks simultáneamente

---

## Estadísticas Generales

- **BLoCs con stream subscriptions:** 7 (AuthBloc, ProjectsBloc, ProjectDetailBloc, AudioTrackBloc, AudioPlayerBloc, AudioCommentBloc, UserProfileBloc, ManageCollaboratorsBloc)
- **BLoC más complejo:** AudioPlayerBloc (15+ eventos públicos, 12 casos de uso)
- **BLoCs más simples:** SettingsBloc (vacío), DashboardBloc (vacío)
- **Total de casos de uso utilizados:** ~50
- **BLoCs con manejo de errores especializado:** ManageCollaboratorsBloc, ProjectsBloc

## Patrones Comunes

1. **Inyección de dependencias:** Todos los BLoCs usan `@injectable`
2. **Stream management:** BLoCs que observan datos implementan `close()` para limpiar subscriptions
3. **Error handling:** Uso consistente de `Either<Failure, Success>` pattern
4. **Event-driven:** Todos siguen el patrón Event/State de flutter_bloc
5. **Use case dependency:** Cada BLoC depende de uno o más casos de uso específicos