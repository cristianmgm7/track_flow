/// Download priority levels for queue management
enum DownloadPriority {
  /// User-initiated immediate download (highest priority)
  high,
  
  /// Standard download priority
  normal,
  
  /// Low priority, can be delayed
  low,
  
  /// Background downloads when app is idle
  background,
}

extension DownloadPriorityExtension on DownloadPriority {
  /// Numeric value for priority comparison (higher = more priority)
  int get value {
    switch (this) {
      case DownloadPriority.high:
        return 100;
      case DownloadPriority.normal:
        return 50;
      case DownloadPriority.low:
        return 25;
      case DownloadPriority.background:
        return 1;
    }
  }

  String get description {
    switch (this) {
      case DownloadPriority.high:
        return 'High Priority (User-initiated)';
      case DownloadPriority.normal:
        return 'Normal Priority';
      case DownloadPriority.low:
        return 'Low Priority';
      case DownloadPriority.background:
        return 'Background';
    }
  }

  bool get isUserInitiated => this == DownloadPriority.high;
  bool get isBackground => this == DownloadPriority.background;
}