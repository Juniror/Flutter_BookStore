import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as developer;

/// Base class for all Firebase services.
/// Provides centralized access to Firebase instances and common utility methods.
abstract class BaseService {
  /// Entry point for all Firestore operations.
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Logs generic service errors to the console in a professional format.
  void logError(String service, dynamic error) {
    developer.log('[$service Error]: $error', name: 'app.services');
  }
}
