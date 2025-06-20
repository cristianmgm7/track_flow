import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

@lazySingleton
class WatchUserProfileUseCase {
  final UserProfileLocalDataSource local;
  final SessionStorage sessionStorage;

  WatchUserProfileUseCase(this.local, this.sessionStorage);

  Stream<UserProfile?> call() {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return Stream.value(null);
    }
    return local.watchUserProfile(userId).map((dto) => dto?.toDomain());
  }
}
