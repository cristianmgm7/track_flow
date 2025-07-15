import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/services/deep_link_service.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_dto.dart';
import 'package:trackflow/features/magic_link/data/models/magic_link_request_dto.dart';

abstract class MagicLinkRemoteDataSource {
  Future<Either<Failure, MagicLinkDto>> generateMagicLink(
    MagicLinkRequestDto request,
  );
  Future<Either<Failure, MagicLinkDto>> validateMagicLink(
    MagicLinkValidationDto validation,
  );
  Future<Either<Failure, Unit>> consumeMagicLink(
    MagicLinkValidationDto validation,
  );
  Future<Either<Failure, Unit>> resendMagicLink(
    MagicLinkValidationDto validation,
  );
  Future<Either<Failure, String>> getMagicLinkStatus(
    MagicLinkStatusDto status,
  );
}

@LazySingleton(as: MagicLinkRemoteDataSource)
class MagicLinkRemoteDataSourceImpl extends MagicLinkRemoteDataSource {
  final FirebaseFirestore _firestore;
  final DeepLinkService _deepLinkService;

  MagicLinkRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required DeepLinkService deepLinkService,
  }) : _firestore = firestore,
       _deepLinkService = deepLinkService;

  @override
  Future<Either<Failure, MagicLinkDto>> generateMagicLink(
    MagicLinkRequestDto request,
  ) async {
    try {
      final docRef = await _firestore.collection('magic_links').add({
        'url': '', // Placeholder
        'userId': request.userId,
        'projectId': request.projectId,
        'createdAt': Timestamp.now(),
        'expiresAt': null,
        'isUsed': false,
        'status': 'valid',
      });

      // Generate the deep link using the new service
      final url = await _deepLinkService.generateMagicLink(
        projectId: request.projectId,
        token: docRef.id,
      );

      await docRef.update({'url': url});
      final doc = await docRef.get();
      final dto = MagicLinkDto.fromFirestore(doc);
      return Right(dto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MagicLinkDto>> validateMagicLink(
    MagicLinkValidationDto validation,
  ) async {
    try {
      final doc =
          await _firestore.collection('magic_links').doc(validation.linkId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Magic link not found'));
      }
      final dto = MagicLinkDto.fromFirestore(doc);
      if (dto.status != 'valid' || dto.isUsed) {
        return Left(ServerFailure('Magic link is not valid'));
      }
      return Right(dto);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> consumeMagicLink(
    MagicLinkValidationDto validation,
  ) async {
    try {
      final docRef = _firestore.collection('magic_links').doc(validation.linkId);
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
  Future<Either<Failure, Unit>> resendMagicLink(
    MagicLinkValidationDto validation,
  ) async {
    try {
      final docRef = _firestore.collection('magic_links').doc(validation.linkId);
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
  Future<Either<Failure, String>> getMagicLinkStatus(
    MagicLinkStatusDto status,
  ) async {
    try {
      final doc =
          await _firestore.collection('magic_links').doc(status.linkId).get();
      if (!doc.exists) {
        return Left(ServerFailure('Magic link not found'));
      }
      final dto = MagicLinkDto.fromFirestore(doc);
      return Right(dto.status);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
