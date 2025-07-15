import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';

abstract class AudioTrackRemoteDataSource {
  Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack(
    AudioTrackDTO trackData,
  );

  Future<Either<Failure, Unit>> deleteAudioTrack(String trackId);

  Future<List<AudioTrackDTO>> getTracksByProjectIds(List<String> projectIds);

  Future<void> editTrackName(String trackId, String projectId, String newName);
}

@LazySingleton(as: AudioTrackRemoteDataSource)
class AudioTrackRemoteDataSourceImpl implements AudioTrackRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AudioTrackRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, AudioTrackDTO>> uploadAudioTrack(
    AudioTrackDTO trackData,
  ) async {
    try {
      // Extract extension from the DTO, not from the URL
      final ext = trackData.extension;
      final fileName = '${trackData.id.value}.$ext';
      final storageRef = _storage.ref().child(
        '${AudioTrackDTO.collection}/$fileName',
      );
      final uploadTask = await storageRef.putFile(File(trackData.url));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final updatedTrackDTO = AudioTrackDTO(
        id: trackData.id,
        name: trackData.name,
        url: downloadUrl,
        projectId: trackData.projectId,
        duration: trackData.duration,
        uploadedBy: trackData.uploadedBy,
        createdAt: trackData.createdAt,
        extension: ext,
      );

      await _firestore
          .collection(AudioTrackDTO.collection)
          .doc(updatedTrackDTO.id.value)
          .set(updatedTrackDTO.toJson());

      return Right(updatedTrackDTO);
    } catch (e) {
      return Left(ServerFailure('Error uploading audio track: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAudioTrack(String trackId) async {
    try {
      // Fetch the track document to get the extension
      final docSnapshot =
          await _firestore
              .collection(AudioTrackDTO.collection)
              .doc(trackId)
              .get();

      String? ext;
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['extension'] != null) {
          ext = data['extension'] as String;
        }
      }

      await _firestore
          .collection(AudioTrackDTO.collection)
          .doc(trackId)
          .delete();

      if (ext != null) {
        final fileName = '$trackId.$ext';
        final storageRef = _storage.ref().child(
          '${AudioTrackDTO.collection}/$fileName',
        );
        try {
          await storageRef.delete();
        } catch (e) {
          // Ignore if file does not exist
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error deleting audio track: $e'));
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
}
