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

  Future<Either<Failure, Unit>> updateTrackVersionMetadata(
    TrackVersionDTO versionData,
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
      // 1. Generate unique filename with proper extension
      final fileExtension = _getFileExtension(audioFile.path);
      final fileName = '${versionData.id}$fileExtension';
      final storageRef = _storage.ref().child('track_versions/$fileName');

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
        version: 1, // Initial version for sync
        lastModified: DateTime.now(),
      );

      // 4. Save metadata to Firestore
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
  Future<Either<Failure, Unit>> updateTrackVersionMetadata(
    TrackVersionDTO versionData,
  ) async {
    try {
      // Update only metadata in Firestore (no file re-upload)
      await _firestore
          .collection(TrackVersionDTO.collection)
          .doc(versionData.id)
          .update(versionData.toJson());

      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Error updating track version metadata: $e'));
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
        // Delete associated waveform files under waveforms/{trackId}/{versionId}/
        try {
          final trackId =
              (data != null && data['trackId'] != null)
                  ? data['trackId'] as String
                  : null;
          if (trackId != null && trackId.isNotEmpty) {
            final folderRef = _storage.ref().child(
              'waveforms/$trackId/$versionId',
            );
            final listResult = await folderRef.listAll();
            for (final item in listResult.items) {
              try {
                await item.delete();
              } catch (_) {}
            }
            for (final prefix in listResult.prefixes) {
              try {
                final subList = await prefix.listAll();
                for (final subItem in subList.items) {
                  try {
                    await subItem.delete();
                  } catch (_) {}
                }
              } catch (_) {}
            }
          }
        } catch (_) {}
        if (data != null && data['fileRemoteUrl'] != null) {
          // Delete file from storage
          final fileRef = _storage.refFromURL(data['fileRemoteUrl'] as String);
          await fileRef.delete();
        }

        // Fallback legacy cleanup: waveforms/{versionId}/** (pre-canonical structure)
        try {
          final legacyFolder = _storage.ref().child('waveforms/$versionId');
          final legacyList = await legacyFolder.listAll();
          for (final item in legacyList.items) {
            try {
              await item.delete();
            } catch (_) {}
          }
          for (final prefix in legacyList.prefixes) {
            try {
              final sub = await prefix.listAll();
              for (final subItem in sub.items) {
                try {
                  await subItem.delete();
                } catch (_) {}
              }
            } catch (_) {}
          }
        } catch (_) {}
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
}
