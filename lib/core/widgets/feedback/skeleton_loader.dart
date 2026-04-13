import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/utils/ui_utils.dart';

/// A reusable shimmer-based loading placeholder for UI elements.
/// Helps maintain layout stability and provides visual feedback during async operations.
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  /// Factory constructor for a book card skeleton.
  factory SkeletonLoader.bookCard({double width = 140, double height = 200}) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: 16,
    );
  }

  /// Factory constructor for text line skeletons.
  factory SkeletonLoader.text({double width = 100, double height = 14}) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = context.isDarkMode ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = context.isDarkMode ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
