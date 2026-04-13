import 'package:flutter/material.dart';
import '../../pages/book_detail_page.dart';
import '../../pages/book_reader_page.dart';
import '../../models/book.dart';
import '../../../../core/utils/ui_utils.dart';

/// A visually prominent card used for promoted or high-ranking books.
/// Features a larger profile and distinctive rank badge.
class PromotedBookCard extends StatelessWidget {
  final Book book;
  final int? rank;
  final String? heroTag;

  const PromotedBookCard({super.key, required this.book, this.rank, this.heroTag});

  @override
  Widget build(BuildContext context) {
    final effectiveHeroTag = heroTag ?? 'promoted_book_${book.id}_${rank ?? ''}';
    
    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(book: book, heroTag: effectiveHeroTag),
            ),
          );
        },
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Hero(
                      tag: effectiveHeroTag,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          book.coverImageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _buildPlaceholder(context);
                          },
                        ),
                      ),
                    ),
                    if (rank != null)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_getRankColor(context, rank!), _getRankColor(context, rank!).withAlpha(200)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: _getRankColor(context, rank!).withAlpha(100),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '#$rank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          if (book.pdfUrl.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookReaderPage(book: book),
                              ),
                            );
                          } else {
                            UIUtils.showInfoSnackBar(context, 'No digital version available for this book yet.');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withAlpha(100),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'READ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: context.isDarkMode ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.isDarkMode ? Colors.white60 : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_rounded, 
              size: 50, 
              color: Theme.of(context).primaryColor.withAlpha(context.isDarkMode ? 100 : 60),
            ),
            const SizedBox(height: 8),
            Text(
              'FEATURED',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Theme.of(context).primaryColor.withAlpha(100),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(BuildContext context, int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // Gold
      case 2: return const Color(0xFF94A3B8); // Slate-Silver
      case 3: return const Color(0xFFD97706); // Amber-Bronze
      default: return Theme.of(context).primaryColor;
    }
  }
}
