# UI Models Pattern

## Overview

UI Models are presentation-layer classes that wrap domain entities to provide:
- Proper equality comparison for Equatable/BLoC states
- Unwrapped primitives for simpler widget code
- UI-specific computed fields (formatted strings, display logic)
- Clear separation between domain and presentation concerns

## The Problem

Domain entities use **identity-based equality** (comparing only IDs), but BLoC states using Equatable need **content-based equality** to detect UI changes and trigger rebuilds. This architectural mismatch causes:

1. **Missed UI updates**: Two entity instances with the same ID but different field values are considered equal, so state changes don't trigger rebuilds
2. **Manual workarounds**: Developers manually expand entity fields in `props`, which is error-prone and verbose
3. **Value object complexity**: Widgets must unwrap value objects like `ProjectName.value.getOrElse(() => '')` everywhere

## The Solution

UI Models bridge this gap by wrapping domain entities with Equatable-compatible models that:
- Use content-based equality (all field values matter)
- Provide unwrapped primitives for direct access
- Add UI-specific computed values

## When to Create a UI Model

Create a UI model when:
- ✅ A domain entity is stored in a BLoC state
- ✅ A domain entity is passed to multiple widgets
- ✅ You need UI-specific computed fields (formatted dates, display names, status badges)
- ✅ Value objects need unwrapping for widgets
- ✅ You're experiencing reactivity issues (UI not updating on entity changes)

Don't create a UI model when:
- ❌ The entity is only used once in a single widget
- ❌ The widget directly receives data from a use case (use the domain entity)
- ❌ For simple value objects that are already primitives

## Pattern Structure

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/your_entity.dart';

/// UI model wrapping YourEntity domain entity with unwrapped primitives
class YourEntityUiModel extends Equatable {
  // 1. Composition: contain the domain entity
  final YourEntity entity;

  // 2. Unwrapped primitives for easy access
  final String id;
  final String name;
  final DateTime createdAt;
  // ... other primitive fields

  // 3. UI-specific computed fields
  final String displayName;
  final String formattedDate;
  final bool isActive;

  const YourEntityUiModel({
    required this.entity,
    required this.id,
    required this.name,
    required this.createdAt,
    required this.displayName,
    required this.formattedDate,
    required this.isActive,
  });

  // 4. fromDomain factory for conversion
  factory YourEntityUiModel.fromDomain(YourEntity entity) {
    return YourEntityUiModel(
      entity: entity,
      id: entity.id.value,
      name: entity.name.value.getOrElse(() => ''),
      createdAt: entity.createdAt,
      displayName: _computeDisplayName(entity),
      formattedDate: _formatDate(entity.createdAt),
      isActive: entity.status == EntityStatus.active,
    );
  }

  static String _computeDisplayName(YourEntity entity) {
    // UI-specific business logic
    return entity.name.value.getOrElse(() => 'Unnamed ${entity.id.value}');
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }

  // 5. Equatable props - primitives only (NOT the entity)
  @override
  List<Object?> get props => [
    id,
    name,
    createdAt,
    displayName,
    formattedDate,
    isActive,
  ];
}
```

## Usage in BLoCs

Convert domain entities to UI models when emitting states:

```dart
class YourBloc extends Bloc<YourEvent, YourState> {
  Future<void> _onLoadEntities(
    LoadEntitiesEvent event,
    Emitter<YourState> emit,
  ) async {
    final result = await _getEntitiesUseCase();
    
    result.fold(
      (failure) => emit(YourErrorState(failure.message)),
      (entities) => emit(
        YourLoadedState(
          // Convert domain entities to UI models
          items: entities.map(YourEntityUiModel.fromDomain).toList(),
        ),
      ),
    );
  }

  Future<void> _onWatchEntities(
    WatchEntitiesEvent event,
    Emitter<YourState> emit,
  ) async {
    await emit.onEach<Either<Failure, List<YourEntity>>>(
      _watchEntitiesUseCase(),
      onData: (either) {
        either.fold(
          (failure) => emit(YourErrorState(failure.message)),
          (entities) => emit(
            YourLoadedState(
              // Convert on each stream emission
              items: entities.map(YourEntityUiModel.fromDomain).toList(),
            ),
          ),
        );
      },
    );
  }
}
```

## Usage in Widgets

Widgets receive UI models and access primitives directly:

```dart
class EntityCard extends StatelessWidget {
  final YourEntityUiModel entity;

  const EntityCard({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Direct primitive access - no unwrapping needed
          Text(entity.name),
          Text(entity.displayName),
          Text(entity.formattedDate),
          
          // Conditional UI based on computed fields
          if (entity.isActive)
            Icon(Icons.check_circle, color: Colors.green),
        ],
      ),
    );
  }
}
```

## Accessing the Domain Entity

When you need the wrapped domain entity (e.g., for use cases):

```dart
class EditEntityForm extends StatelessWidget {
  final YourEntityUiModel entityUi;

  void _onSave(BuildContext context) {
    // Extract the domain entity for use case
    final updatedEntity = entityUi.entity.copyWith(
      name: YourEntityName.create(newName).getOrElse(() => throw Error()),
    );
    
    context.read<YourBloc>().add(
      UpdateEntityEvent(updatedEntity),
    );
  }
}
```

Alternatively, pass the domain entity directly to child widgets that perform operations:

```dart
// In parent widget
EntityCard(
  entityUi: entityUi,
  onEdit: () => showEditForm(
    context: context,
    entity: entityUi.entity,  // Pass domain entity for editing
  ),
)
```

## Best Practices

### 1. Use Const Constructors
```dart
const YourEntityUiModel({
  required this.entity,
  required this.id,
  // ...
});
```

### 2. Keep Static Helper Methods Private
```dart
static String _formatDuration(Duration duration) {
  // ...
}
```

### 3. Don't Include the Entity in Props
```dart
// ❌ BAD - includes entity (identity-based equality)
@override
List<Object?> get props => [entity, id, name];

