import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/base_service.dart';

/// Service for aggregating and managing book categories.
class CategoryService extends BaseService {

  /// Aggregates and returns a sorted list of unique categories from the provided [snapshot].
  static List<String> _extractUniqueCategories(QuerySnapshot snapshot) {
    final Set<String> categories = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final categoryData = data[FirebaseConstants.fields.bookCategory];
      
      if (categoryData is List) {
        for (var cat in categoryData) {
          if (cat is String && cat.isNotEmpty) categories.add(cat);
        }
      } else if (categoryData is String && categoryData.isNotEmpty) {
        categories.add(categoryData);
      }
    }
    return categories.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  /// Returns a stream of unique categories collected from all books in the library.
  static Stream<List<String>> getCategories() {
    return BaseService.firestore
        .collection(FirebaseConstants.collections.books)
        .snapshots()
        .map((snapshot) => _extractUniqueCategories(snapshot));
  }

  /// Asynchronously retrieves up to [count] random unique categories from the library.
  static Future<List<String>> getRandomCategories(int count) async {
    final snapshot = await BaseService.firestore.collection(FirebaseConstants.collections.books).get();
    final categories = _extractUniqueCategories(snapshot);
    if (categories.isEmpty) return [];
    categories.shuffle();
    return categories.take(count).toList();
  }

  // Deprecated: No longer needs to maintain a separate collection
  static Future<void> ensureCategoriesExist(List<String> categories) async {
    // Books are now the source of truth for categories.
    // No action needed here.
  }
}
