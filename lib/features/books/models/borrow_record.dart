import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';

/// Represents a transaction record for a borrowed book.
class BorrowRecord {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final DateTime borrowDate;
  final DateTime dueDate;
  final bool isReturned;
  final String type; // 'digital' or 'physical'
  final String? deliveryAddress;

  BorrowRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.borrowDate,
    required this.dueDate,
    this.isReturned = false,
    this.type = 'physical',
    this.deliveryAddress,
  });

  factory BorrowRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BorrowRecord(
      id: doc.id,
      userId: data[FirebaseConstants.fields.borrowUserId] ?? '',
      userName: data[FirebaseConstants.fields.borrowUserName] ?? '',
      bookId: data[FirebaseConstants.fields.borrowBookId] ?? '',
      bookTitle: data[FirebaseConstants.fields.borrowBookTitle] ?? '',
      bookAuthor: data[FirebaseConstants.fields.borrowBookAuthor] ?? '',
      borrowDate: data[FirebaseConstants.fields.borrowDate] is Timestamp
          ? (data[FirebaseConstants.fields.borrowDate] as Timestamp).toDate()
          : DateTime.now(),
      dueDate: data[FirebaseConstants.fields.borrowDueDate] is Timestamp
          ? (data[FirebaseConstants.fields.borrowDueDate] as Timestamp).toDate()
          : DateTime.now(),
      isReturned: data[FirebaseConstants.fields.borrowIsReturned] ?? false,
      type: data[FirebaseConstants.fields.borrowType] ?? 'physical',
      deliveryAddress: data[FirebaseConstants.fields.borrowDeliveryAddress],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.fields.borrowUserId: userId,
      FirebaseConstants.fields.borrowUserName: userName,
      FirebaseConstants.fields.borrowBookId: bookId,
      FirebaseConstants.fields.borrowBookTitle: bookTitle,
      FirebaseConstants.fields.borrowBookAuthor: bookAuthor,
      FirebaseConstants.fields.borrowDate: Timestamp.fromDate(borrowDate),
      FirebaseConstants.fields.borrowDueDate: Timestamp.fromDate(dueDate),
      FirebaseConstants.fields.borrowIsReturned: isReturned,
      FirebaseConstants.fields.borrowType: type,
      if (deliveryAddress != null) FirebaseConstants.fields.borrowDeliveryAddress: deliveryAddress,
    };
  }
}
