import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/utils/app_logger.dart';
import 'package:trackflow/core/utils/image_utils.dart';

/// Service responsible for maintaining image integrity and storage
///
/// This service performs periodic maintenance tasks to ensure:
/// - Images are properly stored in permanent locations
/// - Orphaned files are cleaned up
/// - Storage usage is optimized
@injectable
class ImageMaintenanceService {
  Timer? _maintenanceTimer;
  static const Duration _maintenanceInterval = Duration(
    hours: 6,
  ); // Run every 6 hours

  /// Start periodic maintenance
  void startPeriodicMaintenance() {
    if (_maintenanceTimer != null) {
      AppLogger.warning(
        'Image maintenance already running',
        tag: 'IMAGE_MAINTENANCE',
      );
      return;
    }

    AppLogger.info(
      'Starting periodic image maintenance',
      tag: 'IMAGE_MAINTENANCE',
    );

    _maintenanceTimer = Timer.periodic(_maintenanceInterval, (timer) {
      _performMaintenance();
    });

    // Perform initial maintenance
    _performMaintenance();
  }

  /// Stop periodic maintenance
  void stopPeriodicMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = null;
    AppLogger.info(
      'Stopped periodic image maintenance',
      tag: 'IMAGE_MAINTENANCE',
    );
  }

  /// Perform maintenance tasks
  Future<void> _performMaintenance() async {
    try {
      AppLogger.info(
        'Starting image maintenance cycle',
        tag: 'IMAGE_MAINTENANCE',
      );

      // Migrate any remaining images to permanent storage
      await ImageUtils.migrateImagesToPermanentStorage();

      // Clean up old temporary images
      await ImageUtils.cleanupOldImages();

      // Get storage statistics
      final totalSize = await ImageUtils.getProfileImagesSize();
      final sizeInMB = (totalSize / (1024 * 1024)).toStringAsFixed(2);

      AppLogger.info(
        'Image maintenance completed. Total storage: ${sizeInMB}MB',
        tag: 'IMAGE_MAINTENANCE',
      );
    } catch (e) {
      AppLogger.error('Image maintenance failed: $e', tag: 'IMAGE_MAINTENANCE');
    }
  }

  /// Perform immediate maintenance (for manual triggers)
  Future<void> performImmediateMaintenance() async {
    AppLogger.info(
      'Performing immediate image maintenance',
      tag: 'IMAGE_MAINTENANCE',
    );
    await _performMaintenance();
  }

  /// Get maintenance status
  bool get isRunning => _maintenanceTimer != null;

  /// Dispose resources
  void dispose() {
    stopPeriodicMaintenance();
  }
}
