import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:trackflow/core/utils/app_logger.dart';

/// Collects and tracks app performance metrics during startup and runtime
/// 
/// This service provides lightweight performance monitoring to help identify
/// bottlenecks and track initialization performance over time.
@injectable
class PerformanceMetricsCollector {
  final Map<String, PerformanceMetric> _metrics = {};
  final List<String> _initializationPhases = [];
  DateTime? _appStartTime;
  
  /// Starts tracking app initialization
  void startAppInitialization() {
    _appStartTime = DateTime.now();
    AppLogger.info('Started app performance tracking', tag: 'PERF_METRICS');
  }
  
  /// Records a performance metric
  void recordMetric(String name, Duration duration, {Map<String, dynamic>? metadata}) {
    final metric = PerformanceMetric(
      name: name,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
    
    _metrics[name] = metric;
    
    AppLogger.debug(
      'Recorded metric: $name took ${duration.inMilliseconds}ms',
      tag: 'PERF_METRICS',
    );
  }
  
  /// Times an async operation and records the metric
  Future<T> timeOperation<T>(String name, Future<T> Function() operation, {Map<String, dynamic>? metadata}) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await operation();
      stopwatch.stop();
      
      recordMetric(name, stopwatch.elapsed, metadata: metadata);
      return result;
      
    } catch (error) {
      stopwatch.stop();
      
      // Record failed operation with error info
      final errorMetadata = {
        ...?metadata,
        'error': error.toString(),
        'failed': true,
      };
      
      recordMetric(name, stopwatch.elapsed, metadata: errorMetadata);
      rethrow;
    }
  }
  
  /// Records an initialization phase completion
  void recordInitializationPhase(String phaseName, Duration duration) {
    _initializationPhases.add(phaseName);
    recordMetric('init_phase_$phaseName', duration);
    
    AppLogger.info(
      'Initialization phase "$phaseName" completed in ${duration.inMilliseconds}ms',
      tag: 'PERF_METRICS',
    );
  }
  
  /// Completes app initialization tracking
  void completeAppInitialization() {
    if (_appStartTime == null) {
      AppLogger.warning('App start time not recorded', tag: 'PERF_METRICS');
      return;
    }
    
    final totalDuration = DateTime.now().difference(_appStartTime!);
    recordMetric('app_initialization_total', totalDuration, metadata: {
      'phases': _initializationPhases,
      'phases_count': _initializationPhases.length,
    });
    
    AppLogger.info(
      'App initialization completed in ${totalDuration.inMilliseconds}ms',
      tag: 'PERF_METRICS',
    );
    
    // Log performance summary
    logPerformanceSummary();
  }
  
  /// Gets all collected metrics
  Map<String, PerformanceMetric> getAllMetrics() {
    return Map.unmodifiable(_metrics);
  }
  
  /// Gets a specific metric
  PerformanceMetric? getMetric(String name) {
    return _metrics[name];
  }
  
  /// Gets initialization metrics specifically
  Map<String, PerformanceMetric> getInitializationMetrics() {
    return Map.fromEntries(
      _metrics.entries.where((entry) => 
        entry.key.startsWith('init_') || 
        entry.key == 'app_initialization_total'
      ),
    );
  }
  
  /// Logs a performance summary
  void logPerformanceSummary() {
    if (_metrics.isEmpty) {
      AppLogger.info('No performance metrics collected', tag: 'PERF_METRICS');
      return;
    }
    
    AppLogger.info('=== PERFORMANCE SUMMARY ===', tag: 'PERF_METRICS');
    
    final sortedMetrics = _metrics.entries.toList()
      ..sort((a, b) => a.value.duration.compareTo(b.value.duration));
    
    for (final entry in sortedMetrics) {
      final metric = entry.value;
      final failed = metric.metadata['failed'] == true ? ' [FAILED]' : '';
      
      AppLogger.info(
        '${entry.key}: ${metric.duration.inMilliseconds}ms$failed',
        tag: 'PERF_METRICS',
      );
    }
    
    AppLogger.info('=== END PERFORMANCE SUMMARY ===', tag: 'PERF_METRICS');
  }
  
  /// Gets performance statistics
  Map<String, dynamic> getPerformanceStatistics() {
    if (_metrics.isEmpty) {
      return {'metrics_count': 0, 'total_time': 0};
    }
    
    final durations = _metrics.values.map((m) => m.duration.inMilliseconds).toList();
    final totalTime = durations.fold<int>(0, (sum, duration) => sum + duration);
    final avgTime = totalTime / durations.length;
    
    durations.sort();
    final medianTime = durations.length % 2 == 0
        ? (durations[durations.length ~/ 2 - 1] + durations[durations.length ~/ 2]) / 2
        : durations[durations.length ~/ 2].toDouble();
    
    return {
      'metrics_count': _metrics.length,
      'total_time_ms': totalTime,
      'average_time_ms': avgTime.round(),
      'median_time_ms': medianTime.round(),
      'min_time_ms': durations.first,
      'max_time_ms': durations.last,
      'failed_operations': _metrics.values.where((m) => m.metadata['failed'] == true).length,
    };
  }
  
  /// Clears all metrics (useful for testing)
  void clear() {
    _metrics.clear();
    _initializationPhases.clear();
    _appStartTime = null;
    AppLogger.debug('Cleared all performance metrics', tag: 'PERF_METRICS');
  }
}

/// Represents a single performance metric
class PerformanceMetric {
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  const PerformanceMetric({
    required this.name,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });
  
  @override
  String toString() {
    return 'PerformanceMetric(name: $name, duration: ${duration.inMilliseconds}ms, timestamp: $timestamp)';
  }
}