# Audio Comment System - Codebase Analysis

## Research Document: Audio Recording Comments Integration

**Date:** 2025-10-08
**Purpose:** Comprehensive analysis of existing audio comment infrastructure to support integration of audio recording functionality

---

## 1. USER AUTHENTICATION/PERMISSIONS FOR COMMENTING

### 1.1 Permission Definitions

**File:** [lib/features/projects/domain/value_objects/project_permission.dart](lib/features/projects/domain/value_objects/project_permission.dart)
**Lines:** 1-26

```dart
enum ProjectPermission {
  // Lines 14-16: Comment-specific permissions
  addComment,      // Line 14
  editComment,     // Line 15
  deleteComment,   // Line 16
}
```

### 1.2 Permission Validation Logic

**File:** [lib/features/projects/domain/entities/project_collaborator.dart](lib/features/projects/domain/entities/project_collaborator.dart)
**Lines:** 58-97

**Key Implementation:**
- **Lines 58-97:** `hasPermission()` method validates role-based permissions
- **Lines 73-75:** Admin role includes `addComment`, `editComment`, `deleteComment`
- **Lines 87-88:** Editor role includes `addComment`, `editComment` (NOT `deleteComment`)
- **Line 95:** Viewer role has NO comment permissions

**Role Permission Matrix:**
| Role   | addComment | editComment | deleteComment |
|--------|------------|-------------|---------------|
| Owner  | ✓          | ✓           | ✓             |
| Admin  | ✓          | ✓           | ✓             |
| Editor | ✓          | ✓           | ✗             |
| Viewer | ✗          | ✗           | ✗             |

### 1.3 Permission Enforcement

**File:** [lib/features/audio_comment/domain/services/project_comment_service.dart](lib/features/audio_comment/domain/services/project_comment_service.dart)

**Add Comment Validation (Lines 23-47):**
```dart
// Lines 30-37: Permission check before creating comment
final collaborator = project.collaborators.firstWhere(
  (c) => c.userId == requester,
  orElse: () => throw UserNotCollaboratorException(),
);

if (!collaborator.hasPermission(ProjectPermission.addComment)) {
  return Left(ProjectPermissionException());
}
```

**Delete Comment Validation (Lines 49-73):**
```dart
// Lines 56-68: Permission check + ownership validation
if (!collaborator.hasPermission(ProjectPermission.deleteComment)) {
  return Left(ProjectPermissionException());
}
// Only allow users to delete their own comments unless they have admin rights
if (comment.createdBy != requester &&
    !collaborator.hasPermission(ProjectPermission.deleteComment)) {
  return Left(ProjectPermissionException());
}
```

### 1.4 Session & User Context

**File:** [lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart](lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart)
**Lines:** 35-51

```dart
// Lines 36-39: Retrieve current user ID from session
final userId = await sessionStorage.getUserId();
if (userId == null) {
  return Left(ServerFailure('User not found'));
}

// Lines 44-50: Pass userId as requester to permission validation
return await projectCommentService.addComment(
  project: project,
  requester: UserId.fromUniqueString(userId),
  versionId: params.versionId,
  content: params.content,
  timestamp: params.timestamp,
);
```

**File:** [lib/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart](lib/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart)
**Lines:** 29-44

Similar pattern for delete operations with userId retrieval and validation.

---

## 2. CURRENT TEXT COMMENT DATA MODEL AND DATABASE SCHEMA

### 2.1 Domain Entity

**File:** [lib/features/audio_comment/domain/entities/audio_comment.dart](lib/features/audio_comment/domain/entities/audio_comment.dart)
**Lines:** 5-67

**Core Entity Structure (Lines 5-21):**
```dart
class AudioComment extends Entity<AudioCommentId> {
  final ProjectId projectId;           // Line 6
  final TrackVersionId versionId;      // Line 7
  final UserId createdBy;              // Line 8
  final String content;                // Line 9 - TEXT COMMENT FIELD
  final Duration timestamp;            // Line 10 - Audio position
  final DateTime createdAt;            // Line 11
}
```

**Factory Method (Lines 23-38):**
```dart
factory AudioComment.create({
  required ProjectId projectId,
  required TrackVersionId versionId,
  required UserId createdBy,
  required String content,           // Text content parameter
})
```

**Immutability Support (Lines 40-58):**
- `copyWith()` method for creating modified copies

### 2.2 Data Transfer Object (DTO)

**File:** [lib/features/audio_comment/data/models/audio_comment_dto.dart](lib/features/audio_comment/data/models/audio_comment_dto.dart)
**Lines:** 4-101

**DTO Structure (Lines 4-31):**
```dart
class AudioCommentDTO {
  final String id;                     // Line 5
  final String projectId;              // Line 6
  final String trackId;                // Line 7 (stores TrackVersionId)
  final String createdBy;              // Line 9
  final String content;                // Line 10 - TEXT FIELD
  final int timestamp;                 // Line 11 - Duration as milliseconds
  final String createdAt;              // Line 12 - ISO8601 string

  // Sync metadata (Lines 14-17)
  final bool isDeleted;                // Line 15
  final int version;                   // Line 16
  final DateTime? lastModified;        // Line 17
}
```

