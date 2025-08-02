# TrackFlow Feature Generator Guide

A comprehensive boilerplate generator for creating Clean Architecture + DDD features in the TrackFlow project.

## Overview

The `generate_feature.py` script automatically generates the complete folder structure and boilerplate code for new features following TrackFlow's established patterns:

- ✅ **Clean Architecture** with proper layer separation
- ✅ **Domain-Driven Design** patterns
- ✅ **BLoC State Management** with events, states, and blocs
- ✅ **Repository Pattern** with local/remote data sources
- ✅ **Use Case Pattern** with Either<Failure, Success>
- ✅ **Dependency Injection** with injectable annotations
- ✅ **Offline-First Architecture** with sync metadata
- ✅ **Test Templates** following project conventions

## Quick Start

```bash
# Generate a complete feature
python generate_feature.py notifications

# Generate with tests
python generate_feature.py user_settings --with-tests

# Skip presentation layer (BLoC files)
python generate_feature.py analytics --skip-presentation
```

## Generated Structure

```
lib/features/your_feature/
├── domain/
│   ├── entities/
│   │   └── your_feature.dart
│   ├── value_objects/
│   │   ├── your_feature_name.dart
│   │   └── your_feature_description.dart
│   ├── repositories/
│   │   └── your_feature_repository.dart
│   └── usecases/
│       ├── create_your_feature_usecase.dart
│       ├── update_your_feature_usecase.dart
│       ├── delete_your_feature_usecase.dart
│       ├── get_your_feature_by_id_usecase.dart
│       └── watch_your_features_by_user_usecase.dart
├── data/
│   ├── models/
│   │   ├── your_feature_dto.dart
│   │   └── your_feature_document.dart
│   ├── datasources/
│   │   ├── your_feature_local_datasource.dart
│   │   └── your_feature_remote_datasource.dart
│   └── repositories/
│       └── your_feature_repository_impl.dart
└── presentation/
    └── bloc/
        ├── your_feature_event.dart
        ├── your_feature_state.dart
        └── your_feature_bloc.dart
```

## Usage Examples

### 1. Complete Feature Generation

```bash
python generate_feature.py notifications --with-tests
```

Generates:
- Complete domain, data, and presentation layers
- All CRUD use cases
- BLoC pattern implementation
- Comprehensive test files
- Isar document models for offline storage
- Firebase data sources for remote sync

### 2. Domain-Only Feature

```bash
python generate_feature.py analytics --skip-presentation
```

Generates:
- Domain entities and use cases
- Repository contracts and implementations  
- Data models and sources
- Skips BLoC and UI components

### 3. Specific Project Root

```bash
python generate_feature.py user_preferences --project-root /path/to/trackflow
```

## Generated Code Patterns

### Domain Entity
```dart
class YourFeature extends Entity<YourFeatureId> {
  final String name;
  final String description;
  final UserId createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Factory constructor with DDD patterns
  factory YourFeature.create({
    required String name,
    required String description,
    required UserId createdBy,
  }) {
    // Implementation with generated ID and timestamps
  }

  // Business logic methods
  bool isOwnedBy(UserId userId) {
    return createdBy == userId;
  }
}
```

### Use Case with Either Pattern
```dart
@lazySingleton
class CreateYourFeatureUseCase {
  final YourFeatureRepository _repository;

  Future<Either<Failure, Unit>> call(CreateYourFeatureParams params) async {
    // Implementation with proper error handling
  }
}
```

### Repository Implementation
```dart
@LazySingleton(as: YourFeatureRepository)
class YourFeatureRepositoryImpl implements YourFeatureRepository {
  // Offline-first implementation with background sync
  // Cache-aside pattern
  // Proper error handling
}
```

### BLoC with Clean Architecture
```dart
@injectable
class YourFeatureBloc extends Bloc<YourFeatureEvent, YourFeatureState> {
  // Proper dependency injection
  // Stream subscriptions management
  // Error handling patterns
}
```

