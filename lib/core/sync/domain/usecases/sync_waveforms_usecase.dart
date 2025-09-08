import 'package:injectable/injectable.dart';
import 'package:trackflow/core/app_flow/data/session_storage.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/features/projects/data/datasources/project_remote_data_source.dart';
import 'package:trackflow/features/audio_track/data/datasources/audio_track_remote_datasource.dart';
import 'package:trackflow/features/track_version/data/datasources/track_version_local_data_source.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_local_datasource.dart';
import 'package:trackflow/features/waveform/data/datasources/waveform_remote_datasource.dart';
import 'package:trackflow/core/entities/unique_id.dart';
import 'package:trackflow/features/track_version/data/models/track_version_dto.dart';

/// 🔄 Sync Waveforms by Version (Downstream)
///
/// Pulls existing waveform JSONs from Firebase Storage for known versions
/// and saves them into Isar for UI consumption. No-ops when already cached.
@lazySingleton
class SyncWaveformsUseCase {
  final SessionStorage _sessionStorage;
  final ProjectRemoteDataSource _projectRemoteDataSource;
  final AudioTrackRemoteDataSource _audioTrackRemoteDataSource;
  final TrackVersionLocalDataSource _trackVersionLocalDataSource;
  final WaveformLocalDataSource _waveformLocalDataSource;
  final WaveformRemoteDataSource _waveformRemoteDataSource;

  SyncWaveformsUseCase(
    this._sessionStorage,
    this._projectRemoteDataSource,
    this._audioTrackRemoteDataSource,
    this._trackVersionLocalDataSource,
    this._waveformLocalDataSource,
    this._waveformRemoteDataSource,
  );

  Future<void> call({TrackVersionId? scopedVersionId}) async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) return; // Preserve local data when no user

    try {
      // Scoped: only sync a specific version's waveform
      if (scopedVersionId != null) {
        await _syncForVersions(<String>[scopedVersionId.value]);
        return;
      }

      // Try to rely on local versions (already synced by versions use case)
      final localVersionsEither =
          await _trackVersionLocalDataSource.getAllVersions();
      final List<TrackVersionDTO> localVersions = localVersionsEither.fold(
        (_) => <TrackVersionDTO>[],
        (v) => v,
      );

      if (localVersions.isEmpty) {
        // Fallback path: fetch projects -> tracks to ensure we have coverage
        final projectsEither = await _projectRemoteDataSource.getUserProjects(
          userId,
        );
        await projectsEither.fold((_) async {}, (projects) async {
          if (projects.isEmpty) return;
          final projectIds = projects.map((p) => p.id).toList();
          final tracks = await _audioTrackRemoteDataSource
              .getTracksByProjectIds(projectIds);

          for (final track in tracks) {
            final versionsStream = _trackVersionLocalDataSource
                .watchVersionsByTrackId(track.id.value);
            // Read one snapshot and proceed
            final snapshot = await versionsStream.first;
            final List<TrackVersionDTO> versions = snapshot.fold(
              (_) => <TrackVersionDTO>[],
              (v) => v,
            );
            await _syncForVersions(versions.map((e) => e.id).toList());
          }
        });
      } else {
        await _syncForVersions(localVersions.map((e) => e.id).toList());
      }
    } catch (e) {
      AppLogger.warning(
        'SyncWaveformsUseCase: failed: $e',
        tag: 'SYNC_WAVEFORMS',
      );
    }
  }

  Future<void> _syncForVersions(List<String> versionIds) async {
    for (final versionIdStr in versionIds) {
      try {
        final versionId = TrackVersionId.fromUniqueString(versionIdStr);
        // If already cached locally, skip
        final local = await _waveformLocalDataSource.getWaveformByVersionId(
          versionId,
        );
        if (local != null) continue;

        // Resolve trackId for canonical path and pull best remote waveform
        final versionResult = await _trackVersionLocalDataSource.getVersionById(
          versionIdStr,
        );
        final version = versionResult.fold((_) => null, (v) => v);
        if (version == null) continue;

        final remote = await _waveformRemoteDataSource.fetchBestForVersion(
          trackId: version.trackId,
          versionId: versionId,
        );
        if (remote != null) {
          await _waveformLocalDataSource.saveWaveform(remote);
        }
      } catch (_) {
        // best-effort; continue
      }
    }
  }
}
