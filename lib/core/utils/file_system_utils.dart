import 'dart:io';
import 'package:uuid/uuid.dart';

/// Centralized utilities for file system operations
class FileSystemUtils {
  // Prevent instantiation
  FileSystemUtils._();

  /// Create directory if it doesn't exist
  /// Uses recursive creation for parent directories
  static Future<Directory> ensureDirectoryExists(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Delete file if it exists
  /// Returns true if deleted, false if didn't exist or error
  static Future<bool> deleteFileIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Extract file extension from path
  /// Returns null if no extension found or invalid
  static String? extractExtension(String path) {
    final idx = path.lastIndexOf('.');
    if (idx == -1) return null;
    final ext = path.substring(idx).toLowerCase();
    if (ext.length > 5) return null; // Avoid query strings
    return ext;
  }

  /// Generate unique filename for temporary recordings
  /// Format: recording_{timestamp}_{uuid}.{extension}
  static String generateUniqueFilename(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final uuid = const Uuid().v4().substring(0, 8);
    return 'recording_${timestamp}_$uuid$extension';
  }

  /// Get file size in bytes
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    return await file.length();
  }

  /// Check if file exists
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }
}
