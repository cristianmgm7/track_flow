import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';

abstract class TrackVersionRemoteDataSource {
  Future<Either<Failure, TrackVersionDTO>> uploadTrackVersion(
    TrackVersionDTO versionData,
    File audioFile,
  );

  Future<Either<Failure, Unit>> deleteTrackVersion(String versionId);

  Future<List<TrackVersionDTO>> getVersionsByTrackId(String trackId);
}

@LazySingleton(as: TrackVersionRemoteDataSource)
class TrackVersionRemoteDataSourceImpl implements TrackVersionRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  TrackVersionRemoteDataSourceImpl(this._firestore, this._storage);

  @override
  Future<Either<Failure, TrackVersionDTO>> uploadTrackVersion(
    TrackVersionDTO versionData,
    File audioFile,
  ) async {
    try {
      // 1. Upload file to Storage
      final fileName = '${versionData.id}.mp3'; // Assuming mp3 for now
      final storageRef = _storage.ref().child('track_versions/$fileName');

      final uploadTask = await storageRef.putFile(audioFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // 2. Update DTO with download URL
      final updatedVersionDTO = TrackVersionDTO(
        id: versionData.id,
        trackId: versionData.trackId,
        versionNumber: versionData.versionNumber,
        label: versionData.label,
        fileLocalPath: versionData.fileLocalPath,
        fileRemoteUrl: downloadUrl,
        durationMs: versionData.durationMs,
        status: versionData.status,
        createdAt: versionData.createdAt,
        createdBy: versionData.createdBy,
      );

      // 3. Save metadata to Firestore
      await _firestore
          .collection(TrackVersionDTO.collection)
          .doc(updatedVersionDTO.id)
          .set(updatedVersionDTO.toJson());

      return Right(updatedVersionDTO);
    } catch (e) {
      return Left(ServerFailure('Error uploading track version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrackVersion(String versionId) async {
    try {
      // Get version data to delete file from storage
      final docSnapshot =
          await _firestore
              .collection(TrackVersionDTO.collection)
              .doc(versionId)
              .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data['fileRemoteUrl'] != null) {
          // Delete file from storage
          final fileRef = _storage.refFromURL(data['fileRemoteUrl'] as String);
          await fileRef.delete();
        }
      }

      // Delete metadata from Firestore
      await _firestore
          .collection(TrackVersionDTO.collection)
          .doc(versionId)
          .delete();

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error deleting track version: $e'));
    }
  }

  @override
  Future<List<TrackVersionDTO>> getVersionsByTrackId(String trackId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection(TrackVersionDTO.collection)
              .where('trackId', isEqualTo: trackId)
              .orderBy('versionNumber')
              .get();

      return querySnapshot.docs
          .map((doc) => TrackVersionDTO.fromJson(doc.data()))
          .toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }
}
