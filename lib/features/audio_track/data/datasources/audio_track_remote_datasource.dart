import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/core/sync/domain/services/incremental_sync_service.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';

abstract class AudioTrackRemoteDataSource {
  Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack(
    AudioTrackDTO trackData,
  );

  Future<Either<Failure, Unit>> deleteAudioTrack(String trackId);

  Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds);

  Future<void> editTrackName(String trackId, String projectId, String newName);

  Future<Either<Failure, Unit>> updateActiveVersion(
    String trackId,
    String versionId,
  );

  /// Get audio tracks modified since a specific timestamp for specific project IDs
  Future<Either<Failure, List<AudioTrackDTO>>> getAudioTracksModifiedSince(
    DateTime since,
    List<String> projectIds,
  );
}

@LazySingleton(as: AudioTrackRemoteDataSource)
class AudioTrackRemoteDataSourceImpl implements AudioTrackRemoteDataSource {
  final FirebaseFirestore _firestore;

  AudioTrackRemoteDataSourceImpl(this._firestore);

  @override
  Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack(
    AudioTrackDTO trackData,
  ) async {
    try {
      // AudioTrack only stores metadata, no file upload
      // Files are now handled by TrackVersionRemoteDataSource

      await _firestore
          .collection(AudioTrackDTO.collection)
          .doc(trackData.id.value)
          .set(trackData.toJson());

      return Right(trackData);
    } catch (e) {
      return Left(ServerFailure('Error saving audio track metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAudioTrack(String trackId) async {
    try {
      // Soft delete: mark as deleted with server timestamp
      await _firestore.collection(AudioTrackDTO.collection).doc(trackId).update(
        {'isDeleted': true, 'lastModified': DateTime.now().toIso8601String()},
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        ServerFailure('Error soft deleting audio track metadata: $e'),
      );
    }
  }

  // for offline first
  @override
  Future<List<AudioTrackDTO>> getTracksByProjectIds(
    List<String> projectIds,
  ) async {
    if (projectIds.isEmpty) {
      // Received empty projectIds list
      return [];
    }
    // Fetching tracks for projects: ${projectIds.toList()}

    try {
      final List<AudioTrackDTO> allTracks = [];
      // Firestore 'whereIn' clause is limited to 30 elements.
      // We process the projectIds in chunks of 10 to be safe.
      for (var i = 0; i < projectIds.length; i += 10) {
        final sublist = projectIds.sublist(
          i,
          i + 10 > projectIds.length ? projectIds.length : i + 10,
        );

        final snapshot =
            await _firestore
                .collection(AudioTrackDTO.collection)
                .where('projectId', whereIn: sublist)
                .get();

        final tracks =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return AudioTrackDTO.fromJson(data);
            }).toList();

        allTracks.addAll(tracks);
      }

      // Total tracks found: ${allTracks.length}
      return allTracks;
    } catch (e) {
      // Error getting tracks by project ids: $e
      return [];
    }
  }

  @override
  Future<void> editTrackName(
    String trackId,
    String projectId,
    String newName,
  ) async {
    try {
      await _firestore.collection('audio_tracks').doc(trackId).update({
        'name': newName,
      });
    } catch (e) {
      throw Exception('Error updating track name: $e');
    }
  }

  @override
  Future<Either<Failure, Unit>> updateActiveVersion(
    String trackId,
    String versionId,
  ) async {
    try {
      await _firestore
          .collection(AudioTrackDTO.collection)
          .doc(trackId)
          .update({
            'activeVersionId': versionId,
            'lastModified': DateTime.now().toIso8601String(),
          });

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error updating active version: $e'));
    }
  }

  @override
  Future<Either<Failure, List<AudioTrackDTO>>> getAudioTracksModifiedSince(
    DateTime since,
    List<String> projectIds,
  ) async {
    try {
      if (projectIds.isEmpty) {
        return const Right([]);
      }

      final List<AudioTrackDTO> allTracks = [];
      // Firestore 'whereIn' clause is limited to 10 elements.
      // We process the projectIds in chunks of 10 to be safe.
      for (var i = 0; i < projectIds.length; i += 10) {
        final sublist = projectIds.sublist(
          i,
          i + 10 > projectIds.length ? projectIds.length : i + 10,
        );

        final snapshot =
            await _firestore
                .collection(AudioTrackDTO.collection)
                .where('projectId', whereIn: sublist)
                .where('lastModified', isGreaterThan: since)
                .orderBy('lastModified')
                .get();

        final tracks =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return AudioTrackDTO.fromJson(data);
            }).toList();

        allTracks.addAll(tracks);
      }

      return Right(allTracks);
    } catch (e) {
      return Left(ServerFailure('Error getting modified audio tracks: $e'));
    }
  }
}