// ✅ GOOD - only primitives
@override
List<Object?> get props => [id, name, createdAt];
```

### 4. Computed Fields Should Be Deterministic
```dart
// ✅ GOOD - same input always produces same output
static String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '${minutes}:${seconds.toString().padLeft(2, '0')}';
}

// ❌ BAD - depends on current time (non-deterministic)
String get formattedDate => DateFormat.yMd().format(DateTime.now());
```

### 5. Name UI Models Consistently
- Pattern: `{EntityName}UiModel`
- Examples: `ProjectUiModel`, `AudioTrackUiModel`, `VoiceMemoUiModel`

## Common Patterns

### Handling Nullable Domain Entities
```dart
class YourState extends Equatable {
  final YourEntityUiModel? entity;  // Nullable UI model
  
  const YourState({this.entity});
}

// In BLoC
emit(YourState(
  entity: domainEntity != null 
    ? YourEntityUiModel.fromDomain(domainEntity)
    : null,
));
```

### Lists of UI Models
```dart
class YourState extends Equatable {
  final List<YourEntityUiModel> items;
  
  @override
  List<Object?> get props => [items];  // Equatable handles list comparison
}
```

### Sorting UI Models
```dart
// Extract domain entities, sort them, convert back
void _onChangeSort(ChangeSortEvent event, Emitter emit) {
  final current = state as YourLoadedState;
  final domainEntities = current.items.map((ui) => ui.entity).toList();
  final sorted = [...domainEntities]..sort(compareBySort);
  
  emit(current.copyWith(
    items: sorted.map(YourEntityUiModel.fromDomain).toList(),
  ));
}
```

## Examples from TrackFlow

### ProjectUiModel
```dart
class ProjectUiModel extends Equatable {
  final Project project;
  final String id;
  final String name;
  final String description;
  final int collaboratorCount;  // Computed from entity
  
  factory ProjectUiModel.fromDomain(Project project) {
    return ProjectUiModel(
      project: project,
      id: project.id.value,
      name: project.name.value.getOrElse(() => ''),
      description: project.description.value.getOrElse(() => ''),
      collaboratorCount: project.collaborators.length,  // UI-specific
    );
  }
}
```

### AudioTrackUiModel
```dart
class AudioTrackUiModel extends Equatable {
  final AudioTrack track;
  final String id;
  final String name;
  final Duration duration;
  final String formattedDuration;  // UI-specific formatting
  
  factory AudioTrackUiModel.fromDomain(AudioTrack track) {
    return AudioTrackUiModel(
      track: track,
      id: track.id.value,
      name: track.name,
      duration: track.duration,
      formattedDuration: _formatDuration(track.duration),
    );
  }
  
  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}
```

### VoiceMemoUiModel
```dart
class VoiceMemoUiModel extends Equatable {
  final VoiceMemo memo;
  final String id;
  final String title;
  final String formattedDate;  // Relative time formatting
  final bool isConverted;       // Business logic check
  
  factory VoiceMemoUiModel.fromDomain(VoiceMemo memo) {
    return VoiceMemoUiModel(
      memo: memo,
      id: memo.id.value,
      title: memo.title,
      formattedDate: _formatDate(memo.recordedAt),
      isConverted: memo.convertedToTrackId != null,
    );
  }
  
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}
```

## Migration Checklist

When adding UI models to an existing feature:

- [ ] Create `presentation/models/{entity}_ui_model.dart`
- [ ] Implement with composition pattern and `fromDomain()` factory
- [ ] Update state classes to use UI model instead of domain entity
- [ ] Update BLoC emit logic to convert via `fromDomain()`
- [ ] Update widgets to accept UI model and use primitives
- [ ] Remove any manual equality workarounds from state `props`
- [ ] Test that UI updates correctly on entity changes
- [ ] Verify no compilation errors with `flutter analyze`

## Performance Considerations

**Conversion Overhead**:
- `fromDomain()` creates new UI model instances
- Acceptable overhead for typical list sizes (< 1000 items)
- Consider caching for very large lists if profiling shows issues

**Memory Usage**:
- UI models contain both primitives and domain entity reference
- Small overhead per entity (a few extra strings/numbers)
- Negligible for typical app usage

**Optimization Tips**:
- Use const constructors where possible
- Avoid expensive computations in `fromDomain()` - do them once
- Profile before optimizing - premature optimization is the root of all evil

## Troubleshooting

### UI Not Updating After Entity Change

**Symptom**: Entity changes in database but UI doesn't reflect it.

**Solution**: Check that:
1. State uses UI model (not domain entity)
2. BLoC converts entities via `fromDomain()` on each emission
3. Equatable props include all relevant primitive fields

### Type Errors When Passing to Widgets

**Symptom**: `The argument type 'ProjectUiModel' can't be assigned to 'Project'`

**Solution**: 
- Widget should accept `ProjectUiModel`, not `Project`
- Or access the domain entity via `projectUi.project`

### Equality Not Working Correctly

**Symptom**: States with same values are not equal / trigger unnecessary rebuilds

**Solution**: Check that:
1. UI model extends Equatable
2. Props only contain primitives (not the entity itself)
3. All relevant fields are included in props

## Related Documentation

- [Clean Architecture Guidelines](../../CLAUDE.md#architecture-guidelines)
- [BLoC Pattern Best Practices](../../CLAUDE.md#state-management)
- [Equatable Package Docs](https://pub.dev/packages/equatable)