**Domain Conversion (Lines 35-49):**
```dart
factory AudioCommentDTO.fromDomain(AudioComment audioComment) {
  return AudioCommentDTO(
    content: audioComment.content,                    // Line 41
    timestamp: audioComment.timestamp.inMilliseconds, // Line 42
  );
}
```

**Firebase Serialization (Lines 63-79):**
```dart
Map<String, dynamic> toJson() {
  return {
    'content': content,              // Line 71
    'timestamp': timestamp,          // Line 72
    'isDeleted': isDeleted,         // Line 75
    'version': version,             // Line 76
    'lastModified': lastModified?.toIso8601String(), // Line 77
  };
}
```

**Firebase Deserialization (Lines 81-100):**
```dart
factory AudioCommentDTO.fromJson(Map<String, dynamic> json) {
  return AudioCommentDTO(
    content: json['content'] as String,    // Line 89
    timestamp: json['timestamp'] as int,   // Line 90
  );
}
```

### 2.3 Local Database Schema (Isar)

**File:** [lib/features/audio_comment/data/models/audio_comment_document.dart](lib/features/audio_comment/data/models/audio_comment_document.dart)
**Lines:** 8-107

**Isar Collection Schema (Lines 8-28):**
```dart
@collection
class AudioCommentDocument {
  Id get isarId => fastHash(id);        // Line 10 - Auto-generated ID

  @Index(unique: true)
  late String id;                       // Lines 12-13 - Unique index

  @Index()
  late String projectId;                // Lines 15-16 - Query index

  @Index()
  late String trackId;                  // Lines 18-19 - Query index (versionId)

  late String createdBy;                // Line 22
  late String content;                  // Line 23 - TEXT COMMENT FIELD
  late int timestamp;                   // Line 24 - Duration in milliseconds
  late DateTime createdAt;              // Line 25

  SyncMetadataDocument? syncMetadata;   // Line 28 - Offline-first sync
}
```

**Database Indexes:**
1. **Unique index on `id`** (Lines 12-13) - Primary key
2. **Index on `projectId`** (Lines 15-16) - For project-level queries
3. **Index on `trackId`** (Lines 18-19) - For version-level queries (most common)

**DTO Conversion (Lines 32-51):**
```dart
factory AudioCommentDocument.fromDTO(AudioCommentDTO dto, {
  SyncMetadataDocument? syncMeta,
}) {
  return AudioCommentDocument()
    ..content = dto.content              // Line 41
    ..timestamp = dto.timestamp          // Line 42
    ..syncMetadata = syncMeta ?? SyncMetadataDocument.fromRemote(...);
}
```

**Local Creation Factory (Lines 74-91):**
```dart
factory AudioCommentDocument.forLocalCreation({
  required String content,             // Line 79
  required int timestamp,              // Line 80
}) {
  return AudioCommentDocument()
    ..content = content                // Line 87
    ..timestamp = timestamp            // Line 88
    ..syncMetadata = SyncMetadataDocument.initial(); // Line 90 - Offline flag
}
```

### 2.4 Firebase Remote Schema

**File:** [lib/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart](lib/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart)
**Lines:** 25-38

**Firebase Document Creation:**
```dart
@override
Future<Either<Failure, Unit>> addComment(AudioCommentDTO comment) async {
  try {
    final data = comment.toJson();              // Line 28 - Convert to JSON
    data['lastModified'] = FieldValue.serverTimestamp(); // Line 29
    await _firestore
        .collection(AudioCommentDTO.collection) // Line 31 - 'audio_comments'
        .doc(comment.id)                        // Line 32 - Document ID
        .set(data);                             // Line 33
    return Right(unit);
  } catch (e) {
    return Left(ServerFailure('Failed to add comment'));
  }
}
```

**Collection Name:** `audio_comments` (Line 33)

**Document Structure in Firestore:**
```json
{
  "id": "string",
  "projectId": "string",
  "trackId": "string (versionId)",
  "createdBy": "string (userId)",
  "content": "string - TEXT COMMENT",
  "timestamp": "int (milliseconds)",
  "createdAt": "string (ISO8601)",
  "isDeleted": "bool",
  "version": "int",
  "lastModified": "Timestamp (server)"
}
```

---

## 3. LOGIC FOR ASSOCIATING COMMENTS WITH AUDIO TIMESTAMPS

### 3.1 Timestamp Capture (UI Layer)

**File:** [lib/features/audio_comment/presentation/components/comment_input_modal.dart](lib/features/audio_comment/presentation/components/comment_input_modal.dart)

