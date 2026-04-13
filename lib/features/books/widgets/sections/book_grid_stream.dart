import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book.dart';
import '../cards/book_grid_card.dart';

class BookGridStream extends StatelessWidget {
  final Query bookQuery;
  final int gridColumnCount;

  const BookGridStream({
    super.key,
    required this.bookQuery,
    this.gridColumnCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: bookQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final books = snapshot.data?.docs.map((doc) => Book.fromFirestore(doc)).toList() ?? [];

        if (books.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories_rounded, size: 64, color: Colors.blue.withAlpha(40)),
                  const SizedBox(height: 16),
                  const Text(
                    'No books found in this category.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumnCount,
              childAspectRatio: gridColumnCount == 3 ? 0.58 : 0.42,
              crossAxisSpacing: 12,
              mainAxisSpacing: 20,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => BookGridCard(book: books[index]),
              childCount: books.length,
            ),
          ),
        );
      },
    );
  }
}
