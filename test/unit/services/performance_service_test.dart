import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/performance_service.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/services.dart';
import 'package:hobbyist/database/database_helper.dart';
import 'dart:io';

@GenerateNiceMocks([MockSpec<FirebasePerformance>(), MockSpec<Trace>()])
import 'performance_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PerformanceService service;
  late MockFirebasePerformance mockPerformance;
  late MockTrace mockTrace;

  // Each test file gets a unique temp directory so concurrent test runs
  // don't collide on the same hobbyist.db file path.
  final testDir = Directory.systemTemp.createTempSync('hobbyist_perf_test_');

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            return testDir.path;
          },
        );
  });

  setUp(() async {
    // Close before deleting so sqflite's singleInstance pool releases the path.
    await DatabaseHelper.instance.close();
    final file = File('${testDir.path}/hobbyist.db');
    if (file.existsSync()) file.deleteSync();

    mockPerformance = MockFirebasePerformance();
    mockTrace = MockTrace();

    when(mockPerformance.newTrace(any)).thenReturn(mockTrace);

    PerformanceService.mockPerformance = mockPerformance;
    await PerformanceService.initialize();
    service = PerformanceService();

    // Enable telemetry for tests that expect it enabled
    final db = await DatabaseHelper.instance.database;
    await db.insert('settings', {
      'key': 'telemetry_enabled',
      'value': 'true',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  });

  tearDown(() {
    PerformanceService.mockPerformance = null;
  });

  group('PerformanceService Tests', () {
    test('Singleton check', () {
      expect(PerformanceService(), same(PerformanceService()));
    });

    test('updateCollectionEnabled', () async {
      when(
        mockPerformance.setPerformanceCollectionEnabled(true),
      ).thenAnswer((_) async {});

      await service.updateCollectionEnabled();
      verify(mockPerformance.setPerformanceCollectionEnabled(true)).called(1);
    });

    test('startTrace and stopTrace', () async {
      final trace = await service.startTrace('test_trace');
      expect(trace, same(mockTrace));
      verify(mockPerformance.newTrace('test_trace')).called(1);
      verify(mockTrace.start()).called(1);

      await service.stopTrace(trace);
      verify(mockTrace.stop()).called(1);
    });

    test('traceDatabaseQuery success', () async {
      final result = await service.traceDatabaseQuery('test_query', () async {
        return 'success';
      });

      expect(result, 'success');
      verify(mockPerformance.newTrace('db_test_query')).called(1);
      verify(mockTrace.start()).called(1);
      verify(mockTrace.stop()).called(1);
    });

    test('traceDatabaseQuery error', () async {
      try {
        await service.traceDatabaseQuery('test_query', () async {
          throw Exception('error');
        });
      } catch (_) {}

      verify(mockTrace.start()).called(1);
      verify(mockTrace.stop()).called(1);
    });

    test('traceScreenLoad', () async {
      await service.traceScreenLoad('test_screen', () async {
        return 'done';
      });

      verify(mockPerformance.newTrace('screen_test_screen')).called(1);
      verify(mockTrace.stop()).called(1);
    });

    test('traceOperation with attributes and metrics', () async {
      await service.traceOperation(
        'test_op',
        () async => 'result',
        attributes: {'attr': 'val'},
        metrics: {'met': 123},
      );

      verify(mockTrace.putAttribute('attr', 'val')).called(1);
      verify(mockTrace.setMetric('met', 123)).called(1);
      verify(mockTrace.start()).called(1);
      verify(mockTrace.stop()).called(1);
    });

    test('traceOperation error', () async {
      try {
        await service.traceOperation('test_op', () async {
          throw Exception('error');
        });
      } catch (_) {}

      verify(mockTrace.stop()).called(1);
    });

    test('incrementMetric and setAttribute', () {
      service.incrementMetric(mockTrace, 'm', 1);
      verify(mockTrace.incrementMetric('m', 1)).called(1);

      service.setAttribute(mockTrace, 'k', 'v');
      verify(mockTrace.putAttribute('k', 'v')).called(1);
    });

    test('Behavior when telemetry is disabled', () async {
      final db = await DatabaseHelper.instance.database;
      await db.insert('settings', {
        'key': 'telemetry_enabled',
        'value': 'false',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      final trace = await service.startTrace('test');
      expect(trace, isNull);
      verifyNever(mockPerformance.newTrace(any));

      final result = await service.traceOperation('test_op', () async => 'ok');
      expect(result, 'ok');
      verifyNever(mockPerformance.newTrace(any));
    });
  });
}
