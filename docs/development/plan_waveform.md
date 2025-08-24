# Plan de Migración: Sistema de Waveform Client-Side

## Resumen Ejecutivo

Este documento detalla la migración del sistema actual de waveform basado en la librería `audio_waveforms` hacia un sistema client-side que genere, almacene y sincronice waveforms de manera consistente entre todos los dispositivos. La nueva arquitectura prepara el codebase para futuras funcionalidades de ML audio splitting.

## Problemas Actuales Identificados

### 1. Inconsistencia de Renderizado
- **Problema**: La forma de onda se renderiza diferente dependiendo de si el audio está en caché o no
- **Ubicación**: `lib/features/audio_comment/presentation/waveform_bloc/audio_waveform_bloc.dart:86-146`
- **Causa**: Dependencia directa de `PlayerController` de la librería `audio_waveforms` que usa archivos locales cached

### 2. Falta de Sincronización
- **Problema**: Cada dispositivo puede mostrar waveforms diferentes para el mismo track
- **Causa**: No existe un documento unificado de waveform compartido entre usuarios

### 3. Limitaciones para ML Features
- **Problema**: Arquitectura actual no está preparada para múltiples waveforms por track (splits)
- **Impacto**: Bloquea futuras funcionalidades de análisis ML y splits automáticos

## Arquitectura Propuesta

### Nuevo Domain Layer

#### Entidades Core

```dart
// lib/features/waveform/domain/entities/audio_waveform.dart
class AudioWaveform extends Entity<AudioWaveformId> {
  final AudioTrackId trackId;
  final WaveformData data;
  final WaveformType type; // full, split
  final String? splitId; // null for full track, UUID for splits
  final WaveformMetadata metadata;
  final DateTime generatedAt;
  
  // Business rules
  bool isFullTrack() => splitId == null;
  bool belongsToSplit(String splitId) => this.splitId == splitId;
}

// lib/features/waveform/domain/value_objects/waveform_data.dart
class WaveformData extends ValueObject {
  final List<double> amplitudes;
  final int sampleRate;
  final Duration duration;
  final int targetSampleCount;
  
  // Validation rules
  bool get isValid => amplitudes.isNotEmpty && duration.inMilliseconds > 0;
  List<double> get normalizedAmplitudes => _normalizeAmplitudes();
}

// lib/features/waveform/domain/value_objects/waveform_metadata.dart
class WaveformMetadata extends ValueObject {
  final double maxAmplitude;
  final double rmsLevel;
  final int compressionLevel;
  final String generationMethod; // 'client_fft', 'ml_analysis', etc.
}
```

#### Repository Contracts

```dart
// lib/features/waveform/domain/repositories/waveform_repository.dart
abstract class WaveformRepository {
  // Core operations
  Future<Either<WaveformFailure, AudioWaveform>> getWaveformByTrackId(AudioTrackId trackId);
  Future<Either<WaveformFailure, List<AudioWaveform>>> getWaveformsByTrackId(AudioTrackId trackId);
  Future<Either<WaveformFailure, Unit>> saveWaveform(AudioWaveform waveform);
  Future<Either<WaveformFailure, Unit>> deleteWaveformsForTrack(AudioTrackId trackId);
  
  // Split support (future ML feature)
  Future<Either<WaveformFailure, List<AudioWaveform>>> getWaveformsBySplit(AudioTrackId trackId, String splitId);
  
  // Sync operations
  Stream<AudioWaveform> watchWaveformChanges(AudioTrackId trackId);
  Future<Either<WaveformFailure, Unit>> syncWaveformsToRemote(List<AudioWaveform> waveforms);
}
```

#### Domain Services

```dart
// lib/features/waveform/domain/services/waveform_generator_service.dart
abstract class WaveformGeneratorService {
  Future<Either<WaveformFailure, AudioWaveform>> generateWaveform(
    AudioTrackId trackId,
    String audioFilePath, {
    int? targetSampleCount,
    String? splitId,
  });
  
  Future<Either<WaveformFailure, List<AudioWaveform>>> generateSplitWaveforms(
    AudioTrackId trackId,
    String audioFilePath,
    List<AudioSplit> splits, // Future ML feature
  );
}

// lib/features/waveform/domain/services/waveform_compression_service.dart
abstract class WaveformCompressionService {
  List<double> compressAmplitudes(List<double> amplitudes, int targetCount);
  List<double> decompressAmplitudes(List<double> compressed, int originalCount);
  WaveformData optimizeForSync(WaveformData data);
}
```

### Use Cases

