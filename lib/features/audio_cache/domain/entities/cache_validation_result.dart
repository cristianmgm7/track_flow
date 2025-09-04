import 'package:equatable/equatable.dart';

/// Cache validation results
class CacheValidationResult extends Equatable {
  const CacheValidationResult({
    required this.totalFiles,
    required this.validFiles,
    required this.corruptedFiles,
    required this.orphanedFiles,
    required this.missingMetadata,
    required this.inconsistentSizes,
    this.issues = const [],
  });

  final int totalFiles;
  final int validFiles;
  final int corruptedFiles;
  final int orphanedFiles;
  final int missingMetadata;
  final int inconsistentSizes;
  final List<String> issues;

  bool get isValid =>
      corruptedFiles == 0 &&
      orphanedFiles == 0 &&
      missingMetadata == 0 &&
      inconsistentSizes == 0;

  double get validityPercentage =>
      totalFiles > 0 ? (validFiles / totalFiles) : 1.0;

  @override
  List<Object?> get props => [
    totalFiles,
    validFiles,
    corruptedFiles,
    orphanedFiles,
    missingMetadata,
    inconsistentSizes,
    issues,
  ];
}
