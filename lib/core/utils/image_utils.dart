import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:trackflow/core/utils/app_logger.dart';

/// Utility class for handling image operations safely
class ImageUtils {
  static const String _profileImagesDir = 'profile_images';
  static const String _permanentImagesDir = 'permanent_images';
  static const int _maxAgeInDays = 90; // Increased from 30 to 90 days

  /// Creates a safe image provider that handles missing files gracefully
  static ImageProvider? createSafeImageProvider(String imagePath) {
    if (imagePath.isEmpty) return null;

    try {
      if (imagePath.startsWith('http')) {
        return NetworkImage(imagePath);
      } else if (imagePath.startsWith('file://')) {
        final filePath = Uri.parse(imagePath).toFilePath();
        final file = File(filePath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return FileImage(file);
        }
      }

      // If we reach here, the file doesn't exist, try asset image as fallback
      return AssetImage(imagePath);
    } catch (e) {
      // If any error occurs during image provider creation, return null
      // This will show the default icon
      AppLogger.warning(
        'Error creating image provider for $imagePath: $e',
        tag: 'IMAGE_UTILS',
      );
      return null;
    }
  }

  /// Copies an image to a permanent location in the app's documents directory
  /// This ensures the image persists across app restarts and system cleanups
  static Future<String?> copyImageToPermanentLocation(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        AppLogger.warning(
          'Source image file does not exist: $sourcePath',
          tag: 'IMAGE_UTILS',
        );
        return null;
      }

      // Get the app's documents directory (permanent storage)
      final appDir = await getApplicationDocumentsDirectory();
      final permanentImagesDir = Directory(
        '${appDir.path}/$_permanentImagesDir',
      );

      // Create the permanent images directory if it doesn't exist
      if (!await permanentImagesDir.exists()) {
        await permanentImagesDir.create(recursive: true);
      }

      // Generate a unique filename with timestamp
      final extension = path.extension(sourcePath);
      final fileName =
          'image_${DateTime.now().millisecondsSinceEpoch}$extension';
      final destinationPath = '${permanentImagesDir.path}/$fileName';

      // Copy the file to permanent location
      final destinationFile = await sourceFile.copy(destinationPath);

