# Voice Memo Waveform Visualization and Card Redesign Implementation Plan

## Overview

Redesign the voice memo card UI to include interactive waveform visualization with playback synchronization. This implementation adds waveform generation during the recording pipeline, stores waveform data in the voice memo entity, and creates a modern card design with gesture-based scrubbing capabilities.

## Current State Analysis

### Existing Components
- **Voice Memo Card** ([voice_memo_card.dart](lib/features/voice_memos/presentation/components/voice_memo_card.dart)): Simple card with header and basic playback controls using linear progress indicator
- **Recording Pipeline**: Complete audio recording system with `AudioRecording` → `VoiceMemo` creation flow via `CreateVoiceMemoUseCase`
- **Waveform System**: Fully functional waveform system exists for audio tracks with:
  - `JustWaveformGeneratorService` for amplitude extraction
  - `WaveformBloc` for state management with scrubbing support
  - `GeneratedWaveformDisplay` widget with gesture handling
  - `AudioWaveform` entity with `WaveformData` value object
  - Isar storage with `AudioWaveformDocument`

### Current Voice Memo Entity
```dart
class VoiceMemo {
  final VoiceMemoId id;
  final String title;
  final String fileLocalPath;
  final String? fileRemoteUrl;
  final Duration duration;
  final DateTime recordedAt;
  final String? convertedToTrackId;
  final UserId? createdBy;
}
```

**Missing**: Waveform data reference

### Design Requirements (from reference screenshot)
- Title with three-dot menu at top
- Large waveform visualization in center (static bars + progress overlay)
- Interactive progress bar with circular playhead below waveform
- Duration display (MM:SS format) on the right
- Purple gradient background (`AppColors.primary`)
- Rounded card corners
- Clean, modern spacing

## Desired End State

### Functional Requirements
1. **Waveform Generation**: Extract waveform amplitudes after recording completes
2. **Data Storage**: Store waveform amplitudes directly in `VoiceMemoDocument` (embedded data)
3. **Interactive Playback**: Tap/drag on waveform to scrub playback position
4. **Visual Feedback**: Show playback progress with colored waveform bars and moving playhead
5. **Modern UI**: Clean card design with gradient background and proper spacing

### Verification Criteria
**After Implementation Complete**:
1. Record a new voice memo → waveform amplitudes are stored in Isar document
2. Open voice memos screen → cards display with waveform visualization
3. Tap play → waveform progress moves with audio playback
4. Drag on waveform → playback seeks to new position
5. Check Isar database → `VoiceMemoDocument` contains `waveformAmplitudes` field

## What We're NOT Doing

- ❌ "Analyse Recording" button (future feature with YAMNET audio classification)
- ❌ Remote waveform sync to Firebase (voice memos are local-only)
- ❌ Migration for existing voice memos (feature not yet shipped)
- ❌ Waveform regeneration on-demand (all memos will have waveforms from creation)
- ❌ Multiple waveform quality levels (single resolution: 80 samples)
- ❌ Waveform editing or manipulation
- ❌ Separate waveform feature for voice memos (reuse existing system)

## Implementation Approach

### Strategy
1. **Extend Domain Model**: Add optional `WaveformData` to `VoiceMemo` entity
2. **Update Storage**: Add waveform amplitude fields to `VoiceMemoDocument`
3. **Integrate Generation**: Call `JustWaveformGeneratorService` in `CreateVoiceMemoUseCase` after recording
4. **Adapt UI Components**: Create voice memo-specific waveform display widget
5. **Redesign Card**: Implement new layout with gradient background and integrated waveform

### Key Decisions
- **Embedded Waveform**: Store amplitudes directly in `VoiceMemoDocument` (not separate entity) for simplicity
- **Generation Timing**: After recording completes, before saving to database
- **Sample Count**: Use 80 samples (matches audio track default)
- **State Management**: Create lightweight `VoiceMemoWaveformBloc` or reuse `WaveformBloc` with voice memo ID as fake version ID
- **Fallback**: If waveform generation fails, save memo without waveform (graceful degradation)

---

