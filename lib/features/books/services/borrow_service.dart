import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/base_service.dart';
import '../models/book.dart';
import '../models/borrow_record.dart';

/// Service for managing book borrowing and returning transactions.
class BorrowService extends BaseService {
  static CollectionReference get _borrowCollection => 
      BaseService.firestore.collection(FirebaseConstants.collections.borrowedBooks);
  
  static CollectionReference get _booksCollection => 
      BaseService.firestore.collection(FirebaseConstants.collections.books);

  /// Executes a borrowing transaction for a specific [book] and [userId].
  /// Validates availability and existing active borrows before processing.
  /// Deducts one copy from the library stock upon success (for physical).
  static Future<void> borrowBook({
    required Book book,
    required String userId,
    required String type,
    String? deliveryAddress,
  }) async {
    if (type == 'physical' && book.availableCopies <= 0) {
      throw Exception('No physical copies available for this book.');
    }

    // Verify if the user already has an active (unreturned) borrow for this book.
    final existing = await _borrowCollection
        .where(FirebaseConstants.fields.borrowUserId, isEqualTo: userId)
        .where(FirebaseConstants.fields.borrowBookId, isEqualTo: book.id)
        .where(FirebaseConstants.fields.borrowIsReturned, isEqualTo: false)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('You already have an active borrow for this book.');
    }

    final borrowDate = DateTime.now();
    final dueDate = borrowDate.add(const Duration(days: 14)); // 2 weeks borrow time

    await BaseService.firestore.runTransaction((transaction) async {
      // 1. Fetch trusted user data.
      final userDoc = await transaction.get(
        BaseService.firestore.collection(FirebaseConstants.collections.users).doc(userId)
      );
      
      if (!userDoc.exists) {
        throw Exception('User account not found in database.');
      }
      
      final String authenticName = userDoc.get(FirebaseConstants.fields.userDisplayName) ?? 'Library Member';

      // 2. Check book availability.
      int? updatedAvailableCopies;
      if (type == 'physical') {
        final bookDoc = await transaction.get(_booksCollection.doc(book.id));
        final currentAvailable = bookDoc.get(FirebaseConstants.fields.bookAvailableCopies) as int;
        
        if (currentAvailable <= 0) {
          throw Exception('Book just became unavailable.');
        }
        updatedAvailableCopies = currentAvailable - 1;
      }

      // 3. Create borrow record.
      final record = BorrowRecord(
        id: '',
        userId: userId,
        userName: authenticName,
        bookId: book.id,
        bookTitle: book.title,
        bookAuthor: book.author,
        borrowDate: borrowDate,
        dueDate: dueDate,
        type: type,
        deliveryAddress: deliveryAddress,
      );

      final newRecordRef = _borrowCollection.doc();
      transaction.set(newRecordRef, record.toMap());

      // 4. Update library stock.
      if (updatedAvailableCopies != null) {
        transaction.update(_booksCollection.doc(book.id), {
          FirebaseConstants.fields.bookAvailableCopies: updatedAvailableCopies,
        });
      }
    });
  }

  /// Returns a stream of active (unreturned) [BorrowRecord]s for the specified [userId].
  static Stream<List<BorrowRecord>> getUserBorrows(String userId) {
    return _borrowCollection
        .where(FirebaseConstants.fields.borrowUserId, isEqualTo: userId)
        .where(FirebaseConstants.fields.borrowIsReturned, isEqualTo: false) // Filter in Firestore
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => BorrowRecord.fromFirestore(doc))
          .toList();
      
      // Sort by borrow date descending in Dart
      list.sort((a, b) => b.borrowDate.compareTo(a.borrowDate));
      return list;
    });
  }

  /// Processes the return of a borrowed book.
  /// Updates the record status and increments the available library stock if physical.
  static Future<void> returnBook(BorrowRecord record) async {
    await BaseService.firestore.runTransaction((transaction) async {
      // Read phase: all data must be fetched before any writes.
      DocumentSnapshot? bookDoc;
      if (record.type == 'physical') {
        bookDoc = await transaction.get(_booksCollection.doc(record.bookId));
      }

      // Write phase: update records and stock after successful reads.
      // 1. Mark as returned.
      transaction.update(_borrowCollection.doc(record.id), {
        FirebaseConstants.fields.borrowIsReturned: true,
      });

      // 2. Increment available copies if it was a physical borrow
      if (record.type == 'physical' && bookDoc != null) {
        final currentAvailable = bookDoc.get(FirebaseConstants.fields.bookAvailableCopies) as int;
        
        transaction.update(_booksCollection.doc(record.bookId), {
          FirebaseConstants.fields.bookAvailableCopies: currentAvailable + 1,
        });
      }
    });
  }
}
