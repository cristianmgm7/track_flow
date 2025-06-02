import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';

abstract class UserProfileRemoteDataSource {
  Future<Either<Failure, UserProfile>> getProfilesByIds(String userId);
  Future<void> updateProfile(UserProfileDTO profile);
}

@LazySingleton(as: UserProfileRemoteDataSource)
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserProfileRemoteDataSourceImpl(this._firestore);

  @override
  Future<Either<Failure, UserProfile>> getProfilesByIds(String userId) async {
    try {
      final query =
          await _firestore
              .collection(UserProfileDTO.collection)
              .doc(userId)
              .get();
      debugPrint(query.data().toString());

      if (!query.exists) {
        return left(DatabaseFailure('User profile not found for ID: $userId'));
      }

      return right(UserProfileDTO.fromJson(query.data()!).toDomain());
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'An error occurred'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<void> updateProfile(UserProfileDTO profile) async {
    await _firestore
        .collection(UserProfileDTO.collection)
        .doc(profile.id)
        .update(profile.toJson());
  }
}