**Focus Handler - Captures Playback Position (Lines 64-83):**
```dart
void _handleInputFocus() {
  if (_focusNode.hasFocus) {
    final audioPlayerBloc = context.read<AudioPlayerBloc>();
    final state = audioPlayerBloc.state;                // Line 67
    if (state is AudioPlayerSessionState) {
      setState(() {
        _capturedTimestamp = state.session.position;    // Line 70 - CAPTURE!
        _isInputFocused = true;
      });
      audioPlayerBloc.add(const PauseAudioRequested()); // Line 73 - Pause
      _animationController.forward();
    }
  } else {
    setState(() {
      _isInputFocused = false;
      _capturedTimestamp = null;                        // Line 79 - Clear
    });
    _animationController.reverse();
  }
}
```

**Send Handler - Uses Captured Timestamp (Lines 85-101):**
```dart
void _handleSend() {
  final text = _controller.text.trim();
  if (text.isNotEmpty) {
    context.read<AudioCommentBloc>().add(
      AddAudioCommentEvent(
        widget.projectId,
        widget.versionId,
        text,
        _capturedTimestamp ?? Duration.zero,          // Line 93 - Use captured
      ),
    );
    _controller.clear();
    _focusNode.unfocus();
  }
}
```

**Timestamp Display in Header (Lines 156-203):**
```dart
Widget _buildHeader() {
  final timestamp = _capturedTimestamp!;
  final minutes = timestamp.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = (timestamp.inSeconds % 60).toString().padLeft(2, '0');

  return Text('Comment at $minutes:$seconds');  // Line 189 - Display format
}
```

### 3.2 Comment Creation with Timestamp (Domain Layer)

**File:** [lib/features/audio_comment/domain/services/project_comment_service.dart](lib/features/audio_comment/domain/services/project_comment_service.dart)
**Lines:** 23-47

```dart
Future<Either<Failure, Unit>> addComment({
  required Duration timestamp,              // Line 28 - Timestamp parameter
}) async {
  // Permission validation...

  final comment = AudioComment.create(
    projectId: project.id,
    versionId: versionId,
    createdBy: requester,
    content: content,
  ).copyWith(timestamp: timestamp);         // Line 44 - Set timestamp

  return await commentRepository.addComment(comment);
}
```

**File:** [lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart](lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart)
**Lines:** 9-21

```dart
class AddAudioCommentParams {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;
  final Duration timestamp;               // Line 13 - Timestamp in params
}
```

**Lines 44-50 - Use Case Execution:**
```dart
return await projectCommentService.addComment(
  project: project,
  requester: UserId.fromUniqueString(userId),
  versionId: params.versionId,
  content: params.content,
  timestamp: params.timestamp,            // Line 49 - Pass through
);
```

### 3.3 Timestamp Storage & Retrieval

**Domain Entity Storage:**
- **File:** [lib/features/audio_comment/domain/entities/audio_comment.dart](lib/features/audio_comment/domain/entities/audio_comment.dart):10
- `final Duration timestamp` - Stored as Duration object

**DTO Conversion (to milliseconds):**
- **File:** [lib/features/audio_comment/data/models/audio_comment_dto.dart](lib/features/audio_comment/data/models/audio_comment_dto.dart):42
- `timestamp: audioComment.timestamp.inMilliseconds` - Convert to int

**Local Database Storage:**
- **File:** [lib/features/audio_comment/data/models/audio_comment_document.dart](lib/features/audio_comment/data/models/audio_comment_document.dart):24
- `late int timestamp` - Stored as milliseconds in Isar

**Storage Flow:**
```
UI Capture (Duration)
  ↓
Domain Entity (Duration)
  ↓
DTO Conversion (int milliseconds)
  ↓
Isar Document (int) / Firebase (int)
```

**Retrieval Flow:**
```
Isar/Firebase (int milliseconds)
  ↓
DTO (int milliseconds)
  ↓
Domain Entity (Duration)
  ↓
UI Display (formatted MM:SS)
```

### 3.4 Timestamp Display in UI

**File:** [lib/features/audio_comment/presentation/components/audio_comment_content.dart](lib/features/audio_comment/presentation/components/audio_comment_content.dart)
**Lines:** 21-26

```dart
String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return '$minutes:$seconds';
}
```

**Timestamp Badge Display (Lines 73-92):**
```dart
// Timestamp badge
Align(
  alignment: Alignment.centerRight,
  child: Container(
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
    ),
    child: Text(
      'at ${_formatDuration(comment.timestamp)}',   // Line 85
      style: AppTextStyle.labelSmall.copyWith(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
)
```

### 3.5 Seek to Timestamp on Comment Tap

**File:** [lib/features/audio_comment/presentation/components/audio_comment_card.dart](lib/features/audio_comment/presentation/components/audio_comment_card.dart)
**Lines:** 38-42

```dart
return GestureDetector(
  onLongPressStart: (details) => _showCommentMenu(context, details.globalPosition),
  child: BaseCard(
    onTap: () {
      context.read<AudioPlayerBloc>().add(
        SeekToPositionRequested(comment.timestamp),  // Line 40 - SEEK!
      );
    },
  ),
);
```

**File:** [lib/features/audio_player/presentation/bloc/audio_player_event.dart](lib/features/audio_player/presentation/bloc/audio_player_event.dart)
**Lines:** 88-98

