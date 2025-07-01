# Functional Requirements Document – Playlist y Track UI/UX (Offline-aware)

## 1. Playlist View

### Componentes principales:

- Header con:

  - Info: número de tracks, duración total.
  - Botones:
    - Play / Shuffle
    - Download All (⬇️)
    - ... (más acciones)

- Lista scrollable de TrackItemComponent.

### Comportamiento funcional:

| Acción                       | Resultado Esperado                                                                                                                |
| ---------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Tocar botón Play             | Reproduce desde el primer track disponible localmente. Si está offline y el track no está en caché, se salta.                     |
| Tocar Shuffle                | Reproduce un track aleatorio descargado (si offline), o cualquiera si hay conexión.                                               |
| Tocar Download All           | Descarga todos los tracks de la playlist. Cambia a ícono verde (⬇️(download)->spiner(dowloading)->✅(downloaded)) cuando termina. |
| Estado offline sin descargas | Botón Play se desactiva (griseado).                                                                                               |

---

## 2. Track Item Component

### Contenido visual:

- Nombre del track
- Artista
- Duración
- Menú ... con acciones:
- Ícono cambiante de estado de caché (opcional pero recomendado):
  - ✅ = descargado
  - ⏳ = en descarga
  - ⬇️ = no descargado
  - ⚠️ = error

### Comportamiento funcional:

| Acción                              | Resultado Esperado                                                                                                                 |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Tap en el ítem                      | Si el track está en caché o hay conexión: comienza reproducción. Si no, muestra error/snackbar "Track no disponible sin conexión". |
| Tap en ícono de descarga individual | Inicia descarga del track. Cambia a ⏳ mientras descarga, y ✅ cuando termina.                                                     |
|                                     |

---

## 3. Estados del track en la UI

| Estado                 | Visual sugerido          | Descripción UX                          |
| ---------------------- | ------------------------ | --------------------------------------- |
| Online + No descargado | ⬇️ (gris)                | Disponible solo con conexión            |
| Descargando            | ⏳ (animación / spinner) | Feedback visual mientras descarga       |
| Descargado             | ✅ (verde)               | Disponible sin conexión                 |
| Error                  | ⚠️ (rojo)                | Descarga fallida – opción de reintentar |

---

## 4. Mini Reproductor Persistente

### Componentes:

- Portada pequeña
- Título + artista
- Play/Pause
- Progreso lineal opcional
- Swipe up → abre reproductor completo

### Comportamiento:

- Siempre visible.
- Reacciona a cambios de track.
- Desactiva controles si el track no está disponible y estás offline.

---

## 5. Casos UX especiales

| Caso                                                      | Acción UX                                                                              |
| --------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Playlist sin ningún track descargado y offline            | Mostrar un overlay: “No hay tracks disponibles sin conexión” + botón “Descargar ahora” |
| Conexión perdida durante reproducción                     | Mostrar Snackbar: “Sin conexión – algunos tracks pueden no estar disponibles”          |
| Track agregado recientemente a una playlist ya descargada | Iniciar descarga automáticamente si el modo auto-sync está activado                    |

---

## 6. Arquitectura Mejorada del PlaylistWidget

### Problemas actuales identificados:
- Violación de SRP: múltiples responsabilidades en un solo widget
- Acoplamiento directo con AudioPlayerBloc
- Lógica de negocio mezclada con presentación
- Widget monolítico difícil de mantener

### Propuesta de refactorización:

#### 6.1. Separación de responsabilidades:

```dart
// Simplemente extraer lógica de comparación a utils
class PlaylistUtils {
  static bool isPlayingFromPlaylist(List<String> currentQueue, Playlist playlist) {
    if (currentQueue.length != playlist.trackIds.length) return false;
    return playlist.trackIds.every((trackId) => currentQueue.contains(trackId));
  }
}
```

#### 6.2. Widgets especializados:

```dart
// Widget principal simplificado
class PlaylistWidget extends StatelessWidget {
  // Solo propiedades de UI
  final Playlist playlist;
  final List<AudioTrack> tracks;
  final Map<String, UserProfile>? collaboratorsByTrackId;
  final bool showPlayAll;
  final String? projectId;

  Widget build(BuildContext context) {
    return Column(
      children: [
        PlaylistControlsWidget(playlist: playlist),
        PlaylistStatusWidget(playlist: playlist),
        PlaylistTracksWidget(
          playlist: playlist,
          tracks: tracks,
          collaboratorsByTrackId: collaboratorsByTrackId,
          projectId: projectId,
        ),
      ],
    );
  }
}

// Controles del playlist separados
class PlaylistControlsWidget extends StatelessWidget {
  final Playlist playlist;
  
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, playerState) {
        final player = context.read<AudioPlayerBloc>();
        final session = player.currentSession;
        final isPlayingFromThisPlaylist = playerState is AudioPlayerSessionState &&
            session.queue.isNotEmpty &&
            PlaylistUtils.isPlayingFromPlaylist(
              session.queue.sources.map((s) => s.metadata.id.value).toList(),
              playlist,
            );

        return Row(
          children: [
            PlayPauseButton(
              isPlaying: isPlayingFromThisPlaylist && playerState is AudioPlayerPlaying,
              onPressed: () {
                if (isPlayingFromThisPlaylist && playerState is AudioPlayerPlaying) {
                  player.add(PauseAudioRequested());
                } else {
                  player.add(PlayPlaylistRequested(PlaylistId(playlist.id)));
                }
              },
            ),
            ShuffleButton(
              isEnabled: session.queue.shuffleEnabled,
              onPressed: () => player.add(ToggleShuffleRequested()),
            ),
            RepeatButton(
              mode: session.repeatMode,
              onPressed: () => player.add(ToggleRepeatModeRequested()),
            ),
            const Spacer(),
            BlocProvider(
              create: (context) => sl<PlaylistCacheBloc>(),
              child: PlaylistCacheIcon(
                playlistId: playlist.id,
                trackIds: playlist.trackIds,
                size: 28.0,
              ),
            ),
          ],
        );
      },
    );
  }
}
```

#### 6.3. Ventajas de esta arquitectura simplificada:

1. **SRP**: Cada widget tiene una responsabilidad específica
2. **OCP**: Fácil extensión sin modificar código existente  
3. **Testabilidad**: Componentes aislados y mockeables
4. **Reutilización**: Controles pueden usarse en otros contexts
5. **Mantenibilidad**: Código más organizado y legible
6. **Sin sobreingeniería**: Reacciona directamente al AudioPlayerBloc como debe ser

#### 6.4. Estructura de archivos sugerida:

```
lib/features/playlist/presentation/
├── widgets/
│   ├── playlist_widget.dart              # Widget principal simplificado
│   ├── playlist_controls_widget.dart     # Controles (play, shuffle, repeat, cache)
│   ├── playlist_status_widget.dart       # Estado actual del playlist
│   ├── playlist_tracks_widget.dart       # Lista de tracks
│   └── buttons/
│       ├── play_pause_button.dart
│       ├── shuffle_button.dart
│       └── repeat_button.dart
└── utils/
    └── playlist_utils.dart               # Funciones utilitarias
```

#### 6.5. Integración del PlaylistCacheIcon:

El `PlaylistCacheIcon` se integra perfectamente en los controles:
- Muestra estado de caché de la playlist completa
- Permite cachear/descargar todos los tracks
- Respeta el patrón de usar BLoCs para estado
- Se incluye en `PlaylistControlsWidget` con su propio `BlocProvider`
