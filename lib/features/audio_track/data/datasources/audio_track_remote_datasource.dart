import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_model.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

abstract class AudioTrackRemoteDataSource {
  Future<void> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  });

  Stream<List<AudioTrack>> watchTracksByProject(String projectId);

  Future<void> deleteTrack(String trackId);
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
    final storageRef = _storage.ref().child(
      '${AudioTrackDTO.collection}/${DateTime.now().millisecondsSinceEpoch}_${track.name}',
    );
    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    final trackDTO = AudioTrackDTO(
      id: track.id.value,
      name: track.name,
      url: downloadUrl,
      durationMs: track.duration.inMilliseconds,
      projectId: track.projectId,
      uploadedBy: track.uploadedBy,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(AudioTrackDTO.collection)
        .add(trackDTO.toJson());
    return const Right(unit);
  }

  @override
  Stream<List<AudioTrack>> watchTracksByProject(String projectId) {
    return _firestore
        .collection('audio_tracks')
        .where('projectIds', arrayContains: projectId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return AudioTrackDTO.fromJson(data).toDomain();
          }).toList();
        });
  }

  @override
  Future<void> deleteTrack(String trackId) async {
    final docRef = _firestore.collection('audio_tracks').doc(trackId);
    final doc = await docRef.get();

    if (!doc.exists) {
      throw Exception('Track not found');
    }

    final trackData = doc.data() as Map<String, dynamic>;
    final trackDTO = AudioTrackDTO.fromJson({...trackData, 'id': doc.id});

    // Delete from storage
    try {
      final storageRef = _storage.refFromURL(trackDTO.url);
      await storageRef.delete();
    } catch (e) {
      // Log error but continue with Firestore deletion
      print('Error deleting file from storage: $e');
    }

    // Delete from Firestore
    await docRef.delete();
  }
}
