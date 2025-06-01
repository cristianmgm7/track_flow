import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/features/user_profile/data/models/user_profile_dto.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileDTO> getProfile(String userId);
  Future<void> updateProfile(UserProfileDTO profile);
}

@LazySingleton(as: UserProfileRemoteDataSource)
class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserProfileRemoteDataSourceImpl(this._firestore);

  @override
  Future<UserProfileDTO> getProfile(String userId) async {
    final doc =
        await _firestore
            .collection(UserProfileDTO.collection)
            .doc(userId)
            .get();
    return UserProfileDTO.fromJson(doc.data()!);
  }

  @override
  Future<void> updateProfile(UserProfileDTO profile) async {
    await _firestore
        .collection(UserProfileDTO.collection)
        .doc(profile.id)
        .update(profile.toJson());
  }
}
