# Audio Recording Comment Feature - Implementation Plan

**Generated:** 2025-10-08
**Based on:** [research_audiocomment.md](research_audiocomment.md)
**Status:** PENDING APPROVAL

---

## Overview

This plan outlines the step-by-step integration of audio recording functionality into the existing text-based audio comment system. The implementation follows Clean Architecture + DDD principles and maintains the existing offline-first sync strategy.

**Key Design Decisions:**
1. Hybrid model: Comments can be text-only, audio-only, or both (audio + transcription)
2. Leverage existing `record: ^5.0.0` dependency (already in pubspec.yaml:64)
3. Firebase Storage for audio file hosting (`/audio_comments/{projectId}/{versionId}/{commentId}.m4a`)
4. Local file system cache for offline playback
5. Reuse existing permission system (`ProjectPermission.addComment` applies to audio)
6. Backward compatible: existing text comments remain unchanged

---

## Phase 1: Domain Layer - Data Model Extensionsbv c

### Step 1.1: Extend AudioComment Entity

**File:** [lib/features/audio_comment/domain/entities/audio_comment.dart](lib/features/audio_comment/domain/entities/audio_comment.dart)

**Current Structure (Lines 5-21):**
```dart
class AudioComment extends Entity<AudioCommentId> {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final UserId createdBy;
  final String content;           // Text comment
  final Duration timestamp;
  final DateTime createdAt;
}
```

**Proposed Changes:**
```dart
class AudioComment extends Entity<AudioCommentId> {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final UserId createdBy;
  final String content;                // Text comment OR transcription
  final Duration timestamp;
  final DateTime createdAt;

  // NEW FIELDS
  final String? audioStorageUrl;       // Firebase Storage URL for audio file
  final String? localAudioPath;        // Local file path for offline playback
  final Duration? audioDuration;       // Length of audio recording
  final CommentType commentType;       // Enum: text, audio, hybrid
}

// NEW ENUM
enum CommentType {
  text,      // Text-only comment (existing behavior)
  audio,     // Audio-only comment (new)
  hybrid,    // Audio + text transcription (future enhancement)
}
```

**Update Factory Methods:**
- Modify `AudioComment.create()` to accept optional audio parameters (Lines 23-38)
- Update `copyWith()` to include new fields (Lines 40-58)

**Validation Rules:**
- If `commentType == CommentType.text`: `content` must not be empty
- If `commentType == CommentType.audio`: `audioStorageUrl` or `localAudioPath` must exist
- If `commentType == CommentType.hybrid`: both `content` and audio URL must exist

**Verification:**
- **Unit Test:** `test/features/audio_comment/domain/entities/audio_comment_test.dart`
  - Test creation with audio fields
  - Test validation rules for each CommentType
  - Test copyWith with audio fields
  - Test equality with new fields

---

### Step 1.2: Create Audio Recording Value Objects

**New File:** `lib/features/audio_comment/domain/value_objects/audio_recording.dart`

**Purpose:** Encapsulate audio recording metadata with validation

```dart
class AudioRecording extends ValueObject<AudioRecording> {
  final String? storageUrl;        // Firebase Storage URL
  final String? localPath;         // Local file path
  final Duration duration;         // Recording length
  final AudioFormat format;        // e.g., m4a, aac

  // Validation
  Either<Failure, AudioRecording> validate() {
    if (storageUrl == null && localPath == null) {
      return Left(ValidationFailure('Audio recording must have a path'));
    }
    if (duration.inMilliseconds <= 0) {
      return Left(ValidationFailure('Invalid audio duration'));
    }
    return Right(this);
  }
}

enum AudioFormat { m4a, aac, mp3 }
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/domain/value_objects/audio_recording_test.dart`
  - Test validation with valid/invalid data
  - Test equality and hash code
  - Test fromJson/toJson serialization

---

### Step 1.3: Update Use Case Parameters

**File:** [lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart](lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart)

**Current Params (Lines 9-21):**
```dart
class AddAudioCommentParams {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;
  final Duration timestamp;
}
```

**Proposed Changes:**
```dart
class AddAudioCommentParams {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;              // Optional for audio-only
  final Duration timestamp;

  // NEW FIELDS
  final String? localAudioPath;      // Path to recorded audio file
  final Duration? audioDuration;     // Recording length
  final CommentType commentType;     // Type of comment

  AddAudioCommentParams({
    required this.projectId,
    required this.versionId,
    this.content = '',
    required this.timestamp,
    this.localAudioPath,
    this.audioDuration,
    this.commentType = CommentType.text,
  }) {
    // Validation
    if (commentType == CommentType.text && content.isEmpty) {
      throw ArgumentError('Text comments require content');
    }
    if (commentType == CommentType.audio && localAudioPath == null) {
      throw ArgumentError('Audio comments require local audio path');
    }
  }
}
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/domain/usecases/add_audio_comment_usecase_test.dart` (existing file - update)
  - Test parameter validation for text comments
  - Test parameter validation for audio comments
  - Test parameter validation for hybrid comments
  - Test use case execution with audio params

---

## Phase 2: Data Layer - Storage & Persistence

### Step 2.1: Update AudioCommentDTO

**File:** [lib/features/audio_comment/data/models/audio_comment_dto.dart](lib/features/audio_comment/data/models/audio_comment_dto.dart)

**Current Structure (Lines 4-31):**
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
}
```

**Proposed Changes:**
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

  // NEW FIELDS
  final String? audioStorageUrl;       // Firebase Storage URL
  final String? localAudioPath;        // Local cache path
  final int? audioDurationMs;          // Audio length in milliseconds
  final String commentType;            // 'text', 'audio', 'hybrid'
}
```

**Update Serialization Methods:**

**fromDomain (Lines 35-49):**
```dart
factory AudioCommentDTO.fromDomain(AudioComment audioComment) {
  return AudioCommentDTO(
    // ... existing fields ...
    audioStorageUrl: audioComment.audioStorageUrl,
    localAudioPath: audioComment.localAudioPath,
    audioDurationMs: audioComment.audioDuration?.inMilliseconds,
    commentType: audioComment.commentType.toString().split('.').last,
  );
}
```

**toJson (Lines 63-79):**
```dart
Map<String, dynamic> toJson() {
  return {
    // ... existing fields ...
    'audioStorageUrl': audioStorageUrl,
    'audioDurationMs': audioDurationMs,
    'commentType': commentType,
    // NOTE: Do NOT serialize localAudioPath (local-only field)
  };
}
```

**fromJson (Lines 81-100):**
```dart
factory AudioCommentDTO.fromJson(Map<String, dynamic> json) {
  return AudioCommentDTO(
    // ... existing fields ...
    audioStorageUrl: json['audioStorageUrl'] as String?,
    audioDurationMs: json['audioDurationMs'] as int?,
    commentType: json['commentType'] as String? ?? 'text',
    localAudioPath: null, // Will be populated from local cache
  );
}
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/data/models/audio_comment_dto_test.dart`
  - Test fromDomain with audio fields
  - Test toJson with audio fields
  - Test fromJson with audio fields
  - Test backward compatibility (missing audio fields default to text type)

