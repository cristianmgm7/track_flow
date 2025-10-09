# Audio Recording Module - Reusable Architecture Implementation Plan

**Generated:** 2025-10-08 (Revised for Modular Architecture)
**Based on:** [research_audiocomment.md](research_audiocomment.md)
**Status:** PENDING APPROVAL

---

## Overview

This plan outlines the implementation of a **reusable audio recording module** that can be leveraged across the entire TrackFlow application. The module will initially be integrated with the audio comment system but is designed as a standalone feature that can be consumed by any part of the application requiring audio recording capabilities (e.g., voice memos, audio notes, voice journaling, audio messages, etc.).

The implementation follows Clean Architecture + DDD principles with clear architectural boundaries between the recording module and its consumers.

---

## Architectural Vision

### Core Design Principles

1. **Separation of Concerns**: Audio recording logic is isolated in its own feature module (`audio_recording`)
2. **Dependency Inversion**: Consumers depend on recording abstractions, not implementations
3. **Reusability**: Recording module provides high-level interfaces usable by any feature
4. **Clean Boundaries**: Clear contracts between recording module and consumers
5. **Offline-First**: Recording works offline, storage sync handled by consumers
6. **Platform Agnostic**: Recording abstracts platform-specific details

### Module Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        Application Layer                          │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────────┐  │
│  │ Audio Comment  │  │ Voice Memo       │  │ Voice Journal    │  │
│  │ Feature        │  │ Feature (future) │  │ Feature (future) │  │
│  └───────┬────────┘  └────────┬─────────┘  └────────┬─────────┘  │
│          │                    │                      │            │
│          └────────────────────┼──────────────────────┘            │
│                               ▼                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │       Audio Recording Feature (Reusable Module)            │  │
│  │  - Domain: Recording entities, services, use cases         │  │
│  │  - Infrastructure: Platform recording implementation       │  │
│  │  - Presentation: Recording UI components & BLoC            │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Shared Core Services                         │
│  - Audio Storage Service (Firebase Storage abstraction)          │
│  - File System Service (Local file management)                   │
│  - Permission Service (Microphone permissions)                   │
└──────────────────────────────────────────────────────────────────┘
```

### Consumer Integration Pattern

Each consumer feature (e.g., audio_comment) will:

1. **Depend on recording abstractions** via dependency injection
2. **Receive recording results** through callbacks or events
3. **Handle storage** according to their domain needs (Firebase path, metadata, etc.)
4. **Manage lifecycle** of recordings within their context

---

## Key Design Decisions

1. **Modular Audio Recording Feature**: Standalone `audio_recording` feature with its own domain, infrastructure, and presentation layers
2. **Storage Responsibility**: Recording module handles temporary files; consumers handle permanent storage and Firebase upload
3. **Format Standardization**: M4A (AAC-LC codec) as the standard format across all use cases
4. **Permission Management**: Centralized in core services, exposed through recording module
5. **UI Components**: Reusable recording widgets exported from recording module
6. **State Management**: Recording BLoC isolated within recording module, consumers observe via streams
7. **Backward Compatibility**: Existing text comments remain unchanged

---

## Phase 0: Core Infrastructure - Refactoring & Shared Services

> **IMPORTANT**: Analysis of existing codebase revealed significant overlap with planned services. This phase focuses on **extracting and refactoring** existing implementations rather than creating from scratch.

### Step 0.1: Extract and Create Firebase Audio Upload Service

**Purpose**: Create reusable Firebase Storage upload service by extracting existing proven logic

**Context**: Upload logic already exists in `lib/features/track_version/data/datasources/track_version_remote_datasource.dart:38-97`. We need to extract it for reuse by audio comments and future features.

**New File:** `lib/core/services/firebase_audio_upload_service.dart`

```dart
/// Shared Firebase Storage upload service for all audio features
/// Extracted from track_version feature for reusability
@LazySingleton()
class FirebaseAudioUploadService {
  final FirebaseStorage _storage;

  FirebaseAudioUploadService(this._storage);

  /// Upload audio file to Firebase Storage
  /// [audioFile] - Local file to upload
  /// [storagePath] - Firebase Storage path (e.g., 'audio_comments/{projectId}/{versionId}/{commentId}.m4a')
  /// [metadata] - Optional custom metadata
  /// Returns download URL on success
  Future<Either<Failure, String>> uploadAudioFile({
    required File audioFile,
    required String storagePath,
    Map<String, String>? metadata,
  }) async {
    try {
      final fileExtension = AudioFormatUtils.getFileExtension(audioFile.path);
      final ref = _storage.ref().child(storagePath);

      final uploadTask = ref.putFile(
        audioFile,
        SettableMetadata(
          contentType: AudioFormatUtils.getContentType(fileExtension),
          customMetadata: metadata,
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(StorageFailure('Upload failed: ${e.message}'));
    } catch (e) {
      return Left(StorageFailure('Upload failed: ${e.toString()}'));
    }
  }

  /// Delete audio file from Firebase Storage
  /// [storageUrl] - Firebase Storage download URL
  Future<Either<Failure, Unit>> deleteAudioFile({
    required String storageUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(storageUrl);
      await ref.delete();
      return const Right(unit);
    } on FirebaseException catch (e) {
      return Left(StorageFailure('Delete failed: ${e.message}'));
    } catch (e) {
      return Left(StorageFailure('Delete failed: ${e.toString()}'));
    }
  }
}
```

**Changes Required:**
1. Create new service file
2. Update `track_version_remote_datasource.dart` to use new service
3. Remove duplicate upload logic from track version datasource
4. Add DI configuration

**Verification:**
- **Unit Test:** `test/core/services/firebase_audio_upload_service_test.dart`
  - Mock FirebaseStorage
  - Test upload success/failure scenarios
  - Test delete operations
  - Test error handling
- **Integration Test:** Ensure track version upload still works

---

### Step 0.2: Consolidate Audio Format Utilities

**Purpose**: Create single source of truth for MIME type and file extension mapping

**Context**: Duplicate logic exists in:
- `track_version_remote_datasource.dart:180-204`
- `cache_storage_remote_data_source.dart:150-181`

**New File:** `lib/core/utils/audio_format_utils.dart`

```dart
/// Centralized utilities for audio file format detection and conversion
class AudioFormatUtils {
  // Prevent instantiation
  AudioFormatUtils._();

  /// Map file extensions to MIME types
  static const Map<String, String> extensionToMimeType = {
    '.mp3': 'audio/mpeg',
    '.wav': 'audio/wav',
    '.m4a': 'audio/mp4',
    '.aac': 'audio/aac',
    '.ogg': 'audio/ogg',
    '.flac': 'audio/flac',
  };

  /// Map MIME types to file extensions (handles variations)
  static const Map<String, String> mimeTypeToExtension = {
    'audio/mpeg': '.mp3',
    'audio/mp3': '.mp3',
    'audio/mp4': '.m4a',
    'audio/aac': '.m4a',
    'audio/x-m4a': '.m4a',
    'audio/m4a': '.m4a',
    'audio/wav': '.wav',
    'audio/x-wav': '.wav',
    'audio/ogg': '.ogg',
    'application/ogg': '.ogg',
    'audio/flac': '.flac',
  };

  /// Get MIME content type from file extension
  /// Returns 'audio/mpeg' as default if not found
  static String getContentType(String fileExtension) {
    return extensionToMimeType[fileExtension.toLowerCase()] ?? 'audio/mpeg';
  }

  /// Get file extension from MIME content type
  /// Handles charset and other parameters
  static String? getExtensionFromMimeType(String mimeType) {
    final type = mimeType.split(';').first.trim().toLowerCase();
    return mimeTypeToExtension[type];
  }

  /// Extract file extension from file path
  /// Returns '.mp3' as default if not found
  static String getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '.mp3';
    final ext = filePath.substring(lastDot).toLowerCase();
    // Validate reasonable length to avoid query strings
    if (ext.length > 5) return '.mp3';
    return ext;
  }

  /// Supported audio file extensions
  static const List<String> supportedExtensions = [
    '.mp3',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
    '.flac',
  ];
}
```

**Changes Required:**
1. Create utility class
2. Update `track_version_remote_datasource.dart` to use `AudioFormatUtils`
3. Update `cache_storage_remote_data_source.dart` to use `AudioFormatUtils`
4. Remove duplicate helper methods

**Verification:**
- **Unit Test:** `test/core/utils/audio_format_utils_test.dart`
  - Test extension to MIME type conversion
  - Test MIME type to extension conversion
  - Test edge cases (missing extension, unknown types)
  - Test all supported formats

---

### Step 0.3: Extract File System Utilities

**Purpose**: Centralize common file operations found across multiple features

**Context**: Common patterns exist in:
- `audio_storage_repository_impl.dart` (directory creation, extension extraction)
- `upload_version_form.dart` (temporary file handling)
- `cache_storage_local_data_source.dart` (file validation)

**New File:** `lib/core/utils/file_system_utils.dart`

```dart
/// Centralized utilities for file system operations
class FileSystemUtils {
  // Prevent instantiation
  FileSystemUtils._();

  /// Create directory if it doesn't exist
  /// Uses recursive creation for parent directories
  static Future<Directory> ensureDirectoryExists(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Delete file if it exists
  /// Returns true if deleted, false if didn't exist or error
  static Future<bool> deleteFileIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Extract file extension from path
  /// Returns null if no extension found or invalid
  static String? extractExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return null;
    final ext = path.substring(idx).toLowerCase();
    if (ext.length > 5) return null; // Avoid query strings
    return ext;
  }

  /// Generate unique filename for temporary recordings
  /// Format: recording_{timestamp}_{uuid}.{extension}
  static String generateUniqueFilename(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v4().substring(0, 8);
    return 'recording_${timestamp}_$uuid$extension';
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    return await file.length();
  }

