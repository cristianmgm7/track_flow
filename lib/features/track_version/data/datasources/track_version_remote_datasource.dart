import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/audio/domain/audio_file_repository.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/utils/audio_format_utils.dart';

abstract class TrackVersionRemoteDataSource {
  Future<Either<Failure, TrackVersionDTO>> createTrackVersion(
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
  final AudioFileRepository _uploadService;

  TrackVersionRemoteDataSourceImpl(
    this._firestore,
    this._uploadService,
  );

  @override
  Future<Either<Failure, TrackVersionDTO>> createTrackVersion(
    TrackVersionDTO versionData,
    File audioFile,
  ) async {
    try {
      // 1. Generate unique filename with proper extension
      final fileExtension = AudioFormatUtils.getFileExtension(audioFile.path);
      final fileName = '${versionData.id}$fileExtension';
      final storagePath = 'track_versions/${versionData.trackId}/$fileName';

      // 2. Upload file to Firebase Storage with metadata using shared service
      final uploadResult = await _uploadService.uploadAudioFile(
        audioFile: audioFile,
        storagePath: storagePath,
        metadata: {
          'trackId': versionData.trackId,
          'versionNumber': versionData.versionNumber.toString(),
          'createdBy': versionData.createdBy,
        },
        onProgress: (progress) {
          // TODO: Emit progress to BLoC if needed
          AppLogger.debug('Upload progress: ${progress.formattedProgress}');
        },
      );

      // Handle upload failure
      final downloadUrl = uploadResult.fold(
        (failure) => throw Exception(failure.message),
        (url) => url,
      );

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
