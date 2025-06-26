# Domain Layer Best Practices for TrackFlow

This document outlines the established patterns and best practices for implementing the domain layer in TrackFlow, ensuring consistency with Clean Architecture principles.

## Core Principle: Blocs Only Inject Use Cases

**✅ Correct Pattern:**
```dart
@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final PlayAudioUseCase _playAudioUseCase;
  final PauseAudioUseCase _pauseAudioUseCase;
  final StopAudioUseCase _stopAudioUseCase;
  
  AudioPlayerBloc(
    this._playAudioUseCase,
    this._pauseAudioUseCase,
    this._stopAudioUseCase,
  ) : super(const AudioPlayerIdle());
}
```

**❌ Anti-Pattern (Avoid):**
```dart
@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final PlaybackService playbackService;           // ❌ Infrastructure
  final AudioTrackRepository audioTrackRepository; // ❌ Repository
  final UserProfileRepository userProfileRepository; // ❌ Repository
  
  // This violates Clean Architecture separation of concerns
}
```

## Use Case Implementation Guidelines

### 1. Use Case Structure

Every use case should follow this pattern:

```dart
@lazySingleton  // or @injectable
class PlayAudioUseCase {
  final PlaybackService _playbackService;
  final UserProfileRepository _userProfileRepository;
  final AudioSourceResolver _audioSourceResolver;

  PlayAudioUseCase(
    this._playbackService,
    this._userProfileRepository,
    this._audioSourceResolver,
  );

  Future<Either<Failure, PlayAudioResult>> call(AudioTrack track) async {
    // Business logic implementation
  }
}
```

### 2. Use Case Naming Convention

- **Action + Entity/Domain + UseCase**
- Examples:
  - `PlayAudioUseCase`
  - `SavePlaybackStateUseCase`
  - `SkipToNextUseCase`
  - `ToggleShuffleUseCase`

### 3. Return Types

Use cases should return:
- `Future<Either<Failure, T>>` for operations that can fail
- `Future<void>` for simple operations without return values
- `T` for synchronous operations (like toggles)

### 4. Result Objects

Create dedicated result classes for complex operations:

```dart
class PlayAudioResult {
  final AudioTrack track;
  final UserProfile collaborator;
  final String resolvedPath;

  PlayAudioResult({
    required this.track,
    required this.collaborator,
    required this.resolvedPath,
  });
}
```

## Dependency Injection Best Practices

### 1. Registration Patterns

- Use `@lazySingleton` for stateless use cases
- Use `@injectable` for stateful use cases (rare)
- Always specify interfaces with `as` parameter for services

```dart
@LazySingleton(as: PlaybackService)
class PlaybackServiceImpl implements PlaybackService {
  // Implementation
}
```

### 2. Avoid Duplicate Registrations

Never register the same service in both:
- Service implementation with `@LazySingleton(as: Interface)`
- AND app_module.dart provider method

### 3. Use Case Dependencies

Use cases can inject:
- ✅ Domain services (interfaces)
- ✅ Repositories (interfaces)
- ✅ Other use cases (when needed)
- ❌ Infrastructure implementations directly
- ❌ Data layer implementations directly

## Business Logic Placement

### What Goes in Use Cases:
- Complex business rules and validation
- Coordination between multiple repositories/services
- Data transformation and aggregation
- Cross-cutting concerns (logging, caching decisions)

### What Stays in Blocs:
- State management logic
- UI-specific business rules
- Event handling and state transitions
- Stream management

### Example: Complex Logic in Use Case

```dart
class SkipToNextUseCase {
  Future<Either<Failure, SkipResult?>> call({
    required List<String> queue,
    required int currentIndex,
    required RepeatMode repeatMode,
    required PlaybackQueueMode queueMode,
  }) async {
    // Complex business logic for determining next track
    final nextIndex = _calculateNextTrackIndex(
      queue: queue,
      currentIndex: currentIndex,
      repeatMode: repeatMode,
      queueMode: queueMode,
    );
    
    if (nextIndex == -1) return right(null);
    
    // Coordinate multiple services
    final track = await _getTrackById(queue[nextIndex]);
    final collaborator = await _getCollaboratorForTrack(track);
    await _playbackService.play(url: track.resolvedUrl);
    
    return right(SkipResult(track, collaborator, nextIndex));
  }
}
```

## Error Handling

### Use Case Error Handling:
```dart
Future<Either<Failure, T>> call(...) async {
  try {
    // Business logic
    return right(result);
  } catch (e) {
    return left(UnexpectedFailure(e.toString()));
  }
}
```

### Bloc Error Handling:
```dart
final result = await _useCase(params);
result.fold(
  (failure) {
    // Emit error state or handle gracefully
    emit(ErrorState(failure.message));
  },
  (success) {
    // Emit success state
    emit(SuccessState(success));
  },
);
```

## Testing Strategy

### Use Case Testing:
- Mock all dependencies
- Test business logic thoroughly
- Test error scenarios
- Use cases should be easily unit testable

### Bloc Testing:
- Mock use cases, not repositories
- Test state transitions
- Verify use case calls with correct parameters

## Migration Guidelines

When refactoring existing code to follow these patterns:

1. **Identify Business Logic**: Extract complex logic from blocs
2. **Create Use Cases**: One per distinct business operation
3. **Update Dependencies**: Replace repository/service injections with use cases
4. **Simplify Bloc**: Focus on state management only
5. **Update Tests**: Test use cases independently

## Anti-Patterns to Avoid

❌ **Giant Use Cases**: Break down complex operations into smaller, focused use cases
❌ **Use Case Chains**: Avoid use cases calling other use cases excessively
❌ **State in Use Cases**: Keep use cases stateless when possible
❌ **UI Logic in Use Cases**: Business logic only, no UI concerns
❌ **Direct Infrastructure Access**: Always go through domain interfaces

## Benefits of This Approach

- **Consistency**: All features follow the same pattern
- **Testability**: Easy to unit test business logic
- **Maintainability**: Clear separation of concerns
- **Reusability**: Use cases can be reused across different UI components
- **Compliance**: Follows Clean Architecture principles strictly

## Quick Checklist

Before implementing a new feature:

- [ ] Business logic is in use cases, not blocs
- [ ] Blocs only inject use cases
- [ ] Use cases follow naming conventions
- [ ] Proper error handling with Either<Failure, T>
- [ ] Dependencies properly registered
- [ ] No duplicate registrations
- [ ] Use cases are stateless
- [ ] Result objects for complex returns

---

**Remember**: This pattern ensures clean, maintainable, and testable code that scales well as the application grows. Always prefer this approach over direct repository/service injection in presentation layer components.