  /// Check if file exists
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }
}
```

**Changes Required:**
1. Create utility class
2. Update audio cache repository to use utilities
3. Update upload form to use utilities
4. Remove duplicate helper methods

**Verification:**
- **Unit Test:** `test/core/utils/file_system_utils_test.dart`
  - Test directory creation
  - Test file deletion
  - Test extension extraction
  - Test unique filename generation

---

### Step 0.4: Document Integration with Existing Audio Cache

**Purpose**: Clarify how recording feature integrates with existing audio cache system

**Context**: The existing `AudioStorageRepository` (`lib/features/audio_cache/data/repositories/audio_storage_repository_impl.dart`) already provides:
- Local file storage with directory management
- File validation with SHA-1 checksums
- Cache cleanup and maintenance
- Isar persistence for metadata

**Integration Strategy:**

1. **Local Storage for Recordings:**
   - Use existing `AudioStorageRepository.storeAudio()` for caching recorded comments
   - Directory structure: `Documents/trackflow/audio/{projectId}/{commentId}.m4a`
   - Leverages existing validation and checksum logic

2. **Firebase Upload:**
   - Use new `FirebaseAudioUploadService` for uploading to storage
   - Storage path: `audio_comments/{projectId}/{versionId}/{commentId}.m4a`
   - Consistent with existing track version pattern

3. **Temporary Recording Files:**
   - Use `getTemporaryDirectory()` from `path_provider` for active recordings
   - Move to permanent cache after recording complete
   - Use `FileSystemUtils` for file operations

**No New Storage Service Needed**: The planned `AudioStorageService` is **not required** because:
- Upload: Handled by new `FirebaseAudioUploadService`
- Download: Handled by existing `AudioCacheRepository`
- Local storage: Handled by existing `AudioStorageRepository`

**Updated Architecture Diagram:**

```
┌──────────────────────────────────────────────────────────┐
│              Audio Comment Feature                       │
│  ┌────────────────────────────────────────────────────┐  │
│  │  Uses FirebaseAudioUploadService (SHARED)         │  │
│  │  Uses AudioStorageRepository (EXISTING)           │  │
│  │  Uses FileSystemUtils (NEW UTILITIES)             │  │
│  └────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│           Audio Recording Feature (NEW MODULE)           │
│  - Domain: Recording entities, services, use cases       │
│  - Infrastructure: Platform recording (record package)   │
│  - Presentation: Recording UI components & BLoC          │
└──────────────────────────────────────────────────────────┘
                          │
                          ▼
┌──────────────────────────────────────────────────────────┐
│                 Shared Services & Utils                  │
│  - FirebaseAudioUploadService (NEW - extracted)         │
│  - AudioFormatUtils (NEW - consolidated)                │
│  - FileSystemUtils (NEW - extracted)                    │
│  - AudioStorageRepository (EXISTING - reused)           │
│  - AudioCacheRepository (EXISTING - reused)             │
└──────────────────────────────────────────────────────────┘
```

**Verification:**
- Document updated integration points
- Architecture diagram reflects actual implementation
- No duplicate services planned

---

## Phase 1: Audio Recording Feature - Domain Layer

### Step 1.1: Create Recording Domain Entities

**New Directory:** `lib/features/audio_recording/domain/entities/`

**File 1:** `lib/features/audio_recording/domain/entities/audio_recording.dart`

```dart
/// Represents a completed audio recording with metadata
class AudioRecording extends Equatable {
  final String id;                  // Unique identifier
  final String localPath;           // Local file path
  final Duration duration;          // Recording length
  final AudioFormat format;         // File format
  final int fileSizeBytes;          // File size
  final DateTime recordedAt;        // Recording timestamp
  final Map<String, dynamic>? metadata; // Optional consumer metadata

  const AudioRecording({
    required this.id,
    required this.localPath,
    required this.duration,
    required this.format,
    required this.fileSizeBytes,
    required this.recordedAt,
    this.metadata,
  });

  /// Create a new recording instance
  factory AudioRecording.create({
    required String localPath,
    required Duration duration,
    AudioFormat format = AudioFormat.m4a,
    int fileSizeBytes = 0,
    Map<String, dynamic>? metadata,
  }) {
    return AudioRecording(
      id: const Uuid().v4(),
      localPath: localPath,
      duration: duration,
      format: format,
      fileSizeBytes: fileSizeBytes,
      recordedAt: DateTime.now(),
      metadata: metadata,
    );
  }