```dart
// lib/features/waveform/domain/usecases/generate_waveform_usecase.dart
@injectable
class GenerateWaveformUseCase {
  final WaveformGeneratorService _generatorService;
  final WaveformRepository _repository;
  final GetCachedTrackPathUseCase _getCachedPathUseCase;
  
  Future<Either<WaveformFailure, AudioWaveform>> call(
    GenerateWaveformParams params,
  ) async {
    // 1. Get cached audio file path
    final pathResult = await _getCachedPathUseCase(params.trackId.value);
    
    // 2. Generate waveform from audio file
    return pathResult.fold(
      (failure) => Left(WaveformFailure.audioNotCached()),
      (filePath) async {
        if (filePath == null) return Left(WaveformFailure.audioNotCached());
        
        final waveformResult = await _generatorService.generateWaveform(
          params.trackId,
          filePath,
          targetSampleCount: params.targetSampleCount,
        );
        
        // 3. Save generated waveform
        return waveformResult.fold(
          (failure) => Left(failure),
          (waveform) async {
            await _repository.saveWaveform(waveform);
            return Right(waveform);
          },
        );
      },
    );
  }
}

// lib/features/waveform/domain/usecases/get_or_generate_waveform_usecase.dart
@injectable
class GetOrGenerateWaveformUseCase {
  final WaveformRepository _repository;
  final GenerateWaveformUseCase _generateUseCase;
  
  Future<Either<WaveformFailure, AudioWaveform>> call(AudioTrackId trackId) async {
    // Try to get existing waveform first
    final existingResult = await _repository.getWaveformByTrackId(trackId);
    
    return existingResult.fold(
      (failure) async {
        // Generate if not found
        return _generateUseCase(GenerateWaveformParams(trackId: trackId));
      },
      (waveform) async => Right(waveform),
    );
  }
}
```

### Data Layer

#### Isar Document

```dart
// lib/features/waveform/data/models/audio_waveform_document.dart
@collection
class AudioWaveformDocument {
  Id get isarId => fastHash(id);
  
  @Index(unique: true)
  late String id;
  
  @Index()
  late String trackId;
  
  late String amplitudesJson; // JSON serialized List<double>
  late int sampleRate;
  late int durationMs;
  late int targetSampleCount;
  
  // Metadata
  late double maxAmplitude;
  late double rmsLevel;
  late int compressionLevel;
  late String generationMethod;
  
  // Split support (future ML feature)
  String? splitId;
  
  late DateTime generatedAt;
  
  /// Sync metadata
  SyncMetadataDocument? syncMetadata;
  
  // Conversion methods
  AudioWaveform toEntity() {
    final amplitudes = (jsonDecode(amplitudesJson) as List)
        .cast<double>();
    
    return AudioWaveform(
      id: AudioWaveformId.fromUniqueString(id),
      trackId: AudioTrackId.fromUniqueString(trackId),
      data: WaveformData(
        amplitudes: amplitudes,
        sampleRate: sampleRate,
        duration: Duration(milliseconds: durationMs),
        targetSampleCount: targetSampleCount,
      ),
      type: splitId == null ? WaveformType.full : WaveformType.split,
      splitId: splitId,
      metadata: WaveformMetadata(
        maxAmplitude: maxAmplitude,
        rmsLevel: rmsLevel,
        compressionLevel: compressionLevel,
        generationMethod: generationMethod,
      ),
      generatedAt: generatedAt,
    );
  }
  
  static AudioWaveformDocument fromEntity(AudioWaveform waveform) {
    return AudioWaveformDocument()
      ..id = waveform.id.value
      ..trackId = waveform.trackId.value
      ..amplitudesJson = jsonEncode(waveform.data.amplitudes)
      ..sampleRate = waveform.data.sampleRate
      ..durationMs = waveform.data.duration.inMilliseconds
      ..targetSampleCount = waveform.data.targetSampleCount
      ..maxAmplitude = waveform.metadata.maxAmplitude
      ..rmsLevel = waveform.metadata.rmsLevel
      ..compressionLevel = waveform.metadata.compressionLevel
      ..generationMethod = waveform.metadata.generationMethod
      ..splitId = waveform.splitId
      ..generatedAt = waveform.generatedAt
      ..syncMetadata = SyncMetadataDocument.initial();
  }
}
```

#### Repository Implementation

