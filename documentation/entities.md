# TrackFlow - Entidades y Value Objects

## Resumen General

TrackFlow implementa un modelo de dominio robusto siguiendo los principios de Domain-Driven Design (DDD) con una clara separación entre **Entidades** y **Value Objects**. Esta documentación presenta un análisis completo de todas las entidades y value objects encontradas en el proyecto.

### Estadísticas del Dominio
- **Entidades Base**: 2 clases abstractas
- **Entidades de Dominio**: ~45 implementaciones
- **Value Objects**: 19 implementaciones
- **DTOs**: ~15 clases para transferencia de datos
- **Document Models**: ~10 modelos para persistencia

---

## 🏗️ Arquitectura Base

### Clases Base Fundamentales

#### **Entity<T>** (`lib/core/domain/entity.dart`)
```dart
abstract class Entity<T>
```
- Clase base abstracta para todas las entidades
- Implementa igualdad basada en ID
- Proporciona el patrón fundamental para objetos con identidad

#### **AggregateRoot<T>** (`lib/core/domain/aggregate_root.dart`)
```dart
abstract class AggregateRoot<T> extends Entity<T>
```
- Extiende Entity para implementar el patrón Aggregate Root de DDD
- Base para entidades principales que encapsulan otros objetos del dominio

#### **ValueObject<T>** (`lib/core/entities/value_object.dart`)
```dart
abstract class ValueObject<T> extends Equatable
```
- Clase base para todos los value objects
- Implementa igualdad basada en valor usando Equatable

---

## 🆔 Sistema de Identificación

### Value Objects de Identificación

#### **UniqueId** (`lib/core/entities/unique_id.dart`)
- **UniqueId**: Identificador base usando UUID
- **UserId**: Identificación de usuarios
- **ProjectId**: Identificación de proyectos
- **AudioTrackId**: Identificación de pistas de audio (dominio)
- **AudioCommentId**: Identificación de comentarios de audio

#### **Identificadores Específicos por Feature**
- **ProjectCollaboratorId** (`lib/features/projects/domain/value_objects/project_collaborator_id.dart`)
- **PlaylistId** (`lib/features/playlist/domain/entities/playlist_id.dart`)
- **AudioTrackId** (`lib/features/audio_player/domain/entities/audio_track_id.dart`) - Para reproductor

---

## 👤 Gestión de Usuarios e Identidad

### Entidades de Usuario

#### **User** (`lib/features/auth/domain/entities/user.dart`)
```dart
class User extends Entity<UserId>
```
- Entidad principal para autenticación
- Maneja información básica del usuario autenticado

#### **UserProfile** (`lib/features/user_profile/domain/entities/user_profile.dart`)
```dart
class UserProfile extends Entity<UserId>
```
- Perfil extendido del usuario
- Incluye roles creativos y información adicional

### Value Objects de Autenticación

#### **EmailAddress** (`lib/features/auth/domain/entities/email.dart`)
```dart
class EmailAddress extends ValueObject<String>
```
- Validación de formato de email
- Retorna Either<Failure, String> para manejo de errores

#### **PasswordValue** (`lib/features/auth/domain/entities/password.dart`)
```dart
class PasswordValue extends ValueObject<String>
```
- Validación de contraseñas
- Implementa reglas de seguridad

#### **UserCreativeRole** (`lib/core/entities/user_creative_role.dart`)
```dart
enum UserCreativeRole
```
- Roles creativos: producer, songwriter, mixing engineer, etc.
- Define capacidades y permisos del usuario

---

## 📁 Gestión de Proyectos

### Entidad Principal

#### **Project** (`lib/features/projects/domain/entities/project.dart`)
```dart
class Project extends AggregateRoot<ProjectId>
```
**Características principales:**
- Aggregate Root principal del dominio de proyectos
- Gestión de colaboradores con roles y permisos
- Operaciones basadas en permisos
- Funcionalidad de soft delete
- Conversión a playlist
- Validación de membresía

**Métodos clave:**
- `addCollaborator()` - Agregar colaboradores
- `removeCollaborator()` - Remover colaboradores
- `updateCollaboratorRole()` - Actualizar roles
- `canUserEdit()` - Validación de permisos
- `toPlaylist()` - Convertir a playlist

