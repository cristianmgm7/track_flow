# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TrackFlow is a collaborative audio platform built with Flutter and Domain-Driven Design (DDD) + Clean Architecture. It enables music creators to collaborate through real-time audio feedback, permission-based project management, and professional audio features.

## Essential Development Commands

### Code Generation & Build
```bash
# Generate Isar database models and dependency injection
flutter packages pub run build_runner build --delete-conflicting-outputs

# Clean previous builds (when having issues)
flutter packages pub run build_runner clean

# Standard Flutter commands
flutter pub get
flutter run
flutter build
flutter analyze
```

### Testing Commands
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Specific test files
flutter test test/features/projects/domain/entities/project_test.dart

# Run E2E tests (requires emulator/device)
cd test/integration_test && ./run_e2e_tests.sh
```

### Development Utilities
```bash
# Fix Android emulator network issues for Google Sign-In
./scripts/fix_emulator_network.sh

# Fix Google Sign-In issues
./scripts/fix_google_signin.sh

# Check Flutter environment
flutter doctor
```

## Architecture Guidelines

### Clean Architecture + DDD Structure
- **Domain Layer**: Contains business entities, value objects, repositories contracts, and use cases
- **Data Layer**: Implements repositories, datasources (Firebase/Isar), and DTOs
- **Presentation Layer**: BLoC state management, screens, and widgets
- **Core**: Shared kernel with dependency injection, error handling, and utilities

### Key Architectural Rules
1. **Always use @lib/core/theme/ in any visual code** - Use the established theme system
2. **Always write in English in the code base even comments** - Maintain consistency
3. **Follow Clean Architecture dependency rules** - Domain layer must not depend on external layers
4. **Use BLoC pattern for state management** - Consistent reactive programming
5. **Implement Either<Failure, Success> for error handling** - Functional error handling
6. **Use dependency injection with get_it and injectable** - Loose coupling

### Feature Development Pattern
Each feature follows this structure:
```
features/[feature_name]/
├── domain/
│   ├── entities/         # Business objects
│   ├── repositories/     # Repository contracts
│   ├── usecases/        # Business logic
│   └── value_objects/   # Domain value objects
├── data/
│   ├── datasources/     # Firebase/Isar implementations
│   ├── models/          # DTOs and documents
│   └── repositories/    # Repository implementations
└── presentation/
    ├── bloc/           # State management
    ├── screens/        # UI screens
    └── widgets/        # Reusable components
```

## Core Systems

### Audio Playback System
- Centralized `PlaybackController` manages all audio state
- Single `AudioPlayer` instance for synchronized playback
- Support for streaming with background caching
- Real-time waveform visualization for collaborative commenting
- Offline-first with automatic sync when reconnected

### Firebase Integration
- **Authentication**: Email/Password + Google Sign-In
- **Firestore**: Real-time collaborative project data
- **Storage**: Audio file storage and retrieval
- **Dynamic Links**: Project sharing via magic links

### Local Storage (Isar)
- High-performance local database for offline-first functionality
- Automatic sync with Firestore when online
- Cached audio files for offline playback
- User preferences and session persistence

### Permission System
- Role-based access control (Owner, Admin, Editor, Viewer)
- Domain-driven permission validation in entities
- Active domain patterns for business rule enforcement

### Download System
- Permission-based download with `ProjectPermission.downloadTrack`
- Reuses cache storage - creates temporary copy with friendly filename
- Filename format: `{trackName}_v{versionNumber}.{ext}`
- Share sheet export for cross-platform support
- Dual entry points: Track actions (active version) and Version actions (specific version)
- Editor and Admin roles can download; Viewer cannot

## Important Files & Directories

### Configuration
- `pubspec.yaml` - Dependencies and project metadata
- `build.yaml` - Code generation configuration for Isar and injectable
- `analysis_options.yaml` - Dart linter configuration
- `firebase.json` - Firebase project configuration

### Core Architecture
- `lib/core/di/` - Dependency injection setup
- `lib/core/domain/` - Base entity and aggregate root classes
- `lib/core/error/` - Error handling and failure types
- `lib/core/theme/` - Design system and UI components

### Key Features
- `lib/features/auth/` - Authentication system
- `lib/features/projects/` - Project management
- `lib/features/audio_player/` - Audio playback system
- `lib/features/audio_comment/` - Collaborative commenting
- `lib/features/invitations/` - Project sharing and collaboration

### Testing
- `test/` - Unit and widget tests
- `test/integration_test/` - End-to-end integration tests

## Development Best Practices

### Code Quality
- Use strong typing with value objects for domain concepts
- Implement comprehensive error handling with Either types
- Write unit tests for all domain logic and use cases
- Follow the established naming conventions and project structure

### State Management
- Use BLoC pattern consistently across all features
- Emit immutable states with proper error handling
- Handle loading, success, and error states explicitly
- Use reactive programming with streams for real-time updates

### Database Operations
- Always use repository pattern for data access
- Implement both remote (Firebase) and local (Isar) data sources
- Handle offline scenarios gracefully with local caching
- Use incremental sync for optimal performance

### Audio Development
- Follow the audio playback rules in `.cursor/rules/playback.mdc`
- Implement centralized audio state management
- Support both streaming and cached playback
- Ensure proper audio session management for background play

## Common Development Tasks

### Adding a New Feature
1. Create feature directory structure following the established pattern
2. Define domain entities and value objects
3. Create repository contracts in domain layer
4. Implement data sources and repository implementations
5. Create use cases for business logic
6. Build BLoC for state management
7. Create UI components and screens
8. Add dependency injection configuration
9. Write comprehensive tests

### Working with Audio
- Use the centralized `PlaybackController` for all audio operations
- Implement proper caching strategies for offline playback
- Follow waveform visualization patterns for commenting
- Ensure audio session management for background playback

### Firebase Operations
- Use repository pattern with Either error handling
- Implement proper offline caching with Isar
- Handle real-time updates with Firestore streams
- Use proper security rules and permission validation