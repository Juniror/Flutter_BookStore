import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../models/book.dart';
import '../feedback/rating_stars.dart';
import '../../services/review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A dialog for users to submit a review and rating.
class AddReviewDialog extends StatefulWidget {
  final Book book;

  const AddReviewDialog({super.key, required this.book});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  void _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_commentController.text.trim().isEmpty) {
      UIUtils.showErrorSnackBar(context, 'Please enter a comment');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ReviewService.addReview(
        bookId: widget.book.id,
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous User',
        userEmail: user.email,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (mounted) {
        UIUtils.showSuccessSnackBar(context, 'Review submitted successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) UIUtils.showErrorSnackBar(context, 'Failed to submit review: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rate this Book',
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'What did you think of "${widget.book.title}"?',
              style: TextStyle(color: context.isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(height: 24),
            Center(
              child: RatingStars(
                rating: _rating,
                size: 40,
                onRatingChanged: (val) => setState(() => _rating = val),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                filled: true,
                fillColor: context.isDarkMode ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Post Review', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
