import 'package:injectable/injectable.dart';
import 'package:trackflow/core/session/data/session_storage.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_local_datasource.dart';
import 'package:trackflow/features/user_profile/data/datasources/user_profile_remote_datasource.dart';

@lazySingleton
class SyncUserProfileUseCase {
  final UserProfileRemoteDataSource remote;
  final UserProfileLocalDataSource local;
  final SessionStorage sessionStorage;

  SyncUserProfileUseCase(this.remote, this.local, this.sessionStorage);

  Future<void> call() async {
    final userId =
        await sessionStorage
            .getUserId(); // Now async - prevents race conditions
    if (userId == null) {
      // DON'T clear cache - preserve existing data when no userId
      return;
    }

    final failureOrProfile = await remote.getProfileById(userId);
    await failureOrProfile.fold(
      (failure) async {
        // Don't clear cache if remote fetch fails - preserve existing data
        print('Error syncing user profile: $failure');
      },
      (profileDTO) async {
        // Only clear cache when we have new data to replace it
        await local.clearCache();
        await local.cacheUserProfile(profileDTO);
      },
    );
  }
}
