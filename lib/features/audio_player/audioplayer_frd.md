# Audio Player Feature Refactoring Document (FRD)

## 📋 Overview

This document outlines the complete refactoring plan for the `audio_player` feature to achieve SOLID principles compliance and transform it into a pure audio reproduction system, decoupled from collaboration and business domain concerns.

## 🎯 Objectives

### Primary Goal
Refactor the audio player to have a **single responsibility: audio reproduction**, removing all non-audio concerns such as user collaboration, project context, and comments integration.

### SOLID Principles Compliance
- **SRP**: Audio player handles only audio reproduction
- **OCP**: Extensible through composition and providers
- **LSP**: Proper abstraction implementations
- **ISP**: Segregated interfaces by responsibility
- **DIP**: Dependencies on abstractions, not concretions

## 🔍 Current State Analysis

### Major Violations Identified

#### 1. Single Responsibility Principle (SRP) Violations
- **AudioPlayerBloc**: Manages audio + user profiles + persistence
- **AudioPlayerState**: Contains `UserProfile collaborator` 
- **PlayAudioUseCase**: Fetches collaborator data + plays audio
- **AudioPlayerScreen**: Integrates comments directly

#### 2. Dependency Inversion Principle (DIP) Violations
- Direct dependency on `UserProfileRepository` in audio use cases
- Tight coupling to `CacheOrchestrationService`
- Infrastructure dependencies in domain layer

#### 3. Interface Segregation Principle (ISP) Violations
- `CommentsForAudioPlayer` requires `projectId`, `track`, and `collaborators`
- Fat interfaces forcing unnecessary dependencies

### Current Coupling Points
```
┌─────────────────────────────────────┐
│           CURRENT STATE             │
├─────────────────────────────────────┤
│ AudioPlayerBloc                     │
│ ├── Audio Control ✅                │
│ ├── User Profile Management ❌      │
│ ├── Project Context ❌              │
│ └── Comments Integration ❌         │
│                                     │
│ Use Cases                           │
│ ├── Pure Audio Logic ✅             │
│ ├── UserProfile Fetching ❌         │
│ └── Repository Access ❌            │
│                                     │
│ UI Components                       │
│ ├── Audio Controls ✅               │
│ ├── Comments Display ❌             │
│ └── Collaborator Info ❌            │
└─────────────────────────────────────┘
```

## 🏗️ Target Architecture

### New Architecture Overview
```
┌─────────────────────────────────────┐
│            TARGET STATE             │
├─────────────────────────────────────┤
│ PURE AUDIO PLAYER                   │
│ ├── Audio Control ✅                │
│ ├── Queue Management ✅             │
│ ├── State Persistence ✅            │
│ └── Source Resolution ✅            │
│                                     │
│ AUDIO CONTEXT (NEW FEATURE)         │
│ ├── User Profile Management ✅       │
│ ├── Project Context ✅              │
│ └── Collaboration Data ✅           │
│                                     │
│ AUDIO COMMENTS (SEPARATE FEATURE)   │
│ ├── Comments Display ✅             │
│ └── Audio Synchronization ✅        │
│                                     │
│ COMPOSITION LAYER                   │
│ └── Combines all features ✅        │
└─────────────────────────────────────┘
```

