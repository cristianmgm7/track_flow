# Refactor Plan: Clean Architecture Best Practices for Data Sources

## Motivation

This project is my first application and serves as my portfolio to demonstrate my understanding and application of Clean Architecture and best practices in Flutter/Dart. My goal is to ensure the codebase is a reference of professional standards, which will help me secure a job as a developer.

## Problem Statement

Currently, some data sources in the codebase receive domain entities or value objects (e.g., `Project`, `ProjectId`) instead of Data Transfer Objects (DTOs) or primitives. According to Clean Architecture, **data sources should only work with DTOs and primitives**. All conversion between domain models and DTOs must happen in the repository layer.

## Why is this important?

- **Separation of concerns:** Keeps domain logic independent from infrastructure.
- **Testability:** Makes it easier to test domain logic and data access separately.
- **Maintainability:** Changes in persistence or API format do not affect domain logic.
- **Professionalism:** Demonstrates a deep understanding of Clean Architecture, which is highly valued by employers.

## Current State

- Most data sources use DTOs, but some still accept domain entities or value objects.
- Some conversion between domain models and DTOs happens inside data sources instead of repositories.

## Target State

- **All data sources (local and remote) must only accept and return DTOs and primitives.**
- **All conversion between DTOs and domain models must happen in the repository layer.**
- **No data source should import or depend on domain entities or value objects.**

## Step-by-Step Refactor Checklist

### 1. **Audit All Data Sources**

- [ ] List all data source interfaces and implementations.
- [ ] Identify all methods that accept or return domain entities or value objects.

### 2. **Update Data Source Interfaces**

- [ ] Change method signatures to accept DTOs/primitives only.
- [ ] Remove any imports of domain entities/value objects from data source files.

### 3. **Update Data Source Implementations**

- [ ] Refactor implementations to work only with DTOs/primitives.
- [ ] Remove any conversion logic from domain model to DTO (or vice versa) from data sources.

### 4. **Update Repositories**

- [ ] Move all conversion logic (domain <-> DTO) to the repository layer.
- [ ] Ensure repositories call data sources with DTOs/primitives only.
- [ ] Update repository interfaces and implementations as needed.

### 5. **Update Use Cases and Services**

- [ ] Ensure use cases and services interact with repositories using domain models/value objects only.
- [ ] No use case or service should ever see a DTO.

### 6. **Update Tests**

- [ ] Update or add tests to verify correct conversion and separation of concerns.
- [ ] Add tests to ensure data sources never receive domain entities/value objects.

### 7. **Documentation**

- [ ] Update `documentation/datasources.md` to reflect the new architecture.
- [ ] Add code comments where necessary to explain conversion points.

## Example Before/After

**Before (incorrect):**

```dart
// In data source
Future<Either<Failure, Unit>> cacheProject(Project project) {
  final dto = ProjectDTO.fromDomain(project); // <-- conversion here (wrong)
  ...
}
```

**After (correct):**

```dart
// In repository
await _localDataSource.cacheProject(ProjectDTO.fromDomain(project));

// In data source
Future<Either<Failure, Unit>> cacheProject(ProjectDTO projectDTO) {
  ... // No knowledge of domain entities
}
```

## How to Verify the Refactor is Complete

- [ ] **No data source imports domain entities or value objects.**
- [ ] **All data source methods use DTOs/primitives only.**
- [ ] **All conversion logic is in repositories.**
- [ ] **Tests pass and verify correct separation.**
- [ ] **Documentation is up to date.**

## Final Note

This refactor will make the codebase a strong example of Clean Architecture, demonstrating your ability to build scalable, maintainable, and professional Flutter/Dart applications.
