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
  // In-memory throttle to avoid repeated attempts per version
  static final Map<String, DateTime> _lastAttemptAt = {};
  static const Duration _attemptTtl = Duration(minutes: 10);

  final SessionStorage _sessionStorage;
  // ignore: unused_field
  final ProjectRemoteDataSource _projectRemoteDataSource;
  // ignore: unused_field
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

  /// Expose local track version ids to orchestrators (no network)
  Future<List<String>> getLocalVersionIds() async {
    final localVersionsEither =
        await _trackVersionLocalDataSource.getAllVersions();
    return localVersionsEither.fold(
      (_) => <String>[],
      (versions) => versions.map((e) => e.id).toList(),
    );
  }

  Future<void> call({TrackVersionId? scopedVersionId}) async {
    final userId = await _sessionStorage.getUserId();
    if (userId == null) {
      AppLogger.info(
        'SyncWaveformsUseCase: No user ID, skipping sync',
        tag: 'SYNC_WAVEFORMS',
      );
      return; // Preserve local data when no user
    }

    try {
      // Scoped: only sync a specific version's waveform
      if (scopedVersionId != null) {
        AppLogger.info(
          'SyncWaveformsUseCase: Starting scoped sync for version ${scopedVersionId.value}',
          tag: 'SYNC_WAVEFORMS',
        );
        await _syncForVersions(<String>[scopedVersionId.value]);
        return;
      }

      // Rely on local versions (already synced by versions stage). If empty, no-op.
      final localVersionsEither =
          await _trackVersionLocalDataSource.getAllVersions();
      final List<TrackVersionDTO> localVersions = localVersionsEither.fold(
        (_) => <TrackVersionDTO>[],
        (v) => v,
      );

      AppLogger.info(
        'SyncWaveformsUseCase: Found ${localVersions.length} local versions',
        tag: 'SYNC_WAVEFORMS',
      );

      if (localVersions.isNotEmpty) {
        await _syncForVersions(localVersions.map((e) => e.id).toList());
      } else {
        AppLogger.warning(
          'SyncWaveformsUseCase: No local versions found, skipping waveform sync',
          tag: 'SYNC_WAVEFORMS',
        );
      }
    } catch (e) {
      AppLogger.warning(
        'SyncWaveformsUseCase: failed: $e',
        tag: 'SYNC_WAVEFORMS',
      );
    }
  }

  Future<void> _syncForVersions(List<String> versionIds) async {
    AppLogger.info(
      'SyncWaveformsUseCase: Processing ${versionIds.length} versions',
      tag: 'SYNC_WAVEFORMS',
    );

    for (final versionIdStr in versionIds) {
      try {
        final versionId = TrackVersionId.fromUniqueString(versionIdStr);
        AppLogger.debug(
          'SyncWaveformsUseCase: Processing version $versionIdStr',
          tag: 'SYNC_WAVEFORMS',
        );

        // If already cached locally, skip
        final local = await _waveformLocalDataSource.getWaveformByVersionId(
          versionId,
        );
        if (local != null) {
          AppLogger.debug(
            'SyncWaveformsUseCase: Version $versionIdStr already cached locally, skipping',
            tag: 'SYNC_WAVEFORMS',
          );
          continue;
        }

        // Throttle attempts per version to avoid repeated remote lookups
        final now = DateTime.now();
        final last = _lastAttemptAt[versionIdStr];
        if (last != null && now.difference(last) < _attemptTtl) {
          AppLogger.debug(
            'SyncWaveformsUseCase: Version $versionIdStr throttled (last attempt: $last)',
            tag: 'SYNC_WAVEFORMS',
          );
          continue;
        }

        // Resolve trackId for canonical path and pull best remote waveform
        final versionResult = await _trackVersionLocalDataSource.getVersionById(
          versionIdStr,
        );
        final version = versionResult.fold((_) => null, (v) => v);
        if (version == null) {
          AppLogger.warning(
            'SyncWaveformsUseCase: Could not resolve version $versionIdStr from local data',
            tag: 'SYNC_WAVEFORMS',
          );
          continue;
        }

        AppLogger.debug(
          'SyncWaveformsUseCase: Fetching canonical remote waveform for version $versionIdStr (track: ${version.trackId})',
          tag: 'SYNC_WAVEFORMS',
        );
        final remote = await _waveformRemoteDataSource.fetchCanonicalForVersion(
          trackId: version.trackId,
          versionId: versionId,
        );

        if (remote != null) {
          AppLogger.info(
            'SyncWaveformsUseCase: Canonical remote waveform found for version $versionIdStr, saving locally',
            tag: 'SYNC_WAVEFORMS',
          );
          await _waveformLocalDataSource.saveWaveform(remote);
          AppLogger.debug(
            'SyncWaveformsUseCase: Successfully saved waveform for version $versionIdStr',
            tag: 'SYNC_WAVEFORMS',
          );
        } else {
          AppLogger.warning(
            'SyncWaveformsUseCase: No canonical remote waveform found for version $versionIdStr',
            tag: 'SYNC_WAVEFORMS',
          );
        }

        _lastAttemptAt[versionIdStr] = now;
      } catch (e) {
        AppLogger.warning(
          'SyncWaveformsUseCase: Error processing version $versionIdStr: $e',
          tag: 'SYNC_WAVEFORMS',
        );
        // best-effort; continue
      }
    }

    AppLogger.info(
      'SyncWaveformsUseCase: Completed processing ${versionIds.length} versions',
      tag: 'SYNC_WAVEFORMS',
    );
  }
}