```dart
/// Seek to specific position in current track
class SeekToPositionRequested extends AudioPlayerEvent {
  const SeekToPositionRequested(this.position);

  final Duration position;                           // Line 91
}
```

**User Flow:**
1. User taps on comment card
2. `SeekToPositionRequested` event dispatched with `comment.timestamp`
3. Audio player bloc seeks to position
4. Audio plays from comment's timestamp

---

## 4. UI/UX COMPONENTS FOR DISPLAYING COMMENTS AND ACCEPTING INPUT

### 4.1 Main Comments Screen

**File:** [lib/features/audio_comment/presentation/screens/app_audio_comments_screen.dart](lib/features/audio_comment/presentation/screens/app_audio_comments_screen.dart)
**Lines:** 25-91

**Screen Structure (Lines 52-90):**
```dart
return AppScaffold(
  backgroundColor: theme.colorScheme.surface,
  appBar: AppAppBar(title: widget.track.name),      // Line 57
  resizeToAvoidBottomInset: true,                   // Line 58 - Keyboard handling
  body: GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),  // Line 61 - Dismiss keyboard
    child: Column(
      children: [
        // Fixed minimal player header
        AudioCommentPlayer(track: widget.track),     // Line 65

        // Scrollable comments
        Expanded(
          child: Container(
            child: CommentsSection(                  // Lines 72-76
              projectId: widget.projectId,
              trackId: widget.track.id,
              versionId: widget.versionId,
            ),
          ),
        ),
      ],
    ),
  ),
  persistentFooterWidget: SafeArea(                  // Lines 82-88
    top: false,
    child: CommentInputModal(
      projectId: widget.projectId,
      versionId: widget.versionId,
    ),
  ),
);
```

**Screen Layout:**
```
┌─────────────────────────────┐
│ AppBar (Track Name)         │
├─────────────────────────────┤
│ AudioCommentPlayer (Fixed)  │
├─────────────────────────────┤
│                             │
│ CommentsSection (Scrollable)│
│   - Comment Cards           │
│   - User Avatars            │
│   - Timestamps              │
│                             │
├─────────────────────────────┤
│ CommentInputModal (Footer)  │
└─────────────────────────────┘
```

### 4.2 Comment Input Component

**File:** [lib/features/audio_comment/presentation/components/comment_input_modal.dart](lib/features/audio_comment/presentation/components/comment_input_modal.dart)
**Lines:** 21-265

**State Variables (Lines 37-41):**
```dart
final FocusNode _focusNode = FocusNode();
final TextEditingController _controller = TextEditingController();
Duration? _capturedTimestamp;
bool _isInputFocused = false;
late AnimationController _animationController;
```

**Component Structure (Lines 112-154):**
```dart
return Container(
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(Dimensions.radiusLarge),
      topRight: Radius.circular(Dimensions.radiusLarge),
    ),
    boxShadow: AppShadows.medium,
  ),
  child: Column(
    children: [
      // Header with X button and timestamp (if focused)
      if (_isInputFocused && _capturedTimestamp != null)   // Lines 137-145
        _buildHeader(),

      // Comment input field (always visible)
      _buildInputField(),                                   // Line 148
    ],
  ),
);
```

**Input Field (Lines 205-264):**
```dart
Widget _buildInputField() {
  return Row(
    children: [
      // Text input field
      Expanded(
        child: Container(
          child: TextField(
            controller: _controller,              // Line 222
            focusNode: _focusNode,                // Line 223
            decoration: InputDecoration(
              hintText: 'Add a comment',          // Line 228
            ),
            onSubmitted: (_) => _handleSend(),    // Line 238
            maxLines: null,                       // Line 239 - Multi-line
            textInputAction: TextInputAction.newline,
          ),
        ),
      ),

      // Send button
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.send_rounded),
          onPressed: _handleSend,                 // Line 259
        ),
      ),
    ],
  );
}
```

**Key Behaviors:**
1. **Focus Capture:** When input gains focus → captures current playback position + pauses audio
2. **Header Display:** Shows "Comment at MM:SS" when focused
3. **Send Action:** Creates comment with captured timestamp
4. **Resume Playback:** Resumes audio after sending or closing

### 4.3 Comments List Display

**File:** [lib/features/audio_comment/presentation/components/comments_section.dart](lib/features/audio_comment/presentation/components/comments_section.dart)
**Lines:** 13-155

**Lifecycle Management (Lines 30-66):**
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      context.read<AudioCommentBloc>().add(
        WatchAudioCommentsBundleEvent(          // Lines 37-41
          widget.projectId,
          widget.trackId,
          widget.versionId,
        ),
      );
    }
  });
}

