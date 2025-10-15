import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:trackflow/core/error/failures.dart';

/// Directory types supported by the application
enum DirectoryType {
  /// Persistent audio cache (base): /Documents/trackflow/audio
  /// @deprecated Use audioTracks or audioComments for new implementations
  audioCache,

  /// Track audio files: /Documents/trackflow/audio/tracks
  audioTracks,

  /// Audio comment files: /Documents/trackflow/audio/comments
  audioComments,

  /// Voice memo files: /Documents/trackflow/audio/voice_memos
  voiceMemos,

  /// Local avatars: /Documents/local_avatars
  localAvatars,

  /// Temporary files: /SystemTemp
  temporary,

  /// Application documents: /Documents
  documents,
}

/// Service for centralized directory management
/// Eliminates code duplication and ensures consistent path handling
abstract class DirectoryService {
  /// Get directory for the specified type
  /// Creates directory if it doesn't exist
  ///
  /// [type] - Type of directory to retrieve
  ///
  /// Returns Directory object on success
  Future<Either<Failure, Directory>> getDirectory(DirectoryType type);

  /// Get subdirectory within a directory type
  /// Creates directory if it doesn't exist
  ///
  /// [type] - Base directory type
  /// [subPath] - Relative path within the directory
  ///
  /// Example: getSubdirectory(DirectoryType.audioCache, 'trackId123')
  /// Returns: /Documents/trackflow/audio/trackId123
  Future<Either<Failure, Directory>> getSubdirectory(
    DirectoryType type,
    String subPath,
  );

  /// Ensure directory exists, creating if necessary
  ///
  /// [path] - Absolute path to directory
  ///
  /// Returns Directory object on success
  Future<Either<Failure, Directory>> ensureDirectoryExists(String path);

  /// Get file path within a directory type
  /// Ensures parent directory exists
  ///
  /// [type] - Base directory type
  /// [relativePath] - Relative file path
  ///
  /// Returns absolute file path string
  Future<Either<Failure, String>> getFilePath(
    DirectoryType type,
    String relativePath,
  );

  /// Convert absolute path to relative path for a directory type
  ///
  /// [absolutePath] - Full path to file
  /// [type] - Directory type to make relative to
  ///
  /// Returns relative path string
  String getRelativePath(String absolutePath, DirectoryType type);

  /// Get absolute path from relative path
  ///
  /// [relativePath] - Relative path within directory
  /// [type] - Directory type to resolve against
  ///
  /// Returns absolute path string
  Future<Either<Failure, String>> getAbsolutePath(
    String relativePath,
    DirectoryType type,
  );
}