### Directory Structure (Target)
```
lib/features/
├── audio_player/                     # PURE AUDIO ONLY
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── audio_track_metadata.dart
│   │   │   ├── playback_session.dart
│   │   │   └── audio_queue.dart
│   │   ├── repositories/
│   │   │   ├── audio_content_repository.dart
│   │   │   └── playback_persistence_repository.dart
│   │   ├── services/
│   │   │   ├── audio_playback_service.dart
│   │   │   └── audio_source_service.dart
│   │   └── usecases/
│   │       └── [PURIFIED USE CASES]
│   ├── infrastructure/
│   │   └── [PURIFIED IMPLEMENTATIONS]
│   └── presentation/
│       ├── bloc/
│       │   ├── audio_player_bloc.dart      # NO UserProfile
│       │   ├── audio_player_state.dart     # NO Collaborators
│       │   └── audio_player_event.dart     # NO Project Context
│       └── widgets/
│           ├── pure_audio_player.dart      # Context-free
│           └── mini_audio_player.dart      # Pure mini player
│
├── audio_context/                    # NEW FEATURE
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── track_context.dart
│   │   │   └── collaboration_info.dart
│   │   ├── services/
│   │   │   └── audio_context_service.dart
│   │   └── repositories/
│   │       └── track_context_repository.dart
│   ├── infrastructure/
│   │   └── track_context_repository_impl.dart
│   └── presentation/
│       ├── providers/
│       │   └── audio_context_provider.dart
│       └── widgets/
│           └── audio_context_display.dart
│
├── audio_comments/                   # SEPARATE FEATURE
│   └── presentation/
│       └── widgets/
│           └── audio_synchronized_comments.dart
│
└── audio_composition/                # COMPOSITION LAYER
    └── presentation/
        └── screens/
            ├── audio_player_with_context_screen.dart
            └── collaborative_audio_screen.dart
```

## 📋 Migration Plan - 6 Phases

### Phase 1: Foundation & Interfaces (Week 1)
**Goal**: Create pure audio interfaces and entities

#### Tasks:
- [ ] Create `AudioTrackMetadata` entity (NO UserProfile)
- [ ] Create `PlaybackSession` entity (pure audio state)
- [ ] Create `AudioQueue` entity (queue management)
- [ ] Define `AudioContentRepository` interface
- [ ] Define `AudioPlaybackService` interface
- [ ] Create `AudioContextService` interface (new feature)

#### Deliverables:
```dart
// audio_track_metadata.dart
class AudioTrackMetadata {
  final AudioTrackId id;
  final String title;
  final String artist;
  final Duration duration;
  final String? coverUrl;
  // NO: UserProfile, ProjectId, or collaboration data
}

// playback_session.dart
class PlaybackSession {
  final AudioTrackMetadata currentTrack;
  final AudioQueue queue;
  final PlaybackState state;
  final Duration position;
  final RepeatMode repeatMode;
  final bool shuffleEnabled;
  // NO: collaboration context
}

// audio_content_repository.dart
abstract class AudioContentRepository {
  Future<AudioTrackMetadata> getTrackMetadata(AudioTrackId id);
  Future<List<AudioTrackMetadata>> getPlaylistTracks(PlaylistId id);
  Future<String> getAudioSourceUrl(AudioTrackId id);
}
```

### Phase 2: Use Cases Refactoring (Week 2)
**Goal**: Purify all use cases to handle only audio logic

#### Tasks:
- [ ] Refactor `PlayAudioUseCase` - Remove UserProfile fetching
- [ ] Refactor `PlayPlaylistUseCase` - Remove collaborator logic
- [ ] Refactor `SkipToNextUseCase` - Remove user context
- [ ] Refactor `SkipToPreviousUseCase` - Remove user context
- [ ] Refactor `RestorePlaybackStateUseCase` - Remove collaboration data
- [ ] Keep pure audio use cases as-is (Pause, Resume, Stop, Seek, etc.)

#### Before/After Example:
```dart
// BEFORE (PlayAudioUseCase)
class PlayAudioUseCase {
  final PlaybackService _playbackService;
  final UserProfileRepository _userProfileRepository; // ❌ REMOVE
  final AudioSourceResolver _audioSourceResolver;

  Future<Either<Failure, PlayAudioResult>> call(AudioTrack track) async {
    // Fetch collaborator - ❌ NON-AUDIO RESPONSIBILITY
    final collaboratorResult = await _getCollaboratorForTrack(track);
    final playResult = await _playbackService.play(track.audioSource);
    return Right(PlayAudioResult(
      track: track,
      collaborator: collaboratorResult, // ❌ REMOVE
    ));
  }
}

// AFTER (PlayAudioUseCase)
class PlayAudioUseCase {
  final AudioPlaybackService _playbackService;
  final AudioContentRepository _audioContentRepository;

  Future<Either<Failure, void>> call(AudioTrackId trackId) async {
    final metadata = await _audioContentRepository.getTrackMetadata(trackId);
    final sourceUrl = await _audioContentRepository.getAudioSourceUrl(trackId);
    return _playbackService.play(AudioSource(sourceUrl, metadata));
  }
}
```

