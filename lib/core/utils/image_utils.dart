import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:trackflow/core/utils/app_logger.dart';

/// Simplified utility class for local image file operations
/// For network images, use CachedNetworkImage directly
class ImageUtils {
  static const String _localAvatarsDir = 'local_avatars';

  /// Copies a locally selected image to app storage
  /// Use this when user picks an image before uploading to Firebase
  static Future<String?> saveLocalImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        AppLogger.warning(
          'Source image file does not exist: $sourcePath',
          tag: 'IMAGE_UTILS',
        );
        return null;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/$_localAvatarsDir');

      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }

      final extension = path.extension(sourcePath);
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}$extension';
      final destinationPath = '${avatarsDir.path}/$fileName';

      await sourceFile.copy(destinationPath);

      AppLogger.info(
        'Image saved to local storage: $destinationPath',
        tag: 'IMAGE_UTILS',
      );
      return destinationPath;
    } catch (e) {
      AppLogger.error(
        'Error saving local image: $e',
        tag: 'IMAGE_UTILS',
      );
      return null;
    }
  }

  /// Deletes a local image file
  static Future<void> deleteLocalImage(String imagePath) async {
    try {
      if (imagePath.isEmpty || imagePath.startsWith('http')) {
        return; // Don't delete network URLs
      }

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Deleted local image: $imagePath', tag: 'IMAGE_UTILS');
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to delete local image: $imagePath - $e',
        tag: 'IMAGE_UTILS',
      );
    }
  }

  /// Validates if a file path points to a valid local image file
  static Future<bool> isValidLocalImage(String filePath) async {
    if (filePath.isEmpty || filePath.startsWith('http')) {
      return false;
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) return false;

      final extension = path.extension(filePath).toLowerCase();
      const validExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.bmp',
        '.webp',
        '.heic',
      ];

      return validExtensions.contains(extension);
    } catch (e) {
      AppLogger.error('Error validating image file: $e', tag: 'IMAGE_UTILS');
      return false;
    }
  }
}
