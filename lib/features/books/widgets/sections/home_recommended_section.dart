import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../models/book.dart';
import '../cards/book_card.dart';
import '../../../../core/widgets/feedback/skeleton_loader.dart';

/// The personalized recommendations section for the HomePage.
class HomeRecommendedSection extends StatelessWidget {
  final List<String> categories;

  const HomeRecommendedSection({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recommended for You',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        for (final category in categories)
          _CategoryRecommendation(category: category),
      ],
    );
  }
}

class _CategoryRecommendation extends StatelessWidget {
  final String category;

  const _CategoryRecommendation({required this.category});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection(FirebaseConstants.collections.books)
          .where(FirebaseConstants.fields.bookCategory, arrayContains: category)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: SkeletonLoader.text(width: 120),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SkeletonLoader.bookCard(width: double.infinity, height: 160),
              ),
              const SizedBox(height: 16),
            ],
          );
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final book = Book.fromFirestore(docs.first);
        final uniqueHeroTag = 'book_image_${book.id}_highlight_$category';
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                '$category Highlights',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BookCard(book: book, heroTag: uniqueHeroTag),
              ),
            ),
          ],
        );
      },
    );
  }
}