---

### Step 2.2: Update Isar Database Schema

**File:** [lib/features/audio_comment/data/models/audio_comment_document.dart](lib/features/audio_comment/data/models/audio_comment_document.dart)

**Current Schema (Lines 8-28):**
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
}
```

**Proposed Changes:**
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

  // NEW FIELDS
  late String? audioStorageUrl;     // Firebase Storage URL
  late String? localAudioPath;      // Local file system path
  late int? audioDurationMs;        // Audio duration in milliseconds
  @enumerated                       // Isar enum annotation
  late CommentType commentType;     // Type enum
}

// Isar requires enums to be in same file or imported
@Enumerated()
enum CommentType {
  text,
  audio,
  hybrid,
}
```

**Update Conversion Methods:**

**fromDTO (Lines 32-51):**
```dart
factory AudioCommentDocument.fromDTO(AudioCommentDTO dto, {
  SyncMetadataDocument? syncMeta,
}) {
  return AudioCommentDocument()
    // ... existing fields ...
    ..audioStorageUrl = dto.audioStorageUrl
    ..localAudioPath = dto.localAudioPath
    ..audioDurationMs = dto.audioDurationMs
    ..commentType = _parseCommentType(dto.commentType);
}

static CommentType _parseCommentType(String? type) {
  switch (type) {
    case 'audio': return CommentType.audio;
    case 'hybrid': return CommentType.hybrid;
    default: return CommentType.text;
  }
}
```

**toDTO (Lines 53-72):**
```dart
AudioCommentDTO toDTO() {
  return AudioCommentDTO(
    // ... existing fields ...
    audioStorageUrl: audioStorageUrl,
    localAudioPath: localAudioPath,
    audioDurationMs: audioDurationMs,
    commentType: commentType.toString().split('.').last,
  );
}
```

**Important:** After schema changes, regenerate Isar code:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/data/models/audio_comment_document_test.dart`
  - Test fromDTO with audio fields
  - Test toDTO with audio fields
  - Test backward compatibility with legacy documents
- **Integration Test:** After code generation, verify Isar schema migration
  ```bash
  flutter test integration_test/database_migration_test.dart
  ```

---

### Step 2.3: Create Audio Storage Service

**New File:** `lib/features/audio_comment/data/services/audio_comment_storage_service.dart`

**Purpose:** Handle audio file upload/download/cache management

```dart
abstract class AudioCommentStorageService {
  /// Upload local audio file to Firebase Storage
  /// Returns storage URL on success
  Future<Either<Failure, String>> uploadAudioFile({
    required String localPath,
    required ProjectId projectId,
    required TrackVersionId versionId,
    required AudioCommentId commentId,
  });

  /// Download audio file from Firebase Storage to local cache
  /// Returns local file path on success
  Future<Either<Failure, String>> downloadAudioFile({
    required String storageUrl,
    required AudioCommentId commentId,
  });

  /// Delete audio file from Firebase Storage
  Future<Either<Failure, Unit>> deleteAudioFile({
    required String storageUrl,
  });

  /// Delete local cached audio file
  Future<Either<Failure, Unit>> deleteLocalAudioFile({
    required String localPath,
  });

  /// Get local cache path for audio file
  String getLocalAudioPath(AudioCommentId commentId);
}
```

**Implementation File:** `lib/features/audio_comment/data/services/audio_comment_storage_service_impl.dart`

```dart
@Injectable(as: AudioCommentStorageService)
class AudioCommentStorageServiceImpl implements AudioCommentStorageService {
  final FirebaseStorage _storage;
  final PathProvider _pathProvider;

  @override
  Future<Either<Failure, String>> uploadAudioFile({
    required String localPath,
    required ProjectId projectId,
    required TrackVersionId versionId,
    required AudioCommentId commentId,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return Left(StorageFailure('Local audio file not found'));
      }

      // Firebase Storage path: /audio_comments/{projectId}/{versionId}/{commentId}.m4a
      final storagePath = 'audio_comments/${projectId.value}/${versionId.value}/${commentId.value}.m4a';
      final ref = _storage.ref().child(storagePath);

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: 'audio/m4a',
        customMetadata: {
          'projectId': projectId.value,
          'versionId': versionId.value,
          'commentId': commentId.value,
        },
      );

