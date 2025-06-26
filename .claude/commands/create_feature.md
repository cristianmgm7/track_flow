# Create Feature Command

This command automates the creation of new features following TrackFlow's clean architecture patterns.

## Usage

```bash
@create_feature.md Create a [FEATURE_NAME] feature with [REQUIREMENTS]
```

## Template

When creating a new feature, provide these details:

```
Create a new [FEATURE_NAME] feature following TrackFlow's architecture with:

**Requirements:**
- [Primary functionality description]
- [CRUD operations needed]
- [Special business rules]

**Data Storage:**
- Remote: Firebase Firestore
- Local: [Isar Database | SharedPreferences]
- Caching: [Offline-first | Network-first]

**Entity Properties:**
- id: UniqueId
- [property]: [Type]
- [property]: [Type]
- createdAt: DateTime
- updatedAt: DateTime

**Use Cases:**
- Create[Entity]UseCase
- Get[Entity]UseCase
- Update[Entity]UseCase
- Delete[Entity]UseCase
- [Custom]UseCase

Follow datasource_best_practices.md patterns with Either<Failure, T> error handling.
```

## Examples

### Simple Feature
```
@create_feature.md Create a notification feature with:
- Store notifications in Firestore
- Cache locally with Isar
- Mark as read/unread
- Different notification types
```

### Complex Feature
```
@create_feature.md Create a file sharing feature with:
- Upload files to Firebase Storage
- Share files between users
- Track download history
- Support multiple file types
- Offline access to downloaded files
```

## Generated Structure

The command will create:
```
lib/features/[feature_name]/
├── data/
│   ├── datasources/
│   ├── dto/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   ├── usecases/
│   └── value_objects/
└── presentation/
    ├── blocs/
    ├── pages/
    └── widgets/
```

## Post-Creation Steps

After feature creation:
1. Run `flutter packages pub run build_runner build`
2. Update dependency injection
3. Add route configuration
4. Create tests
5. Update documentation