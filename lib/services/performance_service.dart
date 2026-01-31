import 'package:firebase_performance/firebase_performance.dart';

/// PerformanceService - Manages performance monitoring and custom traces
/// 
/// This service integrates Firebase Performance Monitoring to track
/// app startup time, screen rendering, and custom performance metrics.
class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  static FirebasePerformance? _performance;

  factory PerformanceService() => _instance;

  PerformanceService._internal();

  /// Initialize Performance Monitoring
  static Future<void> initialize() async {
    _performance = FirebasePerformance.instance;

    // Enable performance monitoring in release mode only
    await _performance!.setPerformanceCollectionEnabled(true);

    print('📊 Performance Monitoring initialized');
  }

  /// Start a custom trace
  Future<Trace?> startTrace(String traceName) async {
    final trace = _performance?.newTrace(traceName);
    await trace?.start();
    return trace;
  }

  /// Stop a trace
  Future<void> stopTrace(Trace? trace) async {
    await trace?.stop();
  }

  /// Create and measure a database query trace
  Future<T> traceDatabaseQuery<T>(
    String queryName,
    Future<T> Function() operation,
  ) async {
    final trace = await startTrace('db_$queryName');
    try {
      final result = await operation();
      await stopTrace(trace);
      return result;
    } catch (e) {
      await stopTrace(trace);
      rethrow;
    }
  }

  /// Trace a screen load
  Future<T> traceScreenLoad<T>(
    String screenName,
    Future<T> Function() operation,
  ) async {
    final trace = await startTrace('screen_$screenName');
    try {
      final result = await operation();
      await stopTrace(trace);
      return result;
    } catch (e) {
      await stopTrace(trace);
      rethrow;
    }
  }

  /// Create a custom trace with automatic start/stop
  Future<T> traceOperation<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    final trace = _performance?.newTrace(operationName);
    
    // Add custom attributes
    if (attributes != null) {
      for (var entry in attributes.entries) {
        trace?.putAttribute(entry.key, entry.value);
      }
    }

    await trace?.start();
    
    try {
      final result = await operation();
      
      // Add custom metrics
      if (metrics != null) {
        for (var entry in metrics.entries) {
          trace?.setMetric(entry.key, entry.value);
        }
      }
      
      await trace?.stop();
      return result;
    } catch (e) {
      await trace?.stop();
      rethrow;
    }
  }

  /// Increment a metric on a trace
  void incrementMetric(Trace? trace, String metricName, int value) {
    trace?.incrementMetric(metricName, value);
  }

  /// Set a custom attribute on a trace
  void setAttribute(Trace? trace, String key, String value) {
    trace?.putAttribute(key, value);
  }
}
