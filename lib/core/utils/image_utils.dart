import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utility class for handling image operations safely
class ImageUtils {
  static const String _profileImagesDir = 'profile_images';

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
      debugPrint('Error creating image provider for $imagePath: $e');
      return null;
    }
  }

  /// Copies an image to a permanent location in the app's documents directory
  static Future<String?> copyImageToPermanentLocation(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('Source image file does not exist: $sourcePath');
        return null;
      }

      // Get the app's documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/$_profileImagesDir');

      // Create the images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename
      final extension = path.extension(sourcePath);
      final fileName =
          'image_${DateTime.now().millisecondsSinceEpoch}$extension';
      final destinationPath = '${imagesDir.path}/$fileName';

      // Copy the file
      final destinationFile = await sourceFile.copy(destinationPath);

      debugPrint('Image copied to: ${destinationFile.path}');
      return destinationFile.path;
    } catch (e) {
      debugPrint('Error copying image: $e');
      return null;
    }
  }

  /// Cleans up old profile images to prevent storage bloat
  static Future<void> cleanupOldImages({int maxAgeInDays = 30}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/$_profileImagesDir');

      if (!await imagesDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: maxAgeInDays));

      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            debugPrint('Deleted old image: ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old images: $e');
    }
  }

  /// Gets the total size of stored profile images
  static Future<int> getProfileImagesSize() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/$_profileImagesDir');

      if (!await imagesDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in imagesDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error calculating profile images size: $e');
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
      debugPrint('Error validating image file: $e');
      return false;
    }
  }
}
