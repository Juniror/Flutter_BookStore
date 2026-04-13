import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../models/book.dart';
import '../cards/promoted_book_card.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/widgets/feedback/skeleton_loader.dart';

/// The trending books horizontal list section for the HomePage.
class HomeTrendingSection extends StatelessWidget {
  const HomeTrendingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trending Now',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection(FirebaseConstants.collections.books)
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SkeletonLoader.bookCard(width: 280, height: 200),
                  ),
                );
              }
              final books = snapshot.data?.docs ?? [];
              if (books.isEmpty) {
                return const Center(child: Text('No trending books found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                scrollDirection: Axis.horizontal,
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = Book.fromFirestore(books[index]);
                  return PromotedBookCard(book: book, rank: index + 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
