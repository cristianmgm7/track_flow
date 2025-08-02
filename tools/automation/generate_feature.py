#!/usr/bin/env python3
"""
TrackFlow Feature Boilerplate Generator
A comprehensive script to generate Clean Architecture + DDD boilerplate code for new features.

Usage:
    python generate_feature.py <feature_name> [options]

Example:
    python generate_feature.py notifications --with-tests
    python generate_feature.py user_settings --skip-presentation
"""

import os
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Optional
import re

class FeatureGenerator:
    """Generates TrackFlow feature boilerplate following Clean Architecture + DDD patterns."""
    
    def __init__(self, feature_name: str, project_root: Path = None):
        self.feature_name = feature_name.lower()
        self.feature_class_name = self._to_pascal_case(feature_name)
        self.project_root = project_root or Path.cwd()
        self.feature_root = self.project_root / "lib" / "features" / self.feature_name
        
    def _to_pascal_case(self, snake_str: str) -> str:
        """Convert snake_case to PascalCase."""
        return ''.join(word.capitalize() for word in snake_str.split('_'))
    
    def _to_camel_case(self, snake_str: str) -> str:
        """Convert snake_case to camelCase."""
        components = snake_str.split('_')
        return components[0] + ''.join(word.capitalize() for word in components[1:])
    
    def _to_snake_case(self, camel_str: str) -> str:
        """Convert CamelCase to snake_case."""
        return re.sub('(.)([A-Z][a-z]+)', r'\1_\2', camel_str).lower()
    
    def _create_file(self, path: Path, content: str, overwrite: bool = False):
        """Create a file with the given content."""
        if path.exists() and not overwrite:
            print(f"Skipping existing file: {path}")
            return
            
        path.parent.mkdir(parents=True, exist_ok=True)
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Created: {path}")

    def generate_domain_entity(self) -> str:
        """Generate domain entity template."""
        return f"""import 'package:trackflow/core/domain/entity.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class {self.feature_class_name} extends Entity<{self.feature_class_name}Id> {{
  final String name;
  final String description;
  final UserId createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const {self.feature_class_name}({{
    required {self.feature_class_name}Id id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  }}) : super(id);

  factory {self.feature_class_name}.create({{
    required String name,
    required String description,
    required UserId createdBy,
  }}) {{
    final now = DateTime.now();
    return {self.feature_class_name}(
      id: {self.feature_class_name}Id(),
      name: name,
      description: description,
      createdBy: createdBy,
      createdAt: now,
      updatedAt: now,
    );
  }}

  {self.feature_class_name} copyWith({{
    {self.feature_class_name}Id? id,
    String? name,
    String? description,
    UserId? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }}) {{
    return {self.feature_class_name}(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }}

  bool isOwnedBy(UserId userId) {{
    return createdBy == userId;
  }}
}}

/// Entity ID for {self.feature_class_name}
class {self.feature_class_name}Id extends UniqueId {{
  {self.feature_class_name}Id([String? value]) : super(value);
  
  factory {self.feature_class_name}Id.fromUniqueString(String value) {{
    return {self.feature_class_name}Id(value);
  }}
}}
"""

    def generate_value_object(self, value_object_name: str) -> str:
        """Generate value object template."""
        class_name = self._to_pascal_case(value_object_name)
        return f"""import 'package:trackflow/core/entities/value_object.dart';
import 'package:trackflow/core/error/value_failure.dart';
import 'package:dartz/dartz.dart';

class {class_name} extends ValueObject<String> {{
  const {class_name}._(String value) : super(value);

  factory {class_name}(String input) {{
    final validation = {class_name}.validate(input);
    return validation.fold(
      (failure) => throw ArgumentError(failure.message),
      (validValue) => {class_name}._(validValue),
    );
  }}

  static Either<ValueFailure<String>, String> validate(String input) {{
    if (input.isEmpty) {{
      return Left(ValueFailure.empty(failedValue: input));
    }}
    
    if (input.length < 3) {{
      return Left(ValueFailure.shortLength(failedValue: input, min: 3));
    }}
    
    if (input.length > 100) {{
      return Left(ValueFailure.exceedingLength(failedValue: input, max: 100));
    }}
    
    return Right(input);
  }}
}}
"""

    def generate_repository_contract(self) -> str:
        """Generate repository contract template."""
        return f"""import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';

abstract class {self.feature_class_name}Repository {{
  /// Get {self.feature_name} by ID
  Future<Either<Failure, {self.feature_class_name}>> get{self.feature_class_name}ById(
    {self.feature_class_name}Id id,
  );

  /// Get all {self.feature_name}s for a user
  Stream<Either<Failure, List<{self.feature_class_name}>>> watch{self.feature_class_name}sByUser(
    UserId userId,
  );

  /// Create a new {self.feature_name}
  Future<Either<Failure, Unit>> create{self.feature_class_name}({self.feature_class_name} {self._to_camel_case(self.feature_name)});

  /// Update an existing {self.feature_name}
  Future<Either<Failure, Unit>> update{self.feature_class_name}({self.feature_class_name} {self._to_camel_case(self.feature_name)});

  /// Delete a {self.feature_name}
  Future<Either<Failure, Unit>> delete{self.feature_class_name}({self.feature_class_name}Id id);
}}
"""

    def generate_usecase(self, usecase_name: str, usecase_type: str = "query") -> str:
        """Generate use case template."""
        class_name = self._to_pascal_case(usecase_name)
        params_class = f"{class_name}Params"
        
        if usecase_type == "command":
            return_type = "Unit"
        else:
            return_type = self.feature_class_name if "get" in usecase_name.lower() else f"List<{self.feature_class_name}>"
            
        return f"""import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';
import 'package:trackflow/features/{self.feature_name}/domain/repositories/{self.feature_name}_repository.dart';

class {params_class} {{
  final UserId userId;
  // Add more parameters as needed
  
  const {params_class}({{
    required this.userId,
  }});
}}

@lazySingleton
class {class_name}UseCase {{
  final {self.feature_class_name}Repository _{self._to_camel_case(self.feature_name)}Repository;

  {class_name}UseCase(this._{self._to_camel_case(self.feature_name)}Repository);

  Future<Either<Failure, {return_type}>> call({params_class} params) async {{
    // TODO: Implement use case logic
    throw UnimplementedError('Implement {class_name}UseCase.call()');
  }}
}}
"""

    def generate_data_model(self) -> str:
        """Generate data model (DTO) template."""
        return f"""import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';
import 'package:trackflow/core/entities/unique_id.dart';

class {self.feature_class_name}DTO {{
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  
  // Sync metadata fields for offline-first sync
  final int version;
  final DateTime? lastModified;

  const {self.feature_class_name}DTO({{
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.version = 1,
    this.lastModified,
  }});

  static const String collection = '{self.feature_name}s';

  factory {self.feature_class_name}DTO.fromDomain({self.feature_class_name} {self._to_camel_case(self.feature_name)}) {{
    return {self.feature_class_name}DTO(
      id: {self._to_camel_case(self.feature_name)}.id.value,
      name: {self._to_camel_case(self.feature_name)}.name,
      description: {self._to_camel_case(self.feature_name)}.description,
      createdBy: {self._to_camel_case(self.feature_name)}.createdBy.value,
      createdAt: {self._to_camel_case(self.feature_name)}.createdAt.toIso8601String(),
      updatedAt: {self._to_camel_case(self.feature_name)}.updatedAt.toIso8601String(),
      version: 1,
      lastModified: {self._to_camel_case(self.feature_name)}.updatedAt,
    );
  }}

  {self.feature_class_name} toDomain() {{
    return {self.feature_class_name}(
      id: {self.feature_class_name}Id.fromUniqueString(id),
      name: name,
      description: description,
      createdBy: UserId.fromUniqueString(createdBy),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }}

  Map<String, dynamic> toJson() {{
    return {{
      'id': id,
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'version': version,
      'lastModified': lastModified?.toIso8601String(),
    }};
  }}

  factory {self.feature_class_name}DTO.fromJson(Map<String, dynamic> json) {{
    return {self.feature_class_name}DTO(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdBy: json['createdBy'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      version: json['version'] as int? ?? 1,
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified'] as String)
          : null,
    );
  }}
}}
"""

    def generate_isar_model(self) -> str:
        """Generate Isar document model template."""
        return f"""import 'package:isar/isar.dart';
import 'package:trackflow/features/{self.feature_name}/data/models/{self.feature_name}_dto.dart';

part '{self.feature_name}_document.g.dart';

@collection
class {self.feature_class_name}Document {{
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String name;
  late String description;
  late String createdBy;
  late String createdAt;
  late String updatedAt;
  
  // Sync metadata
  late int version;
  DateTime? lastModified;
  
  // Soft delete flag
  @Index()
  bool isDeleted = false;

  {self.feature_class_name}Document();

  factory {self.feature_class_name}Document.fromDTO({self.feature_class_name}DTO dto) {{
    return {self.feature_class_name}Document()
      ..id = dto.id
      ..name = dto.name
      ..description = dto.description
      ..createdBy = dto.createdBy
      ..createdAt = dto.createdAt
      ..updatedAt = dto.updatedAt
      ..version = dto.version
      ..lastModified = dto.lastModified;
  }}

  {self.feature_class_name}DTO toDTO() {{
    return {self.feature_class_name}DTO(
      id: id,
      name: name,
      description: description,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt,
      version: version,
      lastModified: lastModified,
    );
  }}
}}
"""

    def generate_repository_impl(self) -> str:
        """Generate repository implementation template."""
        return f"""import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/network/network_state_manager.dart';
import 'package:trackflow/core/sync/domain/services/background_sync_coordinator.dart';
import 'package:trackflow/core/sync/domain/services/pending_operations_manager.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/{self.feature_name}/data/datasources/{self.feature_name}_local_datasource.dart';
import 'package:trackflow/features/{self.feature_name}/data/datasources/{self.feature_name}_remote_datasource.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';
import 'package:trackflow/features/{self.feature_name}/domain/repositories/{self.feature_name}_repository.dart';
import 'package:trackflow/features/{self.feature_name}/data/models/{self.feature_name}_dto.dart';

@LazySingleton(as: {self.feature_class_name}Repository)
class {self.feature_class_name}RepositoryImpl implements {self.feature_class_name}Repository {{
  final {self.feature_class_name}LocalDataSource _localDataSource;
  final BackgroundSyncCoordinator _backgroundSyncCoordinator;
  final PendingOperationsManager _pendingOperationsManager;

  {self.feature_class_name}RepositoryImpl({{
    required {self.feature_class_name}RemoteDataSource remoteDataSource,
    required {self.feature_class_name}LocalDataSource localDataSource,
    required NetworkStateManager networkStateManager,
    required BackgroundSyncCoordinator backgroundSyncCoordinator,
    required PendingOperationsManager pendingOperationsManager,
  }}) : _localDataSource = localDataSource,
       _backgroundSyncCoordinator = backgroundSyncCoordinator,
       _pendingOperationsManager = pendingOperationsManager;

  @override
  Future<Either<Failure, {self.feature_class_name}>> get{self.feature_class_name}ById(
    {self.feature_class_name}Id id,
  ) async {{
    try {{
      // Try local cache first
      final result = await _localDataSource.get{self.feature_class_name}ById(id.value);

      final local{self.feature_class_name} = result.fold(
        (failure) => null,
        (dto) => dto?.toDomain(),
      );

      // If found locally, return it and trigger background refresh
      if (local{self.feature_class_name} != null) {{
        // Trigger background sync for fresh data (non-blocking)
        unawaited(
          _backgroundSyncCoordinator.triggerBackgroundSync(
            syncKey: '{self.feature_name}_${{id.value}}',
          ),
        );

        return Right(local{self.feature_class_name});
      }}

      // Not found locally - trigger background fetch and return not found
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: '{self.feature_name}_${{id.value}}',
        ),
      );

      return Left(DatabaseFailure('{self.feature_class_name} not found in local cache'));
    }} catch (e) {{
      return Left(
        DatabaseFailure('Failed to access local cache: ${{e.toString()}}'),
      );
    }}
  }}

  @override
  Stream<Either<Failure, List<{self.feature_class_name}>>> watch{self.feature_class_name}sByUser(
    UserId userId,
  ) {{
    try {{
      // Trigger background sync when method is called
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: '{self.feature_name}s_${{userId.value}}',
        ),
      );

      // Return local data immediately + trigger background sync
      return _localDataSource.watch{self.feature_class_name}sByUser(userId.value).map((
        localResult,
      ) {{
        return localResult.fold(
          (failure) => Left(failure),
          (dtos) => Right(dtos.map((dto) => dto.toDomain()).toList()),
        );
      }});
    }} catch (e) {{
      return Stream.value(
        Left(
          DatabaseFailure('Failed to watch {self.feature_name}s: ${{e.toString()}}'),
        ),
      );
    }}
  }}

  @override
  Future<Either<Failure, Unit>> create{self.feature_class_name}({self.feature_class_name} {self._to_camel_case(self.feature_name)}) async {{
    try {{
      final dto = {self.feature_class_name}DTO.fromDomain({self._to_camel_case(self.feature_name)});

      // Save locally first
      await _localDataSource.cache{self.feature_class_name}(dto);

      // Queue for background sync
      final queueResult = await _pendingOperationsManager.addCreateOperation(
        entityType: '{self.feature_name}',
        entityId: {self._to_camel_case(self.feature_name)}.id.value,
        data: dto.toJson(),
        priority: SyncPriority.high,
      );

      if (queueResult.isLeft()) {{
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${{failure?.message}}',
          ),
        );
      }}

      // Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: '{self.feature_name}s_create',
        ),
      );

      return const Right(unit);
    }} catch (e) {{
      return Left(DatabaseFailure('Critical storage error: ${{e.toString()}}'));
    }}
  }}

  @override
  Future<Either<Failure, Unit>> update{self.feature_class_name}({self.feature_class_name} {self._to_camel_case(self.feature_name)}) async {{
    try {{
      final dto = {self.feature_class_name}DTO.fromDomain({self._to_camel_case(self.feature_name)});

      // Update locally first
      await _localDataSource.cache{self.feature_class_name}(dto);

      // Queue for background sync
      final queueResult = await _pendingOperationsManager.addUpdateOperation(
        entityType: '{self.feature_name}',
        entityId: {self._to_camel_case(self.feature_name)}.id.value,
        data: dto.toJson(),
        priority: SyncPriority.high,
      );

      if (queueResult.isLeft()) {{
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${{failure?.message}}',
          ),
        );
      }}

      // Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: '{self.feature_name}s_update',
        ),
      );

      return const Right(unit);
    }} catch (e) {{
      return Left(DatabaseFailure('Critical storage error: ${{e.toString()}}'));
    }}
  }}

  @override
  Future<Either<Failure, Unit>> delete{self.feature_class_name}({self.feature_class_name}Id id) async {{
    try {{
      // Soft delete locally first
      await _localDataSource.deleteCached{self.feature_class_name}(id.value);

      // Queue for background sync
      final queueResult = await _pendingOperationsManager.addDeleteOperation(
        entityType: '{self.feature_name}',
        entityId: id.value,
        priority: SyncPriority.high,
      );

      if (queueResult.isLeft()) {{
        final failure = queueResult.fold((l) => l, (r) => null);
        return Left(
          DatabaseFailure(
            'Failed to queue sync operation: ${{failure?.message}}',
          ),
        );
      }}

      // Trigger background sync
      unawaited(
        _backgroundSyncCoordinator.triggerBackgroundSync(
          syncKey: '{self.feature_name}s_delete',
        ),
      );

      return const Right(unit);
    }} catch (e) {{
      return Left(DatabaseFailure('Critical storage error: ${{e.toString()}}'));
    }}
  }}

  // Helper method for fire-and-forget background operations
  void unawaited(Future future) {{
    future.catchError((error) {{
      AppLogger.warning('Background sync trigger failed: $error', tag: '{self.feature_class_name}RepositoryImpl');
    }});
  }}
}}
"""

    def generate_local_datasource(self) -> str:
        """Generate local data source template."""
        return f"""import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/{self.feature_name}/data/models/{self.feature_name}_document.dart';
import 'package:trackflow/features/{self.feature_name}/data/models/{self.feature_name}_dto.dart';

abstract class {self.feature_class_name}LocalDataSource {{
  Future<Either<Failure, {self.feature_class_name}DTO?>> get{self.feature_class_name}ById(String id);
  Stream<Either<Failure, List<{self.feature_class_name}DTO>>> watch{self.feature_class_name}sByUser(String userId);
  Future<Either<Failure, Unit>> cache{self.feature_class_name}({self.feature_class_name}DTO {self._to_camel_case(self.feature_name)}DTO);
  Future<Either<Failure, Unit>> deleteCached{self.feature_class_name}(String id);
}}

@LazySingleton(as: {self.feature_class_name}LocalDataSource)
class {self.feature_class_name}LocalDataSourceImpl implements {self.feature_class_name}LocalDataSource {{
  final Isar _isar;

  {self.feature_class_name}LocalDataSourceImpl(this._isar);

  @override
  Future<Either<Failure, {self.feature_class_name}DTO?>> get{self.feature_class_name}ById(String id) async {{
    try {{
      final document = await _isar.{self._to_camel_case(self.feature_name)}Documents
          .where()
          .idEqualTo(id)
          .and()
          .isDeletedEqualTo(false)
          .findFirst();

      if (document == null) {{
        return const Right(null);
      }}

      return Right(document.toDTO());
    }} catch (e) {{
      return Left(DatabaseFailure('Failed to get {self.feature_name}: ${{e.toString()}}'));
    }}
  }}

  @override
  Stream<Either<Failure, List<{self.feature_class_name}DTO>>> watch{self.feature_class_name}sByUser(String userId) {{
    try {{
      return _isar.{self._to_camel_case(self.feature_name)}Documents
          .where()
          .createdByEqualTo(userId)
          .and()
          .isDeletedEqualTo(false)
          .watch(fireImmediately: true)
          .map((documents) {{
            try {{
              final dtos = documents.map((doc) => doc.toDTO()).toList();
              return Right<Failure, List<{self.feature_class_name}DTO>>(dtos);
            }} catch (e) {{
              return Left<Failure, List<{self.feature_class_name}DTO>>(
                DatabaseFailure('Failed to convert documents: ${{e.toString()}}'),
              );
            }}
          }});
    }} catch (e) {{
      return Stream.value(
        Left(DatabaseFailure('Failed to watch {self.feature_name}s: ${{e.toString()}}')),
      );
    }}
  }}

  @override
  Future<Either<Failure, Unit>> cache{self.feature_class_name}({self.feature_class_name}DTO {self._to_camel_case(self.feature_name)}DTO) async {{
    try {{
      await _isar.writeTxn(() async {{
        await _isar.{self._to_camel_case(self.feature_name)}Documents.put(
          {self.feature_class_name}Document.fromDTO({self._to_camel_case(self.feature_name)}DTO),
        );
      }});

      return const Right(unit);
    }} catch (e) {{
      return Left(DatabaseFailure('Failed to cache {self.feature_name}: ${{e.toString()}}'));
    }}
  }}

  @override
  Future<Either<Failure, Unit>> deleteCached{self.feature_class_name}(String id) async {{
    try {{
      await _isar.writeTxn(() async {{
        final document = await _isar.{self._to_camel_case(self.feature_name)}Documents
            .where()
            .idEqualTo(id)
            .findFirst();

        if (document != null) {{
          document.isDeleted = true;
          await _isar.{self._to_camel_case(self.feature_name)}Documents.put(document);
        }}
      }});

      return const Right(unit);
    }} catch (e) {{
      return Left(DatabaseFailure('Failed to delete {self.feature_name}: ${{e.toString()}}'));
    }}
  }}
}}
"""

    def generate_remote_datasource(self) -> str:
        """Generate remote data source template."""
        return f"""import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/{self.feature_name}/data/models/{self.feature_name}_dto.dart';

abstract class {self.feature_class_name}RemoteDataSource {{
  Future<Either<Failure, {self.feature_class_name}DTO>> get{self.feature_class_name}ById(String id);
  Future<Either<Failure, List<{self.feature_class_name}DTO>>> get{self.feature_class_name}sByUser(String userId);
  Future<Either<Failure, Unit>> create{self.feature_class_name}({self.feature_class_name}DTO {self._to_camel_case(self.feature_name)}DTO);
  Future<Either<Failure, Unit>> update{self.feature_class_name}({self.feature_class_name}DTO {self._to_camel_case(self.feature_name)}DTO);
  Future<Either<Failure, Unit>> delete{self.feature_class_name}(String id);
}}

@LazySingleton(as: {self.feature_class_name}RemoteDataSource)
class {self.feature_class_name}RemoteDataSourceImpl implements {self.feature_class_name}RemoteDataSource {{
  final FirebaseFirestore _firestore;

  {self.feature_class_name}RemoteDataSourceImpl(this._firestore);

  @override
  Future<Either<Failure, {self.feature_class_name}DTO>> get{self.feature_class_name}ById(String id) async {{
    try {{
      final doc = await _firestore
          .collection({self.feature_class_name}DTO.collection)
          .doc(id)
          .get();

      if (!doc.exists) {{
        return Left(ServerFailure('{self.feature_class_name} not found'));
      }}

      final data = doc.data()!;
      data['id'] = doc.id;
      
      return Right({self.feature_class_name}DTO.fromJson(data));
    }} catch (e) {{
      return Left(ServerFailure('Failed to get {self.feature_name}: ${{e.toString()}}'));
    }}
  }}

  @override
  Future<Either<Failure, List<{self.feature_class_name}DTO>>> get{self.feature_class_name}sByUser(String userId) async {{
    try {{
      final querySnapshot = await _firestore
          .collection({self.feature_class_name}DTO.collection)
          .where('createdBy', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final {self._to_camel_case(self.feature_name)}s = querySnapshot.docs.map((doc) {{
        final data = doc.data();
        data['id'] = doc.id;
        return {self.feature_class_name}DTO.fromJson(data);
      }}).toList();

      return Right({self._to_camel_case(self.feature_name)}s);
    }} catch (e) {{
      return Left(ServerFailure('Failed to get {self.feature_name}s: ${{e.toString()}}'));
    }}
  }}

  @override
  Future<Either<Failure, Unit>> create{self.feature_class_name}({self.feature_class_name}DTO {self._to_camel_case(self.feature_name)}DTO) async {{
    try {{
      final data = {self._to_camel_case(self.feature_name)}DTO.toJson();
      data.remove('id'); // Remove ID as Firestore generates it

      await _firestore
          .collection({self.feature_class_name}DTO.collection)
          .doc({self._to_camel_case(self.feature_name)}DTO.id)
          .set(data);

      return const Right(unit);
    }} catch (e) {{
      return Left(ServerFailure('Failed to create {self.feature_name}: ${{e.toString()}}'));
    }}
  }}

  @override
  Future<Either<Failure, Unit>> update{self.feature_class_name}({self.feature_class_name}DTO {self._to_camel_case(self.feature_name)}DTO) async {{
    try {{
      final data = {self._to_camel_case(self.feature_name)}DTO.toJson();
      data.remove('id'); // Remove ID as it's the document ID

      await _firestore
          .collection({self.feature_class_name}DTO.collection)
          .doc({self._to_camel_case(self.feature_name)}DTO.id)
          .update(data);

      return const Right(unit);
    }} catch (e) {{
      return Left(ServerFailure('Failed to update {self.feature_name}: ${{e.toString()}}'));
    }}
  }}

  @override
  Future<Either<Failure, Unit>> delete{self.feature_class_name}(String id) async {{
    try {{
      await _firestore
          .collection({self.feature_class_name}DTO.collection)
          .doc(id)
          .delete();

      return const Right(unit);
    }} catch (e) {{
      return Left(ServerFailure('Failed to delete {self.feature_name}: ${{e.toString()}}'));
    }}
  }}
}}
"""

    def generate_bloc_event(self) -> str:
        """Generate BLoC event template."""
        return f"""import 'package:equatable/equatable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';

abstract class {self.feature_class_name}Event extends Equatable {{
  const {self.feature_class_name}Event();

  @override
  List<Object?> get props => [];
}}

class Watch{self.feature_class_name}sByUserEvent extends {self.feature_class_name}Event {{
  final UserId userId;

  const Watch{self.feature_class_name}sByUserEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}}

class Create{self.feature_class_name}Event extends {self.feature_class_name}Event {{
  final String name;
  final String description;

  const Create{self.feature_class_name}Event({{
    required this.name,
    required this.description,
  }});

  @override
  List<Object?> get props => [name, description];
}}

class Update{self.feature_class_name}Event extends {self.feature_class_name}Event {{
  final {self.feature_class_name} {self._to_camel_case(self.feature_name)};

  const Update{self.feature_class_name}Event(this.{self._to_camel_case(self.feature_name)});

  @override
  List<Object?> get props => [{self._to_camel_case(self.feature_name)}];
}}

class Delete{self.feature_class_name}Event extends {self.feature_class_name}Event {{
  final {self.feature_class_name}Id {self._to_camel_case(self.feature_name)}Id;

  const Delete{self.feature_class_name}Event(this.{self._to_camel_case(self.feature_name)}Id);

  @override
  List<Object?> get props => [{self._to_camel_case(self.feature_name)}Id];
}}

class {self.feature_class_name}sUpdatedEvent extends {self.feature_class_name}Event {{
  final List<{self.feature_class_name}> {self._to_camel_case(self.feature_name)}s;

  const {self.feature_class_name}sUpdatedEvent(this.{self._to_camel_case(self.feature_name)}s);

  @override
  List<Object?> get props => [{self._to_camel_case(self.feature_name)}s];
}}
"""

    def generate_bloc_state(self) -> str:
        """Generate BLoC state template."""
        return f"""import 'package:equatable/equatable.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';

abstract class {self.feature_class_name}State extends Equatable {{
  const {self.feature_class_name}State();

  @override
  List<Object?> get props => [];
}}

class {self.feature_class_name}Initial extends {self.feature_class_name}State {{
  const {self.feature_class_name}Initial();
}}

class {self.feature_class_name}Loading extends {self.feature_class_name}State {{
  const {self.feature_class_name}Loading();
}}

class {self.feature_class_name}sLoaded extends {self.feature_class_name}State {{
  final List<{self.feature_class_name}> {self._to_camel_case(self.feature_name)}s;
  final bool isSyncing;
  final double? syncProgress;

  const {self.feature_class_name}sLoaded({{
    required this.{self._to_camel_case(self.feature_name)}s,
    this.isSyncing = false,
    this.syncProgress,
  }});

  @override
  List<Object?> get props => [{self._to_camel_case(self.feature_name)}s, isSyncing, syncProgress];

  {self.feature_class_name}sLoaded copyWith({{
    List<{self.feature_class_name}>? {self._to_camel_case(self.feature_name)}s,
    bool? isSyncing,
    double? syncProgress,
  }}) {{
    return {self.feature_class_name}sLoaded(
      {self._to_camel_case(self.feature_name)}s: {self._to_camel_case(self.feature_name)}s ?? this.{self._to_camel_case(self.feature_name)}s,
      isSyncing: isSyncing ?? this.isSyncing,
      syncProgress: syncProgress ?? this.syncProgress,
    );
  }}
}}

class {self.feature_class_name}OperationSuccess extends {self.feature_class_name}State {{
  final String message;

  const {self.feature_class_name}OperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}}

class {self.feature_class_name}Error extends {self.feature_class_name}State {{
  final String message;

  const {self.feature_class_name}Error(this.message);

  @override
  List<Object?> get props => [message];
}}
"""

    def generate_bloc(self) -> str:
        """Generate BLoC template."""
        return f"""import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/create_{self.feature_name}_usecase.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/update_{self.feature_name}_usecase.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/delete_{self.feature_name}_usecase.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/watch_{self.feature_name}s_by_user_usecase.dart';
import '{self.feature_name}_event.dart';
import '{self.feature_name}_state.dart';

@injectable
class {self.feature_class_name}Bloc extends Bloc<{self.feature_class_name}Event, {self.feature_class_name}State> {{
  final Create{self.feature_class_name}UseCase _create{self.feature_class_name}UseCase;
  final Update{self.feature_class_name}UseCase _update{self.feature_class_name}UseCase;
  final Delete{self.feature_class_name}UseCase _delete{self.feature_class_name}UseCase;
  final Watch{self.feature_class_name}sByUserUseCase _watch{self.feature_class_name}sByUserUseCase;
  final SessionStorage _sessionStorage;

  StreamSubscription<Either<Failure, List<{self.feature_class_name}>>>? _{self._to_camel_case(self.feature_name)}sSubscription;
  List<{self.feature_class_name}> _current{self.feature_class_name}s = [];

  {self.feature_class_name}Bloc({{
    required Create{self.feature_class_name}UseCase create{self.feature_class_name}UseCase,
    required Update{self.feature_class_name}UseCase update{self.feature_class_name}UseCase,
    required Delete{self.feature_class_name}UseCase delete{self.feature_class_name}UseCase,
    required Watch{self.feature_class_name}sByUserUseCase watch{self.feature_class_name}sByUserUseCase,
    required SessionStorage sessionStorage,
  }}) : _create{self.feature_class_name}UseCase = create{self.feature_class_name}UseCase,
        _update{self.feature_class_name}UseCase = update{self.feature_class_name}UseCase,
        _delete{self.feature_class_name}UseCase = delete{self.feature_class_name}UseCase,
        _watch{self.feature_class_name}sByUserUseCase = watch{self.feature_class_name}sByUserUseCase,
        _sessionStorage = sessionStorage,
        super(const {self.feature_class_name}Initial()) {{
    on<Watch{self.feature_class_name}sByUserEvent>(_onWatch{self.feature_class_name}sByUser);
    on<Create{self.feature_class_name}Event>(_onCreate{self.feature_class_name});
    on<Update{self.feature_class_name}Event>(_onUpdate{self.feature_class_name});
    on<Delete{self.feature_class_name}Event>(_onDelete{self.feature_class_name});
    on<{self.feature_class_name}sUpdatedEvent>(_on{self.feature_class_name}sUpdated);
  }}

  void _onWatch{self.feature_class_name}sByUser(
    Watch{self.feature_class_name}sByUserEvent event,
    Emitter<{self.feature_class_name}State> emit,
  ) async {{
    await _{self._to_camel_case(self.feature_name)}sSubscription?.cancel();
    emit(const {self.feature_class_name}Loading());

    _{self._to_camel_case(self.feature_name)}sSubscription = _watch{self.feature_class_name}sByUserUseCase
        .call(Watch{self.feature_class_name}sByUserParams(userId: event.userId))
        .listen((either) {{
          either.fold(
            (failure) => add({self.feature_class_name}sUpdatedEvent([])),
            ({self._to_camel_case(self.feature_name)}s) => add({self.feature_class_name}sUpdatedEvent({self._to_camel_case(self.feature_name)}s)),
          );
        }});
  }}

  Future<void> _onCreate{self.feature_class_name}(
    Create{self.feature_class_name}Event event,
    Emitter<{self.feature_class_name}State> emit,
  ) async {{
    emit(const {self.feature_class_name}Loading());

    final userId = await _sessionStorage.getUserId();
    if (userId == null) {{
      emit(const {self.feature_class_name}Error('User not authenticated'));
      return;
    }}

    final result = await _create{self.feature_class_name}UseCase.call(
      Create{self.feature_class_name}Params(
        name: event.name,
        description: event.description,
        createdBy: UserId.fromUniqueString(userId),
      ),
    );

    result.fold(
      (failure) => emit({self.feature_class_name}Error(failure.message)),
      (_) => emit(const {self.feature_class_name}OperationSuccess('{self.feature_class_name} created successfully')),
    );
  }}

  Future<void> _onUpdate{self.feature_class_name}(
    Update{self.feature_class_name}Event event,
    Emitter<{self.feature_class_name}State> emit,
  ) async {{
    emit(const {self.feature_class_name}Loading());

    final result = await _update{self.feature_class_name}UseCase.call(
      Update{self.feature_class_name}Params({self._to_camel_case(self.feature_name)}: event.{self._to_camel_case(self.feature_name)}),
    );

    result.fold(
      (failure) => emit({self.feature_class_name}Error(failure.message)),
      (_) => emit(const {self.feature_class_name}OperationSuccess('{self.feature_class_name} updated successfully')),
    );
  }}

  Future<void> _onDelete{self.feature_class_name}(
    Delete{self.feature_class_name}Event event,
    Emitter<{self.feature_class_name}State> emit,
  ) async {{
    emit(const {self.feature_class_name}Loading());

    final result = await _delete{self.feature_class_name}UseCase.call(
      Delete{self.feature_class_name}Params({self._to_camel_case(self.feature_name)}Id: event.{self._to_camel_case(self.feature_name)}Id),
    );

    result.fold(
      (failure) => emit({self.feature_class_name}Error(failure.message)),
      (_) => emit(const {self.feature_class_name}OperationSuccess('{self.feature_class_name} deleted successfully')),
    );
  }}

  void _on{self.feature_class_name}sUpdated(
    {self.feature_class_name}sUpdatedEvent event,
    Emitter<{self.feature_class_name}State> emit,
  ) {{
    _current{self.feature_class_name}s = event.{self._to_camel_case(self.feature_name)}s;
    
    emit({self.feature_class_name}sLoaded(
      {self._to_camel_case(self.feature_name)}s: _current{self.feature_class_name}s,
      isSyncing: false,
      syncProgress: null,
    ));
  }}

  @override
  Future<void> close() {{
    _{self._to_camel_case(self.feature_name)}sSubscription?.cancel();
    return super.close();
  }}
}}
"""

    def generate_entity_test(self) -> str:
        """Generate entity test template."""
        return f"""import 'package:flutter_test/flutter_test.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';

void main() {{
  group('{self.feature_class_name} Entity Tests', () {{
    late {self.feature_class_name} test{self.feature_class_name};
    late UserId userId;

    setUp(() {{
      userId = UserId.fromUniqueString('user-123');
      
      test{self.feature_class_name} = {self.feature_class_name}(
        id: {self.feature_class_name}Id.fromUniqueString('{self.feature_name}-123'),
        name: 'Test {self.feature_class_name}',
        description: 'Test Description',
        createdBy: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }});

    group('factory constructor', () {{
      test('should create {self.feature_name} with generated ID and timestamps', () {{
        // Act
        final {self._to_camel_case(self.feature_name)} = {self.feature_class_name}.create(
          name: 'New {self.feature_class_name}',
          description: 'New Description',
          createdBy: userId,
        );

        // Assert
        expect({self._to_camel_case(self.feature_name)}.name, 'New {self.feature_class_name}');
        expect({self._to_camel_case(self.feature_name)}.description, 'New Description');
        expect({self._to_camel_case(self.feature_name)}.createdBy, userId);
        expect({self._to_camel_case(self.feature_name)}.id.value, isNotEmpty);
        expect({self._to_camel_case(self.feature_name)}.createdAt, isA<DateTime>());
        expect({self._to_camel_case(self.feature_name)}.updatedAt, isA<DateTime>());
      }});
    }});

    group('copyWith', () {{
      test('should return new instance with updated values', () {{
        // Act
        final updated{self.feature_class_name} = test{self.feature_class_name}.copyWith(
          name: 'Updated Name',
          description: 'Updated Description',
        );

        // Assert
        expect(updated{self.feature_class_name}.name, 'Updated Name');
        expect(updated{self.feature_class_name}.description, 'Updated Description');
        expect(updated{self.feature_class_name}.id, test{self.feature_class_name}.id);
        expect(updated{self.feature_class_name}.createdBy, test{self.feature_class_name}.createdBy);
      }});

      test('should return same instance if no values changed', () {{
        // Act
        final copied{self.feature_class_name} = test{self.feature_class_name}.copyWith();

        // Assert
        expect(copied{self.feature_class_name}.name, test{self.feature_class_name}.name);
        expect(copied{self.feature_class_name}.description, test{self.feature_class_name}.description);
        expect(copied{self.feature_class_name}.id, test{self.feature_class_name}.id);
      }});
    }});

    group('isOwnedBy', () {{
      test('should return true when user is owner', () {{
        // Act & Assert
        expect(test{self.feature_class_name}.isOwnedBy(userId), true);
      }});

      test('should return false when user is not owner', () {{
        // Arrange
        final otherUserId = UserId.fromUniqueString('other-user-456');

        // Act & Assert
        expect(test{self.feature_class_name}.isOwnedBy(otherUserId), false);
      }});
    }});

    group('equality', () {{
      test('should be equal when IDs are the same', () {{
        // Arrange
        final other{self.feature_class_name} = {self.feature_class_name}(
          id: test{self.feature_class_name}.id,
          name: 'Different Name',
          description: 'Different Description',
          createdBy: UserId.fromUniqueString('different-user'),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Act & Assert
        expect(test{self.feature_class_name}, equals(other{self.feature_class_name}));
        expect(test{self.feature_class_name}.hashCode, equals(other{self.feature_class_name}.hashCode));
      }});

      test('should not be equal when IDs are different', () {{
        // Arrange
        final other{self.feature_class_name} = {self.feature_class_name}(
          id: {self.feature_class_name}Id.fromUniqueString('different-id'),
          name: test{self.feature_class_name}.name,
          description: test{self.feature_class_name}.description,
          createdBy: test{self.feature_class_name}.createdBy,
          createdAt: test{self.feature_class_name}.createdAt,
          updatedAt: test{self.feature_class_name}.updatedAt,
        );

        // Act & Assert
        expect(test{self.feature_class_name}, isNot(equals(other{self.feature_class_name})));
      }});
    }});
  }});
}}
"""

    def generate_bloc_test(self) -> str:
        """Generate BLoC test template."""
        return f"""import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/{self.feature_name}/domain/entities/{self.feature_name}.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/create_{self.feature_name}_usecase.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/update_{self.feature_name}_usecase.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/delete_{self.feature_name}_usecase.dart';
import 'package:trackflow/features/{self.feature_name}/domain/usecases/watch_{self.feature_name}s_by_user_usecase.dart';
import 'package:trackflow/features/{self.feature_name}/presentation/bloc/{self.feature_name}_bloc.dart';
import 'package:trackflow/features/{self.feature_name}/presentation/bloc/{self.feature_name}_event.dart';
import 'package:trackflow/features/{self.feature_name}/presentation/bloc/{self.feature_name}_state.dart';

import '{self.feature_name}_bloc_test.mocks.dart';

@GenerateMocks([
  Create{self.feature_class_name}UseCase,
  Update{self.feature_class_name}UseCase,
  Delete{self.feature_class_name}UseCase,
  Watch{self.feature_class_name}sByUserUseCase,
  SessionStorage,
])
void main() {{
  group('{self.feature_class_name}Bloc', () {{
    late {self.feature_class_name}Bloc {self._to_camel_case(self.feature_name)}Bloc;
    late MockCreate{self.feature_class_name}UseCase mockCreate{self.feature_class_name}UseCase;
    late MockUpdate{self.feature_class_name}UseCase mockUpdate{self.feature_class_name}UseCase;
    late MockDelete{self.feature_class_name}UseCase mockDelete{self.feature_class_name}UseCase;
    late MockWatch{self.feature_class_name}sByUserUseCase mockWatch{self.feature_class_name}sByUserUseCase;
    late MockSessionStorage mockSessionStorage;

    setUp(() {{
      mockCreate{self.feature_class_name}UseCase = MockCreate{self.feature_class_name}UseCase();
      mockUpdate{self.feature_class_name}UseCase = MockUpdate{self.feature_class_name}UseCase();
      mockDelete{self.feature_class_name}UseCase = MockDelete{self.feature_class_name}UseCase();
      mockWatch{self.feature_class_name}sByUserUseCase = MockWatch{self.feature_class_name}sByUserUseCase();
      mockSessionStorage = MockSessionStorage();

      {self._to_camel_case(self.feature_name)}Bloc = {self.feature_class_name}Bloc(
        create{self.feature_class_name}UseCase: mockCreate{self.feature_class_name}UseCase,
        update{self.feature_class_name}UseCase: mockUpdate{self.feature_class_name}UseCase,
        delete{self.feature_class_name}UseCase: mockDelete{self.feature_class_name}UseCase,
        watch{self.feature_class_name}sByUserUseCase: mockWatch{self.feature_class_name}sByUserUseCase,
        sessionStorage: mockSessionStorage,
      );
    }});

    tearDown(() {{
      {self._to_camel_case(self.feature_name)}Bloc.close();
    }});

    test('initial state is {self.feature_class_name}Initial', () {{
      expect({self._to_camel_case(self.feature_name)}Bloc.state, equals(const {self.feature_class_name}Initial()));
    }});

    group('Create{self.feature_class_name}Event', () {{
      const testName = 'Test {self.feature_class_name}';
      const testDescription = 'Test Description';
      const testUserId = 'user-123';

      blocTest<{self.feature_class_name}Bloc, {self.feature_class_name}State>(
        'emits [{self.feature_class_name}Loading, {self.feature_class_name}OperationSuccess] when creation succeeds',
        build: () {{
          when(mockSessionStorage.getUserId())
              .thenAnswer((_) async => testUserId);
          when(mockCreate{self.feature_class_name}UseCase.call(any))
              .thenAnswer((_) async => const Right(unit));
          return {self._to_camel_case(self.feature_name)}Bloc;
        }},
        act: (bloc) => bloc.add(const Create{self.feature_class_name}Event(
          name: testName,
          description: testDescription,
        )),
        expect: () => [
          const {self.feature_class_name}Loading(),
          const {self.feature_class_name}OperationSuccess('{self.feature_class_name} created successfully'),
        ],
        verify: (_) {{
          verify(mockSessionStorage.getUserId()).called(1);
          verify(mockCreate{self.feature_class_name}UseCase.call(any)).called(1);
        }},
      );

      blocTest<{self.feature_class_name}Bloc, {self.feature_class_name}State>(
        'emits [{self.feature_class_name}Loading, {self.feature_class_name}Error] when user is not authenticated',
        build: () {{
          when(mockSessionStorage.getUserId())
              .thenAnswer((_) async => null);
          return {self._to_camel_case(self.feature_name)}Bloc;
        }},
        act: (bloc) => bloc.add(const Create{self.feature_class_name}Event(
          name: testName,
          description: testDescription,
        )),
        expect: () => [
          const {self.feature_class_name}Loading(),
          const {self.feature_class_name}Error('User not authenticated'),
        ],
        verify: (_) {{
          verify(mockSessionStorage.getUserId()).called(1);
          verifyNever(mockCreate{self.feature_class_name}UseCase.call(any));
        }},
      );

      blocTest<{self.feature_class_name}Bloc, {self.feature_class_name}State>(
        'emits [{self.feature_class_name}Loading, {self.feature_class_name}Error] when creation fails',
        build: () {{
          when(mockSessionStorage.getUserId())
              .thenAnswer((_) async => testUserId);
          when(mockCreate{self.feature_class_name}UseCase.call(any))
              .thenAnswer((_) async => const Left(ServerFailure('Creation failed')));
          return {self._to_camel_case(self.feature_name)}Bloc;
        }},
        act: (bloc) => bloc.add(const Create{self.feature_class_name}Event(
          name: testName,
          description: testDescription,
        )),
        expect: () => [
          const {self.feature_class_name}Loading(),
          const {self.feature_class_name}Error('Creation failed'),
        ],
      );
    }});

    group('Watch{self.feature_class_name}sByUserEvent', () {{
      final testUserId = UserId.fromUniqueString('user-123');
      final test{self.feature_class_name}s = [
        {self.feature_class_name}.create(
          name: 'Test {self.feature_class_name} 1',
          description: 'Description 1',
          createdBy: testUserId,
        ),
        {self.feature_class_name}.create(
          name: 'Test {self.feature_class_name} 2',
          description: 'Description 2',
          createdBy: testUserId,
        ),
      ];

      blocTest<{self.feature_class_name}Bloc, {self.feature_class_name}State>(
        'emits [{self.feature_class_name}Loading, {self.feature_class_name}sLoaded] when watching succeeds',
        build: () {{
          when(mockWatch{self.feature_class_name}sByUserUseCase.call(any))
              .thenAnswer((_) => Stream.value(Right(test{self.feature_class_name}s)));
          return {self._to_camel_case(self.feature_name)}Bloc;
        }},
        act: (bloc) => bloc.add(Watch{self.feature_class_name}sByUserEvent(testUserId)),
        expect: () => [
          const {self.feature_class_name}Loading(),
          {self.feature_class_name}sLoaded(
            {self._to_camel_case(self.feature_name)}s: test{self.feature_class_name}s,
            isSyncing: false,
            syncProgress: null,
          ),
        ],
      );

      blocTest<{self.feature_class_name}Bloc, {self.feature_class_name}State>(
        'emits [{self.feature_class_name}Loading, {self.feature_class_name}sLoaded] with empty list when watching fails',
        build: () {{
          when(mockWatch{self.feature_class_name}sByUserUseCase.call(any))
              .thenAnswer((_) => Stream.value(const Left(ServerFailure('Watch failed'))));
          return {self._to_camel_case(self.feature_name)}Bloc;
        }},
        act: (bloc) => bloc.add(Watch{self.feature_class_name}sByUserEvent(testUserId)),
        expect: () => [
          const {self.feature_class_name}Loading(),
          const {self.feature_class_name}sLoaded(
            {self._to_camel_case(self.feature_name)}s: [],
            isSyncing: false,
            syncProgress: null,
          ),
        ],
      );
    }});
  }});
}}
"""

    def generate_all_files(self, skip_presentation: bool = False, with_tests: bool = False) -> None:
        """Generate all feature files."""
        print(f"🚀 Generating feature '{self.feature_name}' with Clean Architecture + DDD structure...")
        
        # Domain layer
        print("\n📋 Generating Domain Layer...")
        self._create_file(
            self.feature_root / "domain" / "entities" / f"{self.feature_name}.dart",
            self.generate_domain_entity()
        )
        
        # Value objects (optional - can be customized)
        value_objects = ["name", "description"]  # Common value objects
        for vo in value_objects:
            self._create_file(
                self.feature_root / "domain" / "value_objects" / f"{self.feature_name}_{vo}.dart",
                self.generate_value_object(f"{self.feature_name}_{vo}")
            )
        
        # Repository contract
        self._create_file(
            self.feature_root / "domain" / "repositories" / f"{self.feature_name}_repository.dart",
            self.generate_repository_contract()
        )
        
        # Use cases
        use_cases = [
            ("create", "command"),
            ("update", "command"), 
            ("delete", "command"),
            ("watch_by_user", "query"),
            ("get_by_id", "query")
        ]
        
        for uc_name, uc_type in use_cases:
            uc_file_name = f"{uc_name}_{self.feature_name}_usecase.dart"
            if uc_name == "watch_by_user":
                uc_file_name = f"watch_{self.feature_name}s_by_user_usecase.dart"
            elif uc_name == "get_by_id":
                uc_file_name = f"get_{self.feature_name}_by_id_usecase.dart"
                
            self._create_file(
                self.feature_root / "domain" / "usecases" / uc_file_name,
                self.generate_usecase(f"{uc_name}_{self.feature_name}", uc_type)
            )
        
        # Data layer
        print("\n💾 Generating Data Layer...")
        self._create_file(
            self.feature_root / "data" / "models" / f"{self.feature_name}_dto.dart",
            self.generate_data_model()
        )
        
        self._create_file(
            self.feature_root / "data" / "models" / f"{self.feature_name}_document.dart",
            self.generate_isar_model()
        )
        
        self._create_file(
            self.feature_root / "data" / "datasources" / f"{self.feature_name}_local_datasource.dart",
            self.generate_local_datasource()
        )
        
        self._create_file(
            self.feature_root / "data" / "datasources" / f"{self.feature_name}_remote_datasource.dart",
            self.generate_remote_datasource()
        )
        
        self._create_file(
            self.feature_root / "data" / "repositories" / f"{self.feature_name}_repository_impl.dart",
            self.generate_repository_impl()
        )
        
        # Presentation layer
        if not skip_presentation:
            print("\n🎨 Generating Presentation Layer...")
            self._create_file(
                self.feature_root / "presentation" / "bloc" / f"{self.feature_name}_event.dart",
                self.generate_bloc_event()
            )
            
            self._create_file(
                self.feature_root / "presentation" / "bloc" / f"{self.feature_name}_state.dart",
                self.generate_bloc_state()
            )
            
            self._create_file(
                self.feature_root / "presentation" / "bloc" / f"{self.feature_name}_bloc.dart",
                self.generate_bloc()
            )
        
        # Test files
        if with_tests:
            print("\n🧪 Generating Test Files...")
            test_root = self.project_root / "test" / "features" / self.feature_name
            
            self._create_file(
                test_root / "domain" / "entities" / f"{self.feature_name}_test.dart",
                self.generate_entity_test()
            )
            
            if not skip_presentation:
                self._create_file(
                    test_root / "presentation" / "bloc" / f"{self.feature_name}_bloc_test.dart",  
                    self.generate_bloc_test()
                )
        
        print(f"\n✅ Feature '{self.feature_name}' generated successfully!")
        print(f"📁 Generated files in: {self.feature_root}")
        
        # Next steps
        print(f"\n📝 Next Steps:")
        print(f"1. Run: flutter packages pub run build_runner build --delete-conflicting-outputs")
        print(f"2. Add {self.feature_class_name}DocumentSchema to app_module.dart")
        print(f"3. Customize the generated entities and value objects as needed")
        print(f"4. Implement the TODO sections in use cases")
        print(f"5. Create UI screens and widgets in presentation/screens/")
        print(f"6. Write comprehensive tests")