@override
void didUpdateWidget(covariant CommentsSection oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.versionId != widget.versionId) {  // Line 51 - Track changes
    // Re-subscribe for the new track
    context.read<AudioCommentBloc>().add(
      WatchAudioCommentsBundleEvent(...),
    );
  }
}
```

**State Handling (Lines 70-111):**
```dart
return BlocBuilder<AudioCommentBloc, AudioCommentState>(
  builder: (context, state) {
    if (state is AudioCommentLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is AudioCommentError) {
      return Center(child: Text('Error: ${state.message}'));
    }
    if (state is AudioCommentsLoaded) {
      return _buildCommentsListView(              // Lines 86-90
        context,
        state.comments,
        state.collaborators,
      );
    }
    return Center(child: Text('Unable to load comments.'));
  },
);
```

**List View Builder (Lines 114-154):**
```dart
Widget _buildCommentsListView(
  BuildContext context,
  List<AudioComment> comments,
  List<UserProfile> collaborators,
) {
  if (comments.isEmpty) {
    return Center(child: Text('No comments yet.'));
  }

  return ListView.builder(
    reverse: false,                               // Line 131
    itemCount: comments.length,                   // Line 132
    itemBuilder: (context, index) {
      final comment = comments[index];
      final collaborator = collaborators.firstWhere(  // Lines 135-144
        (u) => u.id == comment.createdBy,
        orElse: () => UserProfile(...),           // Fallback profile
      );
      return AudioCommentComponent(               // Lines 146-151
        comment: comment,
        collaborator: collaborator,
        projectId: widget.projectId,
        versionId: widget.versionId,
      );
    },
  );
}
```

### 4.4 Individual Comment Card

**File:** [lib/features/audio_comment/presentation/components/audio_comment_card.dart](lib/features/audio_comment/presentation/components/audio_comment_card.dart)
**Lines:** 18-100

**Card Component (Lines 32-69):**
```dart
return GestureDetector(
  onLongPressStart: (details) => _showCommentMenu(context, details.globalPosition),
  child: BaseCard(
    onTap: () {
      context.read<AudioPlayerBloc>().add(
        SeekToPositionRequested(comment.timestamp),  // Line 40 - Seek on tap
      );
    },
    margin: EdgeInsets.symmetric(
      horizontal: Dimensions.space12,
      vertical: Dimensions.space8,
    ),
    backgroundColor: AppColors.grey700,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User avatar
        AudioCommentAvatar(                          // Lines 52-55
          collaborator: collaborator,
          createdBy: comment.createdBy,
        ),

        SizedBox(width: Dimensions.space16),

        // Comment content
        Expanded(
          child: AudioCommentContent(                // Lines 61-64
            comment: comment,
            collaborator: collaborator,
          ),
        ),
      ],
    ),
  ),
);
```

**Context Menu (Lines 72-93):**
```dart
void _showCommentMenu(BuildContext context, Offset tapPosition) {
  showAppMenu<String>(
    context: context,
    positionOffset: tapPosition,
    items: [
      AppMenuItem<String>(
        value: 'delete',
        label: 'Delete Comment',
        icon: Icons.delete,
        iconColor: AppColors.error,
        textColor: AppColors.error,
      ),
    ],
    onSelected: (value) {
      switch (value) {
        case 'delete':
          _deleteComment(context);               // Line 88
          break;
      }
    },
  );
}
```

**Delete Action (Lines 95-99):**
```dart
void _deleteComment(BuildContext context) {
  context.read<AudioCommentBloc>().add(
    DeleteAudioCommentEvent(comment.id, projectId, versionId),
  );
}
```

### 4.5 Comment Content Display

**File:** [lib/features/audio_comment/presentation/components/audio_comment_content.dart](lib/features/audio_comment/presentation/components/audio_comment_content.dart)
**Lines:** 11-96

**Content Layout (Lines 33-94):**
```dart
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Header with name and date
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            collaborator.name.isNotEmpty
                ? collaborator.name
                : comment.createdBy.value,       // Lines 42-44
            style: AppTextStyle.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          createdAtStr,                          // Line 54 - Date format
          style: AppTextStyle.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ),

    SizedBox(height: Dimensions.space8),

    // Comment text
    Text(comment.content, style: AppTextStyle.bodyMedium),  // Line 68

    SizedBox(height: Dimensions.space8),

    // Timestamp badge
    Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.space8,
          vertical: Dimensions.space4,
        ),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Text(
          'at ${_formatDuration(comment.timestamp)}',  // Line 85
          style: AppTextStyle.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  ],
);
```

**Content Components:**
1. **User Header:** Name + creation date
2. **Comment Text:** Main content (currently string)
3. **Timestamp Badge:** "at MM:SS" indicator

### 4.6 BLoC State Management

**File:** [lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart](lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart)
**Lines:** 14-113

**Event Handlers:**

**Add Comment (Lines 33-49):**
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
    ),
  );
  result.fold(
    (failure) => emit(AudioCommentError(failure.message)),
    (_) => null,  // Success handled by stream update
  );
}
```

**Delete Comment (Lines 51-65):**
```dart
Future<void> _onDeleteAudioComment(
  DeleteAudioCommentEvent event,
  Emitter<AudioCommentState> emit,
) async {
  final result = await deleteAudioCommentUseCase(
    DeleteAudioCommentParams(
      projectId: event.projectId,
      commentId: event.commentId,
    ),
  );
  result.fold(
    (failure) => emit(AudioCommentError(failure.message)),
    (_) => null,  // Success handled by stream update
  );
}
```