## Post-Generation Steps

After running the generator, follow these steps:

### 1. Run Code Generation
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 2. Update App Module
Add your Isar document schema to `lib/core/di/app_module.dart`:

```dart
final schemas = [
  // ... existing schemas
  YourFeatureDocumentSchema, // Add this line
];
```

### 3. Customize Generated Code

#### Entity Customization
- Add domain-specific business logic methods
- Implement validation rules
- Add domain events if needed

#### Value Objects
- Customize validation rules in value objects
- Add domain-specific constraints
- Implement formatting methods

#### Use Cases
- Implement the TODO sections with actual business logic
- Add domain service integrations
- Implement permission checks

#### Repository
- Customize sync strategies
- Add feature-specific caching logic
- Implement conflict resolution

### 4. Create UI Components
```bash
mkdir -p lib/features/your_feature/presentation/{screens,widgets,components}
```

### 5. Write Integration Tests
```dart
// test/features/your_feature/integration/
// Add end-to-end feature tests
```

## Code Generation Features

### 🏗️ Architecture Patterns
- **Clean Architecture** layer separation
- **DDD** entities with business logic
- **CQRS** with separate read/write operations
- **Repository Pattern** with abstraction
- **Dependency Injection** ready

### 🔄 Offline-First Support
- Isar local database integration
- Background sync coordination
- Conflict resolution metadata
- Cache-aside pattern implementation

### 🧪 Testing Support
- Entity tests with business logic validation
- BLoC tests with mockito
- Repository tests (optional)
- Integration test structure

### 📱 State Management
- BLoC pattern with events/states
- Stream subscription management
- Error state handling
- Loading state management

## Advanced Usage

### Custom Templates

The generator is designed to be extensible. You can:

1. **Modify Templates**: Edit methods in `FeatureGenerator` class
2. **Add New Use Cases**: Extend `use_cases` list in `generate_all_files`
3. **Custom Value Objects**: Modify `value_objects` list
4. **Additional Files**: Add new generation methods

### Integration with CI/CD

```yaml
# .github/workflows/feature-generation.yml
- name: Generate Feature Boilerplate
  run: |
    python generate_feature.py ${{ github.event.inputs.feature_name }} --with-tests
    flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### Common Issues

1. **Import Errors**: Run `flutter pub get` after generation
2. **Build Runner Errors**: Clean with `flutter clean` then regenerate
3. **DI Issues**: Ensure new classes are properly annotated with `@injectable`
4. **Isar Schema**: Add document schema to app_module.dart

### Validation

After generation, verify:
- [ ] All imports resolve correctly
- [ ] Code generation runs without errors
- [ ] Tests compile and pass
- [ ] DI registration works
- [ ] Repository pattern implementation follows offline-first principles

## Best Practices

### 1. Feature Naming
- Use **snake_case** for feature names
- Choose descriptive, domain-focused names
- Avoid technical terms in business domain

### 2. Customization Priority
1. **Entities**: Add business logic first
2. **Use Cases**: Implement domain rules
3. **Repository**: Customize sync behavior
4. **UI**: Build screens and widgets
5. **Tests**: Add comprehensive coverage

### 3. Domain Modeling
- Start with the domain entity
- Model real business concepts
- Add value objects for validation
- Implement domain services when needed

### 4. Error Handling
- Use Either<Failure, Success> consistently
- Create specific failure types
- Handle offline scenarios gracefully
- Provide meaningful error messages

## Examples in TrackFlow

Study these existing features for reference:
- `audio_comment/` - Complete CRUD with real-time updates
- `projects/` - Complex domain with collaborator management
- `audio_track/` - File upload and metadata management
- `invitations/` - Permission-based workflows

## Support

For issues or enhancements:
1. Check existing patterns in the codebase
2. Review Clean Architecture principles
3. Follow DDD modeling practices
4. Ensure offline-first design

The generator follows TrackFlow's established patterns and will be updated as the architecture evolves.