## Phase 1: Extend Domain Model for Waveform Data

### Overview
Add waveform data to the voice memo domain model and update storage layer to persist amplitude arrays.

### Changes Required

#### 1. Voice Memo Entity
**File**: [lib/features/voice_memos/domain/entities/voice_memo.dart](lib/features/voice_memos/domain/entities/voice_memo.dart)

**Changes**: Add optional `WaveformData` field

```dart
import '../../../../features/waveform/domain/value_objects/waveform_data.dart';

class VoiceMemo extends Entity<VoiceMemoId> {
  final String title;
  final String fileLocalPath;
  final String? fileRemoteUrl;
  final Duration duration;
  final DateTime recordedAt;
  final String? convertedToTrackId;
  final UserId? createdBy;
  final WaveformData? waveformData; // NEW

  const VoiceMemo({
    required VoiceMemoId id,
    required this.title,
    required this.fileLocalPath,
    this.fileRemoteUrl,
    required this.duration,
    required this.recordedAt,
    this.convertedToTrackId,
    this.createdBy,
    this.waveformData, // NEW
  }) : super(id);

  factory VoiceMemo.create({
    required String fileLocalPath,
    String? fileRemoteUrl,
    required Duration duration,
    UserId? createdBy,
    WaveformData? waveformData, // NEW
  }) {
    final now = DateTime.now();
    return VoiceMemo(
      id: VoiceMemoId(),
      title: _generateTitle(now),
      fileLocalPath: fileLocalPath,
      fileRemoteUrl: fileRemoteUrl,
      duration: duration,
      recordedAt: now,
      convertedToTrackId: null,
      createdBy: createdBy,
      waveformData: waveformData, // NEW
    );
  }

  VoiceMemo copyWith({
    VoiceMemoId? id,
    String? title,
    String? fileLocalPath,
    String? fileRemoteUrl,
    Duration? duration,
    DateTime? recordedAt,
    String? convertedToTrackId,
    UserId? createdBy,
    WaveformData? waveformData, // NEW
  }) {
    return VoiceMemo(
      id: id ?? this.id,
      title: title ?? this.title,
      fileLocalPath: fileLocalPath ?? this.fileLocalPath,
      fileRemoteUrl: fileRemoteUrl ?? this.fileRemoteUrl,
      duration: duration ?? this.duration,
      recordedAt: recordedAt ?? this.recordedAt,
      convertedToTrackId: convertedToTrackId ?? this.convertedToTrackId,
      createdBy: createdBy ?? this.createdBy,
      waveformData: waveformData ?? this.waveformData, // NEW
    );
  }
}
```

#### 2. Voice Memo Document (Isar Model)
**File**: [lib/features/voice_memos/data/models/voice_memo_document.dart](lib/features/voice_memos/data/models/voice_memo_document.dart)

**Changes**: Add waveform amplitude storage fields