def main():
    parser = argparse.ArgumentParser(
        description="Generate TrackFlow feature boilerplate with Clean Architecture + DDD",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python generate_feature.py notifications
  python generate_feature.py user_settings --with-tests
  python generate_feature.py analytics --skip-presentation
        """
    )
    
    parser.add_argument(
        "feature_name",
        help="Name of the feature to generate (snake_case)"
    )
    
    parser.add_argument(
        "--skip-presentation", 
        action="store_true",
        help="Skip generating presentation layer (BLoC files)"
    )
    
    parser.add_argument(
        "--with-tests", 
        action="store_true",
        help="Generate test files"
    )
    
    parser.add_argument(
        "--project-root",
        type=Path,
        help="Path to project root (default: current directory)"
    )
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
    
    args = parser.parse_args()
    
    # Validate feature name
    if not re.match(r'^[a-z_]+$', args.feature_name):
        print("❌ Error: Feature name must be in snake_case (lowercase with underscores)")
        return
    
    # Check if we're in a Flutter project
    project_root = args.project_root or Path.cwd()
    if not (project_root / "pubspec.yaml").exists():
        print("❌ Error: Not in a Flutter project root (pubspec.yaml not found)")
        return
    
    # Generate the feature
    try:
        generator = FeatureGenerator(args.feature_name, project_root)
        generator.generate_all_files(
            skip_presentation=args.skip_presentation,
            with_tests=args.with_tests
        )
    except Exception as e:
        print(f"❌ Error generating feature: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())