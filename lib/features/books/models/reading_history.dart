import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';

/// Represents a single entry in the user's reading history.
class ReadingHistory {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final DateTime timestamp;

  ReadingHistory({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.timestamp,
  });

  factory ReadingHistory.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return ReadingHistory(
      id: doc.id,
      userId: map[FirebaseConstants.fields.historyUserId] ?? '',
      bookId: map[FirebaseConstants.fields.historyBookId] ?? '',
      bookTitle: map[FirebaseConstants.fields.historyBookTitle] ?? '',
      bookAuthor: map[FirebaseConstants.fields.historyBookAuthor] ?? '',
      timestamp:
          (map[FirebaseConstants.fields.historyTimestamp] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.fields.historyUserId: userId,
      FirebaseConstants.fields.historyBookId: bookId,
      FirebaseConstants.fields.historyBookTitle: bookTitle,
      FirebaseConstants.fields.historyBookAuthor: bookAuthor,
      FirebaseConstants.fields.historyTimestamp: FieldValue.serverTimestamp(),
    };
  }
}