#### **ProjectCollaborator** (`lib/features/projects/domain/entities/project_collaborator.dart`)
```dart
class ProjectCollaborator extends Entity<ProjectCollaboratorId>
```
- Gestión de colaboradores individuales
- Sistema de roles y permisos
- Validaciones específicas de permisos
- Sobrescritura de permisos individuales

### Value Objects de Proyecto

#### **ProjectName** (`lib/features/projects/domain/value_objects/project_name.dart`)
```dart
class ProjectName extends ValueObject<String>
```
- Validación de nombres (máximo 50 caracteres)
- Reglas de formato y contenido

#### **ProjectDescription** (`lib/features/projects/domain/value_objects/project_description.dart`)
```dart
class ProjectDescription extends ValueObject<String>
```
- Validación de descripciones (máximo 500 caracteres)
- Formateo y sanitización

#### **ProjectRole** (`lib/features/projects/domain/value_objects/project_role.dart`)
```dart
enum ProjectRole { owner, admin, editor, viewer }
```
- Jerarquía de roles en proyectos
- Define niveles de acceso y permisos

#### **ProjectPermission** (`lib/features/projects/domain/value_objects/project_permission.dart`)
```dart
enum ProjectPermission
```
- Permisos granulares específicos
- Control de acceso fino

---

## 🎵 Sistema de Audio

### Entidades de Contenido de Audio

#### **AudioTrack** (`lib/features/audio_track/domain/entities/audio_track.dart`)
```dart
class AudioTrack extends Entity<AudioTrackId>
```
**Características:**
- Metadatos de pista (nombre, URL, duración)
- Asociación con proyectos
- Seguimiento de uploads
- Validación de membresía de proyecto

#### **AudioComment** (`lib/features/audio_comment/domain/entities/audio_comment.dart`)
```dart
class AudioComment extends Entity<AudioCommentId>
```
- Comentarios con marcas de tiempo
- Asociados a pistas específicas
- Sistema de threading/respuestas

### Sistema de Reproductor de Audio

#### **PlaybackSession** (`lib/features/audio_player/domain/entities/playback_session.dart`)
```dart
class PlaybackSession extends Entity<UniqueId>
```
**Funcionalidades centrales:**
- Estado de pista actual
- Gestión de cola de audio
- Controles de reproducción (play/pause/stop)
- Seguimiento de posición y progreso
- Control de volumen y velocidad
- Manejo de errores de reproducción

**Entidades relacionadas:**
- **AudioTrackMetadata** - Metadatos para el reproductor
- **PlaybackState** - Estados de reproducción
- **RepeatMode** - Modos de repetición
- **AudioSource** - Abstracciones de fuente de audio
- **AudioFailure** - Manejo de errores
- **AudioQueue** - Gestión de cola

### Sistema de Playlists

#### **Playlist** (`lib/features/playlist/domain/entities/playlist.dart`)
```dart
class Playlist extends Entity<PlaylistId>
```
**Características:**
- Colección de IDs de pistas
- Seguimiento de fuente (proyecto vs usuario)
- Operaciones de gestión de playlist

---

## 🗂️ Sistema de Cache de Audio

### Entidades de Cache

#### **CachedAudio** (`lib/features/audio_cache/shared/domain/entities/cached_audio.dart`)
```dart
class CachedAudio extends Entity<UniqueId>
```
**Funcionalidades:**
- Información del sistema de archivos
- Seguimiento de estado de cache
- Niveles de calidad
- Validación de checksum

**Entidades relacionadas:**
- **CacheReference** - Gestión de referencias de cache
- **CacheMetadata** - Metadatos de cache
- **DownloadProgress** - Seguimiento de descargas
- **CacheValidationResult** - Resultados de validación
- **CleanupDetails** - Seguimiento de limpieza
- **PlaylistCacheStats** - Estadísticas de cache de playlist

### Value Objects de Cache

#### **CacheKey** (`lib/features/audio_cache/shared/domain/value_objects/cache_key.dart`)
```dart
class CacheKey extends ValueObject<String>
```
- Generación de claves compuestas
- Hash de URLs
- Validación de integridad

#### **StorageLimit** (`lib/features/audio_cache/shared/domain/value_objects/storage_limit.dart`)
```dart
class StorageLimit extends ValueObject<int>
```
- Conversiones byte/MB/GB
- Cálculos de uso
- Validación de límites

