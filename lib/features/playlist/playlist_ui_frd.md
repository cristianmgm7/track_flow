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
