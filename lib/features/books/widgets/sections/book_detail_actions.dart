import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/widgets/inputs/primary_button.dart';
import '../../pages/book_reader_page.dart';
import '../../models/book.dart';
import '../../services/history_service.dart';

/// The bottom action buttons section for the BookDetailPage.
class BookDetailActions extends StatelessWidget {
  final Book book;
  final bool isBorrowing;
  final VoidCallback onBorrow;
  final VoidCallback onShare;

  const BookDetailActions({
    super.key,
    required this.book,
    required this.isBorrowing,
    required this.onBorrow,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(context.isDarkMode ? 80 : 10),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Unified 'Read Now' Button
            Expanded(
              flex: 1,
              child: PrimaryButton(
                text: 'Read',
                icon: Icons.menu_book_rounded,
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    HistoryService.addToHistory(book: book, userId: user.uid);
                  }

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
              ),
            ),
            const SizedBox(width: 12),
            // Enhanced 'Borrow Book' Button
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PrimaryButton(
                  text: 'Borrow',
                  icon: Icons.auto_stories_rounded,
                  onPressed: !isBorrowing ? onBorrow : null,
                  isLoading: isBorrowing,
                  // We'll trust the PrimaryButton widget's internal styling for consistency
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildShareButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.isDarkMode ? Colors.white12 : Colors.black12),
      ),
      child: IconButton(
        icon: Icon(Icons.share_outlined, color: context.isDarkMode ? Colors.white70 : Colors.black54),
        onPressed: onShare,
      ),
    );
  }
}
