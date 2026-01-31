import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hobby_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final HobbyService _hobbyService = HobbyService();

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String? get userEmail => _auth.currentUser?.email;
  String? get userName => _auth.currentUser?.displayName;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔐 Starting Google Sign-In...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('🔑 Got auth tokens');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔓 Signing in to Firebase...');

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      print('✅ Firebase sign-in successful: ${userCredential.user?.email}');
      
      // Save user data
      if (userCredential.user != null) {
        await _saveUserData(userCredential.user!);
        print('💾 User data saved');
      }

      return userCredential;
    } catch (e) {
      print('❌ Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Mark onboarding as complete
    await prefs.setBool('hasCompletedOnboarding', true);
    
    // Save auth method
    await prefs.setString('authMethod', 'google');
    
    // Save user name from Google account
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      await _hobbyService.setSetting('userName', user.displayName!);
    }
    
    // Save email
    if (user.email != null) {
      await _hobbyService.setSetting('userEmail', user.email!);
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('hasCompletedOnboarding');
      await prefs.remove('authMethod');
      
      // Clear user data but keep hobbies
      await _hobbyService.setSetting('userName', '');
      await _hobbyService.setSetting('userEmail', '');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<bool> isGoogleSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final authMethod = prefs.getString('authMethod');
    return authMethod == 'google' && _auth.currentUser != null;
  }

  Future<void> saveOfflineUser(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasCompletedOnboarding', true);
    await prefs.setString('authMethod', 'offline');
    await _hobbyService.setSetting('userName', name);
  }
}
