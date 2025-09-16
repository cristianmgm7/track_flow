# ML Audio Processing Implementation Plan

## Executive Summary

This document outlines the implementation plan for transforming TrackFlow from a collaborative audio repository into an intelligent platform that leverages machine learning models to process and enrich audio content directly on the device with an offline-first approach.

## Consolidated Scope & Decisions (Single Source of Truth)

This section consolidates and clarifies the plan. It supersedes overlapping details from the technical architecture notes and ad-hoc notes.

- **Primary Goal (now)**: Ship independent waveform generation, storage, and sync, and prepare the ML pipeline foundation without breaking current features.
- **Dual Waveform Strategy**: Keep current `audio_waveforms` display as fallback. Generate our own waveform data for ML and collaboration; use it when available.
- **Trigger Point**: On successful audio upload (`upload_audio_track_usecase`), invoke a new service to extract waveform and (optionally) kick off ML processing.
- **Waveform Storage & Sync**:
  - Store a separate `AudioWaveformDocument` in Isar to keep `AudioTrack` SRP-compliant.
  - Sync a compressed/downsampled amplitude array to Firebase so collaborators see the same waveform.
  - Default `targetSampleCount = 2000` (adaptive by duration: short clips 1000–1500, long clips 3000–4000). Representation: `List<double>` of peak amplitudes in bins.
- **ML Processing (YAMNet)**:
  - Input: 16kHz mono float32 in [-1, 1], 0.96s window, 0.48s hop.
  - Outputs locally: class scores, embeddings, mel spectrogram; derive segments (speech, music, silence, noise).
  - Storage: `AudioMLProcessingDocument` in Isar. Sync only lightweight, collaborative data (segments, minimal metadata). Keep embeddings/spectrogram local.
- **UI Integration**: Enhanced waveform component overlays segments when present; otherwise shows current library waveform. Commenting UX remains unchanged.
- **Out of Scope (track separately)**: `AudioTrack.stage` field, recording integration, and an "AI" button workflow. These will be planned after M2.

### Milestones

1. M1 – Waveform Extraction & Sync

   - Waveform extractor service; invoked from upload use case
   - `AudioWaveformDocument` in Isar + Firebase sync of compressed amplitudes
   - Fallback to library waveform when missing

2. M2 – ML Processing Core

   - YAMNet integration via TFLite; preprocessing pipeline; local storage of outputs
   - Segment detection with confidence; repository to fetch processing results

3. M3 – UI Overlays

   - Hybrid waveform component with segment overlays and position marker

4. M4 – Smart Comments (optional for first release)

   - Comment suggestions from segments

5. M5 – Integration & Performance
   - Background processing, caching, error handling, benchmarks

### Defaults & Parameters

- Waveform: `targetSampleCount = 2000` default, adaptive by duration; peaks per bin representation
- YAMNet: window 0.96s, hop 0.48s; resample to 16kHz mono
- Sync policy: segments and compressed waveform only; heavy ML artifacts remain local

## Current Architecture Analysis

### Audio Processing Infrastructure

- **Audio Player**: Centralized `AudioPlaybackService` with single `AudioPlayer` instance
- **Waveform System**: Uses `audio_waveforms` library with `PlayerController` for visualization
- **Caching Layer**: Isar-based local storage with Firebase sync for offline-first functionality
- **Comment System**: Timestamp-based annotations with real-time collaboration

### Domain Structure

- **Clean Architecture**: Well-established DDD patterns with domain/data/presentation layers
- **Dependency Injection**: Uses `get_it` and `injectable` for loose coupling
- **Error Handling**: Functional error handling with `Either<Failure, Success>` pattern
- **State Management**: BLoC pattern consistently applied across features

### Data Flow

- **Firebase/Isar Integration**: Sync metadata pattern for offline-first functionality
- **Audio Sources**: URL-based with metadata tracking
- **Collaborative Features**: Real-time updates through Firestore streams

## Proposed ML Audio Processing Feature

### Core Concept

Implement on-device ML processing using TensorFlow Lite to analyze audio content and extract meaningful segments, features, and metadata without server-side processing.

### Key Components

#### 1. Audio Analysis Engine

- **YAMNet Integration**: Pre-trained model for audio event classification
- **Spectral Analysis**: Extract spectrograms and audio features
- **Segment Detection**: Identify speech, music, silence, and background noise
- **Waveform Enhancement**: Generate detailed waveform data with semantic markers

#### 2. Processing Pipeline

```
Audio Upload → Cache Locally → ML Analysis → Feature Extraction → Store Results → Sync to Firebase
```

#### 3. Collaborative Enhancement

- **Shared Segments**: Synchronized segment markers across collaborators
- **Intelligent Comments**: Auto-suggest comment placement based on detected events
- **Visual Enhancements**: Enhanced waveform with semantic coloring

