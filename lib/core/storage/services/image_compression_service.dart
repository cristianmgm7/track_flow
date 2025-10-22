import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/utils/app_logger.dart';

@lazySingleton
class ImageCompressionService {
  /// Compress image to WebP format with quality control
  ///
  /// [sourceFile] - Original image file
  /// [quality] - Compression quality 1-100 (default 85)
  ///
  /// Returns compressed WebP file
  Future<File?> compressToWebP({
    required File sourceFile,
    int quality = 85,
  }) async {
    try {
      final sourceExtension = path.extension(sourceFile.path).toLowerCase();

      // Skip compression if already WebP and small enough
      if (sourceExtension == '.webp') {
        final fileSize = await sourceFile.length();
        if (fileSize < 500000) { // 500KB threshold
          AppLogger.info(
            'Image already WebP and under 500KB, skipping compression',
            tag: 'IMAGE_COMPRESSION',
          );
          return sourceFile;
        }
      }

      final targetPath = sourceFile.path.replaceAll(
        RegExp(r'\.[^.]+$'),
        '_compressed.webp',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        quality: quality,
        format: CompressFormat.webp,
      );

      if (result == null) {
        AppLogger.warning(
          'Image compression returned null',
          tag: 'IMAGE_COMPRESSION',
        );
        return null;
      }

      final compressedFile = File(result.path);
      final originalSize = await sourceFile.length();
      final compressedSize = await compressedFile.length();
      final savedPercentage = ((originalSize - compressedSize) / originalSize * 100).toStringAsFixed(1);

      AppLogger.info(
        'Image compressed: ${originalSize} → ${compressedSize} bytes (saved ${savedPercentage}%)',
        tag: 'IMAGE_COMPRESSION',
      );

      return compressedFile;
    } catch (e) {
      AppLogger.error(
        'Image compression failed: $e',
        tag: 'IMAGE_COMPRESSION',
        error: e,
      );
      return null;
    }
  }

  /// Get recommended quality level based on original file size
  int getRecommendedQuality(int fileSizeBytes) {
    if (fileSizeBytes > 5000000) return 80; // >5MB: aggressive compression
    if (fileSizeBytes > 2000000) return 85; // 2-5MB: balanced
    return 90; // <2MB: preserve quality
  }
}
