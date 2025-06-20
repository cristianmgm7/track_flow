import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

abstract class UserProfileLocalDataSource {
  Future<void> cacheUserProfile(UserProfileDTO profile);
  Stream<UserProfileDTO?> watchUserProfile(String userId);
}

@LazySingleton(as: UserProfileLocalDataSource)
class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  final Box<UserProfileDTO> _box;
  UserProfileLocalDataSourceImpl(this._box);

  @override
  Future<void> cacheUserProfile(UserProfileDTO profile) async {
    await _box.put(profile.id, profile);
  }

  @override
  Stream<UserProfileDTO?> watchUserProfile(String userId) {
    return _box.watch(key: userId).map((_) => _box.get(userId));
  }
}
