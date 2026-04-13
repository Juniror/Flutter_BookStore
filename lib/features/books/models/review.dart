import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user review for a book, including rating and comment.
class Review {
  final String id;
  final String bookId;
  final String userId;
  final String userName;
  final String? userEmail;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    this.userEmail,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      bookId: map['bookId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userEmail: map['userEmail'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
