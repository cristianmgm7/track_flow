# Data Source Best Practices for TrackFlow

Based on the current architecture analysis, this guide provides comprehensive best practices for building data source files in TrackFlow's clean architecture.

## Core Architecture Principles

### 1. Clean Architecture Layers
```
Presentation Layer (BLoC)
    ↓
Domain Layer (Use Cases, Repositories)
    ↓
Data Layer (Repository Implementations, Data Sources)
    ↓
External Layer (Firebase, Local Storage)
```

### 2. Data Source Separation
- **Remote Data Sources**: Handle network operations (Firebase, APIs)
- **Local Data Sources**: Handle caching/persistence (SharedPreferences, Isar)

---

## Data Source Structure

### Abstract Class Pattern
```dart
// Abstract class defines the contract
abstract class FeatureRemoteDataSource {
  Future<Either<Failure, Entity>> createEntity(Entity entity);
  Future<Either<Failure, Unit>> updateEntity(Entity entity);
  Future<Either<Failure, Unit>> deleteEntity(UniqueId id);
  Future<Either<Failure, List<Entity>>> getEntities(String userId);
}
```

### Implementation Pattern
```dart
@LazySingleton(as: FeatureRemoteDataSource)
class FeatureRemoteDataSourceImpl implements FeatureRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  FeatureRemoteDataSourceImpl(this._firestore);
  
  @override
  Future<Either<Failure, Entity>> createEntity(Entity entity) async {
    try {
      // Implementation here
      return Right(result);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
```

---

## Error Handling with Either<Failure, T>

### Required Imports
```dart
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';
```

### Failure Types Available
```dart
// Core failures
ValidationFailure('Invalid input')
ServerFailure('Server error')
NetworkFailure('No internet connection')
AuthenticationFailure('Permission denied')
DatabaseFailure('Database operation failed')
UnexpectedFailure('Unexpected error occurred')
PermissionFailure('Access denied')

// Validation failures
InvalidEmailFailure('Invalid email format')
InvalidPasswordFailure('Password too short')
```

### Error Handling Pattern
```dart
Future<Either<Failure, T>> methodName() async {
  try {
    // Operation logic
    final result = await someOperation();
    return Right(result);
  } on FirebaseException catch (e) {
    return Left(_mapFirebaseException(e));
  } on FormatException catch (e) {
    return Left(ValidationFailure('Invalid format: ${e.message}'));
  } catch (e) {
    return Left(UnexpectedFailure('Unexpected error: ${e.toString()}'));
  }
}

// Firebase exception mapping
Failure _mapFirebaseException(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return AuthenticationFailure('Permission denied');
    case 'not-found':
      return DatabaseFailure('Resource not found');
    case 'already-exists':
      return DatabaseFailure('Resource already exists');
    case 'unavailable':
      return NetworkFailure('Service unavailable');
    default:
      return DatabaseFailure('Database error: ${e.message}');
  }
}
```

---

## Remote Data Source Best Practices

### 1. Firebase Firestore Operations
```dart
abstract class ProjectRemoteDataSource {
  Future<Either<Failure, Project>> createProject(Project project);
  Future<Either<Failure, Unit>> updateProject(Project project);
  Future<Either<Failure, Unit>> deleteProject(UniqueId id);
  Future<Either<Failure, List<Project>>> getUserProjects(String userId);
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  ProjectRemoteDataSourceImpl(this._firestore);
  
  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      // Generate document reference with ID
      final docRef = _firestore.collection(ProjectDTO.collection).doc();
      
      // Create project with generated ID
      final projectWithId = project.copyWith(
        id: ProjectId.fromUniqueString(docRef.id),
      );
      
      // Convert to DTO for Firestore
      final dto = ProjectDTO.fromDomain(projectWithId);
      
      // Save to Firestore
      await docRef.set(dto.toFirestore());
      
      return Right(projectWithId);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to create project: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> updateProject(Project project) async {
    try {
      final dto = ProjectDTO.fromDomain(project);
      await _firestore
          .collection(ProjectDTO.collection)
          .doc(project.id.value)
          .update(dto.toFirestore());
      
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to update project: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, List<Project>>> getUserProjects(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(ProjectDTO.collection)
          .where('ownerId', isEqualTo: userId)
          .where('isDeleted', isEqualTo: false)
          .get();
      
      final projects = querySnapshot.docs
          .map((doc) => ProjectDTO.fromFirestore(doc).toDomain())
          .toList();
      
      return Right(projects);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to get projects: ${e.toString()}'));
    }
  }
}
```

