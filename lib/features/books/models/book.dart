import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';

/// Represents a book item with its metadata, availability, and associated links.
class Book {
  final String id;
  final String title;
  final String author;
  final List<String> categories;
  final String publishedYear;
  final int totalCopies;
  final int availableCopies;
  final String description;
  final String coverImageUrl;
  final String pdfUrl;
  final double averageRating;
  final int reviewCount;
  final DateTime? createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.categories,
    required this.publishedYear,
    required this.totalCopies,
    required this.availableCopies,
    required this.description,
    this.coverImageUrl = '',
    this.pdfUrl = '',
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.createdAt,
  });

  /// Creates a [Book] instance from a Firestore [DocumentSnapshot].
  /// Handles category compatibility for legacy single-string data.
  factory Book.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    final categoryData = map[FirebaseConstants.fields.bookCategory];
    
    List<String> categories = [];
    if (categoryData is List) {
      categories = List<String>.from(categoryData);
    } else if (categoryData is String && categoryData.isNotEmpty) {
      // Compatibility for old single-string categories
      categories = [categoryData];
    }

    return Book(
      id: doc.id,
      title: map[FirebaseConstants.fields.bookTitle] ?? '',
      author: map[FirebaseConstants.fields.bookAuthor] ?? '',
      categories: categories,
      publishedYear: map[FirebaseConstants.fields.bookPublishedYear] ?? '',
      totalCopies: map[FirebaseConstants.fields.bookTotalCopies] ?? 0,
      availableCopies: map[FirebaseConstants.fields.bookAvailableCopies] ?? 0,
      description: map[FirebaseConstants.fields.bookDescription] ?? '',
      coverImageUrl: map[FirebaseConstants.fields.bookCoverImageUrl] ?? '',
      pdfUrl: map[FirebaseConstants.fields.bookPdfUrl] ?? '',
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: map[FirebaseConstants.fields.bookCreatedAt] is Timestamp
          ? (map[FirebaseConstants.fields.bookCreatedAt] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirebaseConstants.fields.bookTitle: title,
      FirebaseConstants.fields.bookAuthor: author,
      FirebaseConstants.fields.bookCategory: categories,
      FirebaseConstants.fields.bookPublishedYear: publishedYear,
      FirebaseConstants.fields.bookTotalCopies: totalCopies,
      FirebaseConstants.fields.bookAvailableCopies: availableCopies,
      FirebaseConstants.fields.bookDescription: description,
      FirebaseConstants.fields.bookCoverImageUrl: coverImageUrl,
      FirebaseConstants.fields.bookPdfUrl: pdfUrl,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      FirebaseConstants.fields.bookCreatedAt: createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
