import 'package:flutter/material.dart';
import '../../pages/book_detail_page.dart';
import '../../models/book.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/widgets/feedback/optimized_network_image.dart';

/// A standard card for displaying book details.
/// Includes an optional [rank] badge for trending sections.
class BookCard extends StatelessWidget {
  final Book book;
  final int? rank;
  final String? heroTag;

  const BookCard({super.key, required this.book, this.rank, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final effectiveHeroTag = heroTag ?? 'book_image_${book.id}_${rank ?? ''}';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(book: book, heroTag: effectiveHeroTag),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(context.isDarkMode ? 100 : 15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: context.isDarkMode ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
            ),
          ),
          child: Row(
            children: [
              // Optimized Book Cover with Caching
              Hero(
                tag: effectiveHeroTag,
                child: OptimizedNetworkImage(
                  imageUrl: book.coverImageUrl,
                  width: 110,
                  height: 150,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              
              // Book Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              book.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: context.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                height: 1.2,
                              ),
                            ),
                          ),
                          if (rank != null)
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                 color: Colors.amber.withAlpha(40),
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: Text(
                                 '#$rank',
                                 style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                             ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        book.author,
                        style: TextStyle(
                          color: context.isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildChip(
                            context, 
                            book.categories.isNotEmpty ? book.categories.first : 'General', 
                            Theme.of(context).primaryColor,
                          ),
                          _buildChip(
                            context, 
                            '${book.availableCopies} available', 
                            book.availableCopies > 0 ? const Color(0xFF10B981) : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