## Technical Implementation Plan

### Phase 1: Core ML Infrastructure

#### 1.1 Dependencies and Setup

```yaml
dependencies:
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.3.1
  path_provider: ^2.1.2
  ffi: ^2.1.0
```

#### 1.2 Domain Layer Architecture

```
features/audio_processing/
├── domain/
│   ├── entities/
│   │   ├── audio_segment.dart
│   │   ├── audio_features.dart
│   │   ├── processing_result.dart
│   │   └── ml_model_metadata.dart
│   ├── repositories/
│   │   ├── audio_processing_repository.dart
│   │   └── ml_model_repository.dart
│   ├── services/
│   │   ├── audio_analysis_service.dart
│   │   ├── feature_extraction_service.dart -> this service we have to have methos to get differts features from audio
│   │   └── segment_detection_service.dart - Z what kind of detecgtion strategy ahs to be implemented, byb beddings or by clases ?
│   └── usecases/
│       ├── analyze_audio_usecase.dart
│       ├── extract_segments_usecase.dart
│       └── sync_processing_results_usecase.dart
```

#### 1.3 Core Entities

**AudioSegment Entity:**

```dart
class AudioSegment extends Entity<AudioSegmentId> {
  final AudioTrackId trackId;
  final Duration startTime;
  final Duration endTime;
  final SegmentType type; // speech, music, silence, noise
  final double confidence;
  final Map<String, dynamic> features;
  final DateTime createdAt;
}
```

**ProcessingResult Entity:**

```dart
class ProcessingResult extends Entity<ProcessingResultId> {
  final AudioTrackId trackId;
  final List<AudioSegment> segments;
  final AudioFeatures features;
  final ProcessingStatus status;
  final DateTime processedAt;
}
```

#### 1.4 Domain Services

**AudioAnalysisService Interface:**

```dart
abstract class AudioAnalysisService {
  Future<Either<ProcessingFailure, ProcessingResult>> analyzeAudio(
    String audioPath,
    {ProcessingOptions? options}
  );

  Future<Either<ProcessingFailure, List<AudioSegment>>> detectSegments(
    String audioPath
  );

  Future<Either<ProcessingFailure, AudioFeatures>> extractFeatures(
    String audioPath
  );
}
```

### Phase 2: ML Model Integration

#### 2.1 TensorFlow Lite Implementation

```dart
@injectable
class TensorFlowLiteAnalysisService implements AudioAnalysisService {
  final MLModelRepository _modelRepository;
  late Interpreter _interpreter;

  @override
  Future<Either<ProcessingFailure, ProcessingResult>> analyzeAudio(
    String audioPath, {
    ProcessingOptions? options,
  }) async {
    try {
      // Load audio file and preprocess
      final audioData = await _preprocessAudio(audioPath);

      // Run inference
      final predictions = await _runInference(audioData);

      // Post-process results
      final segments = await _extractSegments(predictions, audioPath);
      final features = await _extractFeatures(audioData);

      return Right(ProcessingResult(
        id: ProcessingResultId(),
        trackId: options?.trackId ?? AudioTrackId(),
        segments: segments,
        features: features,
        status: ProcessingStatus.completed,
        processedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(ProcessingFailure.mlProcessingFailed(e.toString()));
    }
  }
}
```

#### 2.2 Audio Preprocessing

```dart
class AudioPreprocessor {
  static const int sampleRate = 16000;
  static const int windowSize = 1024;

  Future<Float32List> preprocessAudio(String filePath) async {
    // Convert audio to 16kHz mono
    // Extract spectrograms
    // Normalize data for model input
  }

  Future<List<List<double>>> extractSpectrograms(
    Float32List audioData
  ) async {
    // STFT implementation
    // Mel-scale conversion
    // Log transformation
  }
}
```

### Phase 3: Data Layer Implementation

#### 3.1 Local Storage (Isar)

```dart
@collection
class AudioProcessingDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String trackId;

  late String segments; // JSON serialized segments
  late String features; // JSON serialized features
  late int status;
  late DateTime processedAt;

  /// Sync metadata
  SyncMetadataDocument? syncMetadata;
}
```

#### 3.2 Repository Implementation

```dart
@Injectable(as: AudioProcessingRepository)
class AudioProcessingRepositoryImpl implements AudioProcessingRepository {
  final AudioProcessingLocalDataSource _localDataSource;
  final AudioProcessingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<ProcessingFailure, ProcessingResult>> getProcessingResult(
    AudioTrackId trackId,
  ) async {
    // Try local first
    final localResult = await _localDataSource.getProcessingResult(trackId);
    if (localResult != null) {
      return Right(localResult.toEntity());
    }

    // Fallback to remote
    final remoteResult = await _remoteDataSource.getProcessingResult(trackId);
    return remoteResult.fold(
      (failure) => Left(failure),
      (result) async {
        // Cache locally
        await _localDataSource.saveProcessingResult(result);
        return Right(result);
      },
    );
  }
}
```

