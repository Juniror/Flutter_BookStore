import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../models/book.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';
import '../cards/review_card.dart';
import '../feedback/rating_stars.dart';
import '../overlays/add_review_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// a section in BookDetailPage to display the overall rating and user reviews.
class ReviewSection extends StatelessWidget {
  final Book book;

  const ReviewSection({super.key, required this.book});

  void _showAddReview(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UIUtils.showErrorSnackBar(context, 'Please log in to leave a review');
      return;
    }

    final hasReviewed = await ReviewService.hasUserReviewed(user.uid, book.id);
    if (hasReviewed) {
      if (context.mounted) {
        UIUtils.showInfoSnackBar(context, 'You have already reviewed this book');
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AddReviewDialog(book: book),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews',
                style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showAddReview(context),
                icon: const Icon(Icons.add_comment_rounded, size: 18),
                label: const Text('Add Review'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildRatingSummary(context),
        const SizedBox(height: 24),
        StreamBuilder<List<Review>>(
          stream: ReviewService.getReviews(book.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.comment_outlined, size: 48, color: Colors.grey.withAlpha(50)),
                      const SizedBox(height: 12),
                      const Text(
                        'No reviews yet. Be the first to share your thoughts!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: reviews.length,
              itemBuilder: (context, index) => ReviewCard(review: reviews[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withAlpha(10),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      book.averageRating.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Text(' / 5', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                RatingStars(rating: book.averageRating, size: 20),
                const SizedBox(height: 8),
                Text(
                  'Based on ${book.reviewCount} reviews',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            // Simple rating distribution bar visualization could go here
          ],
        ),
      ),
    );
  }
}