      AppLogger.info(
        'Image copied to permanent location: ${destinationFile.path}',
        tag: 'IMAGE_UTILS',
      );
      return destinationFile.path;
    } catch (e) {
      AppLogger.error(
        'Error copying image to permanent location: $e',
        tag: 'IMAGE_UTILS',
      );
      return null;
    }
  }

  /// Validates and repairs image paths - ensures images exist and are accessible
  static Future<String?> validateAndRepairImagePath(String imagePath) async {
    if (imagePath.isEmpty) return null;

    try {
      // Check if the file exists
      final file = File(imagePath);
      if (await file.exists()) {
        return imagePath; // File exists, return original path
      }

      // File doesn't exist, try to find it in permanent storage
      if (imagePath.contains('profile_images')) {
        final repairedPath = await _findImageInPermanentStorage(imagePath);
        if (repairedPath != null) {
          AppLogger.info(
            'Repaired image path: $imagePath -> $repairedPath',
            tag: 'IMAGE_UTILS',
          );
          return repairedPath;
        }
      }

      AppLogger.warning(
        'Image file not found and cannot be repaired: $imagePath',
        tag: 'IMAGE_UTILS',
      );
      return null;
    } catch (e) {
      AppLogger.error('Error validating image path: $e', tag: 'IMAGE_UTILS');
      return null;
    }
  }

  /// Finds an image in permanent storage by extracting filename from original path
  static Future<String?> _findImageInPermanentStorage(
    String originalPath,
  ) async {
    try {
      final fileName = path.basename(originalPath);
      final appDir = await getApplicationDocumentsDirectory();
      final permanentImagesDir = Directory(
        '${appDir.path}/$_permanentImagesDir',
      );

      if (!await permanentImagesDir.exists()) return null;

      final file = File('${permanentImagesDir.path}/$fileName');
      if (await file.exists()) {
        return file.path;
      }

      return null;
    } catch (e) {
      AppLogger.error(
        'Error finding image in permanent storage: $e',
        tag: 'IMAGE_UTILS',
      );
      return null;
    }
  }

  /// Cleans up old profile images to prevent storage bloat
  /// Now only cleans temporary files, preserves permanent ones
  static Future<void> cleanupOldImages({
    int maxAgeInDays = _maxAgeInDays,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempImagesDir = Directory('${appDir.path}/$_profileImagesDir');

      if (!await tempImagesDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));
      int deletedCount = 0;

      await for (final entity in tempImagesDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            try {
              await entity.delete();
              deletedCount++;
              AppLogger.debug(
                'Deleted old temporary image: ${entity.path}',
                tag: 'IMAGE_UTILS',
              );
            } catch (e) {
              AppLogger.warning(
                'Failed to delete old image: ${entity.path}',
                tag: 'IMAGE_UTILS',
              );
            }
          }
        }
      }

      if (deletedCount > 0) {
        AppLogger.info(
          'Cleaned up $deletedCount old temporary images',
          tag: 'IMAGE_UTILS',
        );
      }
    } catch (e) {
      AppLogger.error('Error cleaning up old images: $e', tag: 'IMAGE_UTILS');
    }
  }

  /// Gets the total size of stored profile images
  static Future<int> getProfileImagesSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempImagesDir = Directory('${appDir.path}/$_profileImagesDir');
      final permanentImagesDir = Directory(
        '${appDir.path}/$_permanentImagesDir',
      );

      int totalSize = 0;

      // Calculate size of temporary images
      if (await tempImagesDir.exists()) {
        await for (final entity in tempImagesDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size;
          }
        }
      }

      // Calculate size of permanent images
      if (await permanentImagesDir.exists()) {
        await for (final entity in permanentImagesDir.list()) {
          if (entity is File) {
            final stat = await entity.stat();
            totalSize += stat.size;
          }
        }
      }

      return totalSize;
    } catch (e) {
      AppLogger.error(
        'Error calculating profile images size: $e',
        tag: 'IMAGE_UTILS',
      );
      return 0;
    }
  }

  /// Validates if a file path points to a valid image file
  static bool isValidImageFile(String filePath) {
    if (filePath.isEmpty) return false;

    try {
      final file = File(filePath);
      if (!file.existsSync()) return false;

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

  /// Creates a robust image widget that handles loading errors gracefully
  static Widget createRobustImageWidget({
    required String imagePath,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? fallbackWidget,
  }) {
    if (imagePath.isEmpty) {
      return _buildFallbackWidget(width, height, fallbackWidget);
    }

    return FutureBuilder<String?>(
      future: validateAndRepairImagePath(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final validPath = snapshot.data;
        if (validPath == null) {
          return _buildFallbackWidget(width, height, fallbackWidget);
        }

        return Image.file(
          File(validPath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            AppLogger.warning(
              'Error loading image: $error',
              tag: 'IMAGE_UTILS',
            );
            return _buildFallbackWidget(width, height, fallbackWidget);
          },
        );
      },
    );
  }

  static Widget _buildFallbackWidget(
    double width,
    double height,
    Widget? fallbackWidget,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child:
          fallbackWidget ??
          const Icon(Icons.person, color: Colors.grey, size: 40),
    );
  }

  /// Migrates existing images from temporary to permanent storage
  static Future<void> migrateImagesToPermanentStorage() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final tempImagesDir = Directory('${appDir.path}/$_profileImagesDir');
      final permanentImagesDir = Directory(
        '${appDir.path}/$_permanentImagesDir',
      );

      if (!await tempImagesDir.exists()) return;

      // Create permanent directory if it doesn't exist
      if (!await permanentImagesDir.exists()) {
        await permanentImagesDir.create(recursive: true);
      }

      int migratedCount = 0;
      await for (final entity in tempImagesDir.list()) {
        if (entity is File) {
          try {
            final fileName = path.basename(entity.path);
            final destinationPath = '${permanentImagesDir.path}/$fileName';
            final destinationFile = File(destinationPath);

            // Only migrate if destination doesn't exist
            if (!await destinationFile.exists()) {
              await entity.copy(destinationPath);
              migratedCount++;
              AppLogger.debug(
                'Migrated image: ${entity.path} -> $destinationPath',
                tag: 'IMAGE_UTILS',
              );
            }
          } catch (e) {
            AppLogger.warning(
              'Failed to migrate image: ${entity.path}',
              tag: 'IMAGE_UTILS',
            );
          }
        }
      }

      if (migratedCount > 0) {
        AppLogger.info(
          'Migrated $migratedCount images to permanent storage',
          tag: 'IMAGE_UTILS',
        );
      }
    } catch (e) {
      AppLogger.error('Error migrating images: $e', tag: 'IMAGE_UTILS');
    }
  }
}
