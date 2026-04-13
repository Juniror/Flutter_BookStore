import 'package:flutter/material.dart';

/// A static or interactive star rating widget.
/// Used for displaying current ratings or selecting a rating during review submission.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final int maxRating;
  final ValueChanged<double>? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.maxRating = 5,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starRating = index + 1.0;
        IconData icon;
        if (rating >= starRating) {
          icon = Icons.star_rounded;
        } else if (rating > index) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_outline_rounded;
        }

        return GestureDetector(
          onTap: onRatingChanged != null ? () => onRatingChanged!(starRating) : null,
          child: Icon(
            icon,
            color: color ?? Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}
