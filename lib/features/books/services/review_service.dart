import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/review.dart';

/// Manages Firestore operations for user reviews and book ratings.
class ReviewService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String _collection = FirebaseConstants.collections.reviews;

  /// Submits a new review and updates the book's aggregate rating.
  /// Uses a transaction to ensure data consistency between reviews and book metadata.
  static Future<void> addReview({
    required String bookId,
    required String userId,
    required String userName,
    String? userEmail,
    required double rating,
    required String comment,
  }) async {
    final bookRef = _db.collection(FirebaseConstants.collections.books).doc(bookId);
    final reviewRef = _db.collection(_collection).doc();

    await _db.runTransaction((transaction) async {
      final bookDoc = await transaction.get(bookRef);
      if (!bookDoc.exists) throw Exception('Book not found');

      final data = bookDoc.data()!;
      final double currentAvg = (data['averageRating'] ?? 0.0).toDouble();
      final int currentCount = data['reviewCount'] ?? 0;

      final double newAvg = ((currentAvg * currentCount) + rating) / (currentCount + 1);
      final int newCount = currentCount + 1;

      // Create review
      final review = Review(
        id: reviewRef.id,
        bookId: bookId,
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      transaction.set(reviewRef, review.toMap());
      transaction.update(bookRef, {
        'averageRating': newAvg,
        'reviewCount': newCount,
      });
    });
  }

  /// Streams reviews for a specific book, ordered by newest first.
  static Stream<List<Review>> getReviews(String bookId) {
    return _db
        .collection(_collection)
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  /// Checks if a user has already reviewed a book.
  static Future<bool> hasUserReviewed(String userId, String bookId) async {
    final snapshot = await _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('bookId', isEqualTo: bookId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
