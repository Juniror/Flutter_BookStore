import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../models/reading_history.dart';
import '../models/book.dart';
import '../services/history_service.dart';
import '../../../core/utils/ui_utils.dart';
import '../../../core/widgets/feedback/empty_state.dart';
import '../../../core/widgets/feedback/skeleton_loader.dart';
import 'package:intl/intl.dart';
import 'book_detail_page.dart';

/// Displays a chronological log of books the user has read or accessed.
class ReadingHistoryPage extends StatelessWidget {
  const ReadingHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your history.')),
      );
    }

    return Scaffold(
      backgroundColor: context.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(context, user.uid),
          StreamBuilder<List<ReadingHistory>>(
            stream: HistoryService.getHistory(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SkeletonLoader.bookCard(width: double.infinity, height: 80),
                      ),
                      childCount: 5,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Database Error',
                    message: 'We had trouble loading your history: ${snapshot.error}',
                  ),
                );
              }

              final history = snapshot.data ?? [];

              if (history.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.history_toggle_off_rounded,
                    title: 'History is Empty',
                    message: 'Start reading your first book to see your progress tracked here.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildHistoryCard(context, record),
                      );
                    },
                    childCount: history.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userId) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: context.isDarkMode 
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF64748B), const Color(0xFF475569)], // Sophisticated slate for history
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading History',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Your literary journey',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showClearDialog(context, userId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Clear all',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ReadingHistory record) {
    void handleContinue() async {
      // Show loading
      showDialog(
        context: context, 
        barrierDismissible: false, 
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      
      try {
        final doc = await FirebaseFirestore.instance
            .collection(FirebaseConstants.collections.books)
            .doc(record.bookId)
            .get();
            
        if (context.mounted) Navigator.pop(context); // pop loading
        
        if (doc.exists) {
          final book = Book.fromFirestore(doc);
          if (context.mounted) {
             Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailPage(book: book)));
          }
        } else {
          if (context.mounted) UIUtils.showErrorSnackBar(context, 'This book is no longer available');
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // pop loading
          UIUtils.showErrorSnackBar(context, 'Failed to open book');
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(context.isDarkMode ? 40 : 10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.menu_book_rounded, color: Colors.blue, size: 24),
        ),
        title: Text(
          record.bookTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.bookAuthor, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, hh:mm a').format(record.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
        trailing: FilledButton.tonalIcon(
          onPressed: handleContinue,
          icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
          label: const Text('Continue'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        onTap: handleContinue,
      ),
    );
  }

  void _showClearDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear your entire reading history?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await HistoryService.clearHistory(userId);
              if (context.mounted) {
                Navigator.pop(context);
                UIUtils.showSuccessSnackBar(context, 'History cleared!');
              }
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
