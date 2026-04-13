import 'package:flutter/material.dart';
import '../../pages/book_detail_page.dart';
import '../../models/book.dart';
import '../../../../core/widgets/feedback/optimized_network_image.dart';

/// A grid-styled card for previewing a [book].
/// Triggers navigation to [BookDetailPage] on tap.
class BookGridCard extends StatelessWidget {
  final Book book;
  final String? heroTag;

  const BookGridCard({super.key, required this.book, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final effectiveHeroTag = heroTag ?? 'book_image_${book.id}';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BookDetailPage(book: book, heroTag: effectiveHeroTag),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(Theme.of(context).brightness == Brightness.light ? 15 : 40), 
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Optimized Book thumbnail with caching and shimmer
              Expanded(
                flex: 12,
                child: Hero(
                  tag: effectiveHeroTag,
                  child: OptimizedNetworkImage(
                    imageUrl: book.coverImageUrl,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ),

              // Essential book information (Title, Author, Availability)
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title.isNotEmpty ? book.title : 'Untitled',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              height: 1.2,
                              color: Theme.of(context).textTheme.titleLarge?.color,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            book.author.isNotEmpty ? book.author : 'Unknown Author',
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(160),
                              fontSize: 10, // Slightly smaller for dense grids
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(Theme.of(context).brightness == Brightness.light ? 30 : 50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded, 
                                  size: 10, 
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.green.shade600 : Colors.green.shade300,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  book.availableCopies.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.green.shade700 : Colors.green.shade200,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (book.categories.isNotEmpty)
                            Flexible(
                              child: Text(
                                book.categories.first,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor.withAlpha(180),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
}
