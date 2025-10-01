import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';
import 'package:trackflow/core/utils/app_logger.dart';

abstract class TrackVersionRemoteDataSource {
  Future<Either<Failure, TrackVersionDTO>> uploadTrackVersion(
    TrackVersionDTO versionData,
    File audioFile,
  );

  Future<Either<Failure, Unit>> updateTrackVersionMetadata(
    TrackVersionDTO versionData,
  );

  Future<Either<Failure, Unit>> deleteTrackVersion(String versionId);

  Future<List<TrackVersionDTO>> getVersionsByTrackId(String trackId);

  /// Get track versions modified since a specific timestamp for specific track IDs
  Future<Either<Failure, List<TrackVersionDTO>>> getTrackVersionsModifiedSince(
    DateTime since,
    List<String> trackIds,
  );
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
      // 1. Generate unique filename with proper extension
      final fileExtension = _getFileExtension(audioFile.path);
      final fileName = '${versionData.id}$fileExtension';
      final storageRef = _storage.ref().child(
        'track_versions/${versionData.trackId}/$fileName',
      );

      // 2. Upload file to Firebase Storage with metadata
      final uploadTask = storageRef.putFile(
        audioFile,
        SettableMetadata(
          contentType: _getContentType(fileExtension),
          customMetadata: {
            'trackId': versionData.trackId,
            'versionNumber': versionData.versionNumber.toString(),
            'createdBy': versionData.createdBy,
          },
        ),
      );

      // Wait for upload completion
      final uploadSnapshot = await uploadTask;
      final downloadUrl = await uploadSnapshot.ref.getDownloadURL();

      // 3. Update DTO with download URL and mark as ready
      final updatedVersionDTO = TrackVersionDTO(
        id: versionData.id,
        trackId: versionData.trackId,
        versionNumber: versionData.versionNumber,
        label: versionData.label,
        fileLocalPath: versionData.fileLocalPath,
        fileRemoteUrl: downloadUrl,
        durationMs: versionData.durationMs,
        status: 'ready', // Mark as ready after successful upload
        createdAt: versionData.createdAt,
        createdBy: versionData.createdBy,
        isDeleted: false,
        version: 1, // Initial version for sync
        lastModified: null, // will be set by serverTimestamp
      );

      // 4. Save metadata to Firestore with server timestamps
      final data = updatedVersionDTO.toJson();
      data['lastModified'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(TrackVersionDTO.collection)
          .doc(updatedVersionDTO.id)
          .set(data);

      return Right(updatedVersionDTO);
    } catch (e) {
      return Left(ServerFailure('Error uploading track version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTrackVersionMetadata(
    TrackVersionDTO versionData,
  ) async {
    try {
      // Update only metadata in Firestore (no file re-upload)
      final data = versionData.toJson();
      data['lastModified'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(TrackVersionDTO.collection)
          .doc(versionData.id)
          .update(data);

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error updating track version metadata: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTrackVersion(String versionId) async {
    try {
      // Soft delete: flag isDeleted and set server lastModified. Physical file
      // cleanup is handled by background tasks to preserve offline-first behavior.
      await _firestore
          .collection(TrackVersionDTO.collection)
          .doc(versionId)
          .update({
            'isDeleted': true,
            'lastModified': FieldValue.serverTimestamp(),
          });

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error deleting track version: $e'));
    }
  }

  @override
  Future<List<TrackVersionDTO>> getVersionsByTrackId(String trackId) async {
    try {
      // Preferred: equality + orderBy for stable ordering
      try {
        final querySnapshot =
            await _firestore
                .collection(TrackVersionDTO.collection)
                .where('trackId', isEqualTo: trackId)
                .where('isDeleted', isEqualTo: false)
                .orderBy('versionNumber')
                .get();

        return querySnapshot.docs
            .map((doc) => TrackVersionDTO.fromJson(doc.data()))
            .toList();
      } catch (e) {
        // Fallback: some Firestore projects may miss the composite index
        AppLogger.warning(
          'getVersionsByTrackId fallback without orderBy (likely missing index): $e',
          tag: 'TrackVersionRemoteDataSource',
        );
        final qs =
            await _firestore
                .collection(TrackVersionDTO.collection)
                .where('trackId', isEqualTo: trackId)
                .get();
        final items =
            qs.docs.map((doc) => TrackVersionDTO.fromJson(doc.data())).toList();
        items.sort((a, b) => a.versionNumber.compareTo(b.versionNumber));
        return items;
      }
    } catch (e) {
      // Return empty list on error
      AppLogger.warning(
        'getVersionsByTrackId error for trackId=$trackId: $e',
        tag: 'TrackVersionRemoteDataSource',
      );
      return [];
    }
  }

  /// Get file extension from file path
  String _getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '.mp3'; // Default to mp3
    return filePath.substring(lastDot);
  }

  /// Get MIME content type based on file extension
  String _getContentType(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case '.mp3':
        return 'audio/mpeg';
      case '.wav':
        return 'audio/wav';
      case '.m4a':
        return 'audio/mp4';
      case '.aac':
        return 'audio/aac';
      case '.ogg':
        return 'audio/ogg';
      case '.flac':
        return 'audio/flac';
      default:
        return 'audio/mpeg'; // Default to mp3
    }
  }

  @override
  Future<Either<Failure, List<TrackVersionDTO>>> getTrackVersionsModifiedSince(
    DateTime since,
    List<String> trackIds,
  ) async {
    try {
      if (trackIds.isEmpty) {
        return const Right([]);
      }

      final List<TrackVersionDTO> all = [];
      final safeSince = since.subtract(const Duration(minutes: 2));

      for (var i = 0; i < trackIds.length; i += 10) {
        final sublist = trackIds.sublist(
          i,
          i + 10 > trackIds.length ? trackIds.length : i + 10,
        );

        final snapshot =
            await _firestore
                .collection(TrackVersionDTO.collection)
                .where('trackId', whereIn: sublist)
                .where('lastModified', isGreaterThan: safeSince)
                .orderBy('lastModified')
                .get();

        final items =
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return TrackVersionDTO.fromJson(data);
            }).toList();

        all.addAll(items);
      }

      return Right(all);
    } catch (e) {
      return Left(ServerFailure('Error getting modified track versions: $e'));
    }
  }
}
