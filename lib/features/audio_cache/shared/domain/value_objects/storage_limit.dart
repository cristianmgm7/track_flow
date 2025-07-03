import 'package:equatable/equatable.dart';

abstract class ValueObject<T> extends Equatable {
  const ValueObject(this.value);
  
  final T value;
  
  @override
  List<Object?> get props => [value];
  
  @override
  String toString() => value.toString();
}

class StorageLimit extends ValueObject<int> {
  const StorageLimit._(super.bytes);

  /// Default storage limit: 500MB
  static const StorageLimit defaultLimit = StorageLimit._(500 * 1024 * 1024);

  /// Create storage limit from megabytes
  factory StorageLimit.megabytes(int mb) {
    if (mb < 0) throw ArgumentError('Storage limit cannot be negative');
    return StorageLimit._(mb * 1024 * 1024);
  }

  /// Create storage limit from gigabytes
  factory StorageLimit.gigabytes(int gb) {
    if (gb < 0) throw ArgumentError('Storage limit cannot be negative');
    return StorageLimit._(gb * 1024 * 1024 * 1024);
  }

  /// Create storage limit from bytes
  factory StorageLimit.bytes(int bytes) {
    if (bytes < 0) throw ArgumentError('Storage limit cannot be negative');
    return StorageLimit._(bytes);
  }

  /// Unlimited storage (use with caution)
  static const StorageLimit unlimited = StorageLimit._(-1);

  /// Get limit in bytes
  int get bytes => value;

  /// Get limit in megabytes
  double get megabytes => value / (1024 * 1024);

  /// Get limit in gigabytes
  double get gigabytes => value / (1024 * 1024 * 1024);

  /// Check if this is unlimited storage
  bool get isUnlimited => value == -1;

  /// Check if current usage exceeds this limit
  bool isExceeded(int currentUsageBytes) {
    if (isUnlimited) return false;
    return currentUsageBytes > value;
  }

  /// Get percentage of limit used
  double getUsagePercentage(int currentUsageBytes) {
    if (isUnlimited) return 0.0;
    if (value == 0) return 0.0;
    return (currentUsageBytes / value).clamp(0.0, 1.0);
  }

  /// Get remaining space in bytes
  int getRemainingBytes(int currentUsageBytes) {
    if (isUnlimited) return double.maxFinite.toInt();
    return (value - currentUsageBytes).clamp(0, value);
  }

  /// Format storage limit for display
  String get formatted {
    if (isUnlimited) return 'Unlimited';
    
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${megabytes.toStringAsFixed(1)}MB';
    return '${gigabytes.toStringAsFixed(1)}GB';
  }

  /// Common predefined limits
  static const StorageLimit small = StorageLimit._(100 * 1024 * 1024); // 100MB
  static const StorageLimit medium = StorageLimit._(500 * 1024 * 1024); // 500MB
  static const StorageLimit large = StorageLimit._(1024 * 1024 * 1024); // 1GB
  static const StorageLimit xlarge = StorageLimit._(5 * 1024 * 1024 * 1024); // 5GB
}