### Phase 3: BLoC Refactoring (Week 3)
**Goal**: Purify BLoC to manage only audio state

#### Tasks:
- [ ] Remove `UserProfile collaborator` from `AudioPlayerActiveState`
- [ ] Remove `UserProfile collaborator` from `PlayAudioRequested` event
- [ ] Simplify state management to handle only audio data
- [ ] Create `AudioContextProvider` for external context management
- [ ] Update BLoC to emit pure audio states

#### State Refactoring:
```dart
// BEFORE
abstract class AudioPlayerActiveState extends AudioPlayerState {
  final AudioTrack track;
  final UserProfile collaborator; // ❌ REMOVE
  final List<String> queue;
  final int currentIndex;
  final RepeatMode repeatMode;
  final PlaybackQueueMode queueMode;
}

// AFTER
abstract class AudioPlayerActiveState extends AudioPlayerState {
  final PlaybackSession session;
  // Clean, pure audio state
}
```

#### Event Refactoring:
```dart
// BEFORE
class PlayAudioRequested extends AudioPlayerEvent {
  final AudioTrack track;
  final UserProfile collaborator; // ❌ REMOVE
}

// AFTER
class PlayAudioRequested extends AudioPlayerEvent {
  final AudioTrackId trackId;
  // Context will be provided externally
}
```

### Phase 4: UI Refactoring (Week 4)
**Goal**: Create pure audio UI components and composition layer

#### Tasks:
- [ ] Create `PureAudioPlayer` widget (context-free)
- [ ] Create `MiniAudioPlayer` widget (pure)
- [ ] Create `AudioContextProvider` for dependency injection
- [ ] Create `AudioPlayerWithContext` composite widget
- [ ] Refactor `AudioPlayerScreen` to use composition
- [ ] Remove `CommentsForAudioPlayer` integration
- [ ] Create `AudioSynchronizedComments` as separate feature

#### Component Structure:
```dart
// pure_audio_player.dart
class PureAudioPlayer extends StatelessWidget {
  final AudioContextProvider? contextProvider; // Optional injection
  
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        // Renders ONLY audio controls
        // Context data comes from provider if available
        return Column(
          children: [
            AudioControls(),
            PlaybackProgress(),
            QueueControls(),
            // NO: Comments, collaborator info, project data
          ],
        );
      },
    );
  }
}

// audio_player_with_context.dart (Composition)
class AudioPlayerWithContext extends StatelessWidget {
  final AudioTrackId trackId;
  final ProjectId? projectId;

  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioContextProvider()),
      ],
      child: Column(
        children: [
          // Pure audio player
          PureAudioPlayer(
            contextProvider: context.read<AudioContextProvider>(),
          ),
          // Separate features
          AudioContextDisplay(),
          AudioSynchronizedComments(),
        ],
      ),
    );
  }
}
```

### Phase 5: Infrastructure Refactoring (Week 5)
**Goal**: Implement repository abstractions and purify implementations

#### Tasks:
- [ ] Implement `AudioContentRepositoryImpl`
- [ ] Implement `TrackContextRepositoryImpl` (new feature)
- [ ] Purify `AudioSourceResolverImpl` (remove business logic)
- [ ] Update dependency injection configuration
- [ ] Implement `AudioContextServiceImpl`
- [ ] Abstract cache dependencies behind audio interfaces

