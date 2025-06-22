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
  Future<void> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  });

  Future<void> deleteTrackFromProject(String trackId, String projectId);
  Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds);
}

@LazySingleton(as: AudioTrackRemoteDataSource)
class AudioTrackRemoteDataSourceImpl implements AudioTrackRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AudioTrackRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, Unit>> uploadAudioTrack({
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
          .add(trackDTO.toJson());
      return const Right(unit);
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

  @override
  Future<List<AudioTrackDTO>> getTracksByProjectIds(
    List<String> projectIds,
  ) async {
    if (projectIds.isEmpty) {
      return [];
    }

    try {
      final List<Future<QuerySnapshot>> futures = [];
      for (String projectId in projectIds) {
        futures.add(
          _firestore
              .collection(ProjectDTO.collection)
              .doc(projectId)
              .collection(AudioTrackDTO.collection)
              .get(),
        );
      }

      final List<QuerySnapshot> snapshots = await Future.wait(futures);
      final List<AudioTrackDTO> allTracks = [];

      for (final snapshot in snapshots) {
        for (final doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          allTracks.add(AudioTrackDTO.fromJson(data));
        }
      }

      return allTracks;
    } catch (e) {
      return [];
    }
  }
}
