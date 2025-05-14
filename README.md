# trackflow

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Clean Architecture Overview

This project uses Clean Architecture and Domain-Driven Design (DDD) principles for scalable, maintainable, and testable code.

### Layers

- **Presentation Layer:** Contains UI widgets and Blocs. Blocs only depend on use cases, not on repositories or data sources.
- **Domain Layer:** Contains business logic, use cases, and repository contracts. Use cases encapsulate all business rules and validation.
- **Data Layer:** Contains repository implementations, DTOs, and data sources (local and remote).

### Dependency Injection

- Uses [`get_it`](https://pub.dev/packages/get_it) for dependency injection.
- All use cases are grouped in a `ProjectUseCases` class and injected into Blocs via a service locator.

### User ID Handling

- The authenticated user ID is tracked in `ProjectsBloc` via a `BlocListener` on `AuthBloc`.
- All project operations use the correct user context, ensuring security and correct data access.

### Error Handling

- All errors are represented by subclasses of `Failure` (e.g., `ValidationFailure`, `DatabaseFailure`, `PermissionFailure`, etc.).
- The Bloc maps each failure type to a user-friendly message for the UI.

### Example Flow (Create Project)

1. **UI** dispatches a `CreateProject` event to `ProjectsBloc`.
2. **ProjectsBloc** calls the `CreateProjectUseCase` from the injected `ProjectUseCases` group.
3. **CreateProjectUseCase** validates the project using `ProjectModel` and calls the repository contract.
4. **SyncProjectRepository** implements the contract, using DTOs and data sources to persist the project.
5. **Data Sources** handle local (Hive) and remote (Firestore) storage.

---

## Next Steps

- Add more documentation as new features and improvements are made.
- See the code for detailed comments and structure.