### 2. Firebase Storage Operations
```dart
abstract class AudioTrackRemoteDataSource {
  Future<Either<Failure, String>> uploadAudioFile(File audioFile, String fileName);
  Future<Either<Failure, Unit>> deleteAudioFile(String fileName);
}

@LazySingleton(as: AudioTrackRemoteDataSource)
class AudioTrackRemoteDataSourceImpl implements AudioTrackRemoteDataSource {
  final FirebaseStorage _storage;
  
  @override
  Future<Either<Failure, String>> uploadAudioFile(File audioFile, String fileName) async {
    try {
      final ref = _storage.ref().child('audio_tracks/$fileName');
      final uploadTask = ref.putFile(audioFile);
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return Right(downloadUrl);
    } on FirebaseException catch (e) {
      return Left(_mapFirebaseException(e));
    } catch (e) {
      return Left(UnexpectedFailure('Failed to upload audio: ${e.toString()}'));
    }
  }
}
```

---

## Local Data Source Best Practices

### 1. SharedPreferences for Simple Data
```dart
abstract class AuthLocalDataSource {
  Future<void> cacheUserId(String userId);
  Future<String?> getCachedUserId();
  Future<void> setOnboardingCompleted(bool completed);
  Future<bool> isOnboardingCompleted();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  
  AuthLocalDataSourceImpl(this._prefs);
  
  @override
  Future<void> cacheUserId(String userId) async {
    await _prefs.setString('userId', userId);
  }
  
  @override
  Future<String?> getCachedUserId() async {
    return _prefs.getString('userId');
  }
  
  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool('onboarding_completed', completed);
  }
  
  @override
  Future<bool> isOnboardingCompleted() async {
    return _prefs.getBool('onboarding_completed') ?? false;
  }
}
```

### 2. Isar Database for Complex Data
```dart
abstract class ProjectsLocalDataSource {
  Future<void> cacheProject(ProjectDTO project);
  Future<ProjectDTO?> getCachedProject(UniqueId id);
  Future<void> removeCachedProject(UniqueId id);
  Future<List<ProjectDTO>> getAllProjects();
  Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId);
  Future<void> clearCache();
}

@LazySingleton(as: ProjectsLocalDataSource)
class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  final Isar _isar;
  
  ProjectsLocalDataSourceImpl(this._isar);
  
  @override
  Future<void> cacheProject(ProjectDTO project) async {
    final projectDoc = ProjectDocument.fromDTO(project);
    await _isar.writeTxn(() async {
      await _isar.projectDocuments.put(projectDoc);
    });
  }
  
  @override
  Future<ProjectDTO?> getCachedProject(UniqueId id) async {
    final doc = await _isar.projectDocuments
        .where()
        .idEqualTo(id.value)
        .findFirst();
    return doc?.toDTO();
  }
  
  @override
  Stream<List<ProjectDTO>> watchAllProjects(UserId ownerId) {
    return _isar.projectDocuments
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .and()
        .group((q) => q.ownerIdEqualTo(ownerId.value)
            .or()
            .collaboratorIdsElementEqualTo(ownerId.value))
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }
  
  @override
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.projectDocuments.clear();
    });
  }
}
```

---

## Repository Implementation Pattern

### Combining Data Sources
```dart
@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectRemoteDataSource _remoteDataSource;
  final ProjectsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  ProjectsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );
  
  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    // Check network connectivity
    final hasConnection = await _networkInfo.isConnected;
    if (!hasConnection) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    // Create project remotely
    final result = await _remoteDataSource.createProject(project);
    
    return result.fold(
      (failure) => Left(failure),
      (projectWithId) async {
        // Cache locally on success
        final dto = ProjectDTO.fromDomain(projectWithId);
        await _localDataSource.cacheProject(dto);
        return Right(projectWithId);
      },
    );
  }
  
  @override
  Stream<Either<Failure, List<Project>>> watchLocalProjects(UserId ownerId) {
    return _localDataSource.watchAllProjects(ownerId).map(
      (projects) => Right(
        projects.map((dto) => dto.toDomain()).toList(),
      ),
    ).handleError((error) {
      return Left(DatabaseFailure('Failed to watch projects: ${error.toString()}'));
    });
  }
}
```

---

## Data Transfer Objects (DTOs)

### DTO Pattern
```dart
// Domain Entity
class Project extends Equatable {
  final ProjectId id;
  final ProjectName name;
  final UserId ownerId;
  final DateTime createdAt;
  final bool isDeleted;
  
  const Project({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    required this.isDeleted,
  });
}

// Data Transfer Object
class ProjectDTO extends Equatable {
  static const String collection = 'projects';
  
  final String id;
  final String name;
  final String ownerId;
  final Timestamp createdAt;
  final bool isDeleted;
  
  const ProjectDTO({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.createdAt,
    required this.isDeleted,
  });
  
  // Convert from Domain to DTO
  factory ProjectDTO.fromDomain(Project project) {
    return ProjectDTO(
      id: project.id.value,
      name: project.name.value,
      ownerId: project.ownerId.value,
      createdAt: Timestamp.fromDate(project.createdAt),
      isDeleted: project.isDeleted,
    );
  }
  
  // Convert from DTO to Domain
  Project toDomain() {
    return Project(
      id: ProjectId.fromUniqueString(id),
      name: ProjectName(name),
      ownerId: UserId.fromUniqueString(ownerId),
      createdAt: createdAt.toDate(),
      isDeleted: isDeleted,
    );
  }
  
  // Convert from Firestore
  factory ProjectDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProjectDTO(
      id: doc.id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      isDeleted: data['isDeleted'] ?? false,
    );
  }
  
  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'ownerId': ownerId,
      'createdAt': createdAt,
      'isDeleted': isDeleted,
    };
  }
}
```

---

## Dependency Injection Setup

### Registration Pattern
```dart
// In injection.config.dart
@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  // Implementation
}

@LazySingleton(as: ProjectsLocalDataSource)
class ProjectsLocalDataSourceImpl implements ProjectsLocalDataSource {
  // Implementation
}

@LazySingleton(as: ProjectsRepository)
class ProjectsRepositoryImpl implements ProjectsRepository {
  // Implementation using both data sources
}
```

---

## Testing Best Practices

### Mock Data Sources
```dart
class MockProjectRemoteDataSource extends Mock implements ProjectRemoteDataSource {}
class MockProjectsLocalDataSource extends Mock implements ProjectsLocalDataSource {}

void main() {
  late ProjectsRepositoryImpl repository;
  late MockProjectRemoteDataSource mockRemoteDataSource;
  late MockProjectsLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  
  setUp(() {
    mockRemoteDataSource = MockProjectRemoteDataSource();
    mockLocalDataSource = MockProjectsLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProjectsRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockNetworkInfo,
    );
  });
  
  test('should create project and cache locally on success', () async {
    // Arrange
    when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    when(mockRemoteDataSource.createProject(any))
        .thenAnswer((_) async => Right(tProject));
    when(mockLocalDataSource.cacheProject(any))
        .thenAnswer((_) async => {});
    
    // Act
    final result = await repository.createProject(tProject);
    
    // Assert
    expect(result, equals(Right(tProject)));
    verify(mockRemoteDataSource.createProject(tProject));
    verify(mockLocalDataSource.cacheProject(any));
  });
}
```

---

## Key Tools and Dependencies

### Required Packages
```yaml
dependencies:
  # Functional programming
  dartz: ^0.10.1
  
  # Firebase
  firebase_core: ^2.24.2
  cloud_firestore: ^4.13.6
  firebase_auth: ^4.15.3
  firebase_storage: ^11.5.6
  
  # Local storage
  shared_preferences: ^2.2.2
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  
  # Dependency injection
  injectable: ^2.3.2
  get_it: ^7.6.4
  
  # Networking
  connectivity_plus: ^5.0.2
  
dev_dependencies:
  # Code generation
  build_runner: ^2.4.7
  injectable_generator: ^2.4.1
  isar_generator: ^3.1.0+1
  
  # Testing
  mockito: ^5.4.4
  mocktail: ^1.0.2
```

