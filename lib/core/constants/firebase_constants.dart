/// Constants for Firebase collection names, field names, and roles.
/// Centralized access to Firebase collection names, field keys, and static roles.
abstract class FirebaseConstants {
  FirebaseConstants._();

  /// Firestore collection names.
  static const collections = _FirebaseCollections();

  /// Firestore document field names.
  static const fields = _FirebaseFields();

  /// User role values.
  static const roles = _UserRoles();
}

class _FirebaseCollections {
  const _FirebaseCollections();

  final String users = 'users';
  final String books = 'books';
  final String categories = 'categories';
  final String borrowedBooks = 'borrowed_books';
  final String favorites = 'favorites';
  final String userFolders = 'user_folders';
  final String readingHistory = 'reading_history';
  final String reviews = 'reviews';
}

class _FirebaseFields {
  const _FirebaseFields();

  // User Document Fields
  final String userUuid = 'uuid';
  final String userRole = 'role';
  final String userCreateDate = 'createDate';
  final String userDisplayName = 'displayName';
  final String userUpdatedAt = 'updatedAt';

  // Book Document Fields
  final String bookTitle = 'title';
  final String bookAuthor = 'author';
  final String bookCategory = 'category';
  final String bookPublishedYear = 'publishedYear';
  final String bookTotalCopies = 'totalCopies';
  final String bookAvailableCopies = 'availableCopies';
  final String bookDescription = 'description';
  final String bookCoverImageUrl = 'coverImageUrl';
  final String bookPdfUrl = 'pdfUrl';
  final String bookCreatedAt = 'createdAt';

  // Borrow Record Fields
  final String borrowId = 'id';
  final String borrowUserId = 'userId';
  final String borrowUserName = 'userName';
  final String borrowBookId = 'bookId';
  final String borrowBookTitle = 'bookTitle';
  final String borrowBookAuthor = 'bookAuthor';
  final String borrowDate = 'borrowDate';
  final String borrowDueDate = 'dueDate';
  final String borrowIsReturned = 'isReturned';
  final String borrowType = 'type';
  final String borrowDeliveryAddress = 'deliveryAddress';

  // Favorite Record Fields
  final String favUserId = 'userId';
  final String favBookId = 'bookId';
  final String favBookTitle = 'bookTitle';
  final String favBookAuthor = 'bookAuthor';
  final String favAddedAt = 'addedAt';

  // User Folder Fields
  final String folderOwnerId = 'ownerId';
  final String folderName = 'name';
  final String folderBookIds = 'bookIds';
  final String folderCreatedAt = 'createdAt';

  // Reading History Fields
  final String historyUserId = 'userId';
  final String historyBookId = 'bookId';
  final String historyBookTitle = 'bookTitle';
  final String historyBookAuthor = 'bookAuthor';
  final String historyTimestamp = 'timestamp';
}

class _UserRoles {
  const _UserRoles();

  final String admin = 'admin';
  final String user = 'user';
}