#### **ConflictPolicy** (`lib/features/audio_cache/shared/domain/value_objects/conflict_policy.dart`)
```dart
enum ConflictPolicy
```
- Políticas de resolución de conflictos
- Estrategias de sobrescritura

#### **CleanupResult** (`lib/features/audio_cache/shared/domain/value_objects/cleanup_result.dart`)
```dart
class CleanupResult extends ValueObject<Map<String, dynamic>>
```
- Resultados inmutables de operaciones de limpieza
- Estadísticas de limpieza

---

## 🔗 Otros Dominios

### Autenticación por Magic Link

#### **MagicLink** (`lib/features/magic_link/domain/entities/magic_link.dart`)
```dart
class MagicLink extends Entity<UniqueId>
```
- Autenticación sin contraseña
- Tokens temporales con expiración

### Contexto de Audio

#### **TrackContext** (`lib/features/audio_context/domain/entities/track_context.dart`)
```dart
class TrackContext extends Entity<UniqueId>
```
- Información contextual de pistas
- Metadatos adicionales para reproducción

---

## 📋 Capa de Transferencia de Datos

### Data Transfer Objects (DTOs)

El proyecto incluye DTOs completos para serialización:

- **AuthDto** - Autenticación con Firebase
- **ProjectDTO** - Integración con Firestore
- **AudioTrackDTO** - Transferencia de datos de pistas
- **AudioCommentDto** - Datos de comentarios
- **UserProfileDto** - Datos de perfil
- **PlaylistDto** - Datos de playlist
- **MagicLinkDto** - Autenticación por enlace mágico

### Document Models

Modelos de documentos de base de datos con generación de código:
- Documentos de proyecto, pistas de audio, comentarios
- Documentos de perfil de usuario, playlists
- Documentos de referencias de cache, audio cacheado

---

## 🏛️ Patrones Arquitectónicos

### Domain-Driven Design (DDD)

El codebase sigue principios DDD con:

1. **Entidades** - Objetos con identidad que extienden la clase base Entity
2. **Aggregate Roots** - Objetos de negocio complejos (como Project)
3. **Value Objects** - Datos inmutables con igualdad basada en valor
4. **DTOs** - Transferencia de datos entre capas
5. **Document Models** - Persistencia en base de datos

### Separación de Responsabilidades

- **Domain Layer**: Entidades y value objects puros
- **Data Layer**: DTOs y document models
- **Infrastructure**: Implementaciones específicas

### Validación y Reglas de Negocio

- Value objects encapsulan validaciones
- Entidades implementan reglas de negocio complejas
- Sistema de permisos granular en Project

---

## 📊 Resumen por Categorías

### Entidades (45+ implementaciones)
- **Base**: 2 clases abstractas
- **Identificación y Usuario**: 4 entidades
- **Gestión de Proyectos**: 2 entidades principales
- **Audio**: 15+ entidades (tracks, player, cache)
- **Playlists**: 1 entidad
- **Otros Dominios**: 3 entidades

### Value Objects (19 implementaciones)
- **Base**: 1 clase abstracta
- **IDs**: 7 tipos diferentes
- **Autenticación**: 2 value objects validados
- **Proyecto**: 4 value objects específicos
- **Cache de Audio**: 4 value objects
- **Roles**: 1 value object

### Transferencia de Datos
- **DTOs**: 15+ clases
- **Document Models**: 10+ modelos

---

## 🔍 Observaciones Arquitectónicas

1. **Consistencia**: Uso consistente de patrones DDD en todo el proyecto
2. **Separación Clara**: Distinción bien definida entre entidades y value objects
3. **Validación Robusta**: Value objects encapsulan todas las reglas de validación
4. **Escalabilidad**: Arquitectura preparada para crecimiento
5. **Type Safety**: Fuerte tipado con identificadores específicos por dominio
6. **Error Handling**: Uso de Either<Failure, T> para manejo de errores

La arquitectura de TrackFlow demuestra una implementación madura y bien estructurada de DDD, proporcionando una base sólida para una plataforma de producción de audio colaborativa con capacidades sofisticadas de reproducción, cache y gestión de proyectos.