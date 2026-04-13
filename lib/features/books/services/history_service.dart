import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/base_service.dart';
import '../models/reading_history.dart';
import '../models/book.dart';

/// Service for managing user reading history and session logs.
class HistoryService extends BaseService {
  static CollectionReference get _historyCollection => BaseService.firestore
      .collection(FirebaseConstants.collections.readingHistory);

  /// Add a book to reading history (Upsert)
  static Future<void> addToHistory({
    required Book book,
    required String userId,
  }) async {
    try {
      final docId = '${userId}_${book.id}';

      final record = ReadingHistory(
        id: docId,
        userId: userId,
        bookId: book.id,
        bookTitle: book.title,
        bookAuthor: book.author,
        timestamp: DateTime.now(),
      );

      await _historyCollection
          .doc(docId)
          .set(record.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error adding to history: $e');
    }
  }

  /// Check if a book is in user history
  static Stream<bool> isInHistory(String userId, String bookId) {
    return _historyCollection
        .doc('${userId}_$bookId')
        .snapshots()
        .map((doc) => doc.exists);
  }

  /// Remove book from history
  static Future<void> removeFromHistory(String userId, String bookId) async {
    try {
      await _historyCollection.doc('${userId}_$bookId').delete();
    } catch (e) {
      debugPrint('Error removing from history: $e');
    }
  }

  /// Get reading history for a user
  static Stream<List<ReadingHistory>> getHistory(String userId) {
    return _historyCollection
        .where(FirebaseConstants.fields.historyUserId, isEqualTo: userId)
        .snapshots()
        .map(
      (snapshot) {
        final list = snapshot.docs
            .map((doc) => ReadingHistory.fromFirestore(doc))
            .toList();
        
        // Sort in memory to avoid index requirements during initial setup
        list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return list;
      },
    );
  }

  /// Clear history for a user
  static Future<void> clearHistory(String userId) async {
    try {
      final snapshot = await _historyCollection
          .where(FirebaseConstants.fields.historyUserId, isEqualTo: userId)
          .get();

      const int batchSize = 500;
      final docs = snapshot.docs;

      for (var i = 0; i < docs.length; i += batchSize) {
        final batch = BaseService.firestore.batch();
        final end = (i + batchSize < docs.length) ? i + batchSize : docs.length;

        for (var j = i; j < end; j++) {
          batch.delete(docs[j].reference);
        }

        await batch.commit();
      }
    } catch (e) {
      throw Exception('Failed to clear history: $e');
    }
  }
}
