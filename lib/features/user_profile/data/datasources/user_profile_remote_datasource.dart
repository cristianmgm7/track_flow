import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';
import 'package:trackflow/features/user_profile/domain/entities/user_profile.dart';
import 'dart:io';

abstract class UserProfileRemoteDataSource {
  Future<Either<Failure, UserProfile>> getProfilesByIds(String userId);
  Future<void> updateProfile(UserProfileDTO profile);
}

@LazySingleton(as: UserProfileRemoteDataSource)
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserProfileRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, UserProfile>> getProfilesByIds(String userId) async {
    try {
      final query =
          await _firestore
              .collection(UserProfileDTO.collection)
              .doc(userId)
              .get();

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
  Future<Either<Failure, void>> updateProfile(UserProfileDTO profile) async {
    try {
      String avatarUrl = profile.avatarUrl;
      // Si el avatarUrl es una ruta local, sube la imagen
      if (avatarUrl.isNotEmpty && !avatarUrl.startsWith('http')) {
        final url = await _uploadAvatar(profile.id, avatarUrl);
        if (url != null) {
          avatarUrl = url;
          profile = profile.copyWith(avatarUrl: avatarUrl);
        }
      }
      await _firestore
          .collection(UserProfileDTO.collection)
          .doc(profile.id)
          .update(profile.toJson());
      return right(null);
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'An error occurred'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  Future<String?> _uploadAvatar(String userId, String filePath) async {
    try {
      final ref = _storage.ref().child('avatars/$userId');
      final uploadTask = await ref.putFile(File(filePath));
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