**Watch Comments Bundle (Lines 67-100):**
```dart
Future<void> _onWatchBundle(
  WatchAudioCommentsBundleEvent event,
  Emitter<AudioCommentState> emit,
) async {
  emit(const AudioCommentLoading());
  final stream = watchAudioCommentsBundleUseCase.call(
    projectId: event.projectId,
    trackId: event.trackId,
    versionId: event.versionId,
  );

  await emit.onEach<Either<Failure, AudioCommentsBundle>>(
    stream,
    onData: (either) {
      either.fold(
        (failure) => emit(AudioCommentError(failure.message)),
        (bundle) {
          final sorted = [...bundle.comments]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
          emit(
            AudioCommentsLoaded(
              comments: sorted,
              collaborators: bundle.collaborators,
              isSyncing: false,
              syncProgress: null,
            ),
          );
        }
      );
    },
  );
}
```

**File:** [lib/features/audio_comment/presentation/bloc/audio_comment_event.dart](lib/features/audio_comment/presentation/bloc/audio_comment_event.dart)
**Lines:** 9-48

**Event Definitions:**
```dart
class AddAudioCommentEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final TrackVersionId versionId;
  final String content;                    // Line 12 - TEXT CONTENT
  final Duration timestamp;                // Line 13 - TIMESTAMP
}

class DeleteAudioCommentEvent extends AudioCommentEvent {
  final AudioCommentId commentId;
  final ProjectId projectId;
  final TrackVersionId versionId;
}

class WatchAudioCommentsBundleEvent extends AudioCommentEvent {
  final ProjectId projectId;
  final AudioTrackId trackId;
  final TrackVersionId versionId;
}
```

**File:** [lib/features/audio_comment/presentation/bloc/audio_comment_state.dart](lib/features/audio_comment/presentation/bloc/audio_comment_state.dart)
**Lines:** 37-66

**State Definition:**
```dart
class AudioCommentsLoaded extends AudioCommentState {
  final List<AudioComment> comments;        // Line 38
  final List<UserProfile> collaborators;    // Line 39
  final bool isSyncing;                     // Line 40
  final double? syncProgress;               // Line 41
}
```

### 4.7 Repository Layer

**File:** [lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart](lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart)

**Add Comment - Offline-First Pattern (Lines 126-164):**
```dart
@override
Future<Either<Failure, Unit>> addComment(AudioComment comment) async {
  try {
    final dto = AudioCommentDTO.fromDomain(comment);

    // 1. ALWAYS save locally first (ignore minor cache errors)
    await _localDataSource.cacheComment(dto);         // Line 131

    // 2. Try to queue for background sync
    final queueResult = await _pendingOperationsManager.addCreateOperation(
      entityType: 'audio_comment',                    // Line 135
      entityId: comment.id.value,
      data: {
        'trackId': comment.versionId.value,
        'projectId': comment.projectId.value,
        'createdBy': comment.createdBy.value,
        'content': comment.content,                   // Line 141 - TEXT
        'timestamp': comment.timestamp.inMilliseconds, // Line 142 - TIMESTAMP
        'createdAt': comment.createdAt.toIso8601String(),
      },
      priority: SyncPriority.high,                    // Line 145
    );

    // 3. Trigger background sync (fire-and-forget)
    unawaited(_backgroundSyncCoordinator.pushUpstream()); // Line 158

    return const Right(unit);
  } catch (e) {
    return Left(DatabaseFailure('Critical storage error: ${e.toString()}'));
  }
}
```

**Watch Comments - Reactive Stream (Lines 101-123):**
```dart
@override
Stream<Either<Failure, List<AudioComment>>> watchCommentsByVersion(
  TrackVersionId versionId,
) {
  try {
    // NO sync in watch methods - just return local data stream
    return _localDataSource.watchCommentsByVersion(versionId.value).map((
      localResult,
    ) {
      return localResult.fold(
        (failure) => Left(failure),
        (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
      );
    });
  } catch (e) {
    return Stream.value(Left(DatabaseFailure('Failed to watch...')));
  }
}
```

**File:** [lib/features/audio_comment/domain/repositories/audio_comment_repository.dart](lib/features/audio_comment/domain/repositories/audio_comment_repository.dart)
**Lines:** 6-34

**Repository Contract:**
```dart
abstract class AudioCommentRepository {
  Future<Either<Failure, AudioComment>> getCommentById(
    AudioCommentId commentId,
  );

  Future<Either<Failure, Unit>> addComment(AudioComment comment);  // Line 11

  Stream<Either<Failure, List<AudioComment>>> watchCommentsByVersion(
    TrackVersionId versionId,                                      // Line 19
  );

  Future<Either<Failure, Unit>> deleteComment(AudioCommentId commentId);

  Future<Either<Failure, Unit>> deleteCommentsByVersion(
    TrackVersionId versionId,
  );
}
```

