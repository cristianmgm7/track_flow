/// Cleanup operation results
class CleanupResult {
  const CleanupResult({
    required this.removedFiles,
    required this.freedSpaceBytes,
    required this.corruptedRemoved,
    required this.orphanedRemoved,
    this.errors = const [],
  });

  final int removedFiles;
  final int freedSpaceBytes;
  final int corruptedRemoved;
  final int orphanedRemoved;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;

  String get formattedFreedSpace {
    if (freedSpaceBytes < 1024) return '${freedSpaceBytes}B';
    if (freedSpaceBytes < 1024 * 1024)
      return '${(freedSpaceBytes / 1024).toStringAsFixed(1)}KB';
    if (freedSpaceBytes < 1024 * 1024 * 1024) {
      return '${(freedSpaceBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(freedSpaceBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}
