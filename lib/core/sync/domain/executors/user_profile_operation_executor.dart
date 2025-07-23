import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/sync/data/models/sync_operation_document.dart';
import 'package:trackflow/core/sync/domain/executors/operation_executor.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

/// Handles sync operations for UserProfile entities
/// 
/// This executor is responsible for translating sync operations
/// into appropriate calls to the UserProfileRemoteDataSource.
@injectable
class UserProfileOperationExecutor implements OperationExecutor {
  final UserProfileRemoteDataSource _remoteDataSource;

  UserProfileOperationExecutor(this._remoteDataSource);

  @override
  String get entityType => 'user_profile';

  @override
  Future<void> execute(SyncOperationDocument operation) async {
    final operationData = operation.operationData != null 
        ? jsonDecode(operation.operationData!) as Map<String, dynamic>
        : <String, dynamic>{};

    switch (operation.operationType) {
      case 'update':
        await _executeUpdate(operation, operationData);
        break;
        
      default:
        throw UnsupportedError('Unknown user profile operation: ${operation.operationType}');
    }
  }

  /// Execute user profile update
  /// Note: User profiles are typically only updated, not created or deleted
  Future<void> _executeUpdate(
    SyncOperationDocument operation, 
    Map<String, dynamic> operationData,
  ) async {
    final userProfileDto = UserProfileDTO(
      id: operation.entityId,
      name: operationData['name'] ?? '',
      email: operationData['email'] ?? '',
      avatarUrl: operationData['avatarUrl'] ?? '',
      createdAt: operationData['createdAt'] != null 
          ? DateTime.parse(operationData['createdAt'])
          : DateTime.now(),
      updatedAt: operationData['updatedAt'] != null 
          ? DateTime.parse(operationData['updatedAt'])
          : DateTime.now(),
      creativeRole: _parseCreativeRole(operationData['creativeRole']),
    );
    
    final result = await _remoteDataSource.updateProfile(userProfileDto);
    result.fold(
      (failure) => throw Exception('Profile update failed: ${failure.message}'),
      (_) {
        // Successfully updated
      },
    );
  }

  /// Parse creative role from string
  CreativeRole _parseCreativeRole(String? roleName) {
    if (roleName == null) {
      return CreativeRole.other;
    }
    try {
      return CreativeRole.values.byName(roleName);
    } catch (e) {
      return CreativeRole.other;
    }
  }
}