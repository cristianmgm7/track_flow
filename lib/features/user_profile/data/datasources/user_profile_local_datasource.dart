import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/projects/data/models/project_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_document.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

abstract class UserProfileLocalDataSource {
  Future<void> cacheUserProfile(UserProfileDTO profile);
  Stream<UserProfileDTO?> watchUserProfile(String userId);
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
}
