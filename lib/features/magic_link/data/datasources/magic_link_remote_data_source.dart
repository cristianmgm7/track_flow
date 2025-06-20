import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_dto.dart';

abstract class MagicLinkRemoteDataSource {
  Future<Either<Failure, MagicLink>> generateMagicLink({
    required String projectId,
    required String userId,
  });
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required String linkId,
  });
  Future<Either<Failure, Unit>> consumeMagicLink({required String linkId});
  Future<Either<Failure, Unit>> resendMagicLink({required String linkId});
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required String linkId,
  });
}

@LazySingleton(as: MagicLinkRemoteDataSource)
class MagicLinkRemoteDataSourceImpl extends MagicLinkRemoteDataSource {
  final FirebaseFirestore _firestore;

  MagicLinkRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, MagicLink>> generateMagicLink({
    required String projectId,
    required String userId,
  }) async {
    try {
      final docRef = await _firestore.collection('magic_links').add({
        'url': '', // Placeholder
        'userId': userId,
        'projectId': projectId,
        'createdAt': Timestamp.now(),
        'expiresAt': null,
        'isUsed': false,
        'status': 'valid',
      });

      // Genera el Dynamic Link
      final dynamicLinkParams = DynamicLinkParameters(
        uriPrefix: 'https://trackflow.page.link',
        link: Uri.parse('https://trackflow.page.link/magic-link/${docRef.id}'),
        androidParameters: AndroidParameters(
          packageName: 'com.trackflow.app',
          minimumVersion: 0,
        ),
        iosParameters: IOSParameters(
          bundleId: 'com.trackflow.ios',
          minimumVersion: '0',
        ),
        // Puedes agregar socialMetaTagParameters, etc.
      );

      final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(
        dynamicLinkParams,
      );
      final url = dynamicLink.shortUrl.toString();

      await docRef.update({'url': url});
      final doc = await docRef.get();
      final dto = MagicLinkDto.fromFirestore(doc);
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required String linkId,
  }) async {
    try {
      final doc = await _firestore.collection('magic_links').doc(linkId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Magic link not found'));
      }
      final dto = MagicLinkDto.fromFirestore(doc);
      if (dto.status != 'valid' || dto.isUsed) {
        return Left(ServerFailure('Magic link is not valid'));
      }
      return Right(dto.toDomain());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> consumeMagicLink({
    required String linkId,
  }) async {
    try {
      final docRef = _firestore.collection('magic_links').doc(linkId);
      final doc = await docRef.get();
      if (!doc.exists) {
        return Left(ServerFailure('Magic link not found'));
      }
      await docRef.update({'isUsed': true, 'status': 'used'});
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendMagicLink({
    required String linkId,
  }) async {
    try {
      final docRef = _firestore.collection('magic_links').doc(linkId);
      final doc = await docRef.get();
      if (!doc.exists) {
        return Left(ServerFailure('Magic link not found'));
      }
      // You may want to update expiresAt or send a notification here
      await docRef.update({'status': 'valid', 'isUsed': false});
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required String linkId,
  }) async {
    try {
      final doc = await _firestore.collection('magic_links').doc(linkId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Magic link not found'));
      }
      final dto = MagicLinkDto.fromFirestore(doc);
      return Right(MagicLinkDto.statusFromString(dto.status));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
