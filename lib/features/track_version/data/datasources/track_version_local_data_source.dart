import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/core/error/failures.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';

abstract class TrackVersionLocalDataSource {
  Future<Either<Failure, TrackVersionDTO>> addVersion({
    required AudioTrackId trackId,
    required File file,
    String? label,
  });

  Stream<Either<Failure, List<TrackVersionDTO>>> watchVersionsByTrack(
    AudioTrackId trackId,
  );

  Future<Either<Failure, TrackVersionDTO>> getById(TrackVersionId id);

  Future<Either<Failure, TrackVersionDTO>> getActiveVersion(
    AudioTrackId trackId,
  );

  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  });

  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId);
}

/// In-memory local data source used until code generation is wired.
@LazySingleton(as: TrackVersionLocalDataSource)
class InMemoryTrackVersionLocalDataSource
    implements TrackVersionLocalDataSource {
  final Map<String, List<TrackVersionDTO>> _byTrack = {};
  final Map<String, StreamController<List<TrackVersionDTO>>> _controllers = {};

  StreamController<List<TrackVersionDTO>> _controllerFor(String trackId) {
    return _controllers.putIfAbsent(
      trackId,
      () => StreamController<List<TrackVersionDTO>>.broadcast(),
    );
  }

  void _emit(String trackId) {
    final list = [...(_byTrack[trackId] ?? <TrackVersionDTO>[])];
    list.sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
    _controllerFor(trackId).add(list);
  }

  @override
  Future<Either<Failure, TrackVersionDTO>> addVersion({
    required AudioTrackId trackId,
    required File file,
    String? label,
  }) async {
    try {
      final versions = _byTrack.putIfAbsent(trackId.value, () => []);
      final next =
          (versions.isEmpty)
              ? 1
              : (versions
                      .map((e) => e.versionNumber)
                      .reduce((a, b) => a > b ? a : b) +
                  1);
      final dto = TrackVersionDTO(
        id: TrackVersionId().value,
        trackId: trackId.value,
        versionNumber: next,
        label: label,
        fileLocalPath: null,
        fileRemoteUrl: null,
        durationMs: null,
        waveformCachePath: null,
        status: 'processing',
        createdAt: DateTime.now(),
        createdBy: UserId().value,
      );
      versions.add(dto);
      _emit(trackId.value);
      return Right(dto);
    } catch (e) {
      return Left(CacheFailure('Failed to add version: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<TrackVersionDTO>>> watchVersionsByTrack(
    AudioTrackId trackId,
  ) {
    // Emit current then subsequent
    Future.microtask(() => _emit(trackId.value));
    return _controllerFor(trackId.value).stream.map((list) => Right(list));
  }

  @override
  Future<Either<Failure, TrackVersionDTO>> getById(TrackVersionId id) async {
    try {
      for (final list in _byTrack.values) {
        final found = list.where((e) => e.id == id.value).firstOrNull;
        if (found != null) return Right(found);
      }
      return Left(DatabaseFailure('Version not found'));
    } catch (e) {
      return Left(DatabaseFailure('Failed to get version: $e'));
    }
  }

  @override
  Future<Either<Failure, TrackVersionDTO>> getActiveVersion(
    AudioTrackId trackId,
  ) async {
    try {
      final list = _byTrack[trackId.value] ?? <TrackVersionDTO>[];
      if (list.isEmpty) return Left(DatabaseFailure('No versions found'));
      final sorted = [...list]
        ..sort((a, b) => b.versionNumber.compareTo(a.versionNumber));
      return Right(sorted.first);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active version: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> setActiveVersion({
    required AudioTrackId trackId,
    required TrackVersionId versionId,
  }) async {
    // For linear versions, latest is considered active locally. No-op.
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> deleteVersion(TrackVersionId versionId) async {
    try {
      for (final entry in _byTrack.entries) {
        final before = entry.value.length;
        entry.value.removeWhere((e) => e.id == versionId.value);
        if (entry.value.length != before) {
          _emit(entry.key);
          break;
        }
      }
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete version: $e'));
    }
  }
}
