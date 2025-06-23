import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

abstract class UserProfileLocalDataSource {
  Future<void> cacheUserProfile(UserProfileDTO profile);
  Stream<UserProfileDTO?> watchUserProfile(String userId);

  /// Obtiene múltiples perfiles de usuario por sus IDs (one-shot)
  Future<List<UserProfileDTO>> getUserProfilesByIds(List<String> userIds);

  /// Observa múltiples perfiles de usuario por sus IDs (stream reactivo)
  Stream<Either<Failure, List<UserProfileDTO>>> watchUserProfilesByIds(
    List<String> userIds,
  );

  Future<void> clearCache();
}

@LazySingleton(as: UserProfileLocalDataSource)
class IsarUserProfileLocalDataSource implements UserProfileLocalDataSource {
  final Isar _isar;

  IsarUserProfileLocalDataSource(this._isar);

  @override
  Future<void> cacheUserProfile(UserProfileDTO profile) async {
    final profileDoc = UserProfileDocument.fromDTO(profile);
    await _isar.writeTxn(() async {
      await _isar.userProfileDocuments.put(profileDoc);
    });
  }

  @override
  Stream<UserProfileDTO?> watchUserProfile(String userId) {
    return _isar.userProfileDocuments
        .watchObject(fastHash(userId), fireImmediately: true)
        .map((doc) => doc?.toDTO());
  }

  @override
  Future<List<UserProfileDTO>> getUserProfilesByIds(
    List<String> userIds,
  ) async {
    final docs = await _isar.userProfileDocuments.getAllById(userIds);
    return docs.whereType<UserProfileDocument>().map((e) => e.toDTO()).toList();
  }

  @override
  Stream<Either<Failure, List<UserProfileDTO>>> watchUserProfilesByIds(
    List<String> userIds,
  ) {
    // Observa todos los cambios en la colección y filtra por los IDs dados
    return _isar.userProfileDocuments.watchLazy().asyncMap((_) async {
      final docs = await _isar.userProfileDocuments.getAllById(userIds);
      return right<Failure, List<UserProfileDTO>>(
        docs.whereType<UserProfileDocument>().map((e) => e.toDTO()).toList(),
      );
    });
  }

  @override
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.userProfileDocuments.clear();
    });
  }
}
