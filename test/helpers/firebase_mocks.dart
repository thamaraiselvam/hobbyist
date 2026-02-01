import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

class MockFirebasePlatform extends FirebasePlatform {
  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return FirebaseAppPlatform(
      name ?? '[DEFAULT]',
      options ?? const FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );
  }

  @override
  List<FirebaseAppPlatform> get apps => [
        FirebaseAppPlatform(
          '[DEFAULT]',
          const FirebaseOptions(
            apiKey: '123',
            appId: '123',
            messagingSenderId: '123',
            projectId: '123',
          ),
        ),
      ];

  @override
  FirebaseAppPlatform app([String name = '[DEFAULT]']) {
    return FirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: '123',
        appId: '123',
        messagingSenderId: '123',
        projectId: '123',
      ),
    );
  }
}

Future<void> setupFirebaseMocks() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Use the mock platform for Core
  FirebasePlatform.instance = MockFirebasePlatform();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Mock channels for other Firebase services which might still use MethodChannels
  
  // Mock Firebase Auth
  const MethodChannel authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  authChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'Auth#registerIdTokenListener') {
      return null;
    }
    if (methodCall.method == 'Auth#registerAuthStateListener') {
      return null;
    }
    return null;
  });
  
  // Mock Firebase Analytics
  const MethodChannel analyticsChannel = MethodChannel('plugins.flutter.io/firebase_analytics');
  analyticsChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    return null;
  });

   // Mock Firebase Performance
  const MethodChannel performanceChannel = MethodChannel('plugins.flutter.io/firebase_performance');
  performanceChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    return null;
  });

  // Mock Firebase Remote Config
  const MethodChannel remoteConfigChannel = MethodChannel('plugins.flutter.io/firebase_remote_config');
  remoteConfigChannel.setMockMethodCallHandler((MethodCall methodCall) async {
     if (methodCall.method == 'RemoteConfig#ensureInitialized') {
      return {
        'lastFetchTime': 0,
        'lastFetchStatus': 'success',
        'settings': {'minimumFetchInterval': 0, 'fetchTimeout': 60},
      };
    }
    return null;
  });
  
  // Mock Firebase Crashlytics
    const MethodChannel crashlyticsChannel = MethodChannel('plugins.flutter.io/firebase_crashlytics');
  crashlyticsChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    return null;
  });
  
  // Mock Google Sign In
  const MethodChannel googleSignInChannel = MethodChannel('plugins.flutter.io/google_sign_in');
  googleSignInChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'init') {
      return null;
    }
    return null;
  });
}