  AudioRecording copyWith({
    String? id,
    String? localPath,
    Duration? duration,
    AudioFormat? format,
    int? fileSizeBytes,
    DateTime? recordedAt,
    Map<String, dynamic>? metadata,
  }) {
    return AudioRecording(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      duration: duration ?? this.duration,
      format: format ?? this.format,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      recordedAt: recordedAt ?? this.recordedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [id, localPath, duration, format, fileSizeBytes, recordedAt, metadata];
}

/// Supported audio formats
enum AudioFormat {
  m4a,  // AAC in M4A container (iOS & Android compatible)
  aac,  // Raw AAC
  mp3,  // MP3 (future support)
}
```

**File 2:** `lib/features/audio_recording/domain/entities/recording_session.dart`

```dart
/// Represents an active recording session
class RecordingSession extends Equatable {
  final String sessionId;
  final DateTime startedAt;
  final Duration elapsed;
  final RecordingState state;
  final String outputPath;
  final double? currentAmplitude;  // For waveform visualization

  const RecordingSession({
    required this.sessionId,
    required this.startedAt,
    required this.elapsed,
    required this.state,
    required this.outputPath,
    this.currentAmplitude,
  });

  RecordingSession copyWith({
    String? sessionId,
    DateTime? startedAt,
    Duration? elapsed,
    RecordingState? state,
    String? outputPath,
    double? currentAmplitude,
  }) {
    return RecordingSession(
      sessionId: sessionId ?? this.sessionId,
      startedAt: startedAt ?? this.startedAt,
      elapsed: elapsed ?? this.elapsed,
      state: state ?? this.state,
      outputPath: outputPath ?? this.outputPath,
      currentAmplitude: currentAmplitude ?? this.currentAmplitude,
    );
  }

  @override
  List<Object?> get props => [sessionId, startedAt, elapsed, state, outputPath, currentAmplitude];
}

enum RecordingState {
  idle,
  recording,
  paused,
  stopped,
}
```

**Verification:**
- **Unit Test:** `test/features/audio_recording/domain/entities/audio_recording_test.dart`
  - Test factory creation
  - Test copyWith
  - Test equality
- **Unit Test:** `test/features/audio_recording/domain/entities/recording_session_test.dart`
  - Test session state transitions
  - Test copyWith

---

### Step 1.2: Create Recording Domain Services

**New File:** `lib/features/audio_recording/domain/services/recording_service.dart`

```dart
/// Abstract service for audio recording operations
/// This is the primary interface that consumers will use
abstract class RecordingService {
  /// Check if recording permission is available
  Future<bool> hasPermission();

  /// Request recording permission from user
  Future<bool> requestPermission();

  /// Start a new recording session
  /// [outputPath] - Where to save the recording
  /// Returns session ID on success
  Future<Either<Failure, String>> startRecording({
    required String outputPath,
  });

  /// Stop the current recording
  /// Returns the completed AudioRecording on success
  Future<Either<Failure, AudioRecording>> stopRecording();

  /// Pause the current recording
  Future<Either<Failure, Unit>> pauseRecording();

  /// Resume a paused recording
  Future<Either<Failure, Unit>> resumeRecording();

  /// Cancel the current recording (discards the file)
  Future<Either<Failure, Unit>> cancelRecording();

  /// Get current recording session state
  Stream<RecordingSession> get sessionStream;

  /// Check if currently recording
  bool get isRecording;
}
```

**Verification:**
- Contract will be tested via implementation tests

---

### Step 1.3: Create Recording Use Cases

**Directory:** `lib/features/audio_recording/domain/usecases/`

**Use Case 1:** `start_recording_usecase.dart`

```dart
@injectable
class StartRecordingUseCase {
  final RecordingService _recordingService;

  StartRecordingUseCase(this._recordingService);

  Future<Either<Failure, String>> call({
    String? customOutputPath,
  }) async {
    // Check permission first
    final hasPermission = await _recordingService.hasPermission();
    if (!hasPermission) {
      final granted = await _recordingService.requestPermission();
      if (!granted) {
        return Left(PermissionFailure('Microphone permission denied'));
      }
    }

    // Generate output path if not provided
    final outputPath = customOutputPath ?? await _generateOutputPath();

    // Start recording
    return await _recordingService.startRecording(outputPath: outputPath);
  }

  Future<String> _generateOutputPath() async {
    final tempDir = await getTemporaryDirectory();
    final fileName = FileSystemUtils.generateUniqueFilename('.m4a');
    return '${tempDir.path}/$fileName';
  }
}
```

**Use Case 2:** `stop_recording_usecase.dart`

```dart
@injectable
class StopRecordingUseCase {
  final RecordingService _recordingService;

  StopRecordingUseCase(this._recordingService);

  Future<Either<Failure, AudioRecording>> call() async {
    return await _recordingService.stopRecording();
  }
}
```

**Use Case 3:** `cancel_recording_usecase.dart`

```dart
@injectable
class CancelRecordingUseCase {
  final RecordingService _recordingService;

  CancelRecordingUseCase(this._recordingService);

  Future<Either<Failure, Unit>> call() async {
    // RecordingService handles temp file cleanup internally
    return await _recordingService.cancelRecording();
  }
}
```

**Verification:**
- **Unit Test:** `test/features/audio_recording/domain/usecases/start_recording_usecase_test.dart`
  - Mock RecordingService
  - Test permission checks
  - Test output path generation
- **Unit Test:** `test/features/audio_recording/domain/usecases/stop_recording_usecase_test.dart`
- **Unit Test:** `test/features/audio_recording/domain/usecases/cancel_recording_usecase_test.dart`

---

## Phase 2: Audio Recording Feature - Infrastructure Layer

### Step 2.1: Implement Platform Recording Service

**New File:** `lib/features/audio_recording/infrastructure/services/platform_recording_service.dart`

```dart
@LazySingleton(as: RecordingService)
class PlatformRecordingService implements RecordingService {
  final Record _recorder = Record();

  final _sessionController = StreamController<RecordingSession>.broadcast();
  RecordingSession? _currentSession;
  Timer? _elapsedTimer;
  Timer? _amplitudeTimer;

  PlatformRecordingService();

  @override
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<bool> requestPermission() async {
    // Record package handles permission request automatically on first recording
    return await _recorder.hasPermission();
  }

  @override
  Future<Either<Failure, String>> startRecording({
    required String outputPath,
  }) async {
    try {
      // Check permission
      if (!await hasPermission()) {
        return Left(PermissionFailure('Microphone permission not granted'));
      }

      // Ensure output directory exists
      final file = File(outputPath);
      await file.parent.create(recursive: true);

      // Start recording
      await _recorder.start(
        path: outputPath,
        encoder: AudioEncoder.aacLc,  // M4A format
        bitRate: 128000,
        samplingRate: 44100,
      );

      // Create session
      final sessionId = const Uuid().v4();
      _currentSession = RecordingSession(
        sessionId: sessionId,
        startedAt: DateTime.now(),
        elapsed: Duration.zero,
        state: RecordingState.recording,
        outputPath: outputPath,
      );

      // Start timers
      _startElapsedTimer();
      _startAmplitudeMonitoring();

      _sessionController.add(_currentSession!);

      return Right(sessionId);
    } catch (e) {
      return Left(RecordingFailure('Failed to start recording: $e'));
    }
  }

  @override
  Future<Either<Failure, AudioRecording>> stopRecording() async {
    try {
      if (_currentSession == null) {
        return Left(RecordingFailure('No active recording session'));
      }

      // Stop recording
      final path = await _recorder.stop();
      if (path == null) {
        return Left(RecordingFailure('Recording failed to save'));
      }

      // Stop timers
      _elapsedTimer?.cancel();
      _amplitudeTimer?.cancel();

      // Get file size
      final fileSize = await FileSystemUtils.getFileSize(path);

      // Create AudioRecording entity
      final recording = AudioRecording.create(
        localPath: path,
        duration: _currentSession!.elapsed,
        format: AudioFormat.m4a,
        fileSizeBytes: fileSize,
      );

      // Update session state
      _currentSession = _currentSession!.copyWith(
        state: RecordingState.stopped,
      );
      _sessionController.add(_currentSession!);

      // Clear session
      _currentSession = null;

      return Right(recording);
    } catch (e) {
      return Left(RecordingFailure('Failed to stop recording: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> pauseRecording() async {
    try {
      await _recorder.pause();

      _elapsedTimer?.cancel();
      _amplitudeTimer?.cancel();

      _currentSession = _currentSession?.copyWith(
        state: RecordingState.paused,
      );
      _sessionController.add(_currentSession!);

      return const Right(unit);
    } catch (e) {
      return Left(RecordingFailure('Failed to pause recording: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resumeRecording() async {
    try {
      await _recorder.resume();

      _startElapsedTimer();
      _startAmplitudeMonitoring();

      _currentSession = _currentSession?.copyWith(
        state: RecordingState.recording,
      );
      _sessionController.add(_currentSession!);

      return const Right(unit);
    } catch (e) {
      return Left(RecordingFailure('Failed to resume recording: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelRecording() async {
    try {
      await _recorder.cancel();

      _elapsedTimer?.cancel();
      _amplitudeTimer?.cancel();

      // Delete temporary file
      if (_currentSession != null) {
        await FileSystemUtils.deleteFileIfExists(_currentSession!.outputPath);
      }

      _currentSession = null;
      _sessionController.add(RecordingSession(
        sessionId: '',
        startedAt: DateTime.now(),
        elapsed: Duration.zero,
        state: RecordingState.idle,
        outputPath: '',
      ));

      return const Right(unit);
    } catch (e) {
      return Left(RecordingFailure('Failed to cancel recording: $e'));
    }
  }

  @override
  Stream<RecordingSession> get sessionStream => _sessionController.stream;

  @override
  bool get isRecording => _currentSession?.state == RecordingState.recording;

  void _startElapsedTimer() {
    _elapsedTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (_currentSession != null) {
        final elapsed = DateTime.now().difference(_currentSession!.startedAt);
        _currentSession = _currentSession!.copyWith(elapsed: elapsed);
        _sessionController.add(_currentSession!);
      }
    });
  }

  void _startAmplitudeMonitoring() {
    _amplitudeTimer = Timer.periodic(Duration(milliseconds: 100), (_) async {
      if (_currentSession != null && isRecording) {
        final amplitude = await _recorder.getAmplitude();
        _currentSession = _currentSession!.copyWith(
          currentAmplitude: amplitude.current.abs(),
        );
        _sessionController.add(_currentSession!);
      }
    });
  }

  void dispose() {
    _elapsedTimer?.cancel();
    _amplitudeTimer?.cancel();
    _recorder.dispose();
    _sessionController.close();
  }
}
```

**Verification:**
- **Unit Test:** `test/features/audio_recording/infrastructure/services/platform_recording_service_test.dart`
  - Mock Record package
  - Test start/stop recording flow
  - Test pause/resume flow
  - Test cancel recording
  - Test elapsed timer updates
  - Test amplitude monitoring
  - Test error scenarios
  - Test permission handling

---

## Phase 3: Audio Recording Feature - Presentation Layer

### Step 3.1: Create Recording BLoC

**Directory:** `lib/features/audio_recording/presentation/bloc/`

**File 1:** `recording_event.dart`

```dart
sealed class RecordingEvent extends Equatable {
  const RecordingEvent();

  @override
  List<Object?> get props => [];
}

class StartRecordingRequested extends RecordingEvent {
  final String? customOutputPath;

  const StartRecordingRequested({this.customOutputPath});

  @override
  List<Object?> get props => [customOutputPath];
}

class StopRecordingRequested extends RecordingEvent {
  const StopRecordingRequested();
}

class PauseRecordingRequested extends RecordingEvent {
  const PauseRecordingRequested();
}

class ResumeRecordingRequested extends RecordingEvent {
  const ResumeRecordingRequested();
}

class CancelRecordingRequested extends RecordingEvent {
  const CancelRecordingRequested();
}

class RecordingSessionUpdated extends RecordingEvent {
  final RecordingSession session;

  const RecordingSessionUpdated(this.session);

  @override
  List<Object?> get props => [session];
}
```

**File 2:** `recording_state.dart`

```dart
sealed class RecordingState extends Equatable {
  const RecordingState();

  @override
  List<Object?> get props => [];
}

class RecordingInitial extends RecordingState {
  const RecordingInitial();
}

class RecordingInProgress extends RecordingState {
  final RecordingSession session;

  const RecordingInProgress(this.session);

  @override
  List<Object?> get props => [session];
}

class RecordingPaused extends RecordingState {
  final RecordingSession session;

  const RecordingPaused(this.session);

  @override
  List<Object?> get props => [session];
}

class RecordingCompleted extends RecordingState {
  final AudioRecording recording;

  const RecordingCompleted(this.recording);

  @override
  List<Object?> get props => [recording];
}

class RecordingError extends RecordingState {
  final String message;

  const RecordingError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**File 3:** `recording_bloc.dart`

```dart
@injectable
class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final StartRecordingUseCase _startRecordingUseCase;
  final StopRecordingUseCase _stopRecordingUseCase;
  final CancelRecordingUseCase _cancelRecordingUseCase;
  final RecordingService _recordingService;

  StreamSubscription<RecordingSession>? _sessionSubscription;

  RecordingBloc(
    this._startRecordingUseCase,
    this._stopRecordingUseCase,
    this._cancelRecordingUseCase,
    this._recordingService,
  ) : super(const RecordingInitial()) {
    on<StartRecordingRequested>(_onStartRecording);
    on<StopRecordingRequested>(_onStopRecording);
    on<PauseRecordingRequested>(_onPauseRecording);
    on<ResumeRecordingRequested>(_onResumeRecording);
    on<CancelRecordingRequested>(_onCancelRecording);
    on<RecordingSessionUpdated>(_onSessionUpdated);

    // Listen to recording session updates
    _sessionSubscription = _recordingService.sessionStream.listen((session) {
      add(RecordingSessionUpdated(session));
    });
  }

  Future<void> _onStartRecording(
    StartRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _startRecordingUseCase(
      customOutputPath: event.customOutputPath,
    );

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) {}, // State updated via session stream
    );
  }

  Future<void> _onStopRecording(
    StopRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _stopRecordingUseCase();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (recording) => emit(RecordingCompleted(recording)),
    );
  }

  Future<void> _onPauseRecording(
    PauseRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _recordingService.pauseRecording();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) {}, // State updated via session stream
    );
  }

  Future<void> _onResumeRecording(
    ResumeRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _recordingService.resumeRecording();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) {}, // State updated via session stream
    );
  }

  Future<void> _onCancelRecording(
    CancelRecordingRequested event,
    Emitter<RecordingState> emit,
  ) async {
    final result = await _cancelRecordingUseCase();

    result.fold(
      (failure) => emit(RecordingError(failure.message)),
      (_) => emit(const RecordingInitial()),
    );
  }

  void _onSessionUpdated(
    RecordingSessionUpdated event,
    Emitter<RecordingState> emit,
  ) {
    final session = event.session;

    if (session.state == RecordingState.recording) {
      emit(RecordingInProgress(session));
    } else if (session.state == RecordingState.paused) {
      emit(RecordingPaused(session));
    } else if (session.state == RecordingState.idle) {
      emit(const RecordingInitial());
    }
  }

  @override
  Future<void> close() {
    _sessionSubscription?.cancel();
    return super.close();
  }
}
```

**Verification:**
- **Unit Test:** `test/features/audio_recording/presentation/bloc/recording_bloc_test.dart`
  - Use bloc_test package
  - Mock use cases and recording service
  - Test start recording event
  - Test stop recording event
  - Test pause/resume events
  - Test cancel recording event
  - Test session stream updates
  - Test error scenarios

---

### Step 3.2: Create Reusable Recording Widgets

**Directory:** `lib/features/audio_recording/presentation/widgets/`

**Widget 1:** `recording_button.dart`

```dart
/// Reusable button to start/stop recording
class RecordingButton extends StatelessWidget {
  final VoidCallback? onStartRecording;
  final VoidCallback? onStopRecording;
  final bool isRecording;
  final String? startLabel;
  final String? stopLabel;

  const RecordingButton({
    Key? key,
    this.onStartRecording,
    this.onStopRecording,
    required this.isRecording,
    this.startLabel,
    this.stopLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isRecording ? onStopRecording : onStartRecording,
      icon: Icon(
        isRecording ? Icons.stop : Icons.fiber_manual_record,
        color: isRecording ? AppColors.error : AppColors.primary,
      ),
      label: Text(
        isRecording
          ? (stopLabel ?? 'Stop Recording')
          : (startLabel ?? 'Start Recording'),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isRecording
          ? AppColors.error.withOpacity(0.1)
          : AppColors.primary.withOpacity(0.1),
      ),
    );
  }
}
```

**Widget 2:** `recording_waveform.dart`

```dart
/// Reusable waveform visualization during recording
class RecordingWaveform extends StatelessWidget {
  final double amplitude;
  final Color? color;
  final double height;

  const RecordingWaveform({
    Key? key,
    required this.amplitude,
    this.color,
    this.height = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: CustomPaint(
        painter: WaveformPainter(
          amplitude: amplitude,
          color: color ?? AppColors.primary,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double amplitude;
  final Color color;

  WaveformPainter({required this.amplitude, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    final barHeight = amplitude * size.height;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 6,
      height: barHeight.clamp(10.0, size.height),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(3)),
      paint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude;
  }
}
```

**Widget 3:** `recording_timer.dart`

```dart
/// Reusable timer display during recording
class RecordingTimer extends StatelessWidget {
  final Duration elapsed;
  final TextStyle? style;

  const RecordingTimer({
    Key? key,
    required this.elapsed,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(elapsed),
      style: style ?? AppTextStyle.titleLarge.copyWith(
        fontWeight: FontWeight.bold,
        fontFeatures: [FontFeature.tabularFigures()],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
```

**Widget 4:** `recording_controls.dart`

```dart
/// Reusable recording control panel (pause/resume/cancel)
class RecordingControls extends StatelessWidget {
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onCancel;
  final bool isPaused;

  const RecordingControls({
    Key? key,
    this.onPause,
    this.onResume,
    this.onCancel,
    required this.isPaused,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
          onPressed: isPaused ? onResume : onPause,
          iconSize: 32,
        ),
        SizedBox(width: Dimensions.space16),
        IconButton(
          icon: Icon(Icons.cancel, color: AppColors.error),
          onPressed: onCancel,
          iconSize: 32,
        ),
      ],
    );
  }
}
```

**Verification:**
- **Widget Test:** `test/features/audio_recording/presentation/widgets/recording_button_test.dart`
- **Widget Test:** `test/features/audio_recording/presentation/widgets/recording_waveform_test.dart`
- **Widget Test:** `test/features/audio_recording/presentation/widgets/recording_timer_test.dart`
- **Widget Test:** `test/features/audio_recording/presentation/widgets/recording_controls_test.dart`

---

## Phase 4: Audio Comment Integration - Consuming the Recording Module

### Step 4.1: Extend AudioComment Domain Entity

**File:** [lib/features/audio_comment/domain/entities/audio_comment.dart](lib/features/audio_comment/domain/entities/audio_comment.dart)

**Add Audio Fields:**

```dart
class AudioComment extends Entity<AudioCommentId> {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final UserId createdBy;
  final String content;                // Text comment OR transcription
  final Duration timestamp;
  final DateTime createdAt;

  // NEW AUDIO FIELDS
  final String? audioStorageUrl;       // Firebase Storage URL
  final String? localAudioPath;        // Local cache path
  final Duration? audioDuration;       // Recording length
  final CommentType commentType;       // Type enum

  const AudioComment({
    required AudioCommentId id,
    required this.projectId,
    required this.versionId,
    required this.createdBy,
    required this.content,
    required this.timestamp,
    required this.createdAt,
    this.audioStorageUrl,
    this.localAudioPath,
    this.audioDuration,
    this.commentType = CommentType.text,
  }) : super(id);

  // Factory methods updated...
}

enum CommentType {
  text,    // Text-only (existing)
  audio,   // Audio-only (new)
  hybrid,  // Audio + text (future)
}
```

**Verification:**
- **Unit Test:** Update `test/features/audio_comment/domain/entities/audio_comment_test.dart`
  - Test creation with audio fields
  - Test validation rules
  - Test equality

---

### Step 4.2: Update AudioComment Data Models

**File:** [lib/features/audio_comment/data/models/audio_comment_dto.dart](lib/features/audio_comment/data/models/audio_comment_dto.dart)

**Add Fields:**

```dart
class AudioCommentDTO {
  final String id;
  final String projectId;
  final String trackId;
  final String createdBy;
  final String content;
  final int timestamp;
  final String createdAt;
  final bool isDeleted;
  final int version;
  final DateTime? lastModified;

  // NEW AUDIO FIELDS
  final String? audioStorageUrl;
  final String? localAudioPath;
  final int? audioDurationMs;
  final String commentType;  // 'text', 'audio', 'hybrid'

  // Constructor and methods updated...
}
```

**File:** [lib/features/audio_comment/data/models/audio_comment_document.dart](lib/features/audio_comment/data/models/audio_comment_document.dart)

**Update Isar Schema:**

```dart
@collection
class AudioCommentDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  @Index()
  late String projectId;

  @Index()
  late String trackId;

  late String createdBy;
  late String content;
  late int timestamp;
  late DateTime createdAt;

  SyncMetadataDocument? syncMetadata;

  // NEW AUDIO FIELDS
  late String? audioStorageUrl;
  late String? localAudioPath;
  late int? audioDurationMs;

  @enumerated
  late CommentType commentType;
}

@enumerated
enum CommentType {
  text,
  audio,
  hybrid,
}
```

**Regenerate Isar Schema:**

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Verification:**
- **Unit Test:** Update `test/features/audio_comment/data/models/audio_comment_dto_test.dart`
- **Unit Test:** Update `test/features/audio_comment/data/models/audio_comment_document_test.dart`

---

### Step 4.3: Create Audio Comment Storage Coordinator

**Purpose**: Bridge between recording module and audio comment storage needs

**New File:** `lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart`

```dart
@injectable
class AudioCommentStorageCoordinator {
  final FirebaseAudioUploadService _uploadService;
  final AudioStorageRepository _audioStorageRepository;

  AudioCommentStorageCoordinator(
    this._uploadService,
    this._audioStorageRepository,
  );

  /// Upload audio comment file to Firebase Storage
  Future<Either<Failure, String>> uploadCommentAudio({
    required String localPath,
    required ProjectId projectId,
    required TrackVersionId versionId,
    required AudioCommentId commentId,
  }) async {
    final file = File(localPath);
    final storagePath = _buildStoragePath(projectId, versionId, commentId);

    final metadata = {
      'projectId': projectId.value,
      'versionId': versionId.value,
      'commentId': commentId.value,
      'type': 'audio_comment',
    };

    return await _uploadService.uploadAudioFile(
      audioFile: file,
      storagePath: storagePath,
      metadata: metadata,
    );
  }

  /// Delete audio comment file from Firebase Storage
  Future<Either<Failure, Unit>> deleteCommentAudio({
    required String storageUrl,
  }) async {
    return await _uploadService.deleteAudioFile(storageUrl: storageUrl);
  }

  /// Store recording in audio cache system
  /// Uses existing AudioStorageRepository for consistency
  Future<Either<CacheFailure, String>> storeRecordingInCache({
    required String tempPath,
    required AudioTrackId trackId,  // Using projectId as trackId
    required TrackVersionId versionId,  // Using commentId as versionId
  }) async {
    final audioFile = File(tempPath);

    // Use existing audio cache storage
    final result = await _audioStorageRepository.storeAudio(
      trackId,
      versionId,
      audioFile,
    );

    return result.fold(
      (failure) => Left(failure),
      (cachedAudio) async {
        // Delete temp file after successful cache
        await FileSystemUtils.deleteFileIfExists(tempPath);
        return Right(cachedAudio.filePath);
      },
    );
  }

  String _buildStoragePath(
    ProjectId projectId,
    TrackVersionId versionId,
    AudioCommentId commentId,
  ) {
    return 'audio_comments/${projectId.value}/${versionId.value}/${commentId.value}.m4a';
  }
}
```

**Changes from Original Plan:**
1. Uses `FirebaseAudioUploadService` instead of `AudioStorageService`
2. Uses existing `AudioStorageRepository` for local caching
3. Removed download method (handled by audio cache system)
4. Simplified caching using proven audio cache patterns
5. Uses `FileSystemUtils` for file operations

**Verification:**
- **Unit Test:** `test/features/audio_comment/data/services/audio_comment_storage_coordinator_test.dart`
  - Mock FirebaseAudioUploadService and AudioStorageRepository
  - Test upload path generation
  - Test Firebase metadata attachment
  - Test cache storage integration
  - Test temp file cleanup

---

### Step 4.4: Update Audio Comment Repository

**File:** [lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart](lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart)

**Inject Storage Coordinator:**

```dart
@Injectable(as: AudioCommentRepository)
class AudioCommentRepositoryImpl implements AudioCommentRepository {
  final AudioCommentLocalDataSource _localDataSource;
  final AudioCommentRemoteDataSource _remoteDataSource;
  final PendingOperationsManager _pendingOperationsManager;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;

  // NEW DEPENDENCY
  final AudioCommentStorageCoordinator _storageCoordinator;

  AudioCommentRepositoryImpl(
    this._localDataSource,
    this._remoteDataSource,
    this._pendingOperationsManager,
    this._backgroundSyncCoordinator,
    this._storageCoordinator,  // NEW
  );

  @override
  Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
    try {
      final dto = AudioCommentDTO.fromDomain(comment);

      // 1. Save to local DB immediately
      await _localDataSource.cacheComment(dto);

      // 2. If audio comment, store recording in permanent cache
      if (comment.commentType != CommentType.text &&
          comment.localAudioPath != null) {

        // Use projectId as trackId, commentId as versionId for cache hierarchy
        final trackId = AudioTrackId.fromString(comment.projectId.value);
        final versionId = TrackVersionId.fromString(comment.id.value);

        final cacheResult = await _storageCoordinator.storeRecordingInCache(
          tempPath: comment.localAudioPath!,
          trackId: trackId,
          versionId: versionId,
        );

        final cachePath = await cacheResult.fold(
          (failure) => throw Exception('Failed to cache recording: ${failure.message}'),
          (path) => path,
        );

        // Update DTO with cache path
        final updatedDto = dto.copyWith(localAudioPath: cachePath);
        await _localDataSource.cacheComment(updatedDto);
      }

      // 3. Queue for background sync
      await _pendingOperationsManager.addCreateOperation(
        entityType: 'audio_comment',
        entityId: comment.id.value,
        data: {
          'projectId': comment.projectId.value,
          'trackId': comment.versionId.value,
          'createdBy': comment.createdBy.value,
          'content': comment.content,
          'timestamp': comment.timestamp.inMilliseconds,
          'createdAt': comment.createdAt.toIso8601String(),
          // Audio fields
          'localAudioPath': dto.localAudioPath,
          'audioDurationMs': comment.audioDuration?.inMilliseconds,
          'commentType': comment.commentType.toString().split('.').last,
        },
        priority: SyncPriority.high,
      );

      // 4. Trigger background sync
      unawaited(_backgroundSyncCoordinator.pushUpstream());

      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
    }
  }

  // deleteComment updated similarly...
}
```

**Verification:**
- **Unit Test:** Update `test/features/audio_comment/data/repositories/audio_comment_repository_impl_test.dart`
  - Test addComment with audio recording
  - Test recording move to cache
  - Test sync queue with audio metadata

---

### Step 4.5: Update Audio Comment Presentation

**File:** [lib/features/audio_comment/presentation/components/comment_input_modal.dart](lib/features/audio_comment/presentation/components/comment_input_modal.dart)

**Integrate Recording Module:**

```dart
class _CommentInputModalState extends State<CommentInputModal> {
  // Existing fields
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Duration? _capturedTimestamp;
  bool _isInputFocused = false;

  // NEW: Recording mode
  bool _isRecordingMode = false;
  AudioRecording? _completedRecording;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<RecordingBloc>(),
        ),
        // Existing AudioCommentBloc...
      ],
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      child: Column(
        children: [
          // Mode toggle
          _buildModeToggle(),

          // Conditional input
          if (_isRecordingMode)
            _buildRecordingInterface()
          else
            _buildTextInputField(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return SegmentedButton<bool>(
      segments: [
        ButtonSegment(
          value: false,
          icon: Icon(Icons.text_fields),
          label: Text('Text'),
        ),
        ButtonSegment(
          value: true,
          icon: Icon(Icons.mic),
          label: Text('Audio'),
        ),
      ],
      selected: {_isRecordingMode},
      onSelectionChanged: (Set<bool> selection) {
        setState(() {
          _isRecordingMode = selection.first;
        });
      },
    );
  }

  Widget _buildRecordingInterface() {
    return BlocConsumer<RecordingBloc, RecordingState>(
      listener: (context, state) {
        if (state is RecordingCompleted) {
          setState(() {
            _completedRecording = state.recording;
          });
        }
      },
      builder: (context, state) {
        if (state is RecordingInitial) {
          return _buildRecordingStart();
        } else if (state is RecordingInProgress) {
          return _buildRecordingActive(state.session);
        } else if (state is RecordingPaused) {
          return _buildRecordingPaused(state.session);
        } else if (state is RecordingCompleted) {
          return _buildRecordingPreview(state.recording);
        } else if (state is RecordingError) {
          return _buildRecordingError(state.message);
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildRecordingStart() {
    return RecordingButton(
      isRecording: false,
      onStartRecording: () {
        // Capture timestamp before recording
        final audioPlayerBloc = context.read<AudioPlayerBloc>();
        final playerState = audioPlayerBloc.state;
        if (playerState is AudioPlayerSessionState) {
          setState(() {
            _capturedTimestamp = playerState.session.position;
          });
          // Pause playback
          audioPlayerBloc.add(const PauseAudioRequested());
        }

        // Start recording
        context.read<RecordingBloc>().add(const StartRecordingRequested());
      },
    );
  }

  Widget _buildRecordingActive(RecordingSession session) {
    return Column(
      children: [
        RecordingWaveform(amplitude: session.currentAmplitude ?? 0.0),
        SizedBox(height: Dimensions.space16),
        RecordingTimer(elapsed: session.elapsed),
        SizedBox(height: Dimensions.space16),
        ElevatedButton(
          onPressed: () {
            context.read<RecordingBloc>().add(const StopRecordingRequested());
          },
          child: Text('Stop Recording'),
        ),
        SizedBox(height: Dimensions.space8),
        RecordingControls(
          isPaused: false,
          onCancel: () {
            context.read<RecordingBloc>().add(const CancelRecordingRequested());
          },
        ),
      ],
    );
  }

  Widget _buildRecordingPreview(AudioRecording recording) {
    return Column(
      children: [
        // Audio preview player (simple)
        Text('Recording completed: ${_formatDuration(recording.duration)}'),

        ElevatedButton.icon(
          onPressed: () => _handleSendAudioComment(recording),
          icon: Icon(Icons.send),
          label: Text('Send Audio Comment'),
        ),

        TextButton(
          onPressed: () {
            context.read<RecordingBloc>().add(const CancelRecordingRequested());
            setState(() {
              _completedRecording = null;
            });
          },
          child: Text('Re-record'),
        ),
      ],
    );
  }

  void _handleSendAudioComment(AudioRecording recording) {
    if (_capturedTimestamp == null) return;

    context.read<AudioCommentBloc>().add(
      AddAudioCommentEvent(
        widget.projectId,
        widget.versionId,
        '', // Empty text for audio-only
        _capturedTimestamp!,
        localAudioPath: recording.localPath,
        audioDuration: recording.duration,
        commentType: CommentType.audio,
      ),
    );

    // Reset state
    setState(() {
      _completedRecording = null;
      _isRecordingMode = false;
      _capturedTimestamp = null;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
```

**Verification:**
- **Widget Test:** `test/features/audio_comment/presentation/components/comment_input_modal_test.dart`
  - Test mode toggle
  - Test recording start
  - Test recording preview
  - Test send audio comment
  - Test cancel recording

---

### Step 4.6: Create Audio Comment Playback Widget

**New File:** `lib/features/audio_comment/presentation/components/audio_comment_player.dart`

```dart
/// Widget to play audio from an audio comment
class AudioCommentPlayer extends StatefulWidget {
  final AudioComment comment;

  const AudioCommentPlayer({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  State<AudioCommentPlayer> createState() => _AudioCommentPlayerState();
}

class _AudioCommentPlayerState extends State<AudioCommentPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.positionStream.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _player.playerStateStream.listen((state) {
      if (mounted) setState(() => _isPlaying = state.playing);
    });
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    setState(() => _isLoading = true);

    try {
      // Try local cache first
      if (widget.comment.localAudioPath != null &&
          await File(widget.comment.localAudioPath!).exists()) {
        await _player.setFilePath(widget.comment.localAudioPath!);
      }
      // Otherwise stream from Firebase Storage
      else if (widget.comment.audioStorageUrl != null) {
        await _player.setUrl(widget.comment.audioStorageUrl!);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 48,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(Dimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.grey800,
        borderRadius: BorderRadius.circular(Dimensions.radiusMedium),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (_isPlaying) {
                _player.pause();
              } else {
                _player.play();
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Slider(
                  value: _position.inMilliseconds.toDouble(),
                  max: (widget.comment.audioDuration?.inMilliseconds ?? 0).toDouble(),
                  onChanged: (value) {
                    _player.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: AppTextStyle.labelSmall,
                    ),
                    Text(
                      _formatDuration(widget.comment.audioDuration ?? Duration.zero),
                      style: AppTextStyle.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
```

**Verification:**
- **Widget Test:** `test/features/audio_comment/presentation/components/audio_comment_player_test.dart`
  - Mock AudioPlayer
  - Test play/pause
  - Test seek
  - Test loading state

---

### Step 4.7: Update AudioCommentContent Display

**File:** [lib/features/audio_comment/presentation/components/audio_comment_content.dart](lib/features/audio_comment/presentation/components/audio_comment_content.dart)

**Add Conditional Rendering:**

```dart
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header (name + date)
      _buildHeader(),

      SizedBox(height: Dimensions.space8),

      // Content based on type
      if (comment.commentType == CommentType.text)
        _buildTextContent()
      else if (comment.commentType == CommentType.audio)
        _buildAudioContent()
      else
        _buildHybridContent(),

      SizedBox(height: Dimensions.space8),

      // Timestamp badge
      _buildTimestampBadge(),
    ],
  );
}

Widget _buildTextContent() {
  return Text(comment.content, style: AppTextStyle.bodyMedium);
}

Widget _buildAudioContent() {
  return AudioCommentPlayer(comment: comment);
}

Widget _buildHybridContent() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AudioCommentPlayer(comment: comment),
      SizedBox(height: Dimensions.space8),
      Text(
        comment.content,
        style: AppTextStyle.bodySmall.copyWith(
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
  );
}
```

**Verification:**
- **Widget Test:** Update `test/features/audio_comment/presentation/components/audio_comment_content_test.dart`
  - Test text content rendering
  - Test audio content rendering
  - Test hybrid content rendering

---

## Phase 5: Background Sync Integration

### Step 5.1: Create Audio Comment Sync Executor

**File:** `lib/core/sync/domain/executors/audio_comment_operation_executor.dart`

```dart
@Injectable()
class AudioCommentOperationExecutor implements OperationExecutor {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioCommentStorageCoordinator _storageCoordinator;

  AudioCommentOperationExecutor(
    this._remoteDataSource,
    this._storageCoordinator,
  );

  @override
  String get entityType => 'audio_comment';

  @override
  Future<Either<Failure, Unit>> executeCreate(
    PendingOperation operation,
  ) async {
    try {
      final data = operation.data;

      // 1. Upload audio file if present
      String? audioStorageUrl;
      if (data['localAudioPath'] != null) {
        final uploadResult = await _storageCoordinator.uploadCommentAudio(
          localPath: data['localAudioPath'] as String,
          projectId: ProjectId.fromUniqueString(data['projectId'] as String),
          versionId: TrackVersionId.fromUniqueString(data['trackId'] as String),
          commentId: AudioCommentId.fromUniqueString(operation.entityId),
        );

        audioStorageUrl = await uploadResult.fold(
          (failure) => throw Exception('Audio upload failed: ${failure.message}'),
          (url) => url,
        );
      }

      // 2. Create DTO with audio URL
      final dto = AudioCommentDTO(
        id: operation.entityId,
        projectId: data['projectId'] as String,
        trackId: data['trackId'] as String,
        createdBy: data['createdBy'] as String,
        content: data['content'] as String,
        timestamp: data['timestamp'] as int,
        createdAt: data['createdAt'] as String,
        audioStorageUrl: audioStorageUrl,
        audioDurationMs: data['audioDurationMs'] as int?,
        commentType: data['commentType'] as String? ?? 'text',
        isDeleted: false,
        version: 1,
      );

      // 3. Create Firestore document
      return await _remoteDataSource.addComment(dto);
    } catch (e) {
      return Left(ServerFailure('Sync failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> executeDelete(
    PendingOperation operation,
  ) async {
    try {
      // 1. Delete Firestore document
      final result = await _remoteDataSource.deleteComment(operation.entityId);

      // 2. Delete audio file from Firebase Storage if exists
      final audioStorageUrl = operation.data['audioStorageUrl'] as String?;
      if (audioStorageUrl != null) {
        await _storageCoordinator.deleteCommentAudio(
          storageUrl: audioStorageUrl,
        );
      }

      return result;
    } catch (e) {
      return Left(ServerFailure('Delete sync failed: ${e.toString()}'));
    }
  }
}
```

**Verification:**
- **Unit Test:** `test/core/sync/domain/executors/audio_comment_operation_executor_test.dart`
  - Mock dependencies
  - Test executeCreate with text comment
  - Test executeCreate with audio comment
  - Test executeDelete with audio cleanup

---

## Phase 6: Testing & Deployment

### Step 6.1: Integration Tests

**New Test:** `test/integration_test/audio_recording_integration_test.dart`

**Test Scenarios:**
1. Full recording flow (start → stop → send comment)
2. Recording with pause/resume
3. Recording cancellation
4. Offline recording and sync
5. Audio playback from comment

**New Test:** `test/integration_test/audio_comment_cross_feature_test.dart`

**Test Scenarios:**
1. Record audio → create audio comment → verify in list
2. Play audio comment → seek to timestamp
3. Delete audio comment → verify file cleanup

**Verification:**
```bash
flutter test integration_test/
```

---

### Step 6.2: Manual Testing Checklist

See comprehensive checklist at the end of this document.

---

## Phase 7: Documentation

### Step 7.1: Architecture Documentation

**Update:** `docs/architecture.md`

Add section: **Reusable Audio Recording Module**

```markdown
## Audio Recording Module

The audio recording module is a standalone feature that provides recording capabilities to any part of the application.

### Module Structure

- **Domain Layer**: Recording entities, services, use cases
- **Infrastructure Layer**: Platform-specific recording implementation
- **Presentation Layer**: Reusable recording UI components and BLoC

### Integration Pattern

Consumers integrate via:
1. Depend on `RecordingService` via DI
2. Use `RecordingBloc` for state management
3. Reuse recording widgets (RecordingButton, RecordingWaveform, etc.)
4. Handle recording results (AudioRecording entity)
5. Manage storage according to domain needs

### Current Consumers

- **audio_comment**: Uses recording for voice feedback on tracks
- **Future**: voice_memo, audio_notes, voice_journal
```

---

## Architecture Summary

### Module Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│ audio_recording (Reusable Module)                           │
│  - Provides: Recording capabilities                         │
│  - Exports: RecordingService, RecordingBloc, UI widgets     │
│  - Dependencies: Core services only                         │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ depends on
                            │
┌─────────────────────────────────────────────────────────────┐
│ audio_comment (Consumer)                                    │
│  - Uses: RecordingService, RecordingBloc                    │
│  - Adds: Comment-specific storage logic                     │
│  - Handles: Firebase upload, Firestore persistence          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ voice_memo (Future Consumer)                                │
│  - Uses: RecordingService, RecordingBloc                    │
│  - Adds: Memo-specific storage logic                        │
│  - Handles: Local storage, categorization                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ Core Services (Shared Infrastructure)                       │
│  - AudioStorageService (Firebase Storage abstraction)       │
│  - FileSystemService (Local file operations)                │
│  - PermissionService (Microphone permissions)               │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Injection Configuration

**File:** `lib/core/di/injection.dart`

Ensure all new services are registered:

```dart
@InjectableInit()
void configureDependencies() => getIt.init();

// Modules will auto-register with @injectable annotations:
// - AudioStorageServiceImpl
// - FileSystemServiceImpl
// - PermissionServiceImpl
// - PlatformRecordingService
// - RecordingBloc
// - AudioCommentStorageCoordinator
// - All use cases
```

---

## Files Summary

### New Files (Core Services) - 6 files

1. `lib/core/services/audio_storage_service.dart`
2. `lib/core/services/audio_storage_service_impl.dart`
3. `lib/core/services/file_system_service.dart`
4. `lib/core/services/file_system_service_impl.dart`
5. `lib/core/services/permission_service.dart`
6. `lib/core/services/permission_service_impl.dart`

### New Files (Recording Module) - 18 files

**Domain:**
7. `lib/features/audio_recording/domain/entities/audio_recording.dart`
8. `lib/features/audio_recording/domain/entities/recording_session.dart`
9. `lib/features/audio_recording/domain/services/recording_service.dart`
10. `lib/features/audio_recording/domain/usecases/start_recording_usecase.dart`
11. `lib/features/audio_recording/domain/usecases/stop_recording_usecase.dart`
12. `lib/features/audio_recording/domain/usecases/cancel_recording_usecase.dart`

**Infrastructure:**
13. `lib/features/audio_recording/infrastructure/services/platform_recording_service.dart`

**Presentation:**
14. `lib/features/audio_recording/presentation/bloc/recording_event.dart`
15. `lib/features/audio_recording/presentation/bloc/recording_state.dart`
16. `lib/features/audio_recording/presentation/bloc/recording_bloc.dart`
17. `lib/features/audio_recording/presentation/widgets/recording_button.dart`
18. `lib/features/audio_recording/presentation/widgets/recording_waveform.dart`
19. `lib/features/audio_recording/presentation/widgets/recording_timer.dart`
20. `lib/features/audio_recording/presentation/widgets/recording_controls.dart`

### New Files (Audio Comment Integration) - 3 files

21. `lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart`
22. `lib/features/audio_comment/presentation/components/audio_comment_player.dart`
23. `lib/core/sync/domain/executors/audio_comment_operation_executor.dart`

### Modified Files (Audio Comment) - 6 files

24. `lib/features/audio_comment/domain/entities/audio_comment.dart`
25. `lib/features/audio_comment/data/models/audio_comment_dto.dart`
26. `lib/features/audio_comment/data/models/audio_comment_document.dart`
27. `lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart`
28. `lib/features/audio_comment/presentation/components/comment_input_modal.dart`
29. `lib/features/audio_comment/presentation/components/audio_comment_content.dart`

### Test Files - 23 files

30-52. Corresponding unit/widget/integration tests for all new files

### Documentation - 2 files

53. `docs/architecture.md` (update)
54. `storage.rules` (update)

**Total: 54 files (27 new, 6 modified, 21 tests)**

---

## Estimated Timeline

- **Phase 0 (Core Services)**: 2 days
- **Phase 1 (Recording Domain)**: 2 days
- **Phase 2 (Recording Infrastructure)**: 2 days
- **Phase 3 (Recording Presentation)**: 2 days
- **Phase 4 (Audio Comment Integration)**: 3 days
- **Phase 5 (Sync Integration)**: 2 days
- **Phase 6 (Testing)**: 3 days
- **Phase 7 (Documentation)**: 1 day

**Total: 17 days (3.5 weeks)**

---

# COMPREHENSIVE IMPLEMENTATION CHECKLIST

## Context for Implementation

This checklist provides a sequential, step-by-step guide for implementing the reusable audio recording module and integrating it with the audio comment feature. Each item is self-contained with enough detail for an AI agent or developer to execute independently.

---

## Phase 0: Core Services Setup

### Core Audio Storage Service

- [ ] **Create audio storage service interface**
  - File: `lib/core/services/audio_storage_service.dart`
  - Define abstract methods: `uploadAudioFile`, `downloadAudioFile`, `deleteAudioFile`, `getDownloadUrl`
  - Use `Either<Failure, T>` return types for error handling
  - Accept `remotePath` (Firebase Storage path) and `metadata` (custom key-value pairs)

- [ ] **Implement audio storage service**
  - File: `lib/core/services/audio_storage_service_impl.dart`
  - Inject `FirebaseStorage` instance
  - Annotate with `@LazySingleton(as: AudioStorageService)`
  - Implement upload: use `ref.putFile()` with metadata
  - Implement download: check cache first, then download with `ref.writeToFile()`
  - Implement delete: use `ref.delete()`
  - Wrap all operations with try-catch and return `Either<Failure, T>`

- [ ] **Write unit tests for audio storage service**
  - File: `test/core/services/audio_storage_service_test.dart`
  - Mock `FirebaseStorage` using Mockito
  - Test upload success and failure scenarios
  - Test download with caching logic (skip if file exists)
  - Test delete operations
  - Verify correct Firebase Storage paths are used

---

### Core File System Service

- [ ] **Create file system service interface**
  - File: `lib/core/services/file_system_service.dart`
  - Define methods: `getTemporaryDirectory`, `getApplicationDocumentsDirectory`, `ensureDirectoryExists`, `deleteFile`, `fileExists`, `copyFile`, `getFileSize`, `generateTemporaryFilePath`

- [ ] **Implement file system service**
  - File: `lib/core/services/file_system_service_impl.dart`
  - Annotate with `@LazySingleton(as: FileSystemService)`
  - Use `path_provider` package for directory access
  - Implement `ensureDirectoryExists`: create directory recursively if missing
  - Implement `copyFile`: ensure destination directory exists before copying
  - Implement `generateTemporaryFilePath`: use timestamp + UUID for uniqueness

- [ ] **Write unit tests for file system service**
  - File: `test/core/services/file_system_service_test.dart`
  - Mock `path_provider` methods
  - Test directory creation
  - Test file operations (copy, delete, exists check)
  - Test path generation uniqueness

---

### Core Permission Service

- [ ] **Create permission service interface**
  - File: `lib/core/services/permission_service.dart`
  - Define methods: `hasMicrophonePermission`, `requestMicrophonePermission`, `isPermanentlyDenied`, `openAppSettings`

- [ ] **Implement permission service**
  - File: `lib/core/services/permission_service_impl.dart`
  - Annotate with `@LazySingleton(as: PermissionService)`
  - Use `Record` package's built-in `hasPermission()` method
  - Note: For advanced permission handling, consider adding `permission_handler` package in future

- [ ] **Write unit tests for permission service**
  - File: `test/core/services/permission_service_test.dart`
  - Mock `Record` package
  - Test permission check
  - Test permission request flow

---

## Phase 1: Audio Recording Domain Layer

### Recording Domain Entities

- [ ] **Create AudioRecording entity**
  - File: `lib/features/audio_recording/domain/entities/audio_recording.dart`
  - Fields: `id`, `localPath`, `duration`, `format`, `fileSizeBytes`, `recordedAt`, `metadata`
  - Extend `Equatable` for value equality
  - Provide factory method: `AudioRecording.create()` (auto-generates ID and timestamp)
  - Provide `copyWith()` method
  - Define `AudioFormat` enum: `m4a`, `aac`, `mp3`

- [ ] **Create RecordingSession entity**
  - File: `lib/features/audio_recording/domain/entities/recording_session.dart`
  - Fields: `sessionId`, `startedAt`, `elapsed`, `state`, `outputPath`, `currentAmplitude`
  - Extend `Equatable`
  - Provide `copyWith()` method
  - Define `RecordingState` enum: `idle`, `recording`, `paused`, `stopped`

- [ ] **Write unit tests for recording entities**
  - File: `test/features/audio_recording/domain/entities/audio_recording_test.dart`
  - Test factory creation
  - Test copyWith
  - Test equality
  - File: `test/features/audio_recording/domain/entities/recording_session_test.dart`
  - Test session state transitions

---

### Recording Domain Service

- [ ] **Create RecordingService interface**
  - File: `lib/features/audio_recording/domain/services/recording_service.dart`
  - Define abstract methods: `hasPermission`, `requestPermission`, `startRecording`, `stopRecording`, `pauseRecording`, `resumeRecording`, `cancelRecording`
  - Define getter: `sessionStream` (returns `Stream<RecordingSession>`)
  - Define getter: `isRecording` (returns `bool`)
  - All async methods return `Either<Failure, T>`

---

### Recording Use Cases

- [ ] **Create StartRecordingUseCase**
  - File: `lib/features/audio_recording/domain/usecases/start_recording_usecase.dart`
  - Annotate with `@injectable`
  - Inject: `RecordingService`, `FileSystemService`
  - Logic: Check permission → request if needed → generate output path (temp directory) → call `recordingService.startRecording()`
  - Return `Either<Failure, String>` (session ID)

- [ ] **Create StopRecordingUseCase**
  - File: `lib/features/audio_recording/domain/usecases/stop_recording_usecase.dart`
  - Annotate with `@injectable`
  - Inject: `RecordingService`
  - Logic: Call `recordingService.stopRecording()`
  - Return `Either<Failure, AudioRecording>`

- [ ] **Create CancelRecordingUseCase**
  - File: `lib/features/audio_recording/domain/usecases/cancel_recording_usecase.dart`
  - Annotate with `@injectable`
  - Inject: `RecordingService`, `FileSystemService`
  - Logic: Call `recordingService.cancelRecording()` → delete temp file
  - Return `Either<Failure, Unit>`

- [ ] **Write unit tests for recording use cases**
  - File: `test/features/audio_recording/domain/usecases/start_recording_usecase_test.dart`
  - Mock `RecordingService` and `FileSystemService`
  - Test permission checks
  - Test output path generation
  - File: `test/features/audio_recording/domain/usecases/stop_recording_usecase_test.dart`
  - Test stop recording flow
  - File: `test/features/audio_recording/domain/usecases/cancel_recording_usecase_test.dart`
  - Test cancel and file cleanup

---

## Phase 2: Audio Recording Infrastructure Layer

### Platform Recording Service

- [ ] **Implement PlatformRecordingService**
  - File: `lib/features/audio_recording/infrastructure/services/platform_recording_service.dart`
  - Annotate with `@LazySingleton(as: RecordingService)`
  - Inject: `PermissionService`, `FileSystemService`
  - Maintain state: `_currentSession`, `_elapsedTimer`, `_amplitudeTimer`
  - Implement `startRecording`:
    - Check permission
    - Create output directory
    - Start `Record` package with M4A format (AAC-LC codec, 128kbps, 44.1kHz)
    - Create `RecordingSession` with unique ID
    - Start elapsed timer (100ms interval)
    - Start amplitude monitoring (100ms interval)
    - Emit session via `_sessionController`
  - Implement `stopRecording`:
    - Stop `Record`
    - Cancel timers
    - Get file size
    - Create `AudioRecording` entity
    - Return recording
  - Implement `pauseRecording`, `resumeRecording`, `cancelRecording`
  - Provide `dispose()` method to clean up resources

- [ ] **Write unit tests for platform recording service**
  - File: `test/features/audio_recording/infrastructure/services/platform_recording_service_test.dart`
  - Mock `Record`, `PermissionService`, `FileSystemService`
  - Test start recording flow
  - Test stop recording flow
  - Test pause/resume flow
  - Test cancel recording with cleanup
  - Test elapsed timer updates
  - Test amplitude monitoring
  - Test error scenarios (permission denied, file write failure)

---

## Phase 3: Audio Recording Presentation Layer

### Recording BLoC

- [ ] **Create RecordingEvent**
  - File: `lib/features/audio_recording/presentation/bloc/recording_event.dart`
  - Define events: `StartRecordingRequested`, `StopRecordingRequested`, `PauseRecordingRequested`, `ResumeRecordingRequested`, `CancelRecordingRequested`, `RecordingSessionUpdated`
  - All extend `Equatable`
  - `StartRecordingRequested` has optional `customOutputPath` field

- [ ] **Create RecordingState**
  - File: `lib/features/audio_recording/presentation/bloc/recording_state.dart`
  - Define states: `RecordingInitial`, `RecordingInProgress`, `RecordingPaused`, `RecordingCompleted`, `RecordingError`
  - All extend `Equatable`
  - `RecordingInProgress` and `RecordingPaused` contain `RecordingSession`
  - `RecordingCompleted` contains `AudioRecording`
  - `RecordingError` contains error message

- [ ] **Create RecordingBloc**
  - File: `lib/features/audio_recording/presentation/bloc/recording_bloc.dart`
  - Annotate with `@injectable`
  - Inject: `StartRecordingUseCase`, `StopRecordingUseCase`, `CancelRecordingUseCase`, `RecordingService`
  - Subscribe to `recordingService.sessionStream` in constructor
  - On session updates, add `RecordingSessionUpdated` event
  - Implement event handlers:
    - `_onStartRecording`: Call use case, handle errors
    - `_onStopRecording`: Call use case, emit `RecordingCompleted`
    - `_onPauseRecording`, `_onResumeRecording`, `_onCancelRecording`
    - `_onSessionUpdated`: Map session state to BLoC state
  - Implement `close()`: Cancel session subscription

- [ ] **Write unit tests for recording BLoC**
  - File: `test/features/audio_recording/presentation/bloc/recording_bloc_test.dart`
  - Use `bloc_test` package
  - Mock use cases and recording service
  - Test each event → state transition
  - Test session stream updates
  - Test error scenarios

---

### Recording Widgets

- [ ] **Create RecordingButton widget**
  - File: `lib/features/audio_recording/presentation/widgets/recording_button.dart`
  - Props: `onStartRecording`, `onStopRecording`, `isRecording`, `startLabel`, `stopLabel`
  - Render: ElevatedButton with icon (record or stop) and label
  - Styling: Use AppColors and AppTextStyle

- [ ] **Create RecordingWaveform widget**
  - File: `lib/features/audio_recording/presentation/widgets/recording_waveform.dart`
  - Props: `amplitude`, `color`, `height`
  - Render: CustomPaint with WaveformPainter
  - WaveformPainter: Draw vertical bar with height based on amplitude

- [ ] **Create RecordingTimer widget**
  - File: `lib/features/audio_recording/presentation/widgets/recording_timer.dart`
  - Props: `elapsed`, `style`
  - Render: Text with formatted duration (MM:SS)
  - Use tabular figures font feature for monospace numbers

- [ ] **Create RecordingControls widget**
  - File: `lib/features/audio_recording/presentation/widgets/recording_controls.dart`
  - Props: `onPause`, `onResume`, `onCancel`, `isPaused`
  - Render: Row with pause/resume button and cancel button
  - Use AppColors for styling

- [ ] **Write widget tests for recording widgets**
  - File: `test/features/audio_recording/presentation/widgets/recording_button_test.dart`
  - Test button tap calls correct callback
  - Test icon and label change based on state
  - File: `test/features/audio_recording/presentation/widgets/recording_waveform_test.dart`
  - Test waveform renders
  - File: `test/features/audio_recording/presentation/widgets/recording_timer_test.dart`
  - Test duration formatting
  - File: `test/features/audio_recording/presentation/widgets/recording_controls_test.dart`
  - Test control buttons

---

## Phase 4: Audio Comment Integration

### Domain Layer Updates

- [ ] **Update AudioComment entity**
  - File: `lib/features/audio_comment/domain/entities/audio_comment.dart`
  - Add fields: `audioStorageUrl`, `localAudioPath`, `audioDuration`, `commentType`
  - Define `CommentType` enum: `text`, `audio`, `hybrid`
  - Update factory methods and `copyWith()`
  - Add validation rules

- [ ] **Write unit tests for updated AudioComment entity**
  - File: `test/features/audio_comment/domain/entities/audio_comment_test.dart`
  - Test creation with audio fields
  - Test validation for each CommentType
  - Test copyWith with audio fields

- [ ] **Update AddAudioCommentParams**
  - File: `lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart`
  - Add fields: `localAudioPath`, `audioDuration`, `commentType`
  - Add validation in constructor

---

### Data Layer Updates

- [ ] **Update AudioCommentDTO**
  - File: `lib/features/audio_comment/data/models/audio_comment_dto.dart`
  - Add fields: `audioStorageUrl`, `localAudioPath`, `audioDurationMs`, `commentType`
  - Update `fromDomain()`, `toJson()`, `fromJson()` methods
  - Note: Do NOT serialize `localAudioPath` (local-only field)

- [ ] **Update AudioCommentDocument (Isar schema)**
  - File: `lib/features/audio_comment/data/models/audio_comment_document.dart`
  - Add fields: `audioStorageUrl`, `localAudioPath`, `audioDurationMs`, `commentType` (enumerated)
  - Define `CommentType` enum in same file with `@enumerated` annotation
  - Update `fromDTO()` and `toDTO()` methods

- [ ] **Regenerate Isar schema**
  - Run: `flutter packages pub run build_runner build --delete-conflicting-outputs`
  - Verify no errors in generated code

- [ ] **Write unit tests for updated DTOs**
  - File: `test/features/audio_comment/data/models/audio_comment_dto_test.dart`
  - Test serialization with audio fields
  - Test backward compatibility (missing fields default to text type)
  - File: `test/features/audio_comment/data/models/audio_comment_document_test.dart`
  - Test Isar document conversion

---

### Audio Comment Storage Coordinator

- [ ] **Create AudioCommentStorageCoordinator**
  - File: `lib/features/audio_comment/data/services/audio_comment_storage_coordinator.dart`
  - Annotate with `@injectable`
  - Inject: `AudioStorageService`, `FileSystemService`
  - Implement `uploadCommentAudio`:
    - Build Firebase Storage path: `audio_comments/{projectId}/{versionId}/{commentId}.m4a`
    - Call `audioStorageService.uploadAudioFile()` with metadata
  - Implement `downloadCommentAudio`:
    - Build local cache path
    - Call `audioStorageService.downloadAudioFile()`
  - Implement `deleteCommentAudio`
  - Implement `moveRecordingToCache`:
    - Copy temp file to permanent cache location
    - Delete temp file
  - Provide helper methods: `_buildStoragePath()`, `_buildLocalPath()`, `getFullLocalPath()`

- [ ] **Write unit tests for storage coordinator**
  - File: `test/features/audio_comment/data/services/audio_comment_storage_coordinator_test.dart`
  - Mock `AudioStorageService` and `FileSystemService`
  - Test upload path generation
  - Test download caching
  - Test recording move operation

---

### Repository Updates

- [ ] **Update AudioCommentRepositoryImpl**
  - File: `lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart`
  - Inject: `AudioCommentStorageCoordinator`
  - Update `addComment()`:
    - Save to Isar immediately
    - If audio comment: move recording to cache using coordinator
    - Update Isar document with cache path
    - Queue sync operation with audio metadata
  - Update `deleteComment()`:
    - Mark as deleted in Isar
    - Delete local audio file if exists
    - Queue delete operation with audio URL for remote cleanup

- [ ] **Write unit tests for updated repository**
  - File: `test/features/audio_comment/data/repositories/audio_comment_repository_impl_test.dart`
  - Test addComment with text-only comment
  - Test addComment with audio comment
  - Test recording move to cache
  - Test deleteComment with audio cleanup

---

### Presentation Layer Updates

- [ ] **Update CommentInputModal**
  - File: `lib/features/audio_comment/presentation/components/comment_input_modal.dart`
  - Add state: `_isRecordingMode`, `_completedRecording`
  - Provide `RecordingBloc` via `BlocProvider`
  - Build mode toggle: `SegmentedButton` for text/audio
  - Build recording interface:
    - `RecordingInitial`: Show `RecordingButton`
    - `RecordingInProgress`: Show `RecordingWaveform`, `RecordingTimer`, stop button
    - `RecordingPaused`: Show pause controls
    - `RecordingCompleted`: Show preview and send button
    - `RecordingError`: Show error message
  - On start recording: Capture timestamp from `AudioPlayerBloc` and pause playback
  - On send: Dispatch `AddAudioCommentEvent` with `localAudioPath`, `audioDuration`, `commentType`

- [ ] **Create AudioCommentPlayer widget**
  - File: `lib/features/audio_comment/presentation/components/audio_comment_player.dart`
  - Props: `comment`
  - Manage `AudioPlayer` instance
  - Initialize audio: Try local cache first, fallback to streaming from Firebase Storage
  - Render: Play/pause button, progress slider, duration display
  - Styling: Use AppColors and AppTextStyle

- [ ] **Update AudioCommentContent**
  - File: `lib/features/audio_comment/presentation/components/audio_comment_content.dart`
  - Add conditional rendering based on `comment.commentType`:
    - `CommentType.text`: Render text content
    - `CommentType.audio`: Render `AudioCommentPlayer`
    - `CommentType.hybrid`: Render both

- [ ] **Update AddAudioCommentEvent**
  - File: `lib/features/audio_comment/presentation/bloc/audio_comment_event.dart`
  - Add fields: `localAudioPath`, `audioDuration`, `commentType`

- [ ] **Update AudioCommentBloc handler**
  - File: `lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart`
  - Update `_onAddAudioComment`:
    - Pass audio fields to `AddAudioCommentParams`

- [ ] **Write widget tests for updated components**
  - File: `test/features/audio_comment/presentation/components/comment_input_modal_test.dart`
  - Test mode toggle
  - Test recording flow
  - Test send audio comment
  - File: `test/features/audio_comment/presentation/components/audio_comment_player_test.dart`
  - Mock AudioPlayer
  - Test play/pause
  - Test seek
  - File: `test/features/audio_comment/presentation/components/audio_comment_content_test.dart`
  - Test conditional rendering

---

## Phase 5: Background Sync Integration

### Sync Executor

- [ ] **Create AudioCommentOperationExecutor**
  - File: `lib/core/sync/domain/executors/audio_comment_operation_executor.dart`
  - Annotate with `@Injectable()`
  - Inject: `AudioCommentRemoteDataSource`, `AudioCommentStorageCoordinator`
  - Implement `executeCreate`:
    - Extract audio metadata from operation data
    - If audio comment: Upload audio file via coordinator
    - Create DTO with audio storage URL
    - Create Firestore document
  - Implement `executeDelete`:
    - Delete Firestore document
    - Delete audio file from Firebase Storage if exists

- [ ] **Write unit tests for sync executor**
  - File: `test/core/sync/domain/executors/audio_comment_operation_executor_test.dart`
  - Mock dependencies
  - Test executeCreate with text comment
  - Test executeCreate with audio comment (upload + create)
  - Test executeCreate failure scenarios
  - Test executeDelete with audio cleanup

---

## Phase 6: Testing & Deployment

### Integration Tests

- [ ] **Create audio recording integration test**
  - File: `test/integration_test/audio_recording_integration_test.dart`
  - Test full recording flow: start → stop → receive `AudioRecording`
  - Test recording with pause/resume
  - Test recording cancellation
  - Test elapsed timer updates
  - Test amplitude monitoring

- [ ] **Create audio comment integration test**
  - File: `test/integration_test/audio_comment_recording_integration_test.dart`
  - Test full user flow: navigate to comments → switch to audio mode → record → preview → send → verify comment appears
  - Test offline recording and sync
  - Test audio playback from comment
  - Test permission denial handling

- [ ] **Run all integration tests**
  - Command: `flutter test integration_test/`
  - Verify all tests pass

---

### Manual Testing

- [ ] **Test recording permissions**
  - First-time permission request appears
  - Permission denial shows error message
  - Permission grant enables recording

- [ ] **Test audio recording**
  - Start recording captures audio
  - Waveform animates during recording
  - Elapsed timer updates correctly
  - Stop button ends recording
  - Cancel button discards recording

- [ ] **Test audio preview**
  - Preview player appears after recording
  - Play/pause controls work
  - Duration displays correctly

- [ ] **Test comment submission**
  - Send button creates comment
  - Comment appears in list immediately
  - Audio player renders in comment card

- [ ] **Test audio playback**
  - Tap comment card seeks to timestamp
  - Comment audio player works
  - Audio loads from cache if available

- [ ] **Test offline functionality**
  - Recording works offline
  - Comment saved locally offline
  - Upload queued for background sync
  - Sync completes when online

- [ ] **Test permission system**
  - Viewers cannot record audio comments
  - Editors can record audio comments
  - Users can delete their own audio comments
  - Admins can delete any audio comment

- [ ] **Test edge cases**
  - Very short recording (< 1 second)
  - Long recording (> 5 minutes)
  - Recording interrupted by phone call
  - App backgrounded during recording
  - Network failure during upload

---

### Firebase Configuration

- [ ] **Update Firebase Storage security rules**
  - File: `storage.rules`
  - Add rules for `audio_comments/{projectId}/{versionId}/{commentId}.m4a`
  - Allow read if user is project collaborator
  - Allow write if user has `addComment` permission
  - Allow delete if user is comment author or has `deleteComment` permission

- [ ] **Deploy storage rules**
  - Command: `firebase deploy --only storage`
  - Test rules using Firebase Console emulator

---

### Database Migration

- [ ] **Run Firestore migration script**
  - File: `scripts/migrate_firestore_comments.dart`
  - Add `commentType: 'text'` to existing comments
  - Set `audioStorageUrl` and `audioDurationMs` to null for existing comments
  - Run in batches of 500

- [ ] **Verify migration**
  - Query sample documents in Firebase Console
  - Verify all existing comments have `commentType: "text"`

---

## Phase 7: Documentation

### Code Documentation

- [ ] **Add Dartdoc comments to all new classes**
  - Recording module classes
  - Core service classes
  - Use case classes
  - Include usage examples

### Architecture Documentation

- [ ] **Update architecture.md**
  - Add section: "Reusable Audio Recording Module"
  - Describe module structure
  - Explain integration pattern
  - List current and future consumers

- [ ] **Create user guide**
  - Document how to record audio comments
  - Explain audio comment features
  - Document permission requirements

---

## Final Verification

### Code Quality

- [ ] **Run Flutter analyze**
  - Command: `flutter analyze`
  - Fix all errors and warnings

- [ ] **Run all unit tests**
  - Command: `flutter test`
  - Verify all tests pass

- [ ] **Generate test coverage report**
  - Command: `flutter test --coverage`
  - Command: `genhtml coverage/lcov.info -o coverage/html`
  - Verify code coverage ≥ 80%

### Performance

- [ ] **Profile recording performance**
  - Command: `flutter run --profile`
  - Measure CPU usage during recording
  - Measure memory usage during recording
  - Verify no UI jank (≥ 60 FPS)

- [ ] **Profile upload performance**
  - Measure time to upload 1 MB audio file
  - Verify upload completes within 5 seconds on reasonable network

- [ ] **Profile playback performance**
  - Measure time to start playback (cold cache)
  - Measure time to start playback (warm cache)
  - Verify playback starts within 1 second (cached)

---

## Rollout

### Pre-Release

- [ ] **Create feature branch**
  - Command: `git checkout -b feature/audio-recording-module`

- [ ] **Code review**
  - Submit PR for team review
  - Address all feedback

- [ ] **Merge to main**
  - Command: `git merge feature/audio-recording-module`

### Deployment

- [ ] **Alpha release (TestFlight/Internal Testing)**
  - Deploy to internal test track
  - Team members test all recording flows
  - Monitor Firebase Storage usage
  - Monitor crash reports

- [ ] **Beta release (100 users)**
  - Deploy to beta track
  - Collect user feedback
  - Monitor performance metrics
  - Monitor sync success rate

- [ ] **Production rollout (gradual)**
  - 10% rollout
  - Monitor key metrics (creation rate, upload success, playback errors, storage costs)
  - 50% rollout if metrics healthy
  - 100% rollout if metrics healthy

---

## Post-Release

### Monitoring

- [ ] **Set up Firebase Performance Monitoring**
  - Track audio upload times
  - Track audio playback start times
  - Track recording session durations

- [ ] **Set up Firebase Crashlytics**
  - Monitor crashes related to recording
  - Monitor crashes related to playback

- [ ] **Set up Firebase Analytics**
  - Track audio comment creation events
  - Track audio playback events
  - Track recording cancellation rate

### Maintenance

- [ ] **Monitor Firebase Storage costs**
  - Set up billing alerts
  - Implement storage limits per project (future)

- [ ] **Monitor user feedback**
  - Address user-reported issues
  - Prioritize feature requests (e.g., transcription, editing)

---

## Future Enhancements

### Potential Features

- [ ] **Audio transcription (hybrid comments)**
  - Integrate speech-to-text API
  - Display transcription alongside audio

- [ ] **Audio editing**
  - Trim recordings
  - Adjust volume

- [ ] **Voice memos feature**
  - Reuse recording module for standalone voice memos
  - Implement memo categorization and search

- [ ] **Voice journal feature**
  - Reuse recording module for daily voice entries
  - Implement journal timeline and playback

- [ ] **Audio waveform visualization in playback**
  - Generate waveform data on upload
  - Display interactive waveform in player

---

# END OF IMPLEMENTATION PLAN

This comprehensive checklist provides all necessary context and steps for implementing the reusable audio recording module and integrating it with the audio comment feature. Each checkbox represents a concrete, actionable task that can be executed independently.

**Total Checklist Items:** 150+

**Estimated Completion Time:** 17 days (3.5 weeks)

**Success Criteria:**
- All checkbox items completed
- All tests passing
- Code coverage ≥ 80%
- Performance benchmarks met
- Deployed to production with gradual rollout
