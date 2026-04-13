import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
export 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import '../../profile/services/user_service.dart';

/// Service for managing user authentication via Firebase.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Attempt to initialize profile, but don't block login if it fails (log it instead)
      try {
        await UserService.initializeUserProfile(credential.user!.uid);
      } catch (e) {
        debugPrint('Warning: User profile initialization failed after login: $e');
      }
      
      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  static Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await UserService.createUser(
        uid: credential.user!.uid,
        email: email,
      );
      
      return credential;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  static Future<void> logout() async {
    UserService.clearCache();
    await _auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
