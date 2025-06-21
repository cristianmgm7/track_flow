import 'package:dartz/dartz.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Either<Failure, void>> updateUserProfile(UserProfile userProfile);

  Stream<Either<Failure, UserProfile?>> watchUserProfile(UserId userId);
}