#### Repository Implementation:
```dart
// audio_content_repository_impl.dart
class AudioContentRepositoryImpl implements AudioContentRepository {
  final AudioTrackRepository _trackRepo;
  final CacheOrchestrationService _cacheService;

  @override
  Future<AudioTrackMetadata> getTrackMetadata(AudioTrackId id) async {
    final track = await _trackRepo.getTrack(id);
    return AudioTrackMetadata(
      id: track.id,
      title: track.title,
      artist: track.artist,
      duration: track.duration,
      coverUrl: track.coverUrl,
      // NO: collaborator, project, or business data
    );
  }

  @override
  Future<String> getAudioSourceUrl(AudioTrackId id) async {
    // Check cache first, then streaming
    final cachedUrl = await _cacheService.getCachedUrl(id);
    if (cachedUrl != null) return cachedUrl;
    
    final track = await _trackRepo.getTrack(id);
    return track.streamingUrl;
  }
}

// track_context_repository_impl.dart (NEW FEATURE)
class TrackContextRepositoryImpl implements TrackContextRepository {
  final UserProfileRepository _userRepo;
  final ProjectRepository _projectRepo;

  @override
  Future<TrackContext> getTrackContext(AudioTrackId trackId) async {
    // HERE is where collaborator and project logic belongs
    final collaborator = await _getCollaboratorForTrack(trackId);
    final project = await _getProjectForTrack(trackId);
    return TrackContext(
      collaborator: collaborator,
      project: project,
      // All business context here
    );
  }
}
```

### Phase 6: Testing & Integration (Week 6)
**Goal**: Comprehensive testing and final integration

#### Tasks:
- [ ] Unit tests for pure audio components (no mocking of UserProfile)
- [ ] Integration tests for composite components
- [ ] End-to-end tests for complete user flows
- [ ] Performance testing (memory usage, loading times)
- [ ] Backward compatibility testing
- [ ] Feature flag implementation and testing
- [ ] Documentation updates

#### Testing Strategy:
```dart
// Pure audio player tests - MUCH SIMPLER
testWidgets('should play audio without external context', (tester) async {
  final mockAudioContentRepo = MockAudioContentRepository();
  final mockPlaybackService = MockPlaybackService();
  
  // No need to mock UserProfileRepository, ProjectRepository, etc.
  // Tests are focused and fast
  
  await tester.pumpWidget(
    BlocProvider(
      create: (_) => AudioPlayerBloc(
        playAudioUseCase: PlayAudioUseCase(
          audioContentRepository: mockAudioContentRepo,
          playbackService: mockPlaybackService,
        ),
      ),
      child: PureAudioPlayer(),
    ),
  );
  
  // Test audio functionality only
  expect(find.byType(PlayButton), findsOneWidget);
  await tester.tap(find.byType(PlayButton));
  
  verify(mockPlaybackService.play(any)).called(1);
});

// Composite component tests
testWidgets('should show collaborator info when context provided', (tester) async {
  // Test integration between features
  await tester.pumpWidget(
    AudioPlayerWithContext(
      trackId: AudioTrackId('test-track'),
      projectId: ProjectId('test-project'),
    ),
  );
  
  // Verify both audio controls and context display
  expect(find.byType(PureAudioPlayer), findsOneWidget);
  expect(find.byType(AudioContextDisplay), findsOneWidget);
});
```

## 🔄 Backward Compatibility Strategy

### Adapter Pattern for Transition
```dart
// legacy_audio_player_adapter.dart
class LegacyAudioPlayerAdapter {
  static Widget createLegacyPlayer({
    required AudioTrack track,
    required UserProfile collaborator,
    required ProjectId projectId,
  }) {
    return AudioPlayerWithContext(
      trackId: track.id,
      contextOverride: TrackContext(
        collaborator: collaborator,
        project: projectId,
      ),
    );
  }
}
```

### Feature Flags Configuration
```dart
// feature_flags.dart
class AudioPlayerFeatureFlags {
  static bool get usePureAudioPlayer => 
    RemoteConfig.getBool('use_pure_audio_player');
  
  static bool get enableAudioContext => 
    RemoteConfig.getBool('enable_audio_context');
}

// Usage in screens
Widget buildAudioPlayer() {
  if (AudioPlayerFeatureFlags.usePureAudioPlayer) {
    return AudioPlayerWithContext(trackId: currentTrackId);
  } else {
    return LegacyAudioPlayerAdapter.createLegacyPlayer(
      track: currentTrack,
      collaborator: currentCollaborator,
      projectId: currentProjectId,
    );
  }
}
```

## 📊 Success Metrics

### Code Quality Metrics
- [ ] **Cyclomatic Complexity**: Reduce from 15+ to <10 per method
- [ ] **Coupling**: Reduce from 8+ dependencies to <5 per class
- [ ] **Test Coverage**: Increase from 65% to 85%
- [ ] **Build Time**: Maintain or improve current build times

