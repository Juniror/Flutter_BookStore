import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/base_service.dart';
import '../models/book.dart';
import '../models/favorite_record.dart';

class FavoriteService extends BaseService {
  static CollectionReference get _favoritesCollection => 
      BaseService.firestore.collection(FirebaseConstants.collections.favorites);

  /// Generates a composite document ID combining [userId] and [bookId].
  static String _getDocId(String userId, String bookId) => '${userId}_$bookId';

  /// Toggles the favorite status for a [book] and [userId].
  /// Adds a record if it doesn't exist; removes it if it does.
  static Future<void> toggleFavorite({
    required Book book,
    required String userId,
  }) async {
    try {
      final docId = _getDocId(userId, book.id);
      final docRef = _favoritesCollection.doc(docId);
      
      final doc = await docRef.get();

      if (doc.exists) {
        // Remove favorite
        await docRef.delete();
      } else {
        // Add favorite
        final record = FavoriteRecord(
          userId: userId,
          bookId: book.id,
          bookTitle: book.title,
          bookAuthor: book.author,
          addedAt: DateTime.now(),
        );
        await docRef.set(record.toMap());
      }
    } catch (e) {
      throw Exception('Failed to update favorite status: $e');
    }
  }

  /// Returns a stream yielding the favorite status of a specific [bookId] for [userId].
  static Stream<bool> isFavorite(String userId, String bookId) {
    final docId = _getDocId(userId, bookId);
    return _favoritesCollection.doc(docId).snapshots().map((doc) => doc.exists);
  }

  /// Returns a stream of all [FavoriteRecord]s for the specified [userId].
  /// Note: Sorting is performed client-side in Dart to avoid complex index requirements.
  static Stream<List<FavoriteRecord>> getFavorites(String userId) {
    return _favoritesCollection
        .where(FirebaseConstants.fields.favUserId, isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      // Sort the results in Dart (client-side) instead of Firestore
      final List<FavoriteRecord> list = snapshot.docs
          .map((doc) => FavoriteRecord.fromFirestore(doc))
          .toList();
      
      list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return list;
    });
  }

  /// Explicitly removes a favorite entry by [bookId].
  static Future<void> removeFavorite(String userId, String bookId) async {
    try {
      final docId = _getDocId(userId, bookId);
      await _favoritesCollection.doc(docId).delete();
    } catch (e) {
      throw Exception('Failed to remove favorite: $e');
    }
  }
}
