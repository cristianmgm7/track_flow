import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/magic_link/domain/entities/magic_link.dart';

@lazySingleton
abstract class MagicLinkRemoteDataSource {
  Future<Either<Failure, MagicLink>> generateMagicLink({required String email});
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required String linkId,
  });
  Future<Either<Failure, Unit>> consumeMagicLink({required String linkId});
  Future<Either<Failure, Unit>> resendMagicLink({required String email});
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required String linkId,
  });
}

@Injectable(as: MagicLinkRemoteDataSource)
class MagicLinkRemoteDataSourceImpl extends MagicLinkRemoteDataSource {
  final FirebaseFirestore _firestore;

  MagicLinkRemoteDataSourceImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  @override
  Future<Either<Failure, MagicLink>> generateMagicLink({
    required String projectId,
  }) {
    // TODO: implement generateMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MagicLink>> validateMagicLink({
    required String linkId,
  }) {
    // TODO: implement validateMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> consumeMagicLink({required String linkId}) {
    // TODO: implement consumeMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> resendMagicLink({required String email}) {
    // TODO: implement resendMagicLink
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MagicLinkStatus>> getMagicLinkStatus({
    required String linkId,
  }) {
    // TODO: implement getMagicLinkStatus
    throw UnimplementedError();
  }
}
