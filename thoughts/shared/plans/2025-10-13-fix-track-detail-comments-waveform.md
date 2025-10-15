# Fix Track Detail Screen: Comments Display & Waveform Synchronization

## Overview

Fix three critical issues in the Track Detail screen related to audio comment display and waveform synchronization:
1. Comments not displaying when navigating from comment modal
2. Waveform continues animating during comment playback (visual mismatch)
3. State management confusion between TrackVersionsBloc and TrackDetailCubit

## Current State Analysis

### Issue 1: Initial Version Not Respected
**File**: [track_detail_screen.dart:40-51](lib/features/track_version/presentation/screens/track_detail_screen.dart#L40-L51)

```dart
void initState() {
  super.initState();
  // PROBLEM: Uses track.activeVersionId instead of widget.versionId
  context.read<TrackVersionsBloc>().add(
    WatchTrackVersionsRequested(
      widget.track.id,
      widget.track.activeVersionId,  // ❌ Should be widget.versionId
    ),
  );
  context.read<AudioPlayerBloc>().add(
    PlayVersionRequested(widget.track.activeVersionId!),  // ❌ Should be widget.versionId
  );
}
```

**Impact**: When user taps "Comment" from a modal and passes a specific `versionId`, the screen ignores it and loads the track's active version instead. Comments for the requested version never load.

**Root Cause**: `TrackDetailCubit` is never initialized with the incoming `widget.versionId`, so the screen has no memory of which version was requested.

### Issue 2: Comments Don't Update on Version Change
**File**: [track_detail_screen.dart:121-143](lib/features/track_version/presentation/screens/track_detail_screen.dart#L121-L143)

```dart
child: Builder(
  builder: (context) {
    final effectiveVersionId = selectedFromCubit ?? selectedFromBloc ?? widget.versionId;
    return CommentsSection(
      projectId: widget.projectId,
      trackId: widget.track.id,
      versionId: effectiveVersionId,  // ⚠️ Calculated inside Builder
    );
  },
),
```

**File**: [comments_section.dart:47-64](lib/features/audio_comment/presentation/components/comments_section.dart#L47-L64)

```dart
void didUpdateWidget(covariant CommentsSection oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.versionId != widget.versionId ||  // ⚠️ This never fires!
      oldWidget.projectId != widget.projectId ||
      oldWidget.trackId != widget.trackId) {
    // Re-subscribe for the new version
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AudioCommentBloc>().add(
        WatchAudioCommentsBundleEvent(
          widget.projectId,
          widget.trackId,
          widget.versionId,
        ),
      );
    });
  }
}
```

**Impact**: When user selects a different version from the versions list, `CommentsSection` never re-subscribes because `didUpdateWidget` doesn't fire. The `effectiveVersionId` is recalculated in the `Builder`, but the `CommentsSection` widget itself receives the same parameters (from Flutter's perspective), so it doesn't rebuild.

**Root Cause**: The `versionId` is calculated dynamically in a `Builder` widget, not passed down as an actual widget parameter change. Flutter's widget lifecycle doesn't detect this as a change.

### Issue 3: Waveform Animates During Comment Playback
**File**: [waveform_bloc.dart:40-46](lib/features/waveform/presentation/bloc/waveform_bloc.dart#L40-L46)

```dart
void _listenToAudioPlayer() {
  _sessionSubscription = _audioPlaybackService.sessionStream.listen((session) {
    add(_PlaybackPositionUpdated(session.position));  // ⚠️ No filtering by track ID
  });
}
```

**File**: [waveform_bloc.dart:209-217](lib/features/waveform/presentation/bloc/waveform_bloc.dart#L209-L217)

```dart
void _onPlaybackPositionUpdated(
  _PlaybackPositionUpdated event,
  Emitter<WaveformState> emit,
) {
  if (state.status == WaveformStatus.ready) {
    emit(state.copyWith(currentPosition: event.position));  // ⚠️ Always updates
  }
}
```

**Impact**: When an audio comment plays:
1. The audio player plays the comment audio (different track ID)
2. The waveform bloc receives position updates (0s → comment duration)
3. The waveform displays these positions against the track version's waveform data
4. Result: Waveform animates as if track version is playing, but audio is the comment

**Root Cause**: `WaveformBloc` subscribes to all playback updates without checking if the playing track matches the waveform's loaded version. No mechanism exists to pause waveform updates during comment playback.

### Key Discoveries

**Version Selection Flow** ([versions_section_component.dart:26-33](lib/features/track_version/presentation/components/versions_section_component.dart#L26-L33)):
```dart
onVersionSelected: (versionId) {
  // Play the new version directly
  context.read<AudioPlayerBloc>().add(PlayVersionRequested(versionId));
  // Update UI-only selection via cubit
  context.read<TrackDetailCubit>().setActiveVersion(versionId);
},
```
This works correctly! When user taps a version, it:
1. Plays the version via `AudioPlayerBloc`
2. Updates the cubit with `setActiveVersion`

**Waveform Version Tracking** ([enhanced_waveform_display.dart:38-44](lib/features/waveform/presentation/widgets/enhanced_waveform_display.dart#L38-L44)):
```dart
void didUpdateWidget(EnhancedWaveformDisplay oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.versionId != widget.versionId && widget.versionId != null) {
    context.read<WaveformBloc>().add(LoadWaveform(widget.versionId!));
  }
}
```
This also works! The waveform correctly loads when version changes.

**Audio Comment Track ID** ([audio_player_bloc.dart:315-320](lib/features/audio_player/presentation/bloc/audio_player_bloc.dart#L315-L320)):
```dart
final metadata = AudioTrackMetadata(
  id: AudioTrackId.fromUniqueString(event.commentId),  // Uses comment ID as track ID
  title: 'Audio Comment',
  artist: 'Comment',
  duration: Duration.zero,
);
```
Audio comments use their comment ID as the track ID, making them distinguishable from version playback.

## Desired End State

After implementation, the Track Detail screen will:

1. **Correctly display comments for the requested version** on initial load
2. **Automatically update comments** when user selects a different version from the list
3. **Pause waveform progress updates** when an audio comment plays, showing the waveform in its paused state
4. **Resume waveform progress updates** when the audio comment completes and version playback resumes
5. **Have clear, understandable state management** with `VersionSelectorCubit` managing UI-level version selection

### Verification

**Automated Verification**:
- [ ] All existing tests pass: `flutter test`
- [ ] Code analysis passes: `flutter analyze`
- [ ] No build errors: `flutter packages pub run build_runner build --delete-conflicting-outputs`

**Manual Verification**:
1. [ ] Navigate to track detail screen by tapping "Comment" on a specific version
2. [ ] Verify waveform displays for the correct version
3. [ ] Verify comments list shows comments for that version only
4. [ ] Tap play button and verify version starts playing
5. [ ] Tap on a different version in the versions list
6. [ ] Verify comments update to show new version's comments
7. [ ] Verify waveform updates to show new version's waveform
8. [ ] Verify audio switches to play the new version
9. [ ] Start recording an audio comment
10. [ ] Verify waveform stops animating (paused state)
11. [ ] Verify waveform shows no progress updates during comment recording
12. [ ] Complete the comment recording
13. [ ] Verify version playback resumes
14. [ ] Verify waveform resumes animating with correct position
15. [ ] Play an existing audio comment by tapping on it
16. [ ] Verify waveform pauses during comment playback
17. [ ] Verify waveform resumes when comment finishes

## What We're NOT Doing

- Not creating a separate waveform for audio comments (comments use the track version waveform in paused state)
- Not persisting the selected version to the database (only UI-level selection)
- Not adding undo/redo functionality for version selection
- Not implementing simultaneous playback of version + comment
- Not adding volume controls for comments vs versions
- Not implementing comment-specific seek functionality
- Not showing comment markers on the track version waveform (future enhancement)

## Implementation Approach

**Strategy**: Fix issues incrementally in dependency order:
1. First, establish correct initial state (Phase 1)
2. Then, enable reactive comment updates (Phase 2)
3. Finally, synchronize waveform with playback context (Phase 3)

**Reasoning**: Each phase builds on the previous, ensuring we don't introduce new bugs while fixing existing ones.

---

## Phase 1: Fix Initial State & Rename Cubit

### Overview
Establish correct initial state by ensuring the screen respects the incoming `widget.versionId` and initialize the cubit properly. Rename `TrackDetailCubit` to `VersionSelectorCubit` for clarity.

### Changes Required

#### 1. Rename TrackDetailCubit → VersionSelectorCubit

**File**: `lib/features/track_version/presentation/cubit/track_detail_cubit.dart`

**Changes**: Rename file to `version_selector_cubit.dart` and update class names

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';

/// State for managing version selection in the track detail screen
class VersionSelectorState extends Equatable {
  final TrackVersionId? selectedVersionId;

  const VersionSelectorState({this.selectedVersionId});

  VersionSelectorState copyWith({TrackVersionId? selectedVersionId}) {
    return VersionSelectorState(
      selectedVersionId: selectedVersionId ?? this.selectedVersionId,
    );
  }

  @override
  List<Object?> get props => [selectedVersionId];
}

/// Cubit to manage version selection in the track detail screen
/// This is UI-only state and does not persist to the database
@injectable
class VersionSelectorCubit extends Cubit<VersionSelectorState> {
  VersionSelectorCubit() : super(const VersionSelectorState());

  /// Set the selected version (UI-only, does not persist)
  void selectVersion(TrackVersionId versionId) {
    emit(state.copyWith(selectedVersionId: versionId));
  }

  /// Initialize with a specific version
  void initialize(TrackVersionId versionId) {
    emit(VersionSelectorState(selectedVersionId: versionId));
  }
}
```

**Note**: Delete the old `track_detail_cubit.dart` file after creating the new one.

#### 2. Update Dependency Injection

**File**: `lib/core/di/injection.config.dart`

This file is auto-generated. After renaming the cubit, run:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 3. Update TrackDetailScreen Initialization

**File**: `lib/features/track_version/presentation/screens/track_detail_screen.dart`

**Changes**:
- Import new cubit name
- Initialize cubit with `widget.versionId` in `initState`
- Use `widget.versionId` instead of `track.activeVersionId` for initial load
- Simplify version selection logic in Builders

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_bloc.dart';
import 'package:trackflow/features/audio_player/presentation/bloc/audio_player_event.dart';
import 'package:trackflow/features/track_version/presentation/components/version_header_component.dart';
import 'package:trackflow/features/ui/navigation/app_bar.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../ui/navigation/app_scaffold.dart';
import '../../../ui/modals/app_form_sheet.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_track/domain/entities/audio_track.dart';
import '../../../audio_comment/presentation/components/comments_section.dart';
import '../../../audio_comment/presentation/components/comment_input_modal.dart';
import '../../../waveform/presentation/widgets/audio_comment_player.dart';
import '../blocs/track_versions/track_versions_bloc.dart';
import '../blocs/track_versions/track_versions_event.dart';
import '../blocs/track_versions/track_versions_state.dart';
import '../cubit/version_selector_cubit.dart'; // ✅ Updated import
import '../components/versions_section_component.dart';
import '../widgets/upload_version_form.dart';

class TrackDetailScreen extends StatefulWidget {
  final ProjectId projectId;
  final AudioTrack track;
  final TrackVersionId versionId; // The version to display initially

  const TrackDetailScreen({
    super.key,
    required this.projectId,
    required this.track,
    required this.versionId,
  });

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> {
  @override
  void initState() {
    super.initState();

    // ✅ Initialize version selector cubit with incoming versionId
    context.read<VersionSelectorCubit>().initialize(widget.versionId);

    // ✅ Load versions for this track (pass incoming versionId as initial active)
    context.read<TrackVersionsBloc>().add(
      WatchTrackVersionsRequested(
        widget.track.id,
        widget.versionId, // ✅ Use widget.versionId, not track.activeVersionId
      ),
    );

    // ✅ Play the requested version
    context.read<AudioPlayerBloc>().add(
      PlayVersionRequested(widget.versionId), // ✅ Use widget.versionId
    );
  }

  void _showUploadVersionForm() {
    showAppFormSheet(
      context: context,
      title: 'Upload Version',
      child: BlocProvider.value(
        value: context.read<TrackVersionsBloc>(),
        child: UploadVersionForm(
          trackId: widget.track.id,
          projectId: widget.projectId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppAppBar(
        title: widget.track.name,
        actions: [
          AppIconButton(
            icon: Icons.add,
            onPressed: _showUploadVersionForm,
            tooltip: 'Upload new version',
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Versions Section
            VersionsSectionComponent(trackId: widget.track.id),
            VersionHeaderComponent(trackId: widget.track.id),

            // Audio Player - now directly uses cubit state
            BlocBuilder<VersionSelectorCubit, VersionSelectorState>(
              builder: (context, selectorState) {
                final selectedVersionId = selectorState.selectedVersionId ?? widget.versionId;
                return AudioCommentPlayer(
                  track: widget.track,
                  versionId: selectedVersionId,
                );
              },
            ),

            // Comments Section - now directly uses cubit state
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.screenMarginSmall,
                ),
                child: BlocBuilder<VersionSelectorCubit, VersionSelectorState>(
                  builder: (context, selectorState) {
                    final selectedVersionId = selectorState.selectedVersionId ?? widget.versionId;
                    return CommentsSection(
                      projectId: widget.projectId,
                      trackId: widget.track.id,
                      versionId: selectedVersionId, // ✅ Direct parameter, not calculated in builder
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      persistentFooterWidget: SafeArea(
        top: false,
        child: BlocBuilder<VersionSelectorCubit, VersionSelectorState>(
          builder: (context, selectorState) {
            final selectedVersionId = selectorState.selectedVersionId ?? widget.versionId;
            return CommentInputModal(
              projectId: widget.projectId,
              versionId: selectedVersionId,
            );
          },
        ),
      ),
    );
  }
}
```

#### 4. Update VersionsSectionComponent

**File**: `lib/features/track_version/presentation/components/versions_section_component.dart`

**Changes**: Update to use `VersionSelectorCubit` instead of `TrackDetailCubit`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/entities/unique_id.dart';
import '../../../audio_player/presentation/bloc/audio_player_bloc.dart';
import '../../../audio_player/presentation/bloc/audio_player_event.dart';
import '../cubit/version_selector_cubit.dart'; // ✅ Updated import
import '../widgets/versions_list.dart';

class VersionsSectionComponent extends StatelessWidget {
  final AudioTrackId trackId;

  const VersionsSectionComponent({super.key, required this.trackId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.space4),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 40,
              child: VersionsList(
                trackId: trackId,
                onVersionSelected: (versionId) {
                  // Play the new version directly
                  context.read<AudioPlayerBloc>().add(
                    PlayVersionRequested(versionId),
                  );
                  // Update UI-only selection via cubit
                  context.read<VersionSelectorCubit>().selectVersion(versionId); // ✅ Updated method name
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 5. Update All Other Imports

**Files to update**:
- Any other file that imports `track_detail_cubit.dart`
- Search codebase for `TrackDetailCubit` and replace with `VersionSelectorCubit`

**Search command**:
```bash
grep -r "TrackDetailCubit" lib/
grep -r "track_detail_cubit" lib/
```

### Success Criteria

#### Automated Verification:
- [x] Build runner generates code successfully: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- [x] All tests pass: `flutter test`
- [x] No analyzer warnings: `flutter analyze`
- [ ] App compiles: `flutter run --debug`

#### Manual Verification:
- [ ] Navigate to track detail screen by tapping "Comment" button on a specific version
- [ ] Verify the screen shows the waveform for the **requested version**, not the track's active version
- [ ] Verify comments displayed are for the **requested version**
- [ ] Verify audio playback starts for the **requested version**
- [ ] Select a different version from the versions list
- [ ] Verify the cubit's state updates (can check with Flutter DevTools)
- [ ] Verify audio switches to the newly selected version

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to Phase 2.

---

## Phase 2: Fix Comments Reactivity to Version Changes

### Overview
Ensure that when a user selects a different version from the versions list, the `CommentsSection` automatically re-subscribes and displays comments for the new version.

### Changes Required

#### 1. Make CommentsSection Reactive to Version Changes

**File**: `lib/features/audio_comment/presentation/components/comments_section.dart`

**Current Issue**: The `didUpdateWidget` method checks if `widget.versionId` changed, but it never changes because the `versionId` is calculated in a `Builder` widget, not passed as a direct parameter.

**Solution**: The Phase 1 changes already fix this! By using `BlocBuilder<VersionSelectorCubit>` in the parent and passing `selectedVersionId` directly to `CommentsSection`, the widget will now receive actual parameter changes.

**Verification Only**: No code changes needed in this file. The existing `didUpdateWidget` logic will now work correctly:

```dart
@override
void didUpdateWidget(covariant CommentsSection oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.versionId != widget.versionId ||  // ✅ Now fires correctly!
      oldWidget.projectId != widget.projectId ||
      oldWidget.trackId != widget.trackId) {
    // Re-subscribe for the new version
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AudioCommentBloc>().add(
        WatchAudioCommentsBundleEvent(
          widget.projectId,
          widget.trackId,
          widget.versionId,
        ),
      );
    });
  }
}
```

#### 2. Verify AudioCommentBloc Stream Subscription

**File**: `lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart`

**Current Implementation** (lines 28-31):
```dart
on<WatchAudioCommentsBundleEvent>(
  _onWatchBundle,
  transformer: _restartable(), // ✅ Uses RxDart's switchMap
);
```

**Verification**: The `_restartable()` transformer already uses RxDart's `switchMap` (lines 148-152), which automatically cancels the previous stream subscription when a new `WatchAudioCommentsBundleEvent` is dispatched. This is exactly what we need!

**No changes needed** - the existing implementation is correct.

### Success Criteria

#### Automated Verification:
- [ ] All tests pass: `flutter test`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] App compiles without errors: `flutter run --debug`

#### Manual Verification:
1. [ ] Navigate to track detail screen for a track with multiple versions and comments
2. [ ] Verify initial version's comments are displayed
3. [ ] Tap on a different version in the versions list
4. [ ] Verify `AudioCommentBloc` receives new `WatchAudioCommentsBundleEvent` (check logs or DevTools)
5. [ ] Verify loading state briefly appears (CircularProgressIndicator)
6. [ ] Verify new version's comments are displayed
7. [ ] Verify old version's comments are no longer visible
8. [ ] Rapidly switch between multiple versions
9. [ ] Verify only the final selected version's comments appear (no race conditions)
10. [ ] Switch to a version with zero comments
11. [ ] Verify empty state or "No comments" message displays

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful before proceeding to Phase 3.

---

## Phase 3: Pause Waveform During Comment Playback

### Overview
Detect when an audio comment is playing and pause waveform position updates. Resume updates when the track version plays again.

### Changes Required

#### 1. Extend WaveformState to Track Playback Context

**File**: `lib/features/waveform/presentation/bloc/waveform_bloc.dart`

**Changes**: Add state to track which track is currently playing and pause position updates if it doesn't match the waveform's version.

Update the `WaveformState` class (in `waveform_state.dart` part file):

```dart
class WaveformState extends Equatable {
  final WaveformStatus status;
  final AudioWaveform? waveform;
  final Duration currentPosition;
  final Duration? previewPosition;
  final Duration? dragStartPlaybackPosition;
  final bool? wasPlayingBeforeScrub;
  final bool isScrubbing;
  final String? errorMessage;
  final TrackVersionId? versionId;
  final AudioTrackId? currentlyPlayingTrackId; // ✅ NEW: Track what's playing

  const WaveformState({
    this.status = WaveformStatus.initial,
    this.waveform,
    this.currentPosition = Duration.zero,
    this.previewPosition,
    this.dragStartPlaybackPosition,
    this.wasPlayingBeforeScrub,
    this.isScrubbing = false,
    this.errorMessage,
    this.versionId,
    this.currentlyPlayingTrackId, // ✅ NEW
  });

  // ✅ NEW: Check if a different track (like a comment) is playing
  bool get isOtherTrackPlaying {
    if (versionId == null || currentlyPlayingTrackId == null) return false;
    // Compare version ID with playing track ID
    // If they don't match, it means a comment or other track is playing
    return versionId.value != currentlyPlayingTrackId.value;
  }

  @override
  List<Object?> get props => [
        status,
        waveform,
        currentPosition,
        previewPosition,
        dragStartPlaybackPosition,
        wasPlayingBeforeScrub,
        isScrubbing,
        errorMessage,
        versionId,
        currentlyPlayingTrackId, // ✅ NEW
      ];

  WaveformState copyWith({
    WaveformStatus? status,
    AudioWaveform? waveform,
    Duration? currentPosition,
    Duration? previewPosition,
    Duration? dragStartPlaybackPosition,
    bool? wasPlayingBeforeScrub,
    bool? isScrubbing,
    String? errorMessage,
    TrackVersionId? versionId,
    AudioTrackId? currentlyPlayingTrackId, // ✅ NEW
  }) {
    return WaveformState(
      status: status ?? this.status,
      waveform: waveform ?? this.waveform,
      currentPosition: currentPosition ?? this.currentPosition,
      previewPosition: previewPosition ?? this.previewPosition,
      dragStartPlaybackPosition: dragStartPlaybackPosition ?? this.dragStartPlaybackPosition,
      wasPlayingBeforeScrub: wasPlayingBeforeScrub ?? this.wasPlayingBeforeScrub,
      isScrubbing: isScrubbing ?? this.isScrubbing,
      errorMessage: errorMessage ?? this.errorMessage,
      versionId: versionId ?? this.versionId,
      currentlyPlayingTrackId: currentlyPlayingTrackId ?? this.currentlyPlayingTrackId, // ✅ NEW
    );
  }
}
```

#### 2. Update WaveformBloc to Track Playing Track ID

**File**: `lib/features/waveform/presentation/bloc/waveform_bloc.dart`

**Changes**: Update the listener to extract and store the currently playing track ID, and conditionally update position.

```dart
void _listenToAudioPlayer() {
  _sessionSubscription = _audioPlaybackService.sessionStream.listen((session) {
    // ✅ Update both position and currently playing track ID
    add(_PlaybackPositionUpdated(
      session.position,
      session.currentTrack?.id, // ✅ NEW: Pass the playing track ID
    ));
  });
}
```

Update the `_PlaybackPositionUpdated` event class (in `waveform_event.dart` part file):

```dart
class _PlaybackPositionUpdated extends WaveformEvent {
  final Duration position;
  final AudioTrackId? playingTrackId; // ✅ NEW

  const _PlaybackPositionUpdated(this.position, this.playingTrackId); // ✅ Updated constructor

  @override
  List<Object?> get props => [position, playingTrackId]; // ✅ NEW
}
```

Update the handler:

```dart
void _onPlaybackPositionUpdated(
  _PlaybackPositionUpdated event,
  Emitter<WaveformState> emit,
) {
  if (state.status == WaveformStatus.ready) {
    // ✅ Always update the currently playing track ID
    emit(state.copyWith(currentlyPlayingTrackId: event.playingTrackId));

    // ✅ Only update position if the playing track matches the waveform's version
    if (state.versionId != null && event.playingTrackId != null) {
      // Check if version ID matches playing track ID
      final isMatchingTrack = state.versionId!.value == event.playingTrackId!.value;
      if (isMatchingTrack) {
        // Same track playing - update position
        emit(state.copyWith(currentPosition: event.position));
      }
      // else: Different track (comment) playing - don't update position (paused state)
    }
  }
}
```

#### 3. Update Waveform Display to Show Paused State

**File**: `lib/features/waveform/presentation/widgets/generated_waveform_display.dart`

**Changes**: Use the `isOtherTrackPlaying` flag to determine whether to show progress updates.

The current implementation at lines 48-52 uses:
```dart
progress:
    state.isScrubbing && state.previewPosition != null
        ? state.previewPosition!
        : state.currentPosition,
```

This already uses `state.currentPosition`, which we're now conditionally updating. **No changes needed here** - the waveform will automatically pause when `currentPosition` stops updating.

**However**, we should visually indicate the paused state. Update the waveform overlay to show a "paused" indicator when a comment is playing:

**File**: `lib/features/waveform/presentation/widgets/waveform_overlay.dart`

Add a visual indicator for paused state (optional enhancement):

```dart
// Inside _OverlayPainter.paint method, after drawing the playhead:
if (isCommentPlaying) {
  // Draw a pause icon or dimmed overlay
  final pausePaint = Paint()
    ..color = Colors.white.withOpacity(0.3)
    ..style = PaintingStyle.fill;

  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height),
    pausePaint,
  );
}
```

**Note**: This is an optional enhancement. The main fix is preventing position updates.

#### 4. Update LoadWaveform Event to Store Version ID

**File**: `lib/features/waveform/presentation/bloc/waveform_bloc.dart`

Verify that `LoadWaveform` event handler stores the `versionId` in state:

```dart
Future<void> _onLoadWaveform(
  LoadWaveform event,
  Emitter<WaveformState> emit,
) async {
  if (state.versionId == event.versionId &&
      state.status == WaveformStatus.ready) {
    return; // Already loaded
  }

  emit(
    state.copyWith(
      status: WaveformStatus.loading,
      versionId: event.versionId, // ✅ Store version ID
      errorMessage: null,
    ),
  );

  final result = await _getWaveformByVersion.call(event.versionId);

  result.fold(
    (failure) => emit(
      state.copyWith(
        status: WaveformStatus.error,
        errorMessage: failure.message,
      ),
    ),
    (waveform) => add(_WaveformDataReceived(waveform)),
  );
}
```

This already exists in the current implementation (lines 52-108) - **no changes needed**.

### Success Criteria

#### Automated Verification:
- [ ] All tests pass: `flutter test`
- [ ] No analyzer warnings: `flutter analyze`
- [ ] App compiles without errors: `flutter run --debug`
- [ ] Code generation succeeds: `flutter packages pub run build_runner build --delete-conflicting-outputs`

#### Manual Verification:
1. [ ] Navigate to track detail screen
2. [ ] Start playing a track version by tapping play
3. [ ] Verify waveform animates and progress bar moves
4. [ ] Verify playhead moves in sync with audio
5. [ ] Record a new audio comment or play an existing comment
6. [ ] Verify waveform stops animating immediately
7. [ ] Verify waveform progress bar stays at the last position (paused state)
8. [ ] Verify comment audio plays correctly
9. [ ] Wait for comment to finish playing
10. [ ] Verify track version playback resumes (if it was playing before)
11. [ ] Verify waveform resumes animating from the correct position
12. [ ] Tap to play multiple comments in sequence
13. [ ] Verify waveform remains paused during each comment
14. [ ] Verify no visual glitches or jumps in waveform position
15. [ ] Switch to a different version while a comment is playing
16. [ ] Verify new version's waveform loads correctly
17. [ ] Verify comment continues playing (doesn't interrupt)

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation from the human that the manual testing was successful.

---

## Testing Strategy

### Unit Tests

**New Tests to Add**:

1. **VersionSelectorCubit Tests** (`test/features/track_version/presentation/cubit/version_selector_cubit_test.dart`):
   - Test initial state is empty
   - Test `initialize()` sets the version
   - Test `selectVersion()` updates the version
   - Test state equality

2. **WaveformBloc Position Update Tests** (add to existing `test/features/waveform/presentation/bloc/waveform_bloc_test.dart`):
   - Test position updates when playing track matches loaded version
   - Test position does NOT update when playing track differs from loaded version
   - Test `currentlyPlayingTrackId` is updated correctly
   - Test `isOtherTrackPlaying` getter returns correct values

### Integration Tests

**Existing Tests to Update**:
- Update any tests that import `TrackDetailCubit` to use `VersionSelectorCubit`
- Update tests that mock cubit behavior

**New Integration Test** (`test/integration_test/track_detail_comments_flow_test.dart`):
1. Navigate to track detail screen with specific version
2. Verify correct version's comments load
3. Switch versions
4. Verify comments update
5. Play a comment
6. Verify waveform pauses
7. Wait for comment to complete
8. Verify waveform resumes

### Manual Testing Steps

**Complete Flow Test**:
1. Create a project with a track that has 3+ versions
2. Add text comments to each version (different content for each)
3. Add audio comments to each version
4. From project detail screen, tap "Comment" on Version 2
5. Verify track detail screen opens showing Version 2's waveform and comments
6. Tap play button
7. Verify Version 2 starts playing
8. Tap on Version 1 in the versions list
9. Verify:
   - Comments section updates to show Version 1's comments
   - Waveform updates to show Version 1's waveform
   - Audio switches to Version 1
10. Tap on an audio comment
11. Verify:
    - Comment audio plays
    - Version playback stops
    - Waveform stops animating (paused at current position)
12. Wait for comment to finish
13. Verify:
    - Version playback resumes (if it was playing)
    - Waveform resumes animating
14. Test edge cases:
    - Switch versions while comment is playing
    - Play comment while paused
    - Rapidly switch between versions

## Performance Considerations

### Potential Issues

1. **Stream Subscription Memory Leaks**:
   - Ensure `WaveformBloc.close()` cancels subscriptions (already implemented in line 220-223)
   - Verify `CommentsSection` doesn't create duplicate subscriptions

2. **Excessive Rebuilds**:
   - `BlocBuilder<VersionSelectorCubit>` will rebuild when version changes - this is expected and necessary
   - Use `BlocBuilder` instead of `BlocConsumer` to avoid unnecessary side effects

3. **Comment Loading Performance**:
   - The `switchMap` transformer in `AudioCommentBloc` ensures only one stream subscription is active
   - Previous subscriptions are automatically cancelled - no manual cleanup needed

### Optimizations

- The `didUpdateWidget` check in `CommentsSection` prevents re-subscribing if version hasn't changed
- `WaveformBloc` already checks if version is loaded before re-loading (line 52-59)
- Position updates only trigger state changes when necessary

## Migration Notes

### Database Changes
**None** - This is purely a UI/state management fix. No database schema changes required.

### Breaking Changes
**Class Rename**: `TrackDetailCubit` → `VersionSelectorCubit`

**Impact**: Any code that references `TrackDetailCubit` will need to update imports.

**Migration Path**:
1. Run build_runner to regenerate dependency injection
2. Search codebase for `TrackDetailCubit` and replace with `VersionSelectorCubit`
3. Update any tests that mock the cubit

### Backward Compatibility
- Existing routes and navigation still work
- `TrackDetailScreenArgs` remains unchanged
- All existing features continue to work

## References

- Original issue description: User reported in conversation
- Related research:
  - [Audio Player Architecture](lib/features/audio_player/)
  - [Waveform System](lib/features/waveform/)
  - [Comments System](lib/features/audio_comment/)
- Similar implementations:
  - [VersionsList](lib/features/track_version/presentation/widgets/versions_list.dart) - Already handles version selection correctly
  - [EnhancedWaveformDisplay](lib/features/waveform/presentation/widgets/enhanced_waveform_display.dart) - Already handles version changes correctly via `didUpdateWidget`
