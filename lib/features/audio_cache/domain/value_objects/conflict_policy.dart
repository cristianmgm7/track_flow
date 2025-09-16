/// Simple conflict resolution policies for MVP
/// Determines how to handle conflicts when the same track is cached with different parameters
enum ConflictPolicy {
  /// Last cache request wins, overwrites existing
  lastWins,
  
  /// First cache request wins, ignore subsequent requests
  firstWins,
  
  /// Higher quality version wins
  higherQuality,
  
  /// Let user decide (future enhancement)
  userDecision,
}

extension ConflictPolicyExtension on ConflictPolicy {
  String get description {
    switch (this) {
      case ConflictPolicy.lastWins:
        return 'Latest cache request overwrites existing';
      case ConflictPolicy.firstWins:
        return 'Keep existing cache, ignore new requests';
      case ConflictPolicy.higherQuality:
        return 'Replace with higher quality version';
      case ConflictPolicy.userDecision:
        return 'Ask user to decide';
    }
  }

  bool get isAutomatic {
    return this != ConflictPolicy.userDecision;
  }
}