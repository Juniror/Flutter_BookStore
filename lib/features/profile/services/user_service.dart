import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/base_service.dart';

/// Service for managing user profile data and roles in Firestore.
class UserService extends BaseService {
  static final _usersCollection =
      BaseService.firestore.collection(FirebaseConstants.collections.users);

  static String? _currentUid;
  static String? _currentRole;

  static String? get currentUid => _currentUid;
  static String? get currentRole => _currentRole;

  /// Initializes the user profile cache. Call this after successful login.
  static Future<void> initializeUserProfile(String uid) async {
    _currentUid = uid;
    _currentRole = await getRole(uid);
  }

  /// Clears the user profile cache. Call this on logout.
  static void clearCache() {
    _currentUid = null;
    _currentRole = null;
  }

  /// Stream to listen for real-time role changes.
  static Stream<String?> roleStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        final role = doc.data()?[FirebaseConstants.fields.userRole] as String?;
        // Synchronize local cache for the current user.
        if (uid == _currentUid) _currentRole = role;
        return role;
      }
      return null;
    });
  }

  static Future<void> createUser({
    required String uid,
    required String email,
    String? role,
  }) async {
    try {
      final assignRole = role ?? FirebaseConstants.roles.user;
      
      await _usersCollection.doc(uid).set({
        FirebaseConstants.fields.userUuid: uid,
        FirebaseConstants.fields.userRole: assignRole,
        FirebaseConstants.fields.userCreateDate: FieldValue.serverTimestamp(),
      });

      // Cache results for the current session.
      _currentUid = uid;
      _currentRole = assignRole;
    } catch (e) {
      throw Exception('Failed to create user record: $e');
    }
  }

  static Future<String?> getRole(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return doc.data()?[FirebaseConstants.fields.userRole] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> updateRole(String uid, String role) async {
    try {
      await _usersCollection.doc(uid).set(
        {FirebaseConstants.fields.userRole: role},
        SetOptions(merge: true),
      );
      // Update cache if it's the current user
      if (uid == _currentUid) {
        _currentRole = role;
      }
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  /// Updates the user's display name in Firebase Auth and Firestore.
  static Future<void> updateUserProfile(String uid, String name) async {
    try {
      // 1. Update Firebase Auth Profile
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == uid) {
        await user.updateDisplayName(name);
        await user.reload();
      }

      // 2. Persist profile changes in Firestore.
      await _usersCollection.doc(uid).set({
        FirebaseConstants.fields.userDisplayName: name,
        FirebaseConstants.fields.userUpdatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
