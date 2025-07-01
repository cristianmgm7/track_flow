import 'package:equatable/equatable.dart';

/// Detailed cleanup operation results
class CleanupDetails extends Equatable {
  const CleanupDetails({
    required this.corruptedFilesRemoved,
    required this.orphanedFilesRemoved,
    required this.temporaryFilesRemoved,
    required this.oldestFilesRemoved,
    required this.totalSpaceFreed,
    required this.totalFilesRemoved,
    this.errors = const [],
  });

  final int corruptedFilesRemoved;
  final int orphanedFilesRemoved;
  final int temporaryFilesRemoved;
  final int oldestFilesRemoved;
  final int totalSpaceFreed;
  final int totalFilesRemoved;
  final List<String> errors;

  bool get hasErrors => errors.isNotEmpty;

  String get summary =>
      'Removed $totalFilesRemoved files, freed ${_formatBytes(totalSpaceFreed)}';

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  @override
  List<Object?> get props => [
    corruptedFilesRemoved,
    orphanedFilesRemoved,
    temporaryFilesRemoved,
    oldestFilesRemoved,
    totalSpaceFreed,
    totalFilesRemoved,
    errors,
  ];
}
