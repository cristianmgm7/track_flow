# 🔄 Flujo Completo de Reproducción de Audio - Capa por Capa

## **🎯 Problema Original Identificado**

El audio se reproducía desde URL remota en lugar de archivo cacheado porque se usaban **IDs inconsistentes** entre metadata y cache.

---

## **📋 Flujo Completo: BLoC → Capa Más Profunda**

### **1. 🎮 CAPA DE PRESENTACIÓN - BLoC**

```dart
// lib/features/audio_player/presentation/bloc/audio_player_bloc.dart
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {

  Future<void> _onPlayAudioRequested(
    PlayAudioRequested event,  // ✅ Recibe AudioTrackId consistente
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(AudioPlayerBuffering(currentSession));

    // 🎯 PUNTO 1: Llama al UseCase con trackId consistente
    final result = await _playAudioUseCase(event.trackId);

    result.fold(
      (failure) => emit(AudioPlayerError(failure, currentSession)),
      (_) => // Estado actualizado via SessionStateChanged
    );
  }
}
```

**✅ Estado**: Recibe `AudioTrackId` consistente del dominio de negocio

---

### **2. 🎯 CAPA DE DOMINIO - UseCase**

```dart
// lib/features/audio_player/domain/usecases/play_audio_usecase.dart
class PlayAudioUseCase {

  Future<Either<AudioFailure, void>> call(AudioTrackId trackId) async {
    try {
      // 🎯 PUNTO 2: Obtiene metadata usando trackId consistente
      final metadata = await _audioContentRepository.getTrackMetadata(trackId);

      // 🎯 PUNTO 3: Resuelve fuente de audio (CACHE vs STREAMING)
      final sourceUrl = await _audioContentRepository.getAudioSourceUrl(trackId);

      // 🎯 PUNTO 4: Crea AudioSource para reproducción
      final audioSource = AudioSource(url: sourceUrl, metadata: metadata);

      // 🎯 PUNTO 5: Inicia reproducción
      await _playbackService.play(audioSource);

      return const Right(null);
    } catch (e) {
      // Manejo de errores específicos de audio
    }
  }
}
```

**✅ Estado**: Pasa `AudioTrackId` consistente a todas las operaciones

---

### **3. 🏗️ CAPA DE INFRAESTRUCTURA - Repository**

```dart
// lib/features/audio_player/infrastructure/repositories/audio_content_repository_impl.dart
class AudioContentRepositoryImpl implements AudioContentRepository {

  @override
  Future<String> getAudioSourceUrl(AudioTrackId trackId) async {
    // 🎯 PUNTO 6: Obtiene URL original del dominio de negocio
    final trackResult = await _audioTrackRepository.getTrackById(
      core_ids.AudioTrackId.fromUniqueString(trackId.value),
    );

    return trackResult.fold(
      (failure) => throw Exception('Track not found: ${trackId.value}'),
      (audioTrack) async {
        final originalUrl = audioTrack.url; // 🔗 URL REMOTA

        // 🎯 PUNTO 7: RESOLUCIÓN DE CACHE vs STREAMING
        final sourceResult = await _audioSourceResolver.resolveAudioSource(
          originalUrl,
          trackId: trackId.value, // ✅ ID CONSISTENTE
        );

        return sourceResult.fold(
          (failure) => throw Exception('Audio source not available: ${trackId.value}'),
          (resolvedUrl) => resolvedUrl, // 🎯 RETORNA: cache path O remote URL
        );
      },
    );
  }
}
```

**✅ Estado**: Pasa `trackId` consistente al resolver de cache

---

### **4. 🔍 CAPA DE INFRAESTRUCTURA - AudioSourceResolver**

```dart
// lib/features/audio_player/infrastructure/services/audio_source_resolver_impl.dart
class AudioSourceResolverImpl implements AudioSourceResolver {

  @override
  Future<Either<Failure, String>> resolveAudioSource(
    String originalUrl, {
    String? trackId, // ✅ RECIBE ID CONSISTENTE
  }) async {
    try {
      // 🎯 PUNTO 8: Usa trackId consistente para cache
      final effectiveTrackId = trackId ?? _extractTrackIdFromUrl(originalUrl);

      // 🎯 PUNTO 9: VERIFICA CACHE PRIMERO
      final cacheResult = await validateCachedTrack(
        originalUrl,
        trackId: effectiveTrackId // ✅ ID CONSISTENTE
      );

      if (cacheResult.isRight()) {
        final cachedPath = cacheResult.getOrElse(() => null);
        if (cachedPath != null) {
          return Right(cachedPath); // 🎯 RETORNA: RUTA LOCAL
        }
      }

      // 🎯 PUNTO 10: INICIA CACHE EN BACKGROUND
      await startBackgroundCaching(
        originalUrl,
        trackId: effectiveTrackId // ✅ ID CONSISTENTE
      );

      // 🎯 PUNTO 11: RETORNA URL REMOTA PARA STREAMING
      return Right(originalUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

**✅ Estado**: Usa `trackId` consistente para todas las operaciones de cache

---

### **5. 🗂️ CAPA DE CACHE - CacheOrchestrationService**

```dart
// lib/features/audio_cache/shared/infrastructure/services/cache_orchestration_service_impl.dart
class CacheOrchestrationServiceImpl implements CacheOrchestrationService {