### SOLID Principles Compliance
- [ ] **SRP**: Each class has single, well-defined responsibility
- [ ] **OCP**: New features can be added without modifying existing code
- [ ] **LSP**: All abstractions are properly implemented
- [ ] **ISP**: Interfaces are focused and minimal
- [ ] **DIP**: Dependencies are on abstractions, not concretions

### Performance Metrics
- [ ] **Memory Usage**: Reduce by 20% (fewer loaded dependencies)
- [ ] **Cold Start Time**: Improve by 15% (lazy loading of context)
- [ ] **Test Execution Time**: Improve by 50% (simpler mocks)

## 🚨 Risks & Mitigation

### High Risks
1. **Breaking Changes**: Existing screens expect current API
   - **Mitigation**: Adapter pattern + feature flags
   - **Rollback**: Keep old implementation available

2. **Performance Regression**: New architecture might be slower
   - **Mitigation**: Performance testing in each phase
   - **Rollback**: Feature flag to disable new architecture

### Medium Risks
1. **Testing Complexity**: Integration tests become more complex
   - **Mitigation**: Focus on unit tests, minimal integration tests
   
2. **Developer Learning Curve**: New patterns and composition
   - **Mitigation**: Documentation, pair programming, code reviews

### Low Risks
1. **Feature Parity**: Missing functionality in new implementation
   - **Mitigation**: Comprehensive feature mapping and testing

## 📚 Implementation Checklist

### Pre-Migration
- [ ] Create feature branch: `feature/audio-player-refactor`
- [ ] Set up feature flags in remote config
- [ ] Document current API surface
- [ ] Identify all dependent screens/widgets
- [ ] Set up CI/CD for new architecture testing

### During Migration
- [ ] Phase 1: Foundation & Interfaces ✅
- [ ] Phase 2: Use Cases Refactoring ✅
- [ ] Phase 3: BLoC Refactoring ✅
- [ ] Phase 4: UI Refactoring ✅
- [ ] Phase 5: Infrastructure Refactoring ✅
- [ ] Phase 6: Testing & Integration ✅

### Post-Migration
- [ ] Performance monitoring setup
- [ ] Gradual rollout (0% → 25% → 50% → 100%)
- [ ] Legacy code cleanup (after 100% rollout)
- [ ] Documentation updates
- [ ] Team training sessions

## 🏁 Definition of Done

The refactoring is complete when:

1. **SOLID Principles**: All violations identified in this document are resolved
2. **Single Responsibility**: AudioPlayer handles ONLY audio reproduction
3. **Decoupling**: AudioPlayer can be used without collaboration context
4. **Test Coverage**: 85%+ coverage with simplified test scenarios
5. **Performance**: No regression in key metrics
6. **Backward Compatibility**: Existing features continue to work
7. **Documentation**: Updated architecture documentation and examples

## 👥 Team Responsibilities

### Senior Developer 1 (Technical Lead)
- Architecture design validation
- Code reviews for SOLID principles compliance
- Performance optimization
- Mentoring junior developers

### Senior Developer 2 (Implementation Lead)
- Core refactoring implementation
- BLoC and use case refactoring
- Testing strategy implementation
- Feature flag management

### Mid-Level Developer (Support)
- UI component refactoring
- Test case implementation
- Documentation updates
- Bug fixes and edge cases

## 📅 Timeline

| Week | Phase | Focus | Deliverables |
|------|-------|-------|--------------|
| 1 | Foundation | Interfaces & Entities | Pure audio contracts |
| 2 | Use Cases | Domain Logic | Purified use cases |
| 3 | BLoC | State Management | Clean audio state |
| 4 | UI | Presentation Layer | Pure audio widgets |
| 5 | Infrastructure | Repository Layer | Abstracted dependencies |
| 6 | Testing | Quality Assurance | Tests & Integration |

**Total Duration**: 6 weeks  
**Team Size**: 3 developers  
**Estimated Effort**: 18 person-weeks

---

*This document serves as the single source of truth for the Audio Player feature refactoring. All team members should refer to this document for implementation guidance and progress tracking.*