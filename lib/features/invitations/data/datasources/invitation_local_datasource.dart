import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:trackflow/features/invitations/data/models/invitation_dto.dart';
import 'package:trackflow/features/invitations/data/models/invitation_document.dart';

abstract class InvitationLocalDataSource {
  /// Cache an invitation locally
  Future<void> cacheInvitation(InvitationDto invitation);

  /// Get an invitation by ID
  Future<InvitationDto?> getInvitationById(String invitationId);

  /// Watch an invitation by ID (reactive)
  Stream<InvitationDto?> watchInvitationById(String invitationId);

  /// Get all pending invitations for a user
  Future<List<InvitationDto>> getPendingInvitationsForUser(String userId);

  /// Watch all pending invitations for a user (reactive)
  Stream<List<InvitationDto>> watchPendingInvitationsForUser(String userId);

  /// Get all sent invitations by a user
  Future<List<InvitationDto>> getSentInvitationsByUser(String userId);

  /// Watch all sent invitations by a user (reactive)
  Stream<List<InvitationDto>> watchSentInvitationsByUser(String userId);

  /// Update an invitation
  Future<void> updateInvitation(InvitationDto invitation);

  /// Delete an invitation
  Future<void> deleteInvitation(String invitationId);

  /// Clear all cached invitations
  Future<void> clearCache();

  /// Get pending invitations count for a user
  Future<int> getPendingInvitationsCount(String userId);
}

@LazySingleton(as: InvitationLocalDataSource)
class IsarInvitationLocalDataSource implements InvitationLocalDataSource {
  final Isar _isar;

  IsarInvitationLocalDataSource(this._isar);

  @override
  Future<void> cacheInvitation(InvitationDto invitation) async {
    final invitationDoc = InvitationDocument.fromDTO(invitation);
    await _isar.writeTxn(() async {
      await _isar.invitationDocuments.put(invitationDoc);
    });
  }

  @override
  Future<InvitationDto?> getInvitationById(String invitationId) async {
    final doc =
        await _isar.invitationDocuments
            .where()
            .idEqualTo(invitationId)
            .findFirst();
    return doc?.toDTO();
  }

  @override
  Stream<InvitationDto?> watchInvitationById(String invitationId) {
    return _isar.invitationDocuments
        .watchObject(fastHash(invitationId), fireImmediately: true)
        .map((doc) => doc?.toDTO());
  }

  @override
  Future<List<InvitationDto>> getPendingInvitationsForUser(
    String userId,
  ) async {
    final docs =
        await _isar.invitationDocuments
            .where()
            .filter()
            .invitedByUserIdEqualTo(userId)
            .and()
            .statusEqualTo('pending')
            .findAll();
    return docs.map((doc) => doc.toDTO()).toList();
  }

  @override
  Stream<List<InvitationDto>> watchPendingInvitationsForUser(String userId) {
    return _isar.invitationDocuments
        .where()
        .filter()
        .invitedByUserIdEqualTo(userId)
        .and()
        .statusEqualTo('pending')
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }

  @override
  Future<List<InvitationDto>> getSentInvitationsByUser(String userId) async {
    final docs =
        await _isar.invitationDocuments
            .where()
            .filter()
            .invitedByUserIdEqualTo(userId)
            .findAll();
    return docs.map((doc) => doc.toDTO()).toList();
  }

  @override
  Stream<List<InvitationDto>> watchSentInvitationsByUser(String userId) {
    return _isar.invitationDocuments
        .where()
        .filter()
        .invitedByUserIdEqualTo(userId)
        .watch(fireImmediately: true)
        .map((docs) => docs.map((doc) => doc.toDTO()).toList());
  }

  @override
  Future<void> updateInvitation(InvitationDto invitation) async {
    final invitationDoc = InvitationDocument.fromDTO(invitation);
    await _isar.writeTxn(() async {
      await _isar.invitationDocuments.put(invitationDoc);
    });
  }

  @override
  Future<void> deleteInvitation(String invitationId) async {
    await _isar.writeTxn(() async {
      await _isar.invitationDocuments.delete(fastHash(invitationId));
    });
  }

  @override
  Future<void> clearCache() async {
    await _isar.writeTxn(() async {
      await _isar.invitationDocuments.clear();
    });
  }

  @override
  Future<int> getPendingInvitationsCount(String userId) async {
    final count =
        await _isar.invitationDocuments
            .where()
            .filter()
            .invitedByUserIdEqualTo(userId)
            .and()
            .statusEqualTo('pending')
            .count();
    return count;
  }
}