### 4.8 Use Cases Layer

**File:** [lib/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart](lib/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart)
**Lines:** 14-103

**Bundle Entity (Lines 14-24):**
```dart
class AudioCommentsBundle {
  final AudioTrack track;                // Line 15 - Track metadata
  final List<AudioComment> comments;     // Line 16 - Comments list
  final List<UserProfile> collaborators; // Line 17 - User profiles
}
```

**Reactive Stream Composition (Lines 38-102):**
```dart
Stream<Either<Failure, AudioCommentsBundle>> call({
  required ProjectId projectId,
  required AudioTrackId trackId,
  required TrackVersionId versionId,
}) {
  // Stream of the specific track by ID (header/player)
  final track$ = _audioTrackRepository
      .watchTrackById(trackId)
      .shareReplay(maxSize: 1);

  // Stream of comments for the version
  final comments$ = _audioCommentRepository
      .watchCommentsByVersion(versionId)
      .shareReplay(maxSize: 1);

  // Stream of collaborators derived from the comments' authors
  final collaborators$ = comments$
      .switchMap<Either<Failure, List<UserProfile>>>((eitherComments) {
        return eitherComments.fold(
          (failure) => Stream.value(left(failure)),
          (comments) {
            if (comments.isEmpty) {
              return Stream.value(right(<UserProfile>[]));
            }
            final ids = comments.map((c) => c.createdBy).toSet().toList();
            return _userProfileCacheRepository
                .watchUserProfilesByIds(ids);
          }
        );
      })
      .shareReplay(maxSize: 1);

  // Combine all three streams into a bundle
  return Rx.combineLatest3<
    Either<Failure, AudioTrack>,
    Either<Failure, List<AudioComment>>,
    Either<Failure, List<UserProfile>>,
    Either<Failure, AudioCommentsBundle>
  >(track$, comments$, collaborators$, (trackEither, commentsEither, collaboratorsEither) {
    return trackEither.fold(
      (failure) => left(failure),
      (track) => commentsEither.fold(
        (failure) => left(failure),
        (comments) => collaboratorsEither.fold(
          (failure) => left(failure),
          (collaborators) => right(
            AudioCommentsBundle(
              track: track,
              comments: comments,
              collaborators: collaborators,
            ),
          ),
        ),
      ),
    );
  });
}
```

---

## 5. DATA FLOW SUMMARY

### 5.1 Comment Creation Flow

```
User Input
  ↓
[CommentInputModal] Focus → Capture playback position (Duration)
  ↓
[CommentInputModal] Send → AddAudioCommentEvent(content: String, timestamp: Duration)
  ↓
[AudioCommentBloc] → AddAudioCommentUseCase
  ↓
[AddAudioCommentUseCase] → Get userId from SessionStorage
  ↓
[AddAudioCommentUseCase] → Validate project permissions
  ↓
[ProjectCommentService] → Check ProjectPermission.addComment
  ↓
[ProjectCommentService] → Create AudioComment entity
  ↓
[AudioCommentRepository] → Convert to AudioCommentDTO
  ↓
[AudioCommentRepository] → Save to Isar local DB (immediate)
  ↓
[AudioCommentRepository] → Queue for background Firebase sync
  ↓
[BackgroundSyncCoordinator] → Sync to Firebase when online
  ↓
[WatchCommentsBundleUseCase] → Reactive stream emits update
  ↓
[AudioCommentBloc] → Emit AudioCommentsLoaded state
  ↓
[CommentsSection] → Rebuild UI with new comment
```

### 5.2 Comment Display Flow

```
Screen Init
  ↓
[CommentsSection] → WatchAudioCommentsBundleEvent
  ↓
[AudioCommentBloc] → WatchAudioCommentsBundleUseCase
  ↓
[WatchAudioCommentsBundleUseCase] → Combine 3 streams:
  - Track stream (watchTrackById)
  - Comments stream (watchCommentsByVersion)
  - Collaborators stream (watchUserProfilesByIds)
  ↓
[AudioCommentRepository] → Stream from Isar local DB
  ↓
[IsarLocalDataSource] → Watch query with fireImmediately: true
  ↓
Stream emits: AudioCommentsBundle(track, comments, collaborators)
  ↓
[AudioCommentBloc] → Sort comments by createdAt
  ↓
[AudioCommentBloc] → Emit AudioCommentsLoaded state
  ↓
[CommentsSection] → Build ListView of AudioCommentComponent
  ↓
[AudioCommentComponent] → Display with:
  - AudioCommentAvatar (user)
  - AudioCommentContent (text + timestamp badge)
```

### 5.3 Timestamp Interaction Flow

```
Comment Tap
  ↓
[AudioCommentCard] onTap → SeekToPositionRequested(comment.timestamp)
  ↓
[AudioPlayerBloc] → Seek to Duration
  ↓
Audio plays from comment position
```

---

## 6. KEY INTEGRATION POINTS FOR AUDIO RECORDING

### 6.1 Data Model Changes Required