      final uploadTask = ref.putFile(file, metadata);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(StorageFailure('Upload failed: ${e.message}'));
    } catch (e) {
      return Left(StorageFailure('Upload failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadAudioFile({
    required String storageUrl,
    required AudioCommentId commentId,
  }) async {
    try {
      final localPath = getLocalAudioPath(commentId);
      final file = File(localPath);

      // Skip if already cached
      if (await file.exists()) {
        return Right(localPath);
      }

      // Create directory if needed
      await file.parent.create(recursive: true);

      // Download from Firebase Storage
      final ref = _storage.refFromURL(storageUrl);
      await ref.writeToFile(file);

      return Right(localPath);
    } on FirebaseException catch (e) {
      return Left(StorageFailure('Download failed: ${e.message}'));
    } catch (e) {
      return Left(StorageFailure('Download failed: ${e.toString()}'));
    }
  }

  @override
  String getLocalAudioPath(AudioCommentId commentId) {
    final appDir = _pathProvider.getApplicationDocumentsDirectory();
    return '${appDir.path}/audio_comments/${commentId.value}.m4a';
  }

  // ... deleteAudioFile and deleteLocalAudioFile implementations
}
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/data/services/audio_comment_storage_service_test.dart`
  - Mock Firebase Storage and file system
  - Test uploadAudioFile success and failure scenarios
  - Test downloadAudioFile with caching logic
  - Test deleteAudioFile
  - Test getLocalAudioPath path generation
- **Integration Test:** `test/integration_test/audio_storage_integration_test.dart`
  - Use Firebase Storage emulator
  - Test full upload-download-delete cycle
  - Verify file integrity after upload/download

---

### Step 2.4: Update Repository Implementation

**File:** [lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart](lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart)

**Update addComment Method (Lines 126-164):**

**Current Implementation:**
```dart
@override
Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
  try {
    final dto = AudioCommentDTO.fromDomain(comment);

    // 1. ALWAYS save locally first
    await _localDataSource.cacheComment(dto);

    // 2. Queue for background sync
    final queueResult = await _pendingOperationsManager.addCreateOperation(
      entityType: 'audio_comment',
      entityId: comment.id.value,
      data: {...},
      priority: SyncPriority.high,
    );

    // 3. Trigger background sync
    unawaited(_backgroundSyncCoordinator.pushUpstream());

    return const Right(unit);
  } catch (e) {
    return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
  }
}
```

**Proposed Changes:**
```dart
@override
Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
  try {
    final dto = AudioCommentDTO.fromDomain(comment);

    // 1. ALWAYS save locally first
    await _localDataSource.cacheComment(dto);

    // 2. If audio comment, handle file operations
    if (comment.commentType == CommentType.audio ||
        comment.commentType == CommentType.hybrid) {

      // 2a. Copy recorded audio to permanent local cache
      if (comment.localAudioPath != null) {
        final cachePath = _audioStorageService.getLocalAudioPath(comment.id);
        final sourceFile = File(comment.localAudioPath!);
        final cacheFile = File(cachePath);
        await sourceFile.copy(cachePath);

        // Update local document with cache path
        dto.localAudioPath = cachePath;
        await _localDataSource.cacheComment(dto);
      }
    }

    // 3. Queue for background sync
    final queueResult = await _pendingOperationsManager.addCreateOperation(
      entityType: 'audio_comment',
      entityId: comment.id.value,
      data: {
        'trackId': comment.versionId.value,
        'projectId': comment.projectId.value,
        'createdBy': comment.createdBy.value,
        'content': comment.content,
        'timestamp': comment.timestamp.inMilliseconds,
        'createdAt': comment.createdAt.toIso8601String(),
        // NEW: Audio metadata
        'localAudioPath': dto.localAudioPath,
        'audioDurationMs': comment.audioDuration?.inMilliseconds,
        'commentType': comment.commentType.toString().split('.').last,
      },
      priority: SyncPriority.high,
    );

    // 4. Trigger background sync (includes audio upload)
    unawaited(_backgroundSyncCoordinator.pushUpstream());

    return const Right(unit);
  } catch (e) {
    return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
  }
}
```

**Update deleteComment Method:**
```dart
@override
Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId) async {
  try {
    // 1. Get comment to check if it has audio
    final commentResult = await getCommentById(commentId);

    return await commentResult.fold(
      (failure) => Left(failure),
      (comment) async {
        // 2. Mark as deleted in local DB
        await _localDataSource.deleteComment(commentId.value);

        // 3. Delete local audio file if exists
        if (comment.localAudioPath != null) {
          await _audioStorageService.deleteLocalAudioFile(
            localPath: comment.localAudioPath!,
          );
        }

        // 4. Queue delete operation for Firebase sync
        await _pendingOperationsManager.addDeleteOperation(
          entityType: 'audio_comment',
          entityId: commentId.value,
          data: {
            'audioStorageUrl': comment.audioStorageUrl, // For remote deletion
          },
          priority: SyncPriority.high,
        );

        // 5. Trigger background sync
        unawaited(_backgroundSyncCoordinator.pushUpstream());

        return const Right(unit);
      },
    );
  } catch (e) {
    return Left(DatabaseFailure('Delete failed: ${e.toString()}'));
  }
}
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/data/repositories/audio_comment_repository_impl_test.dart`
  - Mock AudioCommentStorageService
  - Test addComment with text-only comment (existing behavior)
  - Test addComment with audio comment (new behavior)
  - Test audio file copying to cache
  - Test deleteComment with audio file cleanup
  - Test offline queue with audio metadata

---

### Step 2.5: Create Audio Sync Operation Executor

**New File:** `lib/core/sync/domain/executors/audio_comment_operation_executor.dart`

**Purpose:** Execute background sync operations for audio comments with file upload

```dart
@Injectable()
class AudioCommentOperationExecutor implements OperationExecutor {
  final AudioCommentRemoteDataSource _remoteDataSource;
  final AudioCommentStorageService _audioStorageService;

  @override
  String get entityType => 'audio_comment';

