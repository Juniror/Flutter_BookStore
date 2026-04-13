import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/borrow_service.dart';
import '../models/borrow_record.dart';
import '../widgets/cards/book_list_tile.dart';
import '../../../core/widgets/feedback/empty_state_view.dart';
import '../../../core/utils/ui_utils.dart';

/// Displays a list of books currently borrowed by the user.
/// Provides functionality to return books and view due status.
class BorrowedBooksPage extends StatelessWidget {
  const BorrowedBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view borrowed books')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Borrowed Books'),
        elevation: 0,
      ),
      body: StreamBuilder<List<BorrowRecord>>(
        stream: BorrowService.getUserBorrows(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const EmptyStateView(
              icon: Icons.library_books_outlined,
              message: 'No borrowed books found',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: records.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final record = records[index];
              return _BorrowedBookTile(record: record);
            },
          );
        },
      ),
    );
  }
}

class _BorrowedBookTile extends StatefulWidget {
  final BorrowRecord record;

  const _BorrowedBookTile({required this.record});

  @override
  State<_BorrowedBookTile> createState() => _BorrowedBookTileState();
}

class _BorrowedBookTileState extends State<_BorrowedBookTile> {
  bool _isReturning = false;

  void _handleReturn() async {
    setState(() => _isReturning = true);
    try {
      await BorrowService.returnBook(widget.record);
      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'Book returned successfully!');
      }
    } catch (e) {
      if (mounted) {
        UIUtils.showErrorSnackBar(context, 'Failed to return book: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isReturning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysRemaining = widget.record.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;

    return BookListTile(
      title: widget.record.bookTitle,
      subtitle: widget.record.bookAuthor,
      statusText: isOverdue ? 'Overdue!' : 'Due in $daysRemaining days',
      statusColor: isOverdue ? Colors.red : Colors.blue,
      trailing: TextButton(
        onPressed: _isReturning ? null : _handleReturn,
        style: TextButton.styleFrom(
          foregroundColor: context.isDarkMode ? Colors.blue.shade300 : Colors.blue.shade700,
          backgroundColor: context.isDarkMode ? Colors.blue.withAlpha(50) : Colors.blue.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isReturning
            ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Return', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