```dart
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import '../../../../features/waveform/domain/value_objects/waveform_data.dart';
import '../../domain/entities/voice_memo.dart';

part 'voice_memo_document.g.dart';

@collection
class VoiceMemoDocument {
  Id get isarId => fastHash(id);

  @Index(unique: true)
  late String id;

  late String title;
  late String fileLocalPath;
  String? fileRemoteUrl;
  late int durationMs;

  @Index()
  late DateTime recordedAt;

  String? convertedToTrackId;
  String? createdBy;

  // NEW: Waveform data fields
  String? waveformAmplitudesJson; // JSON-encoded List<double>
  int? waveformSampleRate;
  int? waveformTargetSampleCount;

  VoiceMemoDocument();

  factory VoiceMemoDocument.fromDomain(VoiceMemo memo) {
    return VoiceMemoDocument()
      ..id = memo.id.value
      ..title = memo.title
      ..fileLocalPath = memo.fileLocalPath
      ..fileRemoteUrl = memo.fileRemoteUrl
      ..durationMs = memo.duration.inMilliseconds
      ..recordedAt = memo.recordedAt
      ..convertedToTrackId = memo.convertedToTrackId
      ..createdBy = memo.createdBy?.value
      // NEW: Encode waveform data
      ..waveformAmplitudesJson = memo.waveformData != null
          ? jsonEncode(memo.waveformData!.amplitudes)
          : null
      ..waveformSampleRate = memo.waveformData?.sampleRate
      ..waveformTargetSampleCount = memo.waveformData?.targetSampleCount;
  }

  VoiceMemo toDomain() {
    // NEW: Decode waveform data
    WaveformData? waveformData;
    if (waveformAmplitudesJson != null &&
        waveformSampleRate != null &&
        waveformTargetSampleCount != null) {
      final amplitudes = (jsonDecode(waveformAmplitudesJson!) as List)
          .cast<double>();
      waveformData = WaveformData(
        amplitudes: amplitudes,
        sampleRate: waveformSampleRate!,
        duration: Duration(milliseconds: durationMs),
        targetSampleCount: waveformTargetSampleCount!,
      );
    }

    return VoiceMemo(
      id: VoiceMemoId.fromUniqueString(id),
      title: title,
      fileLocalPath: fileLocalPath,
      fileRemoteUrl: fileRemoteUrl,
      duration: Duration(milliseconds: durationMs),
      recordedAt: recordedAt,
      convertedToTrackId: convertedToTrackId,
      createdBy: createdBy != null ? UserId.fromUniqueString(createdBy!) : null,
      waveformData: waveformData, // NEW
    );
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] Domain model compiles: `flutter analyze`
- [ ] Isar code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] No breaking changes in existing voice memo tests: `flutter test test/features/voice_memos/`

#### Manual Verification:
- [ ] New fields added to `VoiceMemo` entity
- [ ] `VoiceMemoDocument` includes waveform storage fields
- [ ] `fromDomain()` and `toDomain()` handle null waveform data correctly

---

## Phase 2: Integrate Waveform Generation in Recording Pipeline

### Overview
Generate waveform amplitudes after recording completes and include them when creating the voice memo entity.

### Changes Required

#### 1. Create Voice Memo Use Case
**File**: [lib/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart](lib/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart)

**Changes**: Inject `WaveformGeneratorService`, generate waveform, and include in memo creation

```dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../audio_recording/domain/entities/audio_recording.dart';
import '../../../waveform/domain/services/waveform_generator_service.dart';
import '../entities/voice_memo.dart';
import '../repositories/voice_memo_repository.dart';

@lazySingleton
class CreateVoiceMemoUseCase {
  final VoiceMemoRepository _repository;
  final WaveformGeneratorService _waveformGenerator; // NEW

  CreateVoiceMemoUseCase(
    this._repository,
    this._waveformGenerator, // NEW
  );

  Future<Either<Failure, VoiceMemo>> call(AudioRecording recording) async {
    // NEW: Generate waveform data (non-blocking failure)
    final waveformDataEither = await _waveformGenerator.generateWaveformData(
      recording.localPath,
      targetSampleCount: 80, // Default for voice memos
    );

    // Log if waveform generation fails but continue
    final waveformData = waveformDataEither.fold(
      (failure) {
        AppLogger.warning(
          'Failed to generate waveform for voice memo: ${failure.message}',
          tag: 'CreateVoiceMemoUseCase',
        );
        return null; // Graceful degradation
      },
      (data) {
        AppLogger.info(
          'Successfully generated waveform with ${data.amplitudes.length} samples',
          tag: 'CreateVoiceMemoUseCase',
        );
        return data;
      },
    );

    // Create memo entity with waveform data
    final memo = VoiceMemo.create(
      fileLocalPath: recording.localPath,
      duration: recording.duration,
      waveformData: waveformData, // NEW
    );

    // Save to repository
    final result = await _repository.saveMemo(memo);

    return result.fold(
      (failure) => Left(failure),
      (_) => Right(memo),
    );
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] Use case compiles without errors: `flutter analyze`
- [ ] Dependency injection resolves correctly: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [ ] Unit test passes for memo creation with waveform: Create test in `test/features/voice_memos/domain/usecases/create_voice_memo_usecase_test.dart`

#### Manual Verification:
- [ ] Record a new voice memo
- [ ] Check Isar Inspector: `VoiceMemoDocument` has populated `waveformAmplitudesJson` field
- [ ] Verify waveform has ~80 samples
- [ ] Verify memo saves correctly even if waveform generation fails (test by providing invalid audio file)

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation that waveform generation works correctly before proceeding to the UI phase.

---

## Phase 3: Create Voice Memo Waveform Display Widget

### Overview
Create a voice memo-specific waveform display widget that reuses the existing waveform rendering system but adapts it for embedded waveform data (no BLoC needed for loading since data is already in entity).

### Changes Required

#### 1. Voice Memo Waveform Display Widget
**File**: `lib/features/voice_memos/presentation/widgets/voice_memo_waveform_display.dart` (NEW)

**Changes**: Create new widget

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/core/theme/app_colors.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_state.dart';
import 'package:trackflow/features/voice_memos/domain/entities/voice_memo.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_painter.dart'
    as static_wave;
import 'package:trackflow/features/waveform/presentation/widgets/waveform_progress_painter.dart';
import 'package:trackflow/features/waveform/presentation/widgets/waveform_overlay.dart';

class VoiceMemoWaveformDisplay extends StatelessWidget {
  final VoiceMemo memo;
  final double height;
  final Function(Duration)? onSeek;