**Current:**
```dart
final String content;  // Text comment
```

**Proposed Addition:**
```dart
final String content;          // Text comment OR transcription
final String? audioUrl;        // Firebase Storage URL for audio file
final Duration? audioDuration; // Length of audio recording
final bool isAudioComment;     // Flag to distinguish type
```

### 6.2 Storage Strategy

**Audio File Storage:**
- Firebase Storage path: `/audio_comments/{projectId}/{versionId}/{commentId}.m4a`
- Local cache: Isar blob storage or file system
- Metadata stored in existing Firestore document

### 6.3 UI Component Extensions

**CommentInputModal:**
- Add recording button alongside text input
- Voice waveform visualization during recording
- Playback preview before sending
- Retain timestamp capture mechanism

**AudioCommentContent:**
- Detect `isAudioComment` flag
- Render audio player widget instead of/in addition to text
- Display audio duration badge
- Playback controls (play/pause/scrub)

### 6.4 Permission Compatibility

**Existing permissions work as-is:**
- `ProjectPermission.addComment` → Record audio comment
- `ProjectPermission.deleteComment` → Delete audio comment
- Same role-based validation applies

### 6.5 Offline-First Sync

**Recording Flow:**
1. Record audio locally
2. Save to device file system
3. Create AudioComment entity with local file path
4. Queue upload operation for background sync
5. Upload to Firebase Storage when online
6. Update Firestore document with Storage URL

---

## 7. TECHNICAL DEPENDENCIES

### 7.1 Current Tech Stack

**State Management:**
- flutter_bloc: ^8.1.3
- rxdart: ^0.27.7

**Database:**
- isar: ^3.1.0+1
- isar_flutter_libs: ^3.1.0+1

**Firebase:**
- cloud_firestore: ^4.13.3
- firebase_storage: ^11.5.3

**Audio Playback:**
- just_audio: ^0.9.36

### 7.2 Required for Audio Recording

**Audio Recording:**
- record: ^5.0.0 (or similar)

**Audio Visualization:**
- flutter_sound_lite: ^9.0.0 (waveform)
- or custom waveform rendering

**File Handling:**
- path_provider: ^2.1.0 (already used)

---

## 8. CRITICAL FILES REFERENCE

### Domain Layer
- [AudioComment Entity](lib/features/audio_comment/domain/entities/audio_comment.dart)
- [AudioCommentRepository Contract](lib/features/audio_comment/domain/repositories/audio_comment_repository.dart)
- [ProjectCommentService](lib/features/audio_comment/domain/services/project_comment_service.dart)
- [AddAudioCommentUseCase](lib/features/audio_comment/domain/usecases/add_audio_comment_usecase.dart)
- [DeleteAudioCommentUseCase](lib/features/audio_comment/domain/usecases/delete_audio_comment_usecase.dart)
- [WatchAudioCommentsBundleUseCase](lib/features/audio_comment/domain/usecases/watch_audio_comments_bundle_usecase.dart)

### Data Layer
- [AudioCommentDTO](lib/features/audio_comment/data/models/audio_comment_dto.dart)
- [AudioCommentDocument (Isar)](lib/features/audio_comment/data/models/audio_comment_document.dart)
- [AudioCommentRepositoryImpl](lib/features/audio_comment/data/repositories/audio_comment_repository_impl.dart)
- [AudioCommentRemoteDataSource](lib/features/audio_comment/data/datasources/audio_comment_remote_datasource.dart)
- [AudioCommentLocalDataSource](lib/features/audio_comment/data/datasources/audio_comment_local_datasource.dart)

### Presentation Layer
- [AudioCommentBloc](lib/features/audio_comment/presentation/bloc/audio_comment_bloc.dart)
- [AudioCommentEvent](lib/features/audio_comment/presentation/bloc/audio_comment_event.dart)
- [AudioCommentState](lib/features/audio_comment/presentation/bloc/audio_comment_state.dart)
- [AppAudioCommentsScreen](lib/features/audio_comment/presentation/screens/app_audio_comments_screen.dart)
- [CommentInputModal](lib/features/audio_comment/presentation/components/comment_input_modal.dart)
- [CommentsSection](lib/features/audio_comment/presentation/components/comments_section.dart)
- [AudioCommentCard](lib/features/audio_comment/presentation/components/audio_comment_card.dart)
- [AudioCommentContent](lib/features/audio_comment/presentation/components/audio_comment_content.dart)

### Permission System
- [ProjectPermission](lib/features/projects/domain/value_objects/project_permission.dart)
- [ProjectCollaborator](lib/features/projects/domain/entities/project_collaborator.dart)
- [Project Entity](lib/features/projects/domain/entities/project.dart)

### Audio Player Integration
- [AudioPlayerBloc](lib/features/audio_player/presentation/bloc/audio_player_bloc.dart)
- [AudioPlayerEvent](lib/features/audio_player/presentation/bloc/audio_player_event.dart)
- [AudioPlayerState](lib/features/audio_player/presentation/bloc/audio_player_state.dart)

---

**End of Research Document**
