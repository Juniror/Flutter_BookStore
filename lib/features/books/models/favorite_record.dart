import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';

/// Represents a user's favorited book entry.
class FavoriteRecord {
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final DateTime addedAt;

  FavoriteRecord({
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.addedAt,
  });

  factory FavoriteRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteRecord(
      userId: data[FirebaseConstants.fields.favUserId] ?? '',
      bookId: data[FirebaseConstants.fields.favBookId] ?? '',
      bookTitle: data[FirebaseConstants.fields.favBookTitle] ?? '',
      bookAuthor: data[FirebaseConstants.fields.favBookAuthor] ?? '',
      addedAt: data[FirebaseConstants.fields.favAddedAt] is Timestamp
          ? (data[FirebaseConstants.fields.favAddedAt] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.fields.favUserId: userId,
      FirebaseConstants.fields.favBookId: bookId,
      FirebaseConstants.fields.favBookTitle: bookTitle,
      FirebaseConstants.fields.favBookAuthor: bookAuthor,
      FirebaseConstants.fields.favAddedAt: Timestamp.fromDate(addedAt),
    };
  }
}