```dart
// lib/features/waveform/data/repositories/waveform_repository_impl.dart
@Injectable(as: WaveformRepository)
class WaveformRepositoryImpl implements WaveformRepository {
  final WaveformLocalDataSource _localDataSource;
  final WaveformRemoteDataSource _remoteDataSource;
  
  @override
  Future<Either<WaveformFailure, AudioWaveform>> getWaveformByTrackId(
    AudioTrackId trackId,
  ) async {
    try {
      // Try local first
      final localWaveform = await _localDataSource.getWaveformByTrackId(trackId);
      if (localWaveform != null) {
        return Right(localWaveform);
      }
      
      // Fallback to remote
      final remoteResult = await _remoteDataSource.getWaveformByTrackId(trackId);
      return remoteResult.fold(
        (failure) => Left(failure),
        (waveform) async {
          // Cache locally
          await _localDataSource.saveWaveform(waveform);
          return Right(waveform);
        },
      );
    } catch (e) {
      return Left(WaveformFailure.repositoryError(e.toString()));
    }
  }
}
```

### Presentation Layer

#### New Waveform BLoC

```dart
// lib/features/waveform/presentation/bloc/enhanced_waveform_bloc.dart
class EnhancedWaveformBloc extends Bloc<EnhancedWaveformEvent, EnhancedWaveformState> {
  final GetOrGenerateWaveformUseCase _getOrGenerateUseCase;
  final AudioPlaybackService _audioPlaybackService;
  
  EnhancedWaveformBloc({
    required GetOrGenerateWaveformUseCase getOrGenerateUseCase,
    required AudioPlaybackService audioPlaybackService,
  }) : _getOrGenerateUseCase = getOrGenerateUseCase,
       _audioPlaybackService = audioPlaybackService,
       super(EnhancedWaveformState.initial()) {
    
    on<LoadWaveformRequested>(_onLoadWaveformRequested);
    on<WaveformSeekRequested>(_onWaveformSeekRequested);
    on<_PlaybackPositionUpdated>(_onPlaybackPositionUpdated);
  }
  
  Future<void> _onLoadWaveformRequested(
    LoadWaveformRequested event,
    Emitter<EnhancedWaveformState> emit,
  ) async {
    emit(state.copyWith(status: WaveformStatus.loading));
    
    final result = await _getOrGenerateUseCase(event.trackId);
    
    result.fold(
      (failure) => emit(state.copyWith(
        status: WaveformStatus.error,
        errorMessage: failure.message,
      )),
      (waveform) => emit(state.copyWith(
        status: WaveformStatus.ready,
        waveform: waveform,
        // Fallback to library waveform if needed
        shouldUseFallback: false,
      )),
    );
  }
}

// States
class EnhancedWaveformState extends Equatable {
  final WaveformStatus status;
  final AudioWaveform? waveform;
  final String? errorMessage;
  final Duration currentPosition;
  final bool shouldUseFallback;
  final PlayerController? fallbackController; // For backward compatibility
  
  const EnhancedWaveformState({
    this.status = WaveformStatus.initial,
    this.waveform,
    this.errorMessage,
    this.currentPosition = Duration.zero,
    this.shouldUseFallback = false,
    this.fallbackController,
  });
}
```

#### Enhanced UI Component

```dart
// lib/features/waveform/presentation/widgets/enhanced_waveform_display.dart
class EnhancedWaveformDisplay extends StatelessWidget {
  final AudioTrackId trackId;
  final double height;
  final Color? waveColor;
  final Color? progressColor;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EnhancedWaveformBloc, EnhancedWaveformState>(
      builder: (context, state) {
        switch (state.status) {
          case WaveformStatus.loading:
            return _buildLoadingState();
          case WaveformStatus.error:
            // Fallback to old system when error occurs
            return _buildFallbackWaveform(context, state);
          case WaveformStatus.ready:
            if (state.waveform != null) {
              return _buildGeneratedWaveform(context, state);
            } else {
              return _buildFallbackWaveform(context, state);
            }
          default:
            return _buildInitialState();
        }
      },
    );
  }
  
  Widget _buildGeneratedWaveform(BuildContext context, EnhancedWaveformState state) {
    return CustomPaint(
      size: Size.fromHeight(height),
      painter: WaveformPainter(
        amplitudes: state.waveform!.data.normalizedAmplitudes,
        currentPosition: state.currentPosition,
        duration: state.waveform!.data.duration,
        waveColor: waveColor ?? Theme.of(context).primaryColor,
        progressColor: progressColor ?? Theme.of(context).accentColor,
      ),
    );
  }
  
  Widget _buildFallbackWaveform(BuildContext context, EnhancedWaveformState state) {
    // Use legacy AudioCommentWaveformDisplay as fallback
    return AudioCommentWaveformDisplay(trackId: trackId);
  }
}

// Custom painter for generated waveforms
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Duration currentPosition;
  final Duration duration;
  final Color waveColor;
  final Color progressColor;
  
  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;
    
    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final barWidth = size.width / amplitudes.length;
    final centerY = size.height / 2;
    final progressX = (currentPosition.inMilliseconds / duration.inMilliseconds) * size.width;
    
    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * barWidth;
      final barHeight = amplitudes[i] * centerY;
      
      // Choose paint based on playback progress
      final currentPaint = x <= progressX ? progressPaint : paint;
      
      // Draw amplitude bar
      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        currentPaint,
      );
    }
    
    // Draw progress line
    canvas.drawLine(
      Offset(progressX, 0),
      Offset(progressX, size.height),
      Paint()
        ..color = progressColor
        ..strokeWidth = 1.5,
    );
  }
  
  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return amplitudes != oldDelegate.amplitudes ||
           currentPosition != oldDelegate.currentPosition ||
           waveColor != oldDelegate.waveColor ||
           progressColor != oldDelegate.progressColor;
  }
}
```

