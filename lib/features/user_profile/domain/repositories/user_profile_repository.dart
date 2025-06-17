import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, UserProfile>> getUserProfile(UserId userId);
  Future<Either<Failure, void>> updateUserProfile(UserProfile userProfile);

  //   // fetch user by id
  //         // remote.fetchUserById
  //         // local.saveUserProfile
  //   // watch my user profile
  //         // loca.watchUserById

  //   //
}


// StartupResourceManager

//  initializeAppData(){
//   // 1. fetch user profile
//   // 2. fetch projects
//   // 3. fetch contacts
//  }


//  refresh()