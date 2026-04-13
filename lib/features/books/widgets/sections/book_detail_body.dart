import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../models/book.dart';
import '../cards/book_info_card.dart';
import '../sections/review_section.dart';

/// The main content section for the BookDetailPage.
class BookDetailBody extends StatelessWidget {
  final Book book;

  const BookDetailBody({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryBadge(context),
              if (book.reviewCount > 0)
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      book.averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      ' (${book.reviewCount})',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTitle(context),
          const SizedBox(height: 8),
          _buildAuthor(context),
          const SizedBox(height: 24),
          _buildInfoRow(),
          const SizedBox(height: 32),
          _buildDescription(context),
          const SizedBox(height: 40),
          const Divider(height: 1),
          const SizedBox(height: 40),
          ReviewSection(book: book),
          const SizedBox(height: 120), // Bottom padding for button clearance
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        book.categories.isNotEmpty ? book.categories.join(', ') : 'General',
        style: TextStyle(
          color: context.isDarkMode ? Colors.white70 : Colors.black54,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      book.title,
      style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.isDarkMode ? Colors.white : Colors.black87,
          ),
    );
  }

  Widget _buildAuthor(BuildContext context) {
    return Text(
      'by ${book.author}',
      style: context.textTheme.titleLarge?.copyWith(
            color: context.isDarkMode ? Colors.white70 : Colors.grey.shade600,
          ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        BookInfoCard(
          icon: Icons.calendar_today_outlined,
          label: 'Year',
          value: book.publishedYear,
        ),
        const SizedBox(width: 16),
        BookInfoCard(
          icon: Icons.copy_outlined,
          label: 'Copies',
          value: '${book.availableCopies}/${book.totalCopies}',
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          book.description.isNotEmpty
              ? book.description
              : 'No description available for this book. Start your journey into this amazing story today!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade700,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}