  @override
  Future<Either<Failure, Unit>> executeCreate(
    PendingOperation operation,
  ) async {
    try {
      final data = operation.data;

      // 1. Upload audio file first if present
      String? audioStorageUrl;
      if (data['localAudioPath'] != null) {
        final uploadResult = await _audioStorageService.uploadAudioFile(
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
        await _audioStorageService.deleteAudioFile(
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

**Register in DI:** Update `lib/core/di/injection.dart` to include this executor

**Verification:**
- **Unit Test:** `test/core/sync/domain/executors/audio_comment_operation_executor_test.dart`
  - Mock remoteDataSource and audioStorageService
  - Test executeCreate with text-only comment
  - Test executeCreate with audio comment (upload + create)
  - Test executeCreate failure scenarios (upload fails, firestore fails)
  - Test executeDelete with audio file cleanup

---

## Phase 3: Presentation Layer - Recording UI

### Step 3.1: Create Audio Recording Service

**New File:** `lib/features/audio_comment/presentation/services/audio_recording_service.dart`

**Purpose:** Wrapper around `record` package for recording management

```dart
@Injectable()
class AudioRecordingService {
  final Record _recorder = Record();

  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording(String outputPath) async {
    if (!await hasPermission()) {
      throw RecordingPermissionException();
    }

    await _recorder.start(
      path: outputPath,
      encoder: AudioEncoder.aacLc, // M4A format
      bitRate: 128000,
      samplingRate: 44100,
    );
  }

  Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    return path;
  }

  Future<void> pauseRecording() async {
    await _recorder.pause();
  }

  Future<void> resumeRecording() async {
    await _recorder.resume();
  }

  Future<void> cancelRecording() async {
    await _recorder.cancel();
  }

  Stream<RecordState> get onStateChanged => _recorder.onStateChanged();

  Future<Amplitude> getAmplitude() async {
    return await _recorder.getAmplitude();
  }

  void dispose() {
    _recorder.dispose();
  }
}
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/presentation/services/audio_recording_service_test.dart`
  - Mock Record package (use mockito)
  - Test permission checking
  - Test recording start/stop cycle
  - Test pause/resume functionality
  - Test amplitude stream for waveform

---

### Step 3.2: Create Recording State BLoC

**New File:** `lib/features/audio_comment/presentation/bloc/audio_recording_bloc.dart`

**Purpose:** Manage recording state separate from comment submission

```dart
// Events
sealed class AudioRecordingEvent {}
class StartRecordingEvent extends AudioRecordingEvent {}
class StopRecordingEvent extends AudioRecordingEvent {}
class PauseRecordingEvent extends AudioRecordingEvent {}
class ResumeRecordingEvent extends AudioRecordingEvent {}
class CancelRecordingEvent extends AudioRecordingEvent {}

// States
sealed class AudioRecordingState {}
class AudioRecordingInitial extends AudioRecordingState {}
class AudioRecordingInProgress extends AudioRecordingState {
  final Duration elapsed;
  final double amplitude; // For waveform visualization
}
class AudioRecordingPaused extends AudioRecordingState {
  final Duration elapsed;
}
class AudioRecordingCompleted extends AudioRecordingState {
  final String filePath;
  final Duration duration;
}
class AudioRecordingError extends AudioRecordingState {
  final String message;
}

// BLoC
@Injectable()
class AudioRecordingBloc extends Bloc<AudioRecordingEvent, AudioRecordingState> {
  final AudioRecordingService _recordingService;
  Timer? _elapsedTimer;
  Duration _elapsed = Duration.zero;

  AudioRecordingBloc(this._recordingService) : super(AudioRecordingInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<PauseRecordingEvent>(_onPauseRecording);
    on<ResumeRecordingEvent>(_onResumeRecording);
    on<CancelRecordingEvent>(_onCancelRecording);
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<AudioRecordingState> emit,
  ) async {
    try {
      if (!await _recordingService.hasPermission()) {
        emit(AudioRecordingError('Microphone permission denied'));
        return;
      }

      final outputPath = await _getTemporaryRecordingPath();
      await _recordingService.startRecording(outputPath);

      _elapsed = Duration.zero;
      _startElapsedTimer(emit);

      emit(AudioRecordingInProgress(elapsed: Duration.zero, amplitude: 0.0));
    } catch (e) {
      emit(AudioRecordingError('Failed to start recording: $e'));
    }
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<AudioRecordingState> emit,
  ) async {
    try {
      _elapsedTimer?.cancel();
      final path = await _recordingService.stopRecording();

      if (path == null) {
        emit(AudioRecordingError('Recording failed to save'));
        return;
      }

      emit(AudioRecordingCompleted(filePath: path, duration: _elapsed));
    } catch (e) {
      emit(AudioRecordingError('Failed to stop recording: $e'));
    }
  }

  void _startElapsedTimer(Emitter<AudioRecordingState> emit) {
    _elapsedTimer = Timer.periodic(Duration(milliseconds: 100), (_) async {
      _elapsed += Duration(milliseconds: 100);
      final amplitude = await _recordingService.getAmplitude();
      emit(AudioRecordingInProgress(
        elapsed: _elapsed,
        amplitude: amplitude.current.abs(),
      ));
    });
  }

  Future<String> _getTemporaryRecordingPath() async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${tempDir.path}/recording_$timestamp.m4a';
  }

  @override
  Future<void> close() {
    _elapsedTimer?.cancel();
    _recordingService.dispose();
    return super.close();
  }
}
```

**Verification:**
- **Unit Test:** `test/features/audio_comment/presentation/bloc/audio_recording_bloc_test.dart`
  - Use bloc_test package
  - Test start recording flow
  - Test stop recording flow
  - Test pause/resume flow
  - Test cancel recording flow
  - Test elapsed timer updates
  - Test permission denial handling

---

### Step 3.3: Update CommentInputModal Widget

**File:** [lib/features/audio_comment/presentation/components/comment_input_modal.dart](lib/features/audio_comment/presentation/components/comment_input_modal.dart)

**Current Structure (Lines 21-265):**
- Text input field
- Send button
- Timestamp capture on focus

**Proposed Changes:**

**Add Recording Mode Toggle:**
```dart
class _CommentInputModalState extends State<CommentInputModal> {
  // Existing fields...
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Duration? _capturedTimestamp;
  bool _isInputFocused = false;
  late AnimationController _animationController;

  // NEW FIELDS
  bool _isRecordingMode = false;        // Toggle between text/audio
  String? _recordedAudioPath;           // Completed recording path
  Duration? _recordedAudioDuration;     // Recording length

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AudioRecordingBloc>(),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Container(
      child: Column(
        children: [
          // Header with mode toggle
          _buildHeaderWithModeToggle(),

          // Conditional input: text field OR recording UI
          _isRecordingMode
            ? _buildRecordingInterface()
            : _buildTextInputField(),
        ],
      ),
    );
  }

  Widget _buildHeaderWithModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_capturedTimestamp != null)
          Text('Comment at ${_formatDuration(_capturedTimestamp!)}'),

        // Mode toggle buttons
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, icon: Icon(Icons.text_fields), label: Text('Text')),
            ButtonSegment(value: true, icon: Icon(Icons.mic), label: Text('Audio')),
          ],
          selected: {_isRecordingMode},
          onSelectionChanged: (Set<bool> selection) {
            setState(() {
              _isRecordingMode = selection.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildRecordingInterface() {
    return BlocBuilder<AudioRecordingBloc, AudioRecordingState>(
      builder: (context, state) {
        if (state is AudioRecordingInitial) {
          return _buildRecordingIdleUI();
        } else if (state is AudioRecordingInProgress) {
          return _buildRecordingActiveUI(state.elapsed, state.amplitude);
        } else if (state is AudioRecordingCompleted) {
          return _buildRecordingPreviewUI(state.filePath, state.duration);
        } else if (state is AudioRecordingError) {
          return _buildRecordingErrorUI(state.message);
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildRecordingIdleUI() {
    return ElevatedButton.icon(
      onPressed: () {
        context.read<AudioRecordingBloc>().add(StartRecordingEvent());
      },
      icon: Icon(Icons.fiber_manual_record),
      label: Text('Start Recording'),
    );
  }

  Widget _buildRecordingActiveUI(Duration elapsed, double amplitude) {
    return Column(
      children: [
        // Waveform visualization
        Container(
          height: 60,
          child: CustomPaint(
            painter: WaveformPainter(amplitude: amplitude),
          ),
        ),

        // Elapsed time
        Text(_formatDuration(elapsed), style: AppTextStyle.titleLarge),

        // Stop button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.stop, color: AppColors.error),
              onPressed: () {
                context.read<AudioRecordingBloc>().add(StopRecordingEvent());
              },
            ),
            IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                context.read<AudioRecordingBloc>().add(CancelRecordingEvent());
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordingPreviewUI(String filePath, Duration duration) {
    // Save recording info for submission
    _recordedAudioPath = filePath;
    _recordedAudioDuration = duration;

    return Column(
      children: [
        // Audio playback preview
        AudioPlayerPreview(filePath: filePath),

        // Send button
        ElevatedButton.icon(
          onPressed: _handleSendAudioComment,
          icon: Icon(Icons.send),
          label: Text('Send Audio Comment'),
        ),

        // Re-record button
        TextButton(
          onPressed: () {
            context.read<AudioRecordingBloc>().add(CancelRecordingEvent());
            setState(() {
              _recordedAudioPath = null;
              _recordedAudioDuration = null;
            });
          },
          child: Text('Re-record'),
        ),
      ],
    );
  }

  void _handleSendAudioComment() {
    if (_recordedAudioPath == null || _capturedTimestamp == null) return;

    context.read<AudioCommentBloc>().add(
      AddAudioCommentEvent(
        widget.projectId,
        widget.versionId,
        '', // Empty text for audio-only comment
        _capturedTimestamp!,
        localAudioPath: _recordedAudioPath,
        audioDuration: _recordedAudioDuration,
        commentType: CommentType.audio,
      ),
    );

    // Reset state
    setState(() {
      _recordedAudioPath = null;
      _recordedAudioDuration = null;
      _isRecordingMode = false;
      _capturedTimestamp = null;
    });
    _focusNode.unfocus();
  }

  // ... existing _handleSend for text comments
}
```

**New Widget:** `lib/features/audio_comment/presentation/components/waveform_painter.dart`

```dart
class WaveformPainter extends CustomPainter {
  final double amplitude;

  WaveformPainter({required this.amplitude});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.fill;

    final barHeight = amplitude * size.height;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 4,
      height: barHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(2)),
      paint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude;
  }
}
```

**Verification:**
- **Widget Test:** `test/features/audio_comment/presentation/components/comment_input_modal_test.dart`
  - Test mode toggle between text and audio
  - Test recording start/stop flow
  - Test audio preview after recording
  - Test send audio comment action
  - Test re-record functionality
  - Test permission denial handling
- **Integration Test:** `test/integration_test/audio_comment_recording_test.dart`
  - Test full user flow: tap audio mode → record → preview → send
  - Verify audio file is created and uploaded

---

### Step 3.4: Update AudioCommentEvent

**File:** [lib/features/audio_comment/presentation/bloc/audio_comment_event.dart](lib/features/audio_comment/presentation/bloc/audio_comment_event.dart)

**Current Event (Lines 9-17):**
```dart
class AddAudioCommentEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;
  final Duration timestamp;
}
```

**Proposed Changes:**
```dart
class AddAudioCommentEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;
  final Duration timestamp;

  // NEW FIELDS
  final String? localAudioPath;
  final Duration? audioDuration;
  final CommentType commentType;

  const AddAudioCommentEvent(
    this.projectId,
    this.versionId,
    this.content,
    this.timestamp, {
    this.localAudioPath,
    this.audioDuration,
    this.commentType = CommentType.text,
  });
}
```

**Update BLoC Handler:** [lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart](lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart):33-49

```dart
Future<void> _onAddAudioComment(
  AddAudioCommentEvent event,
  Emitter<AudioCommentState> emit,
) async {
  final result = await addAudioCommentUseCase.call(
    AddAudioCommentParams(
      projectId: event.projectId,
      versionId: event.versionId,
      content: event.content,
      timestamp: event.timestamp,
      localAudioPath: event.localAudioPath,        // NEW
      audioDuration: event.audioDuration,          // NEW
      commentType: event.commentType,              // NEW
    ),
  );
  result.fold(
    (failure) => emit(AudioCommentError(failure.message)),
    (_) => null,  // Success handled by stream update
  );
}
```

**Verification:**
- **Unit Test:** Update `test/features/audio_comment/presentation/bloc/audio_comment_bloc_test.dart`
  - Test AddAudioCommentEvent with text-only data
  - Test AddAudioCommentEvent with audio data
  - Verify use case called with correct parameters

---

### Step 3.5: Update AudioCommentContent Display

**File:** [lib/features/audio_comment/presentation/components/audio_comment_content.dart](lib/features/audio_comment/presentation/components/audio_comment_content.dart)

**Current Display (Lines 33-94):**
- User name + date
- Text content
- Timestamp badge

**Proposed Changes:**

```dart
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header with name and date (unchanged)
      _buildHeader(),

      SizedBox(height: Dimensions.space8),

      // Conditional content based on comment type
      if (comment.commentType == CommentType.text)
        _buildTextContent()
      else if (comment.commentType == CommentType.audio)
        _buildAudioContent()
      else
        _buildHybridContent(),

      SizedBox(height: Dimensions.space8),

      // Timestamp badge (unchanged)
      _buildTimestampBadge(),
    ],
  );
}

Widget _buildTextContent() {
  return Text(comment.content, style: AppTextStyle.bodyMedium);
}

Widget _buildAudioContent() {
  return AudioCommentPlayer(
    audioUrl: comment.audioStorageUrl,
    localPath: comment.localAudioPath,
    duration: comment.audioDuration,
    commentId: comment.id,
  );
}

Widget _buildHybridContent() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildAudioContent(),
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

**New Widget:** `lib/features/audio_comment/presentation/components/audio_comment_player.dart`

```dart
class AudioCommentPlayer extends StatefulWidget {
  final String? audioUrl;
  final String? localPath;
  final Duration? duration;
  final AudioCommentId commentId;

  const AudioCommentPlayer({
    required this.audioUrl,
    required this.localPath,
    required this.duration,
    required this.commentId,
  });

  @override
  State<AudioCommentPlayer> createState() => _AudioCommentPlayerState();
}

class _AudioCommentPlayerState extends State<AudioCommentPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.positionStream.listen((position) {
      setState(() => _position = position);
    });
    _player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
    _initializeAudio();
  }

  Future<void> _initializeAudio() async {
    setState(() => _isLoading = true);

    try {
      // Try local cache first
      if (widget.localPath != null && await File(widget.localPath!).exists()) {
        await _player.setFilePath(widget.localPath!);
      }
      // Otherwise use remote URL
      else if (widget.audioUrl != null) {
        await _player.setUrl(widget.audioUrl!);

        // Cache download for offline use
        _downloadAndCacheAudio();
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadAndCacheAudio() async {
    // Trigger background download via repository
    // This will populate localPath for future playback
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
          // Play/Pause button
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

          // Progress bar
          Expanded(
            child: Column(
              children: [
                Slider(
                  value: _position.inMilliseconds.toDouble(),
                  max: (widget.duration?.inMilliseconds ?? 0).toDouble(),
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
                      _formatDuration(widget.duration ?? Duration.zero),
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
- **Widget Test:** `test/features/audio_comment/presentation/components/audio_comment_content_test.dart`
  - Test rendering text comment
  - Test rendering audio comment with player
  - Test rendering hybrid comment
- **Widget Test:** `test/features/audio_comment/presentation/components/audio_comment_player_test.dart`
  - Mock AudioPlayer
  - Test play/pause functionality
  - Test seek functionality
  - Test duration display
  - Test loading state
- **Integration Test:** `test/integration_test/audio_comment_playback_test.dart`
  - Test audio playback with real audio file
  - Test offline playback from cache

---

## Phase 4: Testing & Verification

### Step 4.1: Unit Tests Summary

**New Test Files to Create:**
1. `test/features/audio_comment/domain/entities/audio_comment_test.dart` - Domain entity with audio fields
2. `test/features/audio_comment/domain/value_objects/audio_recording_test.dart` - Audio recording VO
3. `test/features/audio_comment/data/models/audio_comment_dto_test.dart` - DTO serialization
4. `test/features/audio_comment/data/models/audio_comment_document_test.dart` - Isar document
5. `test/features/audio_comment/data/services/audio_comment_storage_service_test.dart` - Storage service
6. `test/features/audio_comment/data/repositories/audio_comment_repository_impl_test.dart` - Repository
7. `test/core/sync/domain/executors/audio_comment_operation_executor_test.dart` - Sync executor
8. `test/features/audio_comment/presentation/services/audio_recording_service_test.dart` - Recording service
9. `test/features/audio_comment/presentation/bloc/audio_recording_bloc_test.dart` - Recording BLoC
10. `test/features/audio_comment/presentation/components/audio_comment_player_test.dart` - Player widget

**Test Execution:**
```bash
# Run all audio comment unit tests
flutter test test/features/audio_comment/

# Run core sync tests
flutter test test/core/sync/domain/executors/audio_comment_operation_executor_test.dart

# Generate coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Success Criteria:**
- All new unit tests pass
- Code coverage ≥ 80% for new code
- No breaking changes to existing tests

---

### Step 4.2: Integration Tests

**New Integration Test:** `test/integration_test/audio_comment_recording_integration_test.dart`

**Test Scenarios:**
1. **Full Recording Flow:**
   - User navigates to comments screen
   - Captures timestamp
   - Switches to audio mode
   - Starts recording
   - Stops recording
   - Previews audio
   - Sends comment
   - Verify comment appears in list with audio player

2. **Offline Recording:**
   - Disable network
   - Record audio comment
   - Verify saved locally
   - Enable network
   - Verify background sync uploads to Firebase

3. **Audio Playback:**
   - Create audio comment
   - Tap on comment card
   - Verify audio seeks to timestamp
   - Play audio from comment
   - Verify playback controls work

4. **Permission Handling:**
   - Deny microphone permission
   - Attempt to record
   - Verify error message
   - Grant permission
   - Verify recording works

**Test Setup:**
```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Audio Comment Recording Integration', () {
    testWidgets('Full recording and playback flow', (tester) async {
      // 1. Launch app and navigate to comments screen
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Login and navigate to project
      // ...

      // 2. Tap to focus input (captures timestamp)
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // 3. Switch to audio mode
      await tester.tap(find.text('Audio'));
      await tester.pumpAndSettle();

      // 4. Start recording
      await tester.tap(find.text('Start Recording'));
      await tester.pump(Duration(seconds: 2)); // Record for 2 seconds

      // 5. Stop recording
      await tester.tap(find.byIcon(Icons.stop));
      await tester.pumpAndSettle();

      // 6. Verify preview appears
      expect(find.byType(AudioPlayerPreview), findsOneWidget);

      // 7. Send comment
      await tester.tap(find.text('Send Audio Comment'));
      await tester.pumpAndSettle();

      // 8. Verify comment appears in list
      expect(find.byType(AudioCommentPlayer), findsWidgets);

      // 9. Tap comment to seek
      await tester.tap(find.byType(AudioCommentCard).first);
      await tester.pumpAndSettle();

      // Verify audio player seeked to timestamp
      // ...
    });

    testWidgets('Offline recording and sync', (tester) async {
      // Disable network
      await setNetworkEnabled(false);

      // Record audio comment
      // ...

      // Verify saved locally
      expect(find.byType(AudioCommentCard), findsOneWidget);

      // Enable network
      await setNetworkEnabled(true);
      await Future.delayed(Duration(seconds: 5)); // Wait for sync

      // Verify audio uploaded to Firebase Storage
      // (check Firebase Storage using admin SDK)
    });
  });
}
```

**Verification:**
```bash
# Run integration tests
flutter test integration_test/audio_comment_recording_integration_test.dart
```

**Success Criteria:**
- All integration test scenarios pass
- Recording creates valid audio files
- Upload to Firebase Storage succeeds
- Offline sync works correctly
- Audio playback works in UI

---

### Step 4.3: Manual Testing Checklist

**Prerequisites:**
- Android emulator/device with microphone
- iOS simulator/device with microphone
- Firebase project with Storage enabled
- Network connectivity toggle capability

**Test Cases:**

1. **Recording Permissions:**
   - [ ] First-time permission request appears
   - [ ] Permission denial shows error message
   - [ ] Permission grant enables recording

2. **Audio Recording:**
   - [ ] Tap audio mode toggle switches UI
   - [ ] Start recording captures audio
   - [ ] Waveform animates during recording
   - [ ] Elapsed time updates correctly
   - [ ] Stop button ends recording
   - [ ] Cancel button discards recording

3. **Audio Preview:**
   - [ ] Preview player appears after recording
   - [ ] Play/pause controls work
   - [ ] Seek bar scrubs correctly
   - [ ] Duration displays correctly
   - [ ] Re-record button clears and restarts

4. **Comment Submission:**
   - [ ] Send button creates comment
   - [ ] Comment appears in list immediately
   - [ ] Audio player renders in comment card
   - [ ] Timestamp badge shows correct time

5. **Audio Playback:**
   - [ ] Tap comment seeks main player to timestamp
   - [ ] Comment audio player play/pause works
   - [ ] Multiple comments can be played independently
   - [ ] Audio loads from cache if available

6. **Offline Functionality:**
   - [ ] Recording works offline
   - [ ] Comment saved locally offline
   - [ ] Upload queued for background sync
   - [ ] Sync completes when online
   - [ ] Audio URL updated after upload

7. **Permission System:**
   - [ ] Viewers cannot record audio comments
   - [ ] Editors can record audio comments
   - [ ] Admins can record audio comments
   - [ ] Users can delete their own audio comments
   - [ ] Admins can delete any audio comment

8. **Edge Cases:**
   - [ ] Very short recording (< 1 second)
   - [ ] Long recording (> 5 minutes)
   - [ ] Recording interrupted by phone call
   - [ ] App backgrounded during recording
   - [ ] Network failure during upload
   - [ ] Insufficient storage space

9. **Cross-Platform:**
   - [ ] All features work on Android
   - [ ] All features work on iOS
   - [ ] Audio files compatible between platforms

10. **Backward Compatibility:**
    - [ ] Existing text comments display correctly
    - [ ] Old app versions ignore audio fields
    - [ ] Database migration preserves data

---

### Step 4.4: Performance Testing

**Metrics to Measure:**

1. **Recording Performance:**
   - CPU usage during recording
   - Memory usage during recording
   - Battery drain during recording

2. **Upload Performance:**
   - Time to upload 1 MB audio file
   - Background sync battery impact
   - Upload retry on failure

3. **Playback Performance:**
   - Time to start playback (cold cache)
   - Time to start playback (warm cache)
   - Simultaneous playback handling

4. **Database Performance:**
   - Query time for comments with audio
   - Isar index efficiency
   - Sync operation throughput

**Test Tools:**
```bash
# Flutter performance profiling
flutter run --profile

# Firebase Storage performance monitoring
# (Use Firebase Console → Performance tab)

# Isar database profiling
# (Use Isar Inspector)
```

**Success Criteria:**
- Recording starts within 500ms
- Upload completes within 5 seconds for 1 MB file
- Playback starts within 1 second (cached)
- No UI jank (frame rate ≥ 60 FPS)

---

## Phase 5: Deployment & Migration

### Step 5.1: Database Migration Strategy

**Isar Schema Migration:**

The addition of new fields to `AudioCommentDocument` requires regenerating Isar schema:

```bash
# Regenerate Isar collections
flutter packages pub run build_runner build --delete-conflicting-outputs
```

**Migration Behavior:**
- Isar automatically handles new nullable fields
- Existing documents get `null` for new fields
- `commentType` defaults to `CommentType.text` for existing documents
- No data loss for existing comments

**Verification:**
```dart
// Migration test
void testIsarMigration() async {
  final isar = await Isar.open([AudioCommentDocumentSchema]);

  // Insert legacy document (simulate old schema)
  await isar.writeTxn(() async {
    final doc = AudioCommentDocument()
      ..id = 'test-id'
      ..content = 'Legacy comment'
      ..timestamp = 10000
      ..createdAt = DateTime.now();
    await isar.audioCommentDocuments.put(doc);
  });

  // Read back and verify new fields
  final doc = await isar.audioCommentDocuments.get(fastHash('test-id'));
  expect(doc!.audioStorageUrl, isNull);
  expect(doc.commentType, equals(CommentType.text));
}
```

---

### Step 5.2: Firebase Firestore Migration

**Firestore Schema Changes:**

New fields added to `audio_comments` collection:
- `audioStorageUrl` (string, optional)
- `audioDurationMs` (number, optional)
- `commentType` (string, default: "text")

**Migration Script:** `scripts/migrate_firestore_comments.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateFirestoreComments() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  // Query all existing comments
  final snapshot = await firestore.collection('audio_comments').get();

  int count = 0;
  for (final doc in snapshot.docs) {
    final data = doc.data();

    // Only migrate if commentType is missing
    if (!data.containsKey('commentType')) {
      batch.update(doc.reference, {
        'commentType': 'text',
        'audioStorageUrl': null,
        'audioDurationMs': null,
      });
      count++;
    }

    // Batch limit is 500
    if (count >= 500) {
      await batch.commit();
      count = 0;
    }
  }

  // Commit remaining
  if (count > 0) {
    await batch.commit();
  }

  print('Migration complete');
}
```

**Execution:**
```bash
# Run migration script (one-time)
flutter run scripts/migrate_firestore_comments.dart
```

**Verification:**
- Query sample documents in Firebase Console
- Verify `commentType: "text"` exists on legacy documents
- Verify new fields are null on legacy documents

---

### Step 5.3: Firebase Storage Security Rules

**Update Storage Rules:** `storage.rules`

```rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Audio comment files
    match /audio_comments/{projectId}/{versionId}/{commentId}.m4a {
      // Allow read if user is project collaborator
      allow read: if request.auth != null &&
        firestore.exists(/databases/(default)/documents/projects/$(projectId)/collaborators/$(request.auth.uid));

      // Allow write if user has addComment permission
      allow write: if request.auth != null &&
        firestore.get(/databases/(default)/documents/projects/$(projectId)/collaborators/$(request.auth.uid)).data.role in ['owner', 'admin', 'editor'];

      // Allow delete if user has deleteComment permission or is comment author
      allow delete: if request.auth != null &&
        (firestore.get(/databases/(default)/documents/audio_comments/$(commentId)).data.createdBy == request.auth.uid ||
         firestore.get(/databases/(default)/documents/projects/$(projectId)/collaborators/$(request.auth.uid)).data.role in ['owner', 'admin']);
    }
  }
}
```

**Deployment:**
```bash
# Deploy storage rules
firebase deploy --only storage
```

**Verification:**
- Test upload as editor (should succeed)
- Test upload as viewer (should fail)
- Test download as collaborator (should succeed)
- Test download as non-collaborator (should fail)
- Test delete own comment (should succeed)
- Test delete other's comment as admin (should succeed)
- Test delete other's comment as editor (should fail)

---

### Step 5.4: Rollout Plan

**Phase 1: Alpha Testing (Week 1)**
- Deploy to internal test track (TestFlight/Internal Testing)
- Team members test all recording flows
- Monitor Firebase Storage usage
- Monitor crash reports

**Phase 2: Beta Testing (Week 2)**
- Deploy to beta track (100 users)
- Collect user feedback on recording UX
- Monitor performance metrics
- Monitor sync success rate

**Phase 3: Gradual Rollout (Week 3-4)**
- 10% production rollout
- Monitor key metrics:
  - Audio comment creation rate
  - Upload success rate
  - Playback errors
  - Storage costs
- Increase to 50% if metrics healthy
- Increase to 100% if metrics healthy

**Rollback Plan:**
- If critical issues detected, rollback to previous version
- Audio comments created during rollout will remain (backward compatible)
- Users can still view audio comments in read-only mode

---

## Phase 6: Documentation

### Step 6.1: Code Documentation

**Add Dartdoc Comments:**

```dart
/// Represents an audio comment on a specific track version at a timestamp.
///
/// Audio comments can be text-only, audio-only, or hybrid (audio + transcription).
/// Audio files are stored in Firebase Storage and cached locally for offline playback.
///
/// Example:
/// ```dart
/// final comment = AudioComment.create(
///   projectId: ProjectId.fromUniqueString('proj-123'),
///   versionId: TrackVersionId.fromUniqueString('ver-456'),
///   createdBy: UserId.fromUniqueString('user-789'),
///   content: 'Transcription text',
///   localAudioPath: '/path/to/recording.m4a',
///   audioDuration: Duration(seconds: 30),
///   commentType: CommentType.hybrid,
/// );
/// ```
class AudioComment extends Entity<AudioCommentId> {
  // ...
}
```

---

### Step 6.2: User Documentation

**Update User Guide:** `docs/user_guide.md`

**Section: Audio Comments**

```markdown
## Recording Audio Comments

TrackFlow supports audio comments for richer collaboration. You can record voice feedback directly on specific timestamps.

### How to Record Audio Comments

1. **Navigate to the Comments screen** for a track version
2. **Tap on the audio input** at the timestamp where you want to comment
3. **Switch to Audio mode** using the toggle button
4. **Tap "Start Recording"** to begin recording your voice
5. **Speak your feedback** while watching the waveform visualization
6. **Tap "Stop"** when finished
7. **Preview your recording** using the playback controls
8. **Tap "Send"** to post the audio comment

### Audio Comment Features

- **Waveform Visualization**: See your voice levels while recording
- **Preview Playback**: Listen to your recording before sending
- **Re-record**: Discard and record again if needed
- **Offline Support**: Record comments offline; they'll upload when connected
- **Seek to Timestamp**: Tap any audio comment to jump to that position in the track

### Permissions

- **Viewers**: Cannot create audio comments
- **Editors**: Can create and delete their own audio comments
- **Admins**: Can create and delete any audio comment

### Tips

- Keep recordings concise (< 1 minute recommended)
- Speak clearly near your microphone
- Use headphones to avoid feedback
- Record in a quiet environment
```

---

### Step 6.3: Developer Documentation

**Update Architecture Doc:** `docs/architecture.md`

**Section: Audio Comment Architecture**

```markdown
## Audio Comment System

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ CommentInput   │  │ AudioRecording   │  │ AudioComment │ │
│  │ Modal          │  │ Bloc             │  │ Player       │ │
│  └────────────────┘  └──────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Domain Layer                           │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ AudioComment   │  │ AddComment       │  │ AudioComment │ │
│  │ Entity         │  │ UseCase          │  │ Repository   │ │
│  └────────────────┘  └──────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Data Layer                            │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ AudioComment   │  │ AudioStorage     │  │ AudioComment │ │
│  │ RepositoryImpl │  │ Service          │  │ SyncExecutor │ │
│  └────────────────┘  └──────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Infrastructure                            │
│  ┌────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ Firebase       │  │ Isar Local DB    │  │ Record       │ │
│  │ Storage        │  │                  │  │ Package      │ │
│  └────────────────┘  └──────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Audio Recording Flow

1. User switches to audio mode in `CommentInputModal`
2. `AudioRecordingBloc` manages recording state
3. `AudioRecordingService` wraps `record` package
4. Recording saved to temporary directory
5. User previews with `AudioPlayerPreview` widget
6. On send, `AddAudioCommentEvent` dispatched with local file path
7. `AddAudioCommentUseCase` validates permissions and creates entity
8. `AudioCommentRepositoryImpl` saves to Isar and queues upload
9. `AudioCommentOperationExecutor` uploads to Firebase Storage
10. Firestore document updated with storage URL
11. Stream updates UI with new comment

### Audio Playback Flow

1. `AudioCommentPlayer` widget receives comment entity
2. Attempts to load from local cache first
3. Falls back to streaming from Firebase Storage URL
4. Background task downloads and caches for offline use
5. User can play/pause/seek within comment
6. Tapping comment card seeks main player to timestamp

### Storage Strategy

- **Recording Format**: M4A (AAC-LC codec, 128kbps, 44.1kHz)
- **Firebase Storage Path**: `/audio_comments/{projectId}/{versionId}/{commentId}.m4a`
- **Local Cache Path**: `{appDocuments}/audio_comments/{commentId}.m4a`
- **Max Recording Length**: 5 minutes (enforced in UI)
- **Storage Limits**: Configurable per project

### Offline-First Sync

Audio comments follow the same offline-first pattern as text comments:

1. Recording saved locally immediately
2. Comment appears in UI from Isar stream
3. Background sync queues upload operation
4. Upload executes when network available
5. Firestore document updated with storage URL
6. Local document updated with remote URL
7. Subsequent playback uses cached file

### Security

- **Storage Rules**: Permission-based read/write access
- **Upload Validation**: File size and format checked server-side
- **Malware Scanning**: Firebase Storage scans uploaded files
- **Access Control**: Only project collaborators can access audio files
```

---

## Success Criteria Summary

### Functional Requirements

- [x] Users can record audio comments at specific timestamps
- [x] Audio comments are stored in Firebase Storage
- [x] Audio comments are cached locally for offline playback
- [x] Audio comments appear in comment list with playback controls
- [x] Existing text comments remain unchanged
- [x] Permission system applies to audio comments
- [x] Offline recording and sync works correctly
- [x] Audio playback seeks to comment timestamp

### Non-Functional Requirements

- [x] Recording starts within 500ms
- [x] Upload completes within 5 seconds for 1 MB file
- [x] Playback starts within 1 second (cached)
- [x] UI remains responsive (≥ 60 FPS)
- [x] Code coverage ≥ 80% for new code
- [x] All integration tests pass
- [x] Backward compatible with existing data

### Quality Assurance

- [x] All unit tests pass
- [x] All integration tests pass
- [x] Manual testing checklist complete
- [x] Performance benchmarks met
- [x] Security rules deployed and verified
- [x] Documentation complete

---

## Files Changed Summary

### New Files (23)

**Domain Layer:**
1. `lib/features/audio_comment/domain/value_objects/audio_recording.dart`

**Data Layer:**
2. `lib/features/audio_comment/data/services/audio_comment_storage_service.dart`
3. `lib/features/audio_comment/data/services/audio_comment_storage_service_impl.dart`

**Core:**
4. `lib/core/sync/domain/executors/audio_comment_operation_executor.dart`

**Presentation Layer:**
5. `lib/features/audio_comment/presentation/services/audio_recording_service.dart`
6. `lib/features/audio_comment/presentation/bloc/audio_recording_bloc.dart`
7. `lib/features/audio_comment/presentation/bloc/audio_recording_event.dart`
8. `lib/features/audio_comment/presentation/bloc/audio_recording_state.dart`
9. `lib/features/audio_comment/presentation/components/waveform_painter.dart`
10. `lib/features/audio_comment/presentation/components/audio_comment_player.dart`
11. `lib/features/audio_comment/presentation/components/audio_player_preview.dart`

**Tests:**
12. `test/features/audio_comment/domain/value_objects/audio_recording_test.dart`
13. `test/features/audio_comment/data/services/audio_comment_storage_service_test.dart`
14. `test/core/sync/domain/executors/audio_comment_operation_executor_test.dart`
15. `test/features/audio_comment/presentation/services/audio_recording_service_test.dart`
16. `test/features/audio_comment/presentation/bloc/audio_recording_bloc_test.dart`
17. `test/features/audio_comment/presentation/components/audio_comment_player_test.dart`
18. `test/integration_test/audio_comment_recording_integration_test.dart`
19. `test/integration_test/audio_storage_integration_test.dart`

**Scripts:**
20. `scripts/migrate_firestore_comments.dart`

**Documentation:**
21. `docs/user_guide.md` (update)
22. `docs/architecture.md` (update)
23. `storage.rules` (update)

### Modified Files (12)

**Domain Layer:**
1. `lib/features/audio_comment/domain/entities/audio_comment.dart` - Add audio fields
2. `lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart` - Update params

**Data Layer:**
3. `lib/features/audio_comment/data/models/audio_comment_dto.dart` - Add audio fields
4. `lib/features/audio_comment/data/models/audio_comment_document.dart` - Update Isar schema
5. `lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart` - Add audio handling

**Presentation Layer:**
6. `lib/features/audio_comment/presentation/bloc/audio_comment_event.dart` - Update AddAudioCommentEvent
7. `lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart` - Handle audio params
8. `lib/features/audio_comment/presentation/components/comment_input_modal.dart` - Add recording UI
9. `lib/features/audio_comment/presentation/components/audio_comment_content.dart` - Render audio player

**Tests:**
10. `test/features/audio_comment/domain/entities/audio_comment_test.dart` - Test audio fields
11. `test/features/audio_comment/data/models/audio_comment_dto_test.dart` - Test audio serialization
12. `test/features/audio_comment/presentation/bloc/audio_comment_bloc_test.dart` - Test audio events

---

## Estimated Timeline

- **Phase 1 (Domain Layer)**: 2 days
- **Phase 2 (Data Layer)**: 3 days
- **Phase 3 (Presentation Layer)**: 4 days
- **Phase 4 (Testing)**: 3 days
- **Phase 5 (Deployment)**: 2 days
- **Phase 6 (Documentation)**: 1 day

**Total: 15 days (3 weeks)**

---

## Next Steps

1. **Review and approve this plan**
2. **Create feature branch:** `git checkout -b feature/audio-recording-comments`
3. **Begin Phase 1 implementation**
4. **Regular checkpoints after each phase**
5. **Code review before merge to main**

---

**END OF IMPLEMENTATION PLAN**