  @override
  Future<Either<CacheFailure, String>> getCachedAudioPath(String trackId) async {
    // 🎯 PUNTO 12: Actualiza último acceso
    await _metadataRepository.updateLastAccessed(trackId);

    // 🎯 PUNTO 13: Obtiene ruta del archivo cacheado
    return await _storageRepository.getCachedAudioPath(trackId);
  }
}
```

**✅ Estado**: Usa `trackId` consistente para buscar en cache

---

### **6. 💾 CAPA DE ALMACENAMIENTO - CacheStorageRepository**

```dart
// lib/features/audio_cache/shared/data/repositories/cache_storage_repository_impl.dart
class CacheStorageRepositoryImpl implements CacheStorageRepository {

  @override
  Future<Either<CacheFailure, CachedAudio>> downloadAndStoreAudio(
    String trackId, // ✅ ID CONSISTENTE
    String audioUrl, // 🔗 URL REMOTA
    {void Function(DownloadProgress)? progressCallback}
  ) async {
    try {
      // 🎯 PUNTO 14: Genera clave de cache
      final cacheKey = _localDataSource.generateCacheKey(trackId, audioUrl);
      final filePathResult = await _localDataSource.getFilePathFromCacheKey(cacheKey);

      return await filePathResult.fold((failure) => Left(failure), (filePath) async {
        // 🎯 PUNTO 15: DESCARGA ARCHIVO REMOTO
        final downloadResult = await _remoteDataSource.downloadAudio(
          audioUrl: audioUrl, // 🔗 URL REMOTA
          localFilePath: filePath, // 📁 RUTA LOCAL
          onProgress: (progress) {
            progressCallback?.call(progress);
          },
        );

        return await downloadResult.fold(
          (failure) => Left(failure),
          (downloadedFile) async {
            // 🎯 PUNTO 16: VERIFICA INTEGRIDAD
            final fileSize = await downloadedFile.length();
            final bytes = await downloadedFile.readAsBytes();
            final checksum = sha1.convert(bytes).toString();

            // 🎯 PUNTO 17: CREA CachedAudioDocument
            final cachedAudio = CachedAudio(
              trackId: trackId, // ✅ ID CONSISTENTE
              filePath: filePath, // 📁 RUTA LOCAL
              fileSizeBytes: fileSize,
              cachedAt: DateTime.now(),
              checksum: checksum,
              quality: AudioQuality.medium,
              status: CacheStatus.cached,
            );

            // 🎯 PUNTO 18: GUARDA EN BASE DE DATOS LOCAL
            final storeResult = await _localDataSource.storeCachedAudio(cachedAudio);

            return storeResult.fold(
              (failure) => Left(failure),
              (audio) => Right(audio), // ✅ RETORNA: CachedAudio con ruta local
            );
          },
        );
      });
    } catch (e) {
      return Left(DownloadCacheFailure('Failed to download: $e'));
    }
  }
}
```

**✅ Estado**: Guarda `trackId` consistente en `CachedAudioDocument`

---

### **7. 🗄️ CAPA DE BASE DE DATOS - CachedAudioDocument**

```dart
// lib/features/audio_cache/shared/data/models/cached_audio_document.dart
@collection
class CachedAudioDocument {
  Id get isarId => fastHash(trackId);

  @Index(unique: true)
  late String trackId; // ✅ ID CONSISTENTE

  late String filePath; // 📁 RUTA LOCAL DEL ARCHIVO
  late int fileSizeBytes;
  late DateTime cachedAt;
  late String checksum;
  late AudioQuality quality;
  late CacheStatus status;
}
```

**✅ Estado**: Almacena `trackId` consistente y `filePath` local

---

## **🎯 RESUMEN DEL FLUJO Y PROBLEMA SOLUCIONADO**

### **🔄 Flujo Completo:**

```
1. BLoC (PlayAudioRequested)
   ↓ AudioTrackId consistente
2. UseCase (PlayAudioUseCase)
   ↓ AudioTrackId consistente
3. Repository (AudioContentRepository)
   ↓ AudioTrackId consistente
4. Resolver (AudioSourceResolver)
   ↓ AudioTrackId consistente
5. Cache Service (CacheOrchestrationService)
   ↓ AudioTrackId consistente
6. Storage Repository (CacheStorageRepository)
   ↓ AudioTrackId consistente
7. Database (CachedAudioDocument)
   ↓ AudioTrackId consistente + filePath local
```

### **🔗 Puntos Clave de Cache:**

- **🎯 PUNTO 7**: `AudioSourceResolver.resolveAudioSource()` - Decide cache vs streaming
- **🎯 PUNTO 9**: `validateCachedTrack()` - Verifica si existe en cache
- **🎯 PUNTO 15**: `downloadAudio()` - Descarga URL remota a archivo local
- **🎯 PUNTO 17**: `CachedAudio` - Crea documento con ruta local
- **🎯 PUNTO 18**: `storeCachedAudio()` - Guarda en base de datos local

### **✅ Problema Solucionado:**

**ANTES:**

```dart
// ❌ IDs inconsistentes
final trackId = _extractTrackIdFromUrl(url); // ID extraído de URL
final metadata = await getTrackMetadata(audioTrackId); // ID del dominio
// Resultado: No encontraba cache porque usaba IDs diferentes
```

**DESPUÉS:**

```dart
// ✅ IDs consistentes
final sourceResult = await _audioSourceResolver.resolveAudioSource(
  originalUrl,
  trackId: trackId.value, // Mismo ID en toda la cadena
);
// Resultado: Encuentra cache correctamente usando ID consistente
```

### **📊 Datos Finales:**

- **AudioTrackDocument**: Mantiene URL remota (`url`)
- **CachedAudioDocument**: Mantiene ruta local (`filePath`)
- **CacheMetadataDocument**: Mantiene estado y referencias
- **CacheReferenceDocument**: Mantiene contador de referencias

**El sistema ahora funciona correctamente: cache primero, streaming como fallback.**
