import 'package:flutter_test/flutter_test.dart';
import 'package:hobbyist/services/auth_service.dart';
import 'package:hobbyist/services/hobby_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
  MockSpec<GoogleSignIn>(),
  MockSpec<GoogleSignInAccount>(),
  MockSpec<GoogleSignInAuthentication>(),
  MockSpec<UserCredential>(),
  MockSpec<HobbyService>(),
])
import 'auth_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService service;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockGoogleSignInAccount mockGoogleUser;
  late MockGoogleSignInAuthentication mockGoogleAuth;
  late MockUserCredential mockUserCredential;
  late MockHobbyService mockHobbyService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockGoogleSignIn = MockGoogleSignIn();
    mockGoogleUser = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockHobbyService = MockHobbyService();

    service = AuthService.forTesting(
      auth: mockAuth,
      googleSignIn: mockGoogleSignIn,
      hobbyService: mockHobbyService,
    );
    AuthService.instance = service;
  });

  tearDown(() {
    // Reset singleton if needed or just let it be
  });

  group('AuthService Tests', () {
    test('Singleton check', () {
      expect(AuthService(), same(AuthService()));
    });

    test('isLoggedIn returns correctly', () {
      when(mockAuth.currentUser).thenReturn(mockUser);
      expect(service.isLoggedIn, true);

      when(mockAuth.currentUser).thenReturn(null);
      expect(service.isLoggedIn, false);
    });

    test('userEmail and userName return correctly', () {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');

      expect(service.userEmail, 'test@example.com');
      expect(service.userName, 'Test User');
    });

    test('signInWithGoogle success', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleUser);
      when(
        mockGoogleUser.authentication,
      ).thenAnswer((_) async => mockGoogleAuth);
      when(mockGoogleAuth.accessToken).thenReturn('access_token');
      when(mockGoogleAuth.idToken).thenReturn('id_token');
      when(mockGoogleUser.email).thenReturn('test@example.com');

      when(
        mockAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');

      final result = await service.signInWithGoogle();

      expect(result, mockUserCredential);
      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockAuth.signInWithCredential(any)).called(1);
      verify(mockHobbyService.setSetting('userName', 'Test User')).called(1);
      verify(
        mockHobbyService.setSetting('userEmail', 'test@example.com'),
      ).called(1);
    });

    test('signInWithGoogle cancel', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

      final result = await service.signInWithGoogle();

      expect(result, isNull);
      verify(mockGoogleSignIn.signIn()).called(1);
      verifyNever(mockAuth.signInWithCredential(any));
    });

    test('signInWithGoogle error', () async {
      when(mockGoogleSignIn.signIn()).thenThrow(Exception('Sign in error'));

      final result = await service.signInWithGoogle();

      expect(result, isNull);
    });

    test('signOut success', () async {
      await service.signOut();

      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockAuth.signOut()).called(1);
      verify(mockHobbyService.setSetting('userName', '')).called(1);
      verify(mockHobbyService.setSetting('userEmail', '')).called(1);
    });

    test('isGoogleSignedIn', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authMethod', 'google');
      when(mockAuth.currentUser).thenReturn(mockUser);

      expect(await service.isGoogleSignedIn(), true);

      await prefs.setString('authMethod', 'offline');
      expect(await service.isGoogleSignedIn(), false);
    });

    test('saveOfflineUser', () async {
      await service.saveOfflineUser('Offline User');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('hasCompletedOnboarding'), true);
      expect(prefs.getString('authMethod'), 'offline');
      verify(mockHobbyService.setSetting('userName', 'Offline User')).called(1);
    });
  });
}