### Phase 4: Enhanced Waveform Integration

#### 4.1 Enhanced Waveform Component

```dart
class EnhancedAudioWaveform extends StatelessWidget {
  final AudioTrackId trackId;
  final ProcessingResult? processingResult;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioProcessingBloc, AudioProcessingState>(
      builder: (context, state) {
        return CustomPaint(
          painter: SegmentedWaveformPainter(
            waveformData: state.waveformData,
            segments: state.processingResult?.segments,
            currentPosition: state.currentPosition,
          ),
        );
      },
    );
  }
}
```

#### 4.2 Segment Visualization

```dart
class SegmentedWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final List<AudioSegment>? segments;
  final Duration currentPosition;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw base waveform
    _drawWaveform(canvas, size);

    // Overlay segment colors
    if (segments != null) {
      _drawSegmentOverlays(canvas, size, segments!);
    }

    // Draw current position marker
    _drawPositionMarker(canvas, size);
  }

  void _drawSegmentOverlays(
    Canvas canvas,
    Size size,
    List<AudioSegment> segments,
  ) {
    for (final segment in segments) {
      final color = _getSegmentColor(segment.type);
      final rect = _getSegmentRect(segment, size);

      final paint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, paint);
    }
  }

  Color _getSegmentColor(SegmentType type) {
    switch (type) {
      case SegmentType.speech:
        return Colors.blue;
      case SegmentType.music:
        return Colors.green;
      case SegmentType.silence:
        return Colors.grey;
      case SegmentType.noise:
        return Colors.orange;
    }
  }
}
```

### Phase 5: BLoC State Management

#### 5.1 Audio Processing BLoC

```dart
class AudioProcessingBloc extends Bloc<AudioProcessingEvent, AudioProcessingState> {
  final AnalyzeAudioUseCase _analyzeAudioUseCase;
  final AudioProcessingRepository _repository;

  AudioProcessingBloc({
    required AnalyzeAudioUseCase analyzeAudioUseCase,
    required AudioProcessingRepository repository,
  }) : _analyzeAudioUseCase = analyzeAudioUseCase,
       _repository = repository,
       super(AudioProcessingState.initial()) {

    on<ProcessAudioRequested>(_onProcessAudioRequested);
    on<ProcessingResultLoaded>(_onProcessingResultLoaded);
    on<SegmentSelected>(_onSegmentSelected);
  }

  Future<void> _onProcessAudioRequested(
    ProcessAudioRequested event,
    Emitter<AudioProcessingState> emit,
  ) async {
    emit(state.copyWith(status: ProcessingStatus.processing));

    final result = await _analyzeAudioUseCase(
      ProcessingParams(
        trackId: event.trackId,
        audioPath: event.audioPath,
        options: event.options,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: ProcessingStatus.error,
        errorMessage: failure.message,
      )),
      (processingResult) => emit(state.copyWith(
        status: ProcessingStatus.completed,
        processingResult: processingResult,
      )),
    );
  }
}
```

### Phase 6: Enhanced Commenting System

#### 6.1 Smart Comment Suggestions

```dart
class SmartCommentService {
  final AudioProcessingRepository _processingRepository;

  Future<List<CommentSuggestion>> generateSuggestions(
    AudioTrackId trackId,
  ) async {
    final processingResult = await _processingRepository
        .getProcessingResult(trackId);

    return processingResult.fold(
      (_) => [],
      (result) => _generateSuggestionsFromSegments(result.segments),
    );
  }

  List<CommentSuggestion> _generateSuggestionsFromSegments(
    List<AudioSegment> segments,
  ) {
    final suggestions = <CommentSuggestion>[];

    for (final segment in segments) {
      switch (segment.type) {
        case SegmentType.speech:
          suggestions.add(CommentSuggestion(
            position: segment.startTime,
            text: "Speech section begins",
            type: CommentType.informational,
          ));
          break;
        case SegmentType.music:
          suggestions.add(CommentSuggestion(
            position: segment.startTime,
            text: "Musical content detected",
            type: CommentType.creative,
          ));
          break;
      }
    }

    return suggestions;
  }
}
```

## Implementation Timeline

### Sprint 1 (2 weeks): Foundation

- [ ] Set up TensorFlow Lite dependencies
- [ ] Create domain layer structure
- [ ] Implement basic audio preprocessing
- [ ] Set up ML model loading infrastructure

### Sprint 2 (2 weeks): Core ML Integration