  const VoiceMemoWaveformDisplay({
    super.key,
    required this.memo,
    this.height = 80,
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    // If no waveform data, show empty placeholder
    if (memo.waveformData == null) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'No waveform data',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final waveformData = memo.waveformData!;
    final amplitudes = waveformData.normalizedAmplitudes;

    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        // Determine if this memo is currently playing
        final isCurrentMemo = audioState is AudioPlayerSessionState &&
            audioState.session.currentTrack?.id.value == memo.id.value;

        final currentPosition = isCurrentMemo
            ? audioState.session.position
            : Duration.zero;

        return GestureDetector(
          onTapDown: (details) => _handleTap(context, details),
          onPanUpdate: (details) => _handlePan(context, details),
          child: SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Static waveform bars (gray)
                CustomPaint(
                  size: Size.fromHeight(height),
                  painter: static_wave.WaveformPainter(
                    amplitudes: amplitudes,
                    waveColor: Colors.grey[400]!,
                    progressColor: Colors.grey[400]!,
                  ),
                ),
                // Progress bars (colored up to current position)
                CustomPaint(
                  size: Size.fromHeight(height),
                  painter: WaveformProgressPainter(
                    amplitudes: amplitudes,
                    duration: memo.duration,
                    progress: currentPosition,
                    progressColor: AppColors.primary.withValues(alpha: 0.8),
                  ),
                ),
                // Playhead overlay
                WaveformOverlay(
                  duration: memo.duration,
                  playbackPosition: currentPosition,
                  previewPosition: null,
                  isScrubbing: false,
                  progressColor: AppColors.primary,
                  baselineColor: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleTap(BuildContext context, TapDownDetails details) {
    final position = _calculatePositionFromX(
      details.localPosition.dx,
      context.size!.width,
    );
    onSeek?.call(position);
  }

  void _handlePan(BuildContext context, DragUpdateDetails details) {
    final position = _calculatePositionFromX(
      details.localPosition.dx,
      context.size!.width,
    );
    onSeek?.call(position);
  }

  Duration _calculatePositionFromX(double x, double width) {
    final ratio = (x / width).clamp(0.0, 1.0);
    final ms = (memo.duration.inMilliseconds * ratio).round();
    return Duration(milliseconds: ms);
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] Widget compiles: `flutter analyze`
- [ ] No linter warnings
- [ ] Widget can be imported in test environment

#### Manual Verification:
- [ ] Widget renders waveform bars correctly
- [ ] Playback progress updates smoothly during audio playback
- [ ] Tapping on waveform seeks to correct position
- [ ] Playhead indicator moves correctly

---

## Phase 4: Redesign Voice Memo Card UI

### Overview
Completely redesign the voice memo card to match the reference design with gradient background, integrated waveform display, and modern layout.

### Changes Required

#### 1. Voice Memo Card Component
**File**: [lib/features/voice_memos/presentation/components/voice_memo_card.dart](lib/features/voice_memos/presentation/components/voice_memo_card.dart)

**Changes**: Complete redesign with gradient background and waveform integration

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../../../audio_player/presentation/bloc/audio_player_state.dart';
import '../../../ui/menus/app_popup_menu.dart';
import '../../domain/entities/voice_memo.dart';
import '../bloc/voice_memo_bloc.dart';
import '../bloc/voice_memo_event.dart';
import '../widgets/voice_memo_delete_background.dart';
import '../widgets/voice_memo_delete_confirmation_dialog.dart';
import '../widgets/voice_memo_rename_dialog.dart';
import '../widgets/voice_memo_waveform_display.dart';

class VoiceMemoCard extends StatelessWidget {
  final VoiceMemo memo;

  const VoiceMemoCard({super.key, required this.memo});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(memo.id.value),
      direction: DismissDirection.endToStart,
      background: const VoiceMemoDeleteBackground(),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmation(context);
      },
      onDismissed: (direction) {
        context.read<VoiceMemoBloc>().add(
          DeleteVoiceMemoRequested(memo.id),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.space16,
          vertical: Dimensions.space8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius16),
        ),
        child: Padding(
          padding: EdgeInsets.all(Dimensions.space16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title and Menu
              _buildHeader(context),

              SizedBox(height: Dimensions.space16),

              // Waveform Display
              VoiceMemoWaveformDisplay(
                memo: memo,
                height: 100,
                onSeek: (position) => _handleSeek(context, position),
              ),

              SizedBox(height: Dimensions.space12),

              // Playback Controls Row
              _buildPlaybackControls(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title
        Expanded(
          child: Text(
            memo.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Menu Button
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, audioState) {
        final isCurrentMemo = audioState is AudioPlayerSessionState &&
            audioState.session.currentTrack?.id.value == memo.id.value;

        final isPlaying = isCurrentMemo &&
            audioState is AudioPlayerPlaying;

        final position = isCurrentMemo
            ? audioState.session.position
            : Duration.zero;

        return Row(
          children: [
            // Play/Pause Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => _togglePlayback(context, isPlaying),
              ),
            ),

            SizedBox(width: Dimensions.space12),

            // Progress Bar
            Expanded(
              child: _buildProgressBar(position),
            ),

            SizedBox(width: Dimensions.space12),

            // Duration
            Text(
              _formatDuration(memo.duration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressBar(Duration position) {
    final progress = memo.duration.inMilliseconds > 0
        ? position.inMilliseconds / memo.duration.inMilliseconds
        : 0.0;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // Background bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Progress bar
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        // Playhead circle
        if (progress > 0)
          Positioned(
            left: (progress * 200).clamp(0.0, 200.0), // Adjust based on actual width
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  void _togglePlayback(BuildContext context, bool isPlaying) {
    if (isPlaying) {
      context.read<AudioPlayerBloc>().add(const PauseAudioRequested());
    } else {
      context.read<VoiceMemoBloc>().add(PlayVoiceMemoRequested(memo));
    }
  }

  void _handleSeek(BuildContext context, Duration position) {
    context.read<AudioPlayerBloc>().add(SeekAudioRequested(position));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => VoiceMemoRenameDialog(
        memo: memo,
        onRename: (newTitle) {
          context.read<VoiceMemoBloc>().add(
            UpdateVoiceMemoRequested(memo, newTitle),
          );
        },
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showAppMenu<String>(
      context: context,
      items: [
        AppMenuItem<String>(
          value: 'rename',
          label: 'Rename',
          icon: Icons.edit,
        ),
        AppMenuItem<String>(
          value: 'delete',
          label: 'Delete',
          icon: Icons.delete,
          iconColor: AppColors.error,
          textColor: AppColors.error,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'rename':
            _showRenameDialog(context);
            break;
          case 'delete':
            context.read<VoiceMemoBloc>().add(
              DeleteVoiceMemoRequested(memo.id),
            );
            break;
        }
      },
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => const VoiceMemoDeleteConfirmationDialog(),
    ) ?? false;
  }
}
```

### Success Criteria

#### Automated Verification:
- [ ] Card compiles without errors: `flutter analyze`
- [ ] No missing imports or undefined references
- [ ] App builds successfully: `flutter build apk --debug` (or iOS equivalent)

#### Manual Verification:
- [ ] Card displays with purple gradient background
- [ ] Title and menu button positioned correctly at top
- [ ] Waveform visualization renders in center
- [ ] Play/pause button works correctly
- [ ] Progress bar updates during playback
- [ ] Circular playhead moves with progress
- [ ] Duration displays correctly (MM:SS format)
- [ ] Tapping/dragging on waveform seeks playback
- [ ] Swipe-to-delete still works
- [ ] Menu (rename/delete) works correctly

---

## Testing Strategy

### Unit Tests

#### Domain Layer Tests
- **Test**: `VoiceMemo.create()` with waveform data
  - File: `test/features/voice_memos/domain/entities/voice_memo_test.dart`
  - Verify: Entity stores waveform data correctly

- **Test**: `CreateVoiceMemoUseCase` with successful waveform generation
  - File: `test/features/voice_memos/domain/usecases/create_voice_memo_usecase_test.dart`
  - Verify: Memo created with waveform data
  - Mock: `WaveformGeneratorService` returns success

- **Test**: `CreateVoiceMemoUseCase` with failed waveform generation
  - File: Same as above
  - Verify: Memo created without waveform (graceful degradation)
  - Mock: `WaveformGeneratorService` returns failure

#### Data Layer Tests
- **Test**: `VoiceMemoDocument.fromDomain()` with waveform
  - File: `test/features/voice_memos/data/models/voice_memo_document_test.dart`
  - Verify: Amplitudes encoded to JSON correctly

- **Test**: `VoiceMemoDocument.toDomain()` with waveform
  - File: Same as above
  - Verify: Amplitudes decoded from JSON correctly

- **Test**: `VoiceMemoDocument` with null waveform
  - File: Same as above
  - Verify: Handles null waveform data gracefully

### Widget Tests

#### Waveform Display Tests
- **Test**: `VoiceMemoWaveformDisplay` renders with waveform data
  - File: `test/features/voice_memos/presentation/widgets/voice_memo_waveform_display_test.dart`
  - Verify: Waveform bars rendered, no errors

- **Test**: `VoiceMemoWaveformDisplay` handles null waveform
  - File: Same as above
  - Verify: Shows placeholder message

- **Test**: `VoiceMemoWaveformDisplay` seek callback
  - File: Same as above
  - Verify: Tap triggers onSeek with correct position

#### Card Tests
- **Test**: `VoiceMemoCard` renders complete UI
  - File: `test/features/voice_memos/presentation/components/voice_memo_card_test.dart`
  - Verify: All components visible (title, waveform, controls, duration)

- **Test**: `VoiceMemoCard` playback toggle
  - File: Same as above
  - Verify: Play button triggers correct event

### Integration Tests

#### End-to-End Recording Flow
- **Test**: Record voice memo → verify waveform stored
  - File: `integration_test/voice_memo_recording_flow_test.dart`
  - Steps:
    1. Navigate to voice memos screen
    2. Tap record button
    3. Record for 5 seconds
    4. Tap save
    5. Query Isar database
    6. Verify `waveformAmplitudesJson` is not null
    7. Verify amplitudes array has ~80 elements

#### Playback with Waveform
- **Test**: Play voice memo → verify waveform updates
  - File: `integration_test/voice_memo_playback_flow_test.dart`
  - Steps:
    1. Create mock voice memo with waveform
    2. Navigate to voice memos screen
    3. Tap play on memo
    4. Verify waveform progress updates
    5. Verify playhead moves
    6. Tap on waveform to seek
    7. Verify audio position changes

### Manual Testing Steps

#### Recording and Storage
1. Open TrackFlow app
2. Navigate to Voice Memos screen
3. Tap floating action button to record
4. Speak for 10 seconds
5. Tap save
6. **Verify**: New memo appears in list with waveform visualization
7. **Verify**: Waveform has visible bars (not flat)

#### Playback Interaction
1. Tap play button on any memo
2. **Verify**: Play button changes to pause icon
3. **Verify**: Waveform bars turn purple from left to right
4. **Verify**: Circular playhead moves along progress bar
5. **Verify**: Duration timer updates
6. Tap on middle of waveform
7. **Verify**: Audio seeks to tapped position
8. **Verify**: Playhead jumps to new position

#### UI Visual Verification
1. Check card appearance
   - **Verify**: Purple gradient background
   - **Verify**: Rounded corners
   - **Verify**: White text on colored background is readable
   - **Verify**: Spacing between elements looks balanced
2. Compare with reference screenshot
   - **Verify**: Overall layout matches design intent

#### Error Handling
1. Create memo with audio file that fails waveform generation (corrupt file)
2. **Verify**: Memo still saves successfully
3. **Verify**: Card shows "No waveform data" message
4. **Verify**: Playback still works

#### Edge Cases
1. Record very short memo (< 1 second)
   - **Verify**: Waveform generates correctly
2. Record long memo (> 5 minutes)
   - **Verify**: Waveform still has ~80 samples (resampled)
3. Play/pause rapidly multiple times
   - **Verify**: No UI glitches or crashes
4. Scrub on waveform while audio loading
   - **Verify**: Seek happens after loading completes

---

## Performance Considerations

### Waveform Generation
- **Impact**: Blocking operation during memo creation
- **Optimization**: Generation happens after recording, adds ~1-2 seconds to save time
- **Mitigation**: Show loading indicator during save process
- **Future**: Could move to background task if becomes issue

### JSON Encoding/Decoding
- **Impact**: 80 doubles = ~640 bytes JSON + overhead
- **Performance**: Negligible for this size
- **Storage**: Adds ~1KB per memo to Isar database
- **Trade-off**: Acceptable for instant waveform availability

### UI Rendering
- **CustomPaint**: Efficient for static waveforms
- **Repainting**: Only progress overlay repaints during playback
- **60fps**: Should maintain smooth animation with 80 samples

### Memory Usage
- **Per Memo**: ~800 bytes for waveform data in memory
- **100 Memos**: ~80KB total waveform data
- **Acceptable**: Well within mobile memory constraints

---

## Migration Notes

**Not Applicable**: Voice memo feature has not been shipped yet, so no existing data to migrate.

All new voice memos will include waveform data from creation. No migration strategy needed.

---

## References

### Design Reference
- Original screenshot: `/Users/cristian/Documents/track_flow/voice_memo_design.jpeg`

### Related Implementation Files
- Waveform generation: [lib/features/waveform/data/services/just_waveform_generator_service.dart](lib/features/waveform/data/services/just_waveform_generator_service.dart)
- Waveform display: [lib/features/waveform/presentation/widgets/generated_waveform_display.dart](lib/features/waveform/presentation/widgets/generated_waveform_display.dart)
- Waveform bloc: [lib/features/waveform/presentation/bloc/waveform_bloc.dart](lib/features/waveform/presentation/bloc/waveform_bloc.dart)
- Recording pipeline: [lib/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart](lib/features/voice_memos/domain/usecases/create_voice_memo_usecase.dart)
- Audio player integration: [lib/features/audio_player/presentation/bloc/audio_player_bloc.dart](lib/features/audio_player/presentation/bloc/audio_player_bloc.dart)

### Architecture Documentation
- CLAUDE.md: Project overview and development guidelines
- Audio playback rules: `.cursor/rules/playback.mdc`

### Theme System
- App colors: [lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart) - Use `AppColors.primary` for gradient
- Dimensions: [lib/core/theme/app_dimensions.dart](lib/core/theme/app_dimensions.dart) - Use `Dimensions.space*` constants
