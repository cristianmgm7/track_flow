import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/audio_track/data/models/audio_track_dto.dart';
import 'package:trackflow/features/audio_track/domain/entities/audio_track.dart';

abstract class AudioTrackRemoteDataSource {
  Future<Either<Failure, AudioTrack>> getTrackById(AudioTrackId id);
  Future<void> uploadAudioTrack({
    required File file,
    required AudioTrack track,
  });

  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  );

  Future<void> deleteTrack(String trackId);
}

@LazySingleton(as: AudioTrackRemoteDataSource)
class AudioTrackRemoteDataSourceImpl implements AudioTrackRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  AudioTrackRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, AudioTrack>> getTrackById(AudioTrackId id) async {
    try {
      final doc =
          await _firestore
              .collection(AudioTrackDTO.collection)
              .doc(id.value)
              .get();

      if (!doc.exists) {
        return Left(ServerFailure('Track not found'));
      }

      final data = doc.data()!;
      data['id'] = doc.id;

      final track = AudioTrackDTO.fromJson(data).toDomain();
      return Right(track);
    } catch (e) {
      return Left(ServerFailure('Error fetching track: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<AudioTrack>>> watchTracksByProject(
    ProjectId projectId,
  ) {
    return _firestore
        .collection(AudioTrackDTO.collection)
        .where('projectId', isEqualTo: projectId.value)
        .snapshots()
        .map((snapshot) {
          return Right(
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return AudioTrackDTO.fromJson(data).toDomain();
            }).toList(),
          );
        });
  }

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
    } catch (e, stack) {
      print('Error uploading audio track: $e\n$stack');
      return Left(ServerFailure('Error uploading audio track: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrack(String trackId) async {
    final docRef = _firestore.collection(AudioTrackDTO.collection).doc(trackId);
    final doc = await docRef.get();

    if (!doc.exists) {
      return Left(ServerFailure('Track not found'));
    }

    final trackData = doc.data() as Map<String, dynamic>;
    final trackDTO = AudioTrackDTO.fromJson({...trackData, 'id': doc.id});

    try {
      final storageRef = _storage.refFromURL(trackDTO.url);
      await storageRef.delete();
    } catch (e) {
      return Left(ServerFailure('Error deleting file from storage: $e'));
    }

    await docRef.delete();
    return const Right(unit);
  }
}
