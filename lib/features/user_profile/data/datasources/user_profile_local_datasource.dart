import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

abstract class UserProfileLocalDataSource {
  Future<void> cacheUserProfile(UserProfileDTO profile);
  Stream<UserProfileDTO?> watchUserProfile(String userId);
}

@LazySingleton(as: UserProfileLocalDataSource)
class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  late final Box<Map> _box;
  UserProfileLocalDataSourceImpl(@Named('userProfilesBox') this._box);

  @override
  Future<void> cacheUserProfile(UserProfileDTO profile) async {
    await _box.put(profile.id, profile.toJson());
  }

  @override
  Stream<UserProfileDTO?> watchUserProfile(String userId) {
    return _box.watch(key: userId).map((_) {
      final map = _box.get(userId);
      if (map != null) {
        return UserProfileDTO.fromJson(map.cast<String, dynamic>());
      }
      return null;
    });
  }
}