- [ ] Integrate YAMNet model
- [ ] Implement audio analysis service
- [ ] Create segment detection algorithms
- [ ] Add feature extraction capabilities

### Sprint 3 (2 weeks): Data Layer & Storage

- [ ] Implement Isar document models
- [ ] Create local/remote data sources
- [ ] Set up repository implementations
- [ ] Add Firebase sync for processing results

### Sprint 4 (2 weeks): Enhanced UI

- [ ] Enhance waveform visualization
- [ ] Add segment overlays and coloring
- [ ] Implement segment selection and interaction
- [ ] Create processing progress indicators

### Sprint 5 (1 week): Smart Comments

- [ ] Implement comment suggestion system
- [ ] Add intelligent comment placement
- [ ] Enhance collaborative experience
- [ ] Add segment-based commenting

### Sprint 6 (1 week): Integration & Testing

- [ ] Integration testing with existing features
- [ ] Performance optimization
- [ ] Error handling and edge cases
- [ ] Documentation and cleanup

## Technical Considerations

### Performance Optimization

- **Background Processing**: Use isolates for ML inference
- **Caching Strategy**: Cache processed results to avoid recomputation
- **Progressive Loading**: Load segments incrementally for large files
- **Memory Management**: Dispose of ML models when not needed

### Error Handling

- **Model Loading Failures**: Graceful fallback to basic waveform
- **Processing Timeouts**: Implement cancellation and retry logic
- **Storage Failures**: Handle local/remote sync conflicts
- **Device Compatibility**: Check device capabilities before processing

### Security & Privacy

- **Local Processing**: All ML inference happens on-device
- **Data Privacy**: No audio content sent to external servers
- **Model Verification**: Verify model integrity and authenticity
- **Permission Management**: Request necessary audio processing permissions

## Success Metrics

### Technical KPIs

- Processing time < 2x audio duration
- Memory usage < 200MB during processing
- 95% accuracy for speech/music detection
- 99.9% offline availability

### User Experience KPIs

- Increased comment engagement by 40%
- Reduced time to find relevant sections by 60%
- Enhanced collaboration satisfaction scores
- Improved audio discovery and navigation

## Monetization Strategy

### Subscription Model (Following Dubnote)

- **Free Tier**: Basic segment detection (speech/silence)
- **Pro Tier (€8/month)**: Advanced features (music analysis, custom models)
- **Team Tier**: Enhanced collaboration features with ML insights
- **Enterprise**: Custom model training and deployment

### Value Proposition

- **Local Processing**: No server costs for ML inference
- **Enhanced Collaboration**: Intelligent segment sharing
- **Professional Tools**: Industry-grade audio analysis
- **Offline-First**: Works without internet connectivity

## Risk Mitigation

### Technical Risks

- **Model Size**: Use quantized models to reduce app size
- **Battery Usage**: Implement power-aware processing modes
- **Compatibility**: Test across diverse Android/iOS devices
- **Performance**: Benchmark on low-end devices

### Business Risks

- **Adoption**: Gradual rollout with feature flags
- **Competition**: Focus on collaboration advantage
- **Maintenance**: Automated testing for ML components
- **Scalability**: Design for horizontal feature expansion

## Conclusion

This implementation plan transforms TrackFlow into an intelligent audio collaboration platform by leveraging on-device ML processing. The architecture maintains clean separation of concerns, follows established patterns, and provides a foundation for future AI-powered features while preserving the core collaborative experience that differentiates TrackFlow from competitors.

The offline-first approach with local ML processing provides significant advantages in terms of privacy, performance, and cost-effectiveness, while the enhanced visualization and smart commenting features create substantial value for professional audio creators and collaborative teams.

## Acceptance Criteria

### M1 – Waveform Extraction & Sync

- On audio upload, waveform is generated via service and saved as `AudioWaveformDocument` in Isar.
- Compressed amplitudes sync to Firebase; another device loads identical waveform for the same track.
- Existing waveform UI works; if ML waveform unavailable, fallback uses `audio_waveforms` with no regressions.

### M2 – ML Processing Core

- YAMNet runs on-device with preprocessing and returns class scores and embeddings.
- Segments (speech/music/silence/noise) created with start/end times and confidence.
- `AudioMLProcessingDocument` persisted locally; only lightweight segments/metadata synced.

### M3 – UI Overlays

- Enhanced waveform overlays segments with distinct colors and shows a position marker.
- Performance: 60 FPS on typical devices for tracks up to 10 minutes using ML waveform.

### M4 – Smart Comments (optional)

- Service returns at least one suggestion per speech/music segment with correct timestamps.

### Performance & Reliability

- Processing time ≤ 2× audio duration for M2 on mid-tier devices.
- Peak memory < 200MB during processing; no UI jank during background inference.
- Offline behavior: waveform and segments available when previously generated.
