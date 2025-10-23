import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';

abstract class AudioTrackRemoteDataSource {
  Future<Either<Failure, AudioTrackDTO>> createAudioTrack(
    AudioTrackDTO trackData,
  );

  Future<Either<Failure, Unit>> deleteAudioTrack(String trackId);

  Future<Either<Failure, Unit>> updateTrack(AudioTrackDTO trackData);

  Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds);

  Future<void> editTrackName(String trackId, String projectId, String newName);

  Future<Either<Failure, Unit>> updateActiveVersion(
    String trackId,
    String versionId,
  );

  Future<Either<Failure, Unit>> updateTrackCoverUrl(
    String trackId,
    String coverUrl,
    String? coverLocalPath,
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
  Future<Either<Failure, AudioTrackDTO>> createAudioTrack(
    AudioTrackDTO trackData,
  ) async {
    try {
      // AudioTrack only stores metadata, no file upload
      // Files are now handled by TrackVersionRemoteDataSource

      final data = Map<String, dynamic>.from(trackData.toJson());
      // Ensure server authoritative timestamp
      data['lastModified'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(AudioTrackDTO.collection)
          .doc(trackData.id.value)
          .set(data);

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
        {'isDeleted': true, 'lastModified': FieldValue.serverTimestamp()},
      );

      return const Right(unit);
    } catch (e) {
      return Left(
        ServerFailure('Error soft deleting audio track metadata: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTrack(AudioTrackDTO trackData) async {
    try {
      // Update track with complete data including sync metadata
      final data = Map<String, dynamic>.from(trackData.toJson());
      // Ensure server authoritative timestamp regardless of client value
      data['lastModified'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(AudioTrackDTO.collection)
          .doc(trackData.id.value)
          .update(data);

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error updating audio track: $e'));
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
                .where('isDeleted', isEqualTo: false)
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
        'lastModified': FieldValue.serverTimestamp(),
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
      // DEBUG: trace firestore write arguments (concise)
      // ignore: avoid_print
      print('[AUDIO_TRACK_REMOTE] updateActiveVersion → trackId=$trackId versionId=$versionId');
      await _firestore.collection(AudioTrackDTO.collection).doc(trackId).update(
        {
          'activeVersionId': versionId,
          'lastModified': FieldValue.serverTimestamp(),
        },
      );

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error updating active version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTrackCoverUrl(
    String trackId,
    String coverUrl,
    String? coverLocalPath,
  ) async {
    try {
      // Note: coverLocalPath is NOT synced to Firestore (local-only field)
      // DEBUG: trace firestore write arguments (concise)
      // ignore: avoid_print
      print('[AUDIO_TRACK_REMOTE] updateTrackCoverUrl → trackId=$trackId coverUrl=$coverUrl');
      await _firestore.collection(AudioTrackDTO.collection).doc(trackId).update(
        {
          'coverUrl': coverUrl,
          'lastModified': FieldValue.serverTimestamp(),
        },
      );

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error updating track cover URL: $e'));
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
      // Use a small buffer to avoid missing server-timestamped writes near the cursor boundary
      final DateTime safeSince = since.subtract(const Duration(minutes: 5));
      // Firestore 'whereIn' clause is limited to 10 elements.
      // We process the projectIds in chunks of 10 to be safe.
      for (var i = 0; i < projectIds.length; i += 10) {
        final sublist = projectIds.sublist(
          i,
          i + 10 > projectIds.length ? projectIds.length : i + 10,
        );

        // Single query using a buffered cursor; both updates and soft-deletes
        // are captured via lastModified
        final snapshot =
            await _firestore
                .collection(AudioTrackDTO.collection)
                .where('projectId', whereIn: sublist)
                .where('lastModified', isGreaterThan: safeSince)
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