### Code Generation Commands
```bash
# Generate dependency injection
flutter packages pub run build_runner build

# Generate Isar database schema
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## Checklist for New Data Sources

### ✅ Structure Checklist
- [ ] Abstract class with method signatures
- [ ] Concrete implementation with `@LazySingleton` annotation
- [ ] Proper error handling with `Either<Failure, T>`
- [ ] DTO classes for data transformation
- [ ] Dependency injection registration

### ✅ Error Handling Checklist
- [ ] Try-catch blocks for all operations
- [ ] Specific exception mapping (Firebase, Format, etc.)
- [ ] Appropriate failure types used
- [ ] Generic catch block for unexpected errors

### ✅ Testing Checklist
- [ ] Mock classes for testing
- [ ] Unit tests for all methods
- [ ] Error case testing
- [ ] Success case testing

### ✅ Documentation Checklist
- [ ] Method documentation
- [ ] Parameter descriptions
- [ ] Return type documentation
- [ ] Usage examples

---

This guide ensures consistency, maintainability, and proper error propagation throughout TrackFlow's data layer while following clean architecture principles.

---

## 🚀 Feature Creation Automation

### Command Usage in Claude Code

This document serves as a **context command** that you can reference when creating new features. Here's how to effectively use it:

#### **Method 1: Direct Reference**
```
@datasource_best_practices.md Create a new notification feature with remote and local data sources
```

#### **Method 2: Explicit Context**
```
Using the patterns from datasource_best_practices.md, help me create a complete messaging feature
```

#### **Method 3: Specific Guidance**
```
Follow the data source best practices to implement a settings feature with SharedPreferences
```

---

## 📋 Feature Creation Workflow

### Step-by-Step Process

When creating a new feature, follow this systematic approach:

#### **1. Feature Planning**
```
📁 Feature: [feature_name]
├── 📋 Requirements gathering
├── 🗂️ File structure planning  
├── 🔧 Dependencies identification
└── 📝 Implementation checklist
```

#### **2. File Structure Template**
```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   │   ├── [feature]_remote_datasource.dart
│   │   └── [feature]_local_datasource.dart
│   ├── dto/
│   │   └── [feature]_dto.dart
│   ├── models/
│   │   └── [feature]_document.dart (for Isar)
│   └── repositories/
│       └── [feature]_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── [feature].dart
│   ├── repositories/
│   │   └── [feature]_repository.dart
│   ├── usecases/
│   │   ├── create_[feature]_usecase.dart
│   │   ├── get_[feature]_usecase.dart
│   │   ├── update_[feature]_usecase.dart
│   │   └── delete_[feature]_usecase.dart
│   └── value_objects/
│       └── [feature]_value_objects.dart
└── presentation/
    ├── blocs/
    │   ├── [feature]_bloc.dart
    │   ├── [feature]_event.dart
    │   └── [feature]_state.dart
    ├── pages/
    │   └── [feature]_page.dart
    └── widgets/
        └── [feature]_widgets.dart
```

#### **3. Implementation Checklist**
```markdown
### 🏗️ Domain Layer
- [ ] Create entity class with proper value objects
- [ ] Define repository interface
- [ ] Implement use cases (CRUD operations)
- [ ] Add validation logic

### 📊 Data Layer  
- [ ] Create DTO classes with Firestore mapping
- [ ] Implement remote data source (Firebase)
- [ ] Implement local data source (Isar/SharedPreferences)
- [ ] Create repository implementation
- [ ] Add proper error handling with Either<Failure, T>

### 🎨 Presentation Layer
- [ ] Create BLoC with events and states
- [ ] Implement UI pages and widgets
- [ ] Add proper error handling and loading states
- [ ] Connect BLoC to data layer

### 🔧 Infrastructure
- [ ] Register dependencies in injection.config.dart
- [ ] Run code generation commands
- [ ] Add tests for all layers
- [ ] Update documentation
```

---

## 📝 Code Generation Templates

### Quick Start Template
When asking Claude to create a new feature, use this template:

```
Create a new [FEATURE_NAME] feature following TrackFlow's architecture with:

**Requirements:**
- [Describe what the feature should do]
- [List specific CRUD operations needed]
- [Mention any special requirements]

**Data Storage:**
- Remote: Firebase Firestore
- Local: [Isar Database | SharedPreferences]
- Caching strategy: [Offline-first | Network-first]

**Key Properties:**
- [List main properties of the entity]
- [Mention any relationships to other entities]

**Use Cases:**
- Create[FeatureName]UseCase
- Get[FeatureName]UseCase  
- Update[FeatureName]UseCase
- Delete[FeatureName]UseCase

Please follow the patterns from datasource_best_practices.md and create all necessary files with proper error handling using Either<Failure, T>.
```

### Example Usage
```
Create a new notification feature following TrackFlow's architecture with:

**Requirements:**
- Send push notifications to users
- Store notification history
- Mark notifications as read/unread
- Support different notification types

**Data Storage:**
- Remote: Firebase Firestore  
- Local: Isar Database
- Caching strategy: Offline-first

**Key Properties:**
- id: UniqueId
- userId: UserId
- title: NotificationTitle
- message: NotificationMessage
- type: NotificationType
- isRead: bool
- createdAt: DateTime

**Use Cases:**
- CreateNotificationUseCase
- GetNotificationsUseCase
- UpdateNotificationUseCase
- DeleteNotificationUseCase
- MarkAsReadUseCase

Please follow the patterns from datasource_best_practices.md and create all necessary files with proper error handling using Either<Failure, T>.
```

---

## 🛠️ Automation Commands

### Common Claude Code Commands

#### **1. Feature Creation**
```bash
# Create complete feature structure
@datasource_best_practices.md Create a complete [feature] feature with all layers

# Create specific layer
@datasource_best_practices.md Create only the data layer for [feature]

