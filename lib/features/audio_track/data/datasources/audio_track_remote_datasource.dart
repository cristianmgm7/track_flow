import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';
import 'package:trackflow/features/projects/data/models/project_dto.dart';

abstract class AudioTrackRemoteDataSource {
  Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  });

  Future<void> deleteTrackFromProject(String trackId, String projectId);
  Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds);
  Future<void> editTrackName({
    required String trackId,
    required String projectId,
    required String newName,
  });
}

@LazySingleton(as: AudioTrackRemoteDataSource)
class AudioTrackRemoteDataSourceImpl implements AudioTrackRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AudioTrackRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  }) async {
    try {
      final storageRef = _storage.ref().child(
        '${AudioTrackDTO.collection}/${DateTime.now().millisecondsSinceEpoch}_${track.name}',
      );
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final trackDTO = AudioTrackDTO.fromDomain(track, url: downloadUrl);

      await _firestore
          .collection(AudioTrackDTO.collection)
          .doc(trackDTO.id.value)
          .set(trackDTO.toJson());

      return Right(trackDTO);
    } catch (e) {
      return Left(ServerFailure('Error uploading audio track: $e'));
    }
  }

  @override
  Future<void> deleteTrackFromProject(String trackId, String projectId) async {
    try {
      await _firestore
          .collection(ProjectDTO.collection)
          .doc(projectId)
          .collection(AudioTrackDTO.collection)
          .doc(trackId)
          .delete();
    } catch (e) {
      // Handle error
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
    // Fetching tracks for projects: $projectIds

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
  Future<void> editTrackName({
    required String trackId,
    required String projectId,
    required String newName,
  }) async {
    try {
      await _firestore.collection('audio_tracks').doc(trackId).update({
        'name': newName,
      });
    } catch (e) {
      throw Exception('Error updating track name: $e');
    }
  }
}
