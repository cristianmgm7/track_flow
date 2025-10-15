/// Centralized utilities for audio file format detection and conversion
class AudioFormatUtils {
  // Prevent instantiation
  AudioFormatUtils._();

  /// Map file extensions to MIME types
  static const Map<String, String> extensionToMimeType = {
    '.mp3': 'audio/mpeg',
    '.wav': 'audio/wav',
    '.m4a': 'audio/mp4',
    '.aac': 'audio/aac',
    '.ogg': 'audio/ogg',
    '.flac': 'audio/flac',
  };

  /// Map MIME types to file extensions (handles variations)
  static const Map<String, String> mimeTypeToExtension = {
    'audio/mpeg': '.mp3',
    'audio/mp3': '.mp3',
    'audio/mp4': '.m4a',
    'audio/aac': '.m4a',
    'audio/x-m4a': '.m4a',
    'audio/m4a': '.m4a',
    'audio/wav': '.wav',
    'audio/x-wav': '.wav',
    'audio/ogg': '.ogg',
    'application/ogg': '.ogg',
    'audio/flac': '.flac',
  };

  /// Get MIME content type from file extension
  /// Returns 'audio/mpeg' as default if not found
  static String getContentType(String fileExtension) {
    return extensionToMimeType[fileExtension.toLowerCase()] ?? 'audio/mpeg';
  }

  /// Get file extension from MIME content type
  /// Handles charset and other parameters
  static String? getExtensionFromMimeType(String mimeType) {
    final type = mimeType.split(';').first.trim().toLowerCase();
    return mimeTypeToExtension[type];
  }

  /// Extract file extension from file path
  /// Returns '.mp3' as default if not found
  static String getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '.mp3';
    final ext = filePath.substring(lastDot).toLowerCase();
    // Validate reasonable length to avoid query strings
    if (ext.length > 5) return '.mp3';
    return ext;
  }

  /// Supported audio file extensions
  static const List<String> supportedExtensions = [
    '.mp3',
    '.wav',
    '.m4a',
    '.aac',
    '.ogg',
    '.flac',
  ];
}