# Create with specific requirements  
@datasource_best_practices.md Create [feature] with Firebase Storage and real-time sync
```

#### **2. Code Enhancement**
```bash
# Add error handling
@datasource_best_practices.md Add proper error handling to this data source

# Improve existing code
@datasource_best_practices.md Refactor this repository to follow TrackFlow patterns

# Add missing patterns
@datasource_best_practices.md Add DTO and proper Firebase mapping to this feature
```

#### **3. Testing & Validation**
```bash
# Generate tests
@datasource_best_practices.md Create unit tests for this data source following TrackFlow patterns

# Validate implementation
@datasource_best_practices.md Review this implementation against TrackFlow best practices
```

---

## 🔧 Advanced Automation Features

### Custom Code Snippets

#### **1. Data Source Boilerplate**
```dart
// Quick template for remote data source
abstract class {{FeatureName}}RemoteDataSource {
  Future<Either<Failure, {{EntityName}}>> create{{EntityName}}({{EntityName}} entity);
  Future<Either<Failure, Unit>> update{{EntityName}}({{EntityName}} entity);
  Future<Either<Failure, Unit>> delete{{EntityName}}(UniqueId id);
  Future<Either<Failure, List<{{EntityName}}>>> get{{EntityName}}s(String userId);
}

@LazySingleton(as: {{FeatureName}}RemoteDataSource)
class {{FeatureName}}RemoteDataSourceImpl implements {{FeatureName}}RemoteDataSource {
  final FirebaseFirestore _firestore;
  
  {{FeatureName}}RemoteDataSourceImpl(this._firestore);
  
  // Implementation follows TrackFlow patterns...
}
```

#### **2. Repository Boilerplate**
```dart
@LazySingleton(as: {{FeatureName}}Repository)
class {{FeatureName}}RepositoryImpl implements {{FeatureName}}Repository {
  final {{FeatureName}}RemoteDataSource _remoteDataSource;
  final {{FeatureName}}LocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  
  {{FeatureName}}RepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );
  
  // Implementation follows TrackFlow patterns...
}
```

#### **3. BLoC Boilerplate**
```dart
@injectable
class {{FeatureName}}Bloc extends Bloc<{{FeatureName}}Event, {{FeatureName}}State> {
  final Create{{EntityName}}UseCase _create{{EntityName}};
  final Get{{EntityName}}UseCase _get{{EntityName}};
  final Update{{EntityName}}UseCase _update{{EntityName}};
  final Delete{{EntityName}}UseCase _delete{{EntityName}};
  
  {{FeatureName}}Bloc(
    this._create{{EntityName}},
    this._get{{EntityName}},
    this._update{{EntityName}},
    this._delete{{EntityName}},
  ) : super({{FeatureName}}Initial()) {
    on<{{FeatureName}}Event>((event, emit) async {
      // Implementation follows TrackFlow patterns...
    });
  }
}
```

---

## 📚 Context Usage Best Practices

### **1. Effective Command Structure**
```
[CONTEXT_REFERENCE] [SPECIFIC_REQUEST] [ADDITIONAL_DETAILS]

Examples:
✅ @datasource_best_practices.md Create a chat feature with real-time messaging
✅ Using TrackFlow patterns, implement a user preferences feature  
✅ Follow the data source guide to add file upload functionality
```

### **2. Specify Requirements Clearly**
```
Include:
- Feature purpose and scope
- Data storage requirements (Firebase, Isar, SharedPreferences)
- Specific CRUD operations needed
- Any special business logic
- Integration requirements with existing features
```

### **3. Iterative Development**
```
Phase 1: @datasource_best_practices.md Create the domain layer for [feature]
Phase 2: @datasource_best_practices.md Add data layer implementation
Phase 3: @datasource_best_practices.md Create presentation layer with BLoC
Phase 4: @datasource_best_practices.md Add tests and documentation
```

---

## 🎯 Pro Tips for Feature Automation

### **1. Maintain Consistency**
- Always reference this guide when creating new features
- Use consistent naming conventions across all layers
- Follow the established error handling patterns

### **2. Leverage Code Generation**
- Run `flutter packages pub run build_runner build` after creating new features
- Use injectable for dependency injection
- Generate Isar schemas for local data models

### **3. Testing Strategy**
- Create tests for each layer independently
- Mock external dependencies (Firebase, network)
- Test error scenarios thoroughly

### **4. Documentation**
- Update this guide when adding new patterns
- Document any deviations from standard patterns
- Keep examples up to date with current codebase

---

This enhanced guide now serves as both documentation and automation context for creating new features efficiently while maintaining TrackFlow's architectural standards.
