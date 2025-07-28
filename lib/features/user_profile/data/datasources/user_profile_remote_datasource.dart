import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

abstract class UserProfileRemoteDataSource {
  /// Get a SINGLE user profile by ID
  Future<Either<Failure, UserProfileDTO>> getProfileById(String userId);

  /// Update a user profile
  Future<Either<Failure, UserProfileDTO>> updateProfile(UserProfileDTO profile);

  /// Find a user profile by email address
  Future<Either<Failure, UserProfileDTO?>> findUserByEmail(String email);

  /// Obtiene múltiples perfiles de usuario por sus IDs (Firestore, limitado a 10 por petición)
  Future<Either<Failure, List<UserProfileDTO>>> getUserProfilesByIds(
    List<String> userIds,
  );
}

@LazySingleton(as: UserProfileRemoteDataSource)
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  UserProfileRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, UserProfileDTO>> getProfileById(String userId) async {
    try {
      final query =
          await _firestore
              .collection(UserProfileDTO.collection)
              .doc(userId)
              .get();

      if (!query.exists) {
        return left(DatabaseFailure('User profile not found for ID: $userId'));
      }

      return right(UserProfileDTO.fromJson(query.data()!));
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'An error occurred'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileDTO>> updateProfile(
    UserProfileDTO profile,
  ) async {
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
          .set(profile.toJson(), SetOptions(merge: true));
      return right(profile);
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'An error occurred'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfileDTO?>> findUserByEmail(String email) async {
    try {
      final query =
          await _firestore
              .collection(UserProfileDTO.collection)
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        return right(null); // User not found
      }

      return right(UserProfileDTO.fromJson(query.docs.first.data()));
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'An error occurred'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserProfileDTO>>> getUserProfilesByIds(
    List<String> userIds,
  ) async {
    try {
      // Firestore limita a 10 IDs por whereIn
      final List<UserProfileDTO> result = [];
      for (var i = 0; i < userIds.length; i += 10) {
        final batch = userIds.skip(i).take(10).toList();
        final query =
            await _firestore
                .collection(UserProfileDTO.collection)
                .where('id', whereIn: batch)
                .get();
        result.addAll(
          query.docs.map((doc) => UserProfileDTO.fromJson(doc.data())),
        );
      }
      return right(result);
    } on FirebaseException catch (e) {
      return left(ServerFailure(e.message ?? 'An error occurred'));
    } catch (e) {
      return left(UnexpectedFailure(e.toString()));
    }
  }

  Future<String?> _uploadAvatar(String userId, String filePath) async {
    try {
      final ref = _storage.ref().child('avatars/$userId');
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
