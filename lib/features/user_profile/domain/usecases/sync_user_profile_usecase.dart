import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/session_storage.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';

@lazySingleton
class SyncUserProfileUseCase {
  final UserProfileRemoteDataSource remote;
  final UserProfileLocalDataSource local;
  final SessionStorage sessionStorage;

  SyncUserProfileUseCase(this.remote, this.local, this.sessionStorage);

  Future<void> call() async {
    final userId = sessionStorage.getUserId();
    if (userId == null) {
      return;
    }
    final failureOrProfile = await remote.getProfileById(userId);
    await failureOrProfile.fold((failure) async {}, (profileDTO) async {
      await local.cacheUserProfile(profileDTO);
    });
  }
}
