import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/invitations/data/models/invitation_dto.dart';

abstract class InvitationRemoteDataSource {
  /// Create a new invitation
  Future<Either<Failure, InvitationDto>> createInvitation(
    InvitationDto invitation,
  );

  /// Get an invitation by ID
  Future<Either<Failure, InvitationDto>> getInvitationById(String invitationId);

  /// Update an invitation
  Future<Either<Failure, InvitationDto>> updateInvitation(
    InvitationDto invitation,
  );

  /// Delete an invitation
  Future<Either<Failure, Unit>> deleteInvitation(String invitationId);

  /// Get all pending invitations for a user
  Future<Either<Failure, List<InvitationDto>>> getPendingInvitationsForUser(
    String userId,
  );

  /// Get all sent invitations by a user
  Future<Either<Failure, List<InvitationDto>>> getSentInvitationsByUser(
    String userId,
  );

  /// Get pending invitations count for a user
  Future<Either<Failure, int>> getPendingInvitationsCount(String userId);
}

@LazySingleton(as: InvitationRemoteDataSource)
class FirestoreInvitationRemoteDataSource
    implements InvitationRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreInvitationRemoteDataSource(this._firestore);

  @override
  Future<Either<Failure, InvitationDto>> createInvitation(
    InvitationDto invitation,
  ) async {
    try {
      await _firestore
          .collection(InvitationDto.collection)
          .doc(invitation.id)
          .set(invitation.toJson());
      return Right(invitation);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to create invitation'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvitationDto>> getInvitationById(
    String invitationId,
  ) async {
    try {
      final doc =
          await _firestore
              .collection(InvitationDto.collection)
              .doc(invitationId)
              .get();

      if (!doc.exists) {
        return Left(DatabaseFailure('Invitation not found'));
      }

      return Right(InvitationDto.fromJson(doc.data()!));
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get invitation'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, InvitationDto>> updateInvitation(
    InvitationDto invitation,
  ) async {
    try {
      await _firestore
          .collection(InvitationDto.collection)
          .doc(invitation.id)
          .update(invitation.toJson());
      return Right(invitation);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to update invitation'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteInvitation(String invitationId) async {
    try {
      await _firestore
          .collection(InvitationDto.collection)
          .doc(invitationId)
          .delete();
      return Right(unit);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to delete invitation'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InvitationDto>>> getPendingInvitationsForUser(
    String userId,
  ) async {
    try {
      final query =
          await _firestore
              .collection(InvitationDto.collection)
              .where('invitedByUserId', isEqualTo: userId)
              .where('status', isEqualTo: 'pending')
              .get();

      final invitations =
          query.docs.map((doc) => InvitationDto.fromJson(doc.data())).toList();

      return Right(invitations);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to get pending invitations'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InvitationDto>>> getSentInvitationsByUser(
    String userId,
  ) async {
    try {
      final query =
          await _firestore
              .collection(InvitationDto.collection)
              .where('invitedByUserId', isEqualTo: userId)
              .get();

      final invitations =
          query.docs.map((doc) => InvitationDto.fromJson(doc.data())).toList();

      return Right(invitations);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to get sent invitations'));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getPendingInvitationsCount(String userId) async {
    try {
      final query =
          await _firestore
              .collection(InvitationDto.collection)
              .where('invitedByUserId', isEqualTo: userId)
              .where('status', isEqualTo: 'pending')
              .get();

      return Right(query.docs.length);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(e.message ?? 'Failed to get pending invitations count'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