### Integración con Upload Flow

#### Modificación del Upload Use Case

```dart
// lib/features/audio_track/domain/usecases/up_load_audio_track_usecase.dart
@lazySingleton
class UploadAudioTrackUseCase {
  final ProjectTrackService projectTrackService;
  final ProjectsRepository projectDetailRepository;
  final SessionStorage sessionStorage;
  final GenerateWaveformUseCase _generateWaveformUseCase; // NEW
  
  Future<Either<Failure, Unit>> call(UploadAudioTrackParams params) async {
    // ... existing upload logic ...
    
    final result = await projectTrackService.addTrackToProject(
      project: project,
      requester: UserId.fromUniqueString(userId),
      name: params.name,
      url: params.file.path,
      duration: params.duration,
    );
    
    // NEW: Generate waveform after successful upload
    return result.fold(
      (failure) => Left(failure),
      (unit) async {
        // Extract trackId from the uploaded track
        // This might require modifying projectTrackService to return the created track
        // For now, we'll trigger waveform generation in background
        _triggerWaveformGeneration(params.file.path, params.duration);
        return Right(unit);
      },
    );
  }
  
  void _triggerWaveformGeneration(String filePath, Duration duration) async {
    // Background generation - don't block upload completion
    try {
      // This would need the actual trackId from the upload result
      // await _generateWaveformUseCase(GenerateWaveformParams(...));
    } catch (e) {
      // Log error but don't fail upload
      AppLogger.error('Failed to generate waveform after upload', error: e);
    }
  }
}
```

## Plan de Implementación

### Fase 1: Fundaciones (1-2 semanas)
- [ ] Crear estructura de carpetas para feature `waveform`
- [ ] Implementar entidades domain (`AudioWaveform`, `WaveformData`, `WaveformMetadata`)
- [ ] Crear value objects y validaciones
- [ ] Definir contratos de repository y servicios
- [ ] Implementar `AudioWaveformDocument` en Isar
- [ ] Configurar dependency injection

### Fase 2: Core Services (2-3 semanas)
- [ ] Implementar `WaveformGeneratorService` con FFT analysis
- [ ] Crear `WaveformCompressionService` para optimización
- [ ] Implementar `WaveformRepository` con local/remote data sources
- [ ] Crear use cases (`GenerateWaveformUseCase`, `GetOrGenerateWaveformUseCase`)
- [ ] Configurar Firebase sync para waveform documents

### Fase 3: Presentation Layer (2 semanas)
- [ ] Implementar `EnhancedWaveformBloc`
- [ ] Crear `EnhancedWaveformDisplay` widget con fallback
- [ ] Implementar `WaveformPainter` customizado
- [ ] Integrar gesture handling y seek functionality
- [ ] Testing exhaustivo de UI components

### Fase 4: Integración (1 semana)
- [ ] Modificar `UploadAudioTrackUseCase` para trigger waveform generation
- [ ] Actualizar routing y dependency injection
- [ ] Reemplazar `AudioCommentWaveformDisplay` gradualmente
- [ ] Mantener backward compatibility con sistema actual

### Fase 5: Testing y Optimización (1 semana)
- [ ] Unit tests para domain layer
- [ ] Integration tests para repository
- [ ] Widget tests para UI components
- [ ] Performance testing con archivos de audio grandes
- [ ] Error handling y edge cases

## Preparación para ML Audio Splits

### Arquitectura Extensible

La nueva arquitectura está diseñada para soportar múltiples waveforms por track:

```dart
// Futuro support para ML splits
class AudioSplit extends Entity<AudioSplitId> {
  final AudioTrackId trackId;
  final Duration startTime;
  final Duration endTime;
  final SegmentType type; // speech, music, silence, noise
  final double confidence;
}

// Extended use case para splits
Future<Either<WaveformFailure, List<AudioWaveform>>> generateSplitWaveforms(
  AudioTrackId trackId,
  List<AudioSplit> splits,
) async {
  // Generate individual waveforms for each split
  // Each waveform will have the same trackId but different splitId
}
```

### Database Schema Evolution

```dart
// AudioWaveformDocument ya incluye splitId para futuras expansiones
@collection
class AudioWaveformDocument {
  // ... existing fields ...
  
  String? splitId; // null = full track, UUID = specific split
  
  // Split-specific metadata (future)
  String? splitType; // 'speech', 'music', 'silence', 'noise'
  double? confidence; // ML confidence score
  int? startTimeMs; // Split start time
  int? endTimeMs; // Split end time
}
```

### UI Components Preparados

```dart
// Enhanced display puede mostrar múltiples waveforms
class EnhancedWaveformDisplay extends StatelessWidget {
  final AudioTrackId trackId;
  final String? splitId; // null = show full track, UUID = show specific split
  final bool showAllSplits; // Show overlaid split waveforms
  
  Widget _buildSplitWaveforms(List<AudioWaveform> splitWaveforms) {
    return Stack(
      children: splitWaveforms.map((waveform) => 
        Positioned.fill(
          child: CustomPaint(
            painter: WaveformPainter(
              amplitudes: waveform.data.normalizedAmplitudes,
              color: _getColorForSplit(waveform.splitId),
              opacity: 0.6,
            ),
          ),
        ),
      ).toList(),
    );
  }
}
```

## Migración Gradual

### Estrategia de Rollout

1. **Dual System**: Mantener ambos sistemas funcionando en paralelo
2. **Feature Flag**: Usar feature flags para controlar qué usuarios ven el nuevo sistema
3. **Gradual Migration**: Migrar pantallas una por una
4. **Fallback Always**: Siempre tener fallback al sistema anterior en caso de errores
5. **Performance Monitoring**: Monitorear performance y memory usage del nuevo sistema

### Backward Compatibility

```dart
// Wrapper que decide qué sistema usar
class WaveformDisplayWrapper extends StatelessWidget {
  final AudioTrackId trackId;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeatureFlagsBloc, FeatureFlagsState>(
      builder: (context, flagsState) {
        if (flagsState.isEnhancedWaveformEnabled) {
          return EnhancedWaveformDisplay(trackId: trackId);
        } else {
          return AudioCommentWaveformDisplay(trackId: trackId);
        }
      },
    );
  }
}
```

## Consideraciones Técnicas

### Performance
- **Memory Usage**: Comprimir amplitudes para reducir uso de memoria
- **Generation Time**: Usar isolates para generation en background
- **Caching**: Cache waveforms generados para evitar regeneración
- **Progressive Loading**: Cargar waveforms progresivamente para archivos grandes

### Error Handling
- **Generation Failures**: Fallback al sistema actual si generation falla
- **Sync Failures**: Mantener waveforms locales aunque sync falle
- **File Access**: Handle casos donde archivo cached no está disponible
- **Network Issues**: Funcionalidad offline-first mantenida

### Security
- **File Access**: Validar que solo archivos de audio sean procesados
- **Resource Limits**: Limitar tamaño de archivos que pueden ser procesados
- **Memory Bounds**: Prevenir memory leaks con archivos muy grandes

## Métricas de Éxito

### Technical KPIs
- [ ] Waveform generation time < 3x audio duration
- [ ] Memory usage < 100MB durante generation
- [ ] 100% consistency entre dispositivos para mismo track
- [ ] < 1% fallback rate al sistema anterior

### User Experience KPIs  
- [ ] Tiempo de carga de waveform < 2 segundos
- [ ] 0 inconsistencias visuales reportadas
- [ ] Mantener 60fps durante playback y seek
- [ ] 99.9% uptime de funcionalidad de waveform

### Preparación ML KPIs
- [ ] Arquitectura soporta > 10 splits por track
- [ ] Database schema escalable para 1M+ waveforms
- [ ] API endpoints preparados para ML metadata
- [ ] UI components renders múltiples waveforms sin performance issues

Este plan proporciona una migración estructurada que resuelve los problemas actuales mientras prepara el sistema para futuras funcionalidades de ML audio processing.