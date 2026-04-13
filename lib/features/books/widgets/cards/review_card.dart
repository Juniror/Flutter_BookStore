import 'package:flutter/material.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../models/review.dart';
import '../feedback/rating_stars.dart';
import 'package:intl/intl.dart';

/// A card component representing a single user review.
class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.white.withAlpha(5) : Colors.black.withAlpha(5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.isDarkMode ? Colors.white10 : Colors.black12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                DateFormat('MMM d, y').format(review.createdAt),
                style: TextStyle(
                  color: context.isDarkMode ? Colors.white60 : Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingStars(rating: review.rating, size: 16),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              color: context.